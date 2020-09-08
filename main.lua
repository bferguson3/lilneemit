-- Lil Neemit
-- (c) 2020 Ben Ferguson

-- Load Lua and lovr helper library stuff
m = lovr.filesystem.load('src/lib.lua'); m()

include 'src/worldLights.lua'
include 'src/getInput.lua'
include 'src/renderScene.lua'

-- VERSION OPTIONS -- 
DESKTOP = 1 -- set to 0 for HMD based input
INTEL = false 

-- Globals
fRenderDelta = 0.0
sOperatingSystem = ''
fFPSAvg = 0.0
totalFrames = 0
hx, hy, hz = 0.0, 0.0, 0.0
local rifle_a = nil
local margaret = nil
PLAYERSTATE = {
    ['NORMAL'] = 1,
    ['JUMPING'] = 2,
    ['FALLING'] = 3
}
-- Init values
player = {
    pos = { x = 0.0, y = 0.0, z = 0.0 },
    scaledPos = {},
    rot = 0.0,
    facing = 0.0,
    state = PLAYERSTATE['NORMAL'],
    jumpTimer = 0.0,
    jumpHeight = 10.0,
    jumpBase = 0.0, 
    fallBase = 0.0,
    hmd_orient = {},
    actual_height = 170,
    yaw = 0.0
}
if DESKTOP == 1 then player.actual_height = 220 end 
playerYf = 0.0
playerYDelta = 0.0
player.pos = { x = 0.0, y = 0.0, z = 0.0 }
player.scaledPos = {}
--hmdOffset = { x = 0, y = -1.0, z = 0 }
player.rot = 0.0
worldScale = 1.0
local lightBlob = nil
lightPos = { 0.0, 0.0, 0.0 }
adjLightPos = {} 
sunDirection = { -0.25, -1.0, 0.0 }
sunColor = { 0.0, 0.0, 0.0, 1.0 }
worldAmbience = { 0.05, 0.05, 0.05, 1.0 }
minContrast = 0.005
lovrVer = 0
--deltaTime = 0

--Platform setup - stage test 
platforms = { 
    [1] = {
        pos = {x=5.0, y=0.0, z=4.0},
        platform_ofs = 5.0,
        platform_size = 5.0
    },
    [2] = {
        pos = {x=-8.0, y=0.0, z=0.0},
        platform_ofs = 5.0,
        platform_size = 5.0
    },
    [3] = {
        pos = {x=-3.0, y=3.0, z=-12.0},
        platform_ofs = 5.0,
        platform_size = 5.0
    }
}

