-- Tangram

-- Load Lua and lovr helper library stuff
m = lovr.filesystem.load('src/lib.lua'); m()

-- Lights class 
include 'src/worldLights.lua'

include 'src/getInput.lua'
include 'src/renderScene.lua'

-- Globals
fRenderDelta = 0.0
sOperatingSystem = ''
fFPSAvg = 0.0
totalFrames = 0
hx, hy, hz = 0.0, 0.0, 0.0

local rifle_a = nil
local margaret = nil
-- Init values
playerPosition = { x = 0.0, y = 0.0, z = 0.0 }
scaledPlayerPos = {}
--hmdOffset = { x = 0, y = -1.0, z = 0 }
playerRotation = 0.0
worldScale = 1
local lightBlob = nil
lightPos = { 0, 0, 0 }
adjLightPos = {} 

sunDirection = { -0.25, -1, 0.0 }
sunColor = { 0.0, 0.0, 0.0, 1.0 }
worldAmbience = { 0.1, 0.1, 0.1, 1.0 }

minContrast = 0.005
lovrVer = 0

function lovr.load()
    print(_VERSION)
    local a, b
    a, lovrVer, b = lovr.getVersion()
    lovrVer = 14
    print(string.format("LOVR version: %d.%d.%d", a, lovrVer, b))
    -- print os info
    sOperatingSystem = lovr.getOS()
    print('OS detected: ' .. sOperatingSystem)
    if sOperatingSystem ~= 'Android' then 
        lovr.keyboard = require('src/lovr-keyboard')
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
        lovr.graphics.setDefaultFilter('anisotropic', 4)
    end
    
    -- set up shaders
    local defaultVertex = lovr.filesystem.read('src/default.vs')
    local defaultFragment = lovr.filesystem.read('src/default.fs')
    local specularFragment = lovr.filesystem.read('src/default-specular.fs')
    --local wireframeFrag = lovr.filesystem.read('src/wireframe.fs')
    
    -- Red light -- not as harsh, long range low poer
    worldLights.createWorldLight(
        { -3.0, 1.0, -3.0 }, -- position
        { 1.0, 0.1, 0.1 }, -- RGB
        { 0, 0.1, 0.1 }, -- CLQ 
        'flicker', -- not used
        0.2 -- not used
    )
    -- Blue light -- harsh, moderate range
    worldLights.createWorldLight(
        { 3.0, 1.0, -2.75 }, 
        { 0.1, 0.1, 1.0 }, 
        { 0, 0.5, 0.5 }
    )
    -- Green light -- dull and short range, all light from it fades after ~6m
    worldLights.createWorldLight(
        { -1.0, 3.3, -4.1 }, 
        { 0.3, 1.0, 0.3 }, 
        { 0, 0.2, 0.4 }
    )
    
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
 
    --wfShader = lovr.graphics.newShader(
    --    defaultVertex, wireframeFrag, { flags = { uniformScale = true }}
   -- )
    --wireframeTex = lovr.graphics.newTexture('tex/wireframe.png', 1, 1, 1, 1)
    --wireframeTex2 = lovr.graphics.newTexture('Sphere.png', 1, 1, 1, 1)
    
    -- load models
    --lovr.graphics.setDefaultFilter('nearest')
    --mushtex = lovr.graphics.newTexture('mushbuv.png', 1, 1, 1, 1)
    model = lovr.graphics.newModel('mushboom.glb')--, mushtex)
    --music = lovr.audio.newSource('untitled.ogg', 'static')
    --music:play()
    -- load textures
    texGrass = lovr.graphics.newMaterial(lovr.graphics.newTexture('tex/grass128.png', 1, 1, 1, 1))
    --texGrass = lovr.graphics.newMaterial(lovr.graphics.newTexture('mushroom_top.png', 1, 1, 1, 1))

    texStonewall = lovr.graphics.newMaterial(lovr.graphics.newTexture('tex/stonewall128.png', 1, 1, 1))
    
    --lovr.graphics.setDepthTest('greater', true)
    lovr.graphics.setCullingEnabled(true)
    --a = lovr.graphics.newCanvas(lovr.headset.getDisplayDimensions())
end
 
function lovr.mirror()
    --a:renderTo(function()
    --    lovr.graphics.fill(lovr.headset.getMirrorTexture())
    --end)
    lovr.graphics.clear()
    lovr.draw()
    --lovr.graphics.fill(a:getTexture())
end



function lovr.update(dT)
    --print('androidmymyDebug')
    -- Per-frame ticks
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
    

    -- INPUT
    GetInput(dT)
    -- Scale player position to match worldScale variable
    hx, hy, hz = lovr.headset.getPosition()
    --hy = hy + hmdOffset.y
    scaledPlayerPos = {
        x = playerPosition.x * worldScale + hx,
        y = playerPosition.y * worldScale + hy,
        z = playerPosition.z * worldScale + hz,
    }
    
    -- Create camera projection based on scaled world and headset offsets
    
    
    -- LIGHTING
    -- quick animation
    --worldLights.lights[1].position[1] = worldLights.lights[1].position[1] + 0.02
    --worldLights.lights[2].position[1] = worldLights.lights[2].position[1] - 0.02
    --worldLights.lights[3].position[2] = worldLights.lights[3].position[2] - 0.01
    
    lightBlob:send('sunDirection', sunDirection)
    lightBlob:send('pointLightCount', worldLights.getLightCount()) 
    lightBlob:send('pointLightColors', worldLights.getLightColors())
    lightBlob:send('pointLightPositions', worldLights.getLightPositions())
    lightBlob:send('pointLightCLQ', worldLights.getCLQs())
    
    shader:sendBlock('lightBlob', lightBlob)
    specShader:sendBlock('lightBlob', lightBlob)

    camera = lovr.math.newMat4():lookAt(
        vec3(scaledPlayerPos.x, scaledPlayerPos.y, scaledPlayerPos.z),
        vec3(scaledPlayerPos.x + math.cos(playerRotation), 
             scaledPlayerPos.y, 
             scaledPlayerPos.z + math.sin(playerRotation)))
    lightcam = camera
    view = lovr.math.newMat4(camera):invert()
    
    --specShader:send('specularStrength', 0.5)
    --specShader:send('metallic', 32.0)

    -- Adjust head position (for specular)
    if lovr.headset then 
        hx, hy, hz = lovr.headset.getPosition()
        --specShader:send('viewPos', { hx + scaledPlayerPos.x, 
        --                             hy + scaledPlayerPos.y + hmdOffset.y, 
        --                             hz + scaledPlayerPos.z, 1.0 } )
        --shader:send('viewPos', { hx, hy, hz })
    else
        print('WARNING')
        --specShader:send('viewPos', { playerPosition.x, playerPosition.y, playerPosition.z })
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

