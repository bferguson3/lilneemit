
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
    
    
    lovr.graphics.setColor(1, 1, 1, 1)
    shader:send('useEmissive', 1)
    
    model:draw(3, 0, 0, 1)
    model:draw(-3, 0, 0, 1)
    model:draw(5, 2, -2, 1)
    model:draw(0, 1, -4, 1)
    
    dblock:draw(3, -1.5, 0, 1.5)
    dblock:draw(5, -1.5, 0, 1.5)
    dblock:draw(7, -1.5, 0, 1.5)
    model:draw(5, 2, -2, 1)
    dblock:draw(1, -1.5, 0, 1.5)
    
    
    --lovr.graphics.newModel('mushboom.glb'):draw(-3, 0, 0)
    --lovr.graphics.newModel('mushboom.glb'):draw(-6, 0, 0)
    
    --dblock:draw(-3, -1.5, 0, 1.5)
    
    
    --shader:send('useEmissive', 0)
    
    -- UNLIT SHADER
    lovr.graphics.setShader() -- Reset to default/unlit
    worldLights.drawPointLights()
    -- skybox
    -- todo

    -- light sims
    lovr.graphics.setColor(1, 1, 1, 1)
    lovr.graphics.print('hello world', 0, 2, -3, .5)

          
    --EnableWireframe()
    --lovr.graphics.setColor(0.5, 1, 0.5, 0.05)
    --wfShader:send('wf', wireframeTex2)
    --model:draw(-1, 3.3, -4.1, 3)
    --DisableWireframe()
    

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

