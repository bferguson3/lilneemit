
function EnableWireframe()
    oldsh = lovr.graphics.getShader()
    cm, wm = lovr.graphics.getDepthTest()
    lovr.graphics.setShader(wfShader)
    lovr.graphics.setDepthTest(nil, true)
end

function DisableWireframe()
    lovr.graphics.setColor(1.0, 1.0, 1.0, 1.0)
    lovr.graphics.setDepthTest(cm, true)
    lovr.graphics.setShader(oldsh)
end

local lg = lovr.graphics
local pcol = EGA[16]

renderTitle = function () 
    if DESKTOP then 
        player.rot = -1.55
        player.yaw = 0
    end
    if totalFrames % 20 == 0 then 
        pcol = EGA[math.random(1, 16)] end
    lg.setColor(pcol)
    lg.print('Lil Neemit!', 0, 4, -7, 2)
    lg.setColor(EGA[16])
    lg.print('Desktop Controls:\nWASD) Move\tSpace) Jump\nMouse) Look', -3, 2, -7.1, 0.5)
    lg.print('VR Controls:\nPad) Move\tTrigger) Jump\nTurn with your body', 3, 2, -7.1, 0.5)
    lg.print('"JUMP" to start!', 0, 0, -6.9, 0.5)

end

renderScene = function (deltaTime)

    if INTEL then 
        lovr.graphics.clear()
        lovr.graphics.reset()
        lovr.graphics.print('Intel GPU detected!\nQuit and download the patch:\n\nhttp://itch.io/tekkamansoul', 0, 0, -6)
        return 
    end
    
    shader:send('liteTransform', lightcam)
    --specShader:send('liteTransform', camera) 
    lovr.graphics.setShader(shader)
    
    -- * DRAW ALL PLATFORMS * --
    lovr.graphics.setColor(1, 1, 1, 1)
    shader:send('useEmissive', 1)

    for i,p in ipairs(level.platforms) do 
        model:draw(p.pos.x, p.pos.y, p.pos.z)
        dblock:draw(p.pos.x, p.pos.y-1.5, p.pos.z, 1.5)
    end
    
    shader:send('useEmissive', 0)
    -- WATER
    for wx = -50, 50, 5 do 
        for wy = -50, 50, 5 do 
            lovr.graphics.plane(waterc, wx + (totalFrames%480)/48, (gameTime/3)-1.0, wy, 5, 5, math.pi/2, 1, 0, 0)
            --lovr.graphics.plane(waterfoam, wx, 0.5, wy, 5, 5, math.pi/2, 1, 0, 0)
        end
    end

    -- * DRAW GEMS * --
    lovr.graphics.setShader(gemShader)
    for i,g in ipairs(level.gems) do 
        if not g.got then 
            gem:draw(g.x, g.y, g.z, 1, totalFrames/100 + i) end
    end
    
    -- UNLIT SHADER
    lovr.graphics.setShader() -- Reset to default/unlit
    
    
    --worldLights.drawPointLights()
    -- skybox
    -- todo

    -- light sims
    lovr.graphics.setColor(1, 1, 1, 1)
    --lovr.graphics.print('hello world', 0, 2, -3, .5)
 
    if sOperatingSystem ~= 'Android' then 
        if myDebug.showFrameDelta then 
            fRenderDelta = os.clock() - fRenderDelta 
            print('frame render time', fRenderDelta)
        end
    end
    
end

