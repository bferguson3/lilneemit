
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

renderScene = function ()

    if INTEL then 
        lovr.graphics.clear()
        lovr.graphics.reset()
        lovr.graphics.print('Intel GPU detected!\nQuit and download the patch:\n\nhttp://itch.io/tekkamansoul', 0, 0, -6)
        return 
    end
    
    shader:send('liteTransform', lightcam)
    --specShader:send('liteTransform', camera) 
    lovr.graphics.setShader(shader)
    
-- ENABLE WIREFRAME
    local cm, wm, oldsh 
    --EnableWireframe()
    lovr.graphics.setColor(1.0, 0.0, 1.0, 0.5)
    --wfShader:send('wf', wireframeTex)
    -- draw floor
-- DISABLE WIREFRAME
    --sDisableWireframe()
    
    --specShader:send('metallic', 32)
    --specShader:send('specularStrength', 5.0)
    
    -- * DRAW ALL PLATFORMS * --
    lovr.graphics.setColor(1, 1, 1, 1)
    shader:send('useEmissive', 1)

    for i,p in ipairs(level.platforms) do 
        model:draw(p.pos.x, p.pos.y, p.pos.z)
        dblock:draw(p.pos.x, p.pos.y-1.5, p.pos.z, 1.5)
    end
    
    shader:send('useEmissive', 0)
    
    -- * DRAW GEMS * --
    lovr.graphics.setShader(gemShader)
    for i,g in ipairs(level.gems) do 
        gem:draw(g.x, g.y, g.z, 1, totalFrames/100 + i)
    end

    -- UNLIT SHADER
    lovr.graphics.setShader() -- Reset to default/unlit
    worldLights.drawPointLights()
    -- skybox
    -- todo

    -- light sims
    lovr.graphics.setColor(1, 1, 1, 1)
    --lovr.graphics.print('hello world', 0, 2, -3, .5)


    -- reset color/shader variables
    --specShader:send('metallic', 32)
    --specShader:send('specularStrength', 0.5)
    
    if sOperatingSystem ~= 'Android' then 
        if myDebug.showFrameDelta then 
            fRenderDelta = os.clock() - fRenderDelta 
            print('frame render time', fRenderDelta)
        end
    end
    
end