function lovr.load()

    print(_VERSION)
    local a, b
    a, lovrVer, b = lovr.getVersion()
    --lovrVer = 14
    print(string.format("LOVR version: %d.%d.%d", a, lovrVer, b))
    if b == 1 then print('Intel GPU patch applied.') end
    -- print os info
    sOperatingSystem = lovr.getOS()
    print('OS detected: ' .. sOperatingSystem)
    if sOperatingSystem ~= 'Android' then 
        if sOperatingSystem == 'Linux' and b ~= 1 then 
            os.execute('glxinfo | grep \'Intel\' > log.txt')
            local f = lovr.filesystem.read('log.txt')
            if string.find(f, 'Intel') then 
                lovr.errhand('Intel GPU detected! Please quit and download the patch!')
                INTEL = true 
            end
        end
        lovr.keyboard = require('src/lovr-keyboard')
        lovr.mouse = require('src/lovr-mouse')
        -- set up logfile
        myDebug.init()
        
    end
    -- Important note: 
    -- Custom builds of LOVR for Tangram (that fix keyboard input) need to have LOVR_VERSION_MINOR
    --  set to 14 or higher.
    if lovrVer <= 13 then 
        print("Controls: \nIJKL - Move \nUO - Turn\nDO NOT USE WASDQE OR ARROWS!") else 
        print("Controls: \nWASD/Up/Down - Move\nQE/Left/Right - Turn") end
    if sOperatingSystem ~= 'Android' then 
        lovr.graphics.setDefaultFilter('nearest', 4)
    else
        lovr.graphics.setDefaultFilter('nearest', 1)
        --lovr.graphics.setDefaultFilter('anisotropic', 4)
    end
    
    player.state = PLAYERSTATE.NORMAL

    -- set up shaders
    local defaultVertex = lovr.filesystem.read('src/default.vs')
    local defaultFragment = lovr.filesystem.read('src/default.fs')
    local specularFragment = lovr.filesystem.read('src/default-specular.fs')
    --local wireframeFrag = lovr.filesystem.read('src/wireframe.fs')
    
    -- Init light blob 
    lightBlob = lovr.graphics.newShaderBlock(
        'uniform', 
        {
            pointLightCount  = 'int', 
            pointLightPositions = { 'vec4', 16 },
            pointLightColors = { 'vec4', 16 },
            sunColor = 'vec4', --sun.diffuse
            sunDirection = 'vec3',
            worldAmbience = 'vec4', --sun.ambience
            pointLightCLQ = { 'vec4', 16 }
        },
        {}
    )
    lightBlob:send('sunDirection', sunDirection)
    lightBlob:send('sunColor', sunColor)
    lightBlob:send('worldAmbience', worldAmbience)
    lightBlob:send('pointLightCLQ', worldLights.getCLQs())
    
    shader = lovr.graphics.newShader(
        lightBlob:getShaderCode('lightBlob') .. defaultVertex,
        lightBlob:getShaderCode('lightBlob') .. defaultFragment, 
        { flags = {
            uniformScale = true
        }}
    )
    
    specShader = lovr.graphics.newShader(
        lightBlob:getShaderCode('lightBlob') .. defaultVertex,
        lightBlob:getShaderCode('lightBlob') .. defaultFragment, 
        { flags = {
            uniformScale = true
        }}
    )
 
 -- Red light -- not as harsh, long range low poer
    worldLights.createWorldLight(
        { -3.0, 1.0, -3.0 }, -- position
        { 1.0, 0.1, 0.1 }, -- RGB
        { 0.0, 0.1, 0.1 }, -- CLQ 
        'flicker', -- not used
        0.2 -- not used
    )
    -- Blue light -- harsh, moderate range
    worldLights.createWorldLight(
        { 3.0, 1.0, -2.75 }, 
        { 0.1, 0.1, 1.0 }, 
        { 0.0, 0.1, 0.05 }
    )
    -- Green light -- dull and short range, all light from it fades after ~6m
    worldLights.createWorldLight(
        { -1.0, 3.3, -4.1 }, 
        { 0.3, 1.0, 0.3 }, 
        { 0.0, 0.2, 0.2 }
    )
    
    --[[Wire frame shader bs]]
    --wfShader = lovr.graphics.newShader(
    --    defaultVertex, wireframeFrag, { flags = { uniformScale = true }}
   -- )
    --wireframeTex = lovr.graphics.newTexture('tex/wireframe.png', 1, 1, 1, 1)
    --wireframeTex2 = lovr.graphics.newTexture('Sphere.png', 1, 1, 1, 1)
    
    -- load models
    model = lovr.graphics.newModel('boom2.glb')--, mushtex)
    dblock = lovr.graphics.newModel('dirtblock.glb')
    model2 = lovr.graphics.newModel('boom2.glb')
    --music = lovr.audio.newSource('untitled.ogg', 'static')
    --music:play()

    -- load textures
    texGrass = lovr.graphics.newMaterial(lovr.graphics.newTexture('tex/grass128.png', 1, 1, 1, 1))
    texStonewall = lovr.graphics.newMaterial(lovr.graphics.newTexture('tex/stonewall128.png', 1, 1, 1))
    groundblocktex = lovr.graphics.newTexture('groundblock.png')
    mushbuv=lovr.graphics.newTexture('mushbuv.png')
    --lovr.graphics.setDepthTest('greater', true)
    lovr.graphics.setCullingEnabled(true)

end
 
function lovr.mirror()
    lovr.graphics.clear()
    lovr.draw()
end



function lovr.update(dT)
    -- Per-frame ticks
    --deltaTime = dT 
    fRenderDelta = os.clock()
    totalFrames = totalFrames + 1
    local fr 
    
    if sOperatingSystem ~= 'Android' then 
        if myDebug.showFPS or myDebug.logFPS then fr = 1/dT end 
        if myDebug.showFPS then 
            print('update delta', dT, '/ FPS: ', fr)
        end 
        if myDebug.logFPS then 
            fFPSAvg = fFPSAvg + fr
        end
    end
    
    local lp = player 
     
    -- INPUT
    GetInput(dT)

    -- Scale player position to match worldScale variable
    hx, hy, hz = lovr.headset.getPosition()
    --hy = hy + hmdOffset.y 
    lp.scaledPos = {
        x = lp.pos.x * worldScale + hx,
        y = lp.pos.y * worldScale + hy,
        z = lp.pos.z * worldScale + hz,
    }
    
    -- Jump position code 
    local GRAVITY = 2
    local playerYf = lp.pos.y 
    if lp.state == PLAYERSTATE.JUMPING then 
        lp.jumpTimer = lp.jumpTimer + dT
        lp.pos.y = lp.jumpBase + (lp.jumpHeight * math.sin(lp.jumpTimer)) - (lp.jumpTimer * lp.jumpTimer * GRAVITY)
        local playerYDelta = lp.pos.y - playerYf 
        if playerYDelta < 0 then   
            lp.state = PLAYERSTATE.FALLING
            lp.jumpTimer = 0
            lp.fallBase = lp.pos.y
        end
    elseif lp.state == PLAYERSTATE.FALLING then 
        lp.jumpTimer = lp.jumpTimer + dT 
        lp.pos.y = lp.fallBase - (lp.jumpTimer * lp.jumpTimer * GRAVITY) 
        if lp.pos.y < 0 then 
            lp.pos.y = 0  
            lp.jumpTimer = 0
            lp.state = PLAYERSTATE.NORMAL 
        end
    end
    
    -- LIGHTING
    -- quick animation
    worldLights.lights[1].position[1] = 4*math.sin(totalFrames/120)
    worldLights.lights[2].position[1] = 4*math.cos(totalFrames/120)
    worldLights.lights[3].position[2] = 4*math.sin(totalFrames/120)
    
    lightBlob:send('sunDirection', sunDirection)
    lightBlob:send('pointLightCount', worldLights.getLightCount()) 
    lightBlob:send('pointLightColors', worldLights.getLightColors())
    lightBlob:send('pointLightPositions', worldLights.getLightPositions())
    lightBlob:send('pointLightCLQ', worldLights.getCLQs())
    
    shader:sendBlock('lightBlob', lightBlob)
    specShader:sendBlock('lightBlob', lightBlob)

    
    -- Create camera projection based on scaled world and headset offsets
    local hof = (lp.actual_height - 170.0)/100.0
    camera = lovr.math.newMat4():lookAt(
        vec3(lp.scaledPos.x, lp.scaledPos.y + hof, lp.scaledPos.z),
        vec3(lp.scaledPos.x + math.cos(lp.rot), 
             lp.scaledPos.y + hof + lp.yaw, 
             lp.scaledPos.z + math.sin(lp.rot)))
    lightcam = camera
    view = lovr.math.newMat4(camera):invert()
    
    --specShader:send('specularStrength', 0.5)
    --specShader:send('metallic', 32.0)

    -- Adjust head position (for specular)
    if lovr.headset then 
        hx, hy, hz = lovr.headset.getPosition()
        --specShader:send('viewPos', { hx + player.scaledPos.x, 
        --                             hy + player.scaledPos.y + hmdOffset.y, 
        --                             hz + player.scaledPos.z, 1.0 } )
        --shader:send('viewPos', { hx, hy, hz })
    else
        print('WARNING - Headset driver failed to load')
        --specShader:send('viewPos', { player.pos.x, player.pos.y, player.pos.z })
    end
end



function lovr.draw()
    lovr.graphics.clear(worldAmbience)
    lovr.graphics.transform(view)
    renderScene()
    lovr.graphics.reset()
end



function lovr.quit()
    if sOperatingSystem ~= 'Android' then 
        if myDebug.logFPS then 
            myDebug.print('Average FPS: ' .. round(fFPSAvg/totalFrames, 2))
        end
    end    
    print('OK.')
end

