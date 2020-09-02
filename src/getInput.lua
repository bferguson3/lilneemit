
function GetInput(dT)

    if lovr.headset.isDown('right', 'touchpad') then
        local tpx, tpy = lovr.headset.getAxis('right', 'touchpad')
        --if tpy > 0.8 then playerPosition.z = playerPosition.z + 0.1 end 
        --if tpy < 0.2 then playerPosition.z = playerPosition.z - 0.1 end 
        --if tpx > 0.8 then playerPosition.x = playerPosition.x - 0.1 end 
        --if tpx < 0.2 then playerPosition.x = playerPosition.x + 0.1 end 
    end 
    if lovr.headset.isDown('right', 'trigger') then
        --playerPosition.z = (playerPosition.z + 0.1) 
    end
    local playerRotSpd = 2
    local playerWalkSpd = 5
    if lovrVer <= 13 then 
        if lovr.keyboard then 
            if lovr.keyboard.isDown('k') then 
                playerPosition.x = playerPosition.x - playerWalkSpd*(dT)*(math.cos(playerRotation))
                playerPosition.z = playerPosition.z - playerWalkSpd*(dT)*(math.sin(playerRotation))
            elseif lovr.keyboard.isDown('i') then 
                playerPosition.x = playerPosition.x + playerWalkSpd*(dT)*(math.cos(playerRotation))
                playerPosition.z = playerPosition.z + playerWalkSpd*(dT)*(math.sin(playerRotation))
            end
            if lovr.keyboard.isDown('j') then 
                playerPosition.x = playerPosition.x + playerWalkSpd*(dT)*(math.cos(playerRotation-(math.pi/2)))
                playerPosition.z = playerPosition.z + playerWalkSpd*(dT)*(math.sin(playerRotation-(math.pi/2)))
            elseif lovr.keyboard.isDown('l') then 
                playerPosition.x = playerPosition.x + playerWalkSpd*(dT)*(math.cos(playerRotation+(math.pi/2)))
                playerPosition.z = playerPosition.z + playerWalkSpd*(dT)*(math.sin(playerRotation+(math.pi/2)))
            end
            if lovr.keyboard.isDown('o') then 
                playerRotation = playerRotation + playerRotSpd*dT
            elseif lovr.keyboard.isDown('u') then 
                playerRotation = playerRotation - playerRotSpd*dT
            end
        end
    else
        if lovr.keyboard then 
            if lovr.keyboard.isDown('q')  or lovr.keyboard.isDown('left') then 
                playerRotation = playerRotation - playerRotSpd*dT
            elseif lovr.keyboard.isDown('e')  or lovr.keyboard.isDown('right') then 
                playerRotation = playerRotation + playerRotSpd*dT
            end
            if lovr.keyboard.isDown('w') or lovr.keyboard.isDown('up') then 
                --given a direction, we need to find x (cos t) and y (sin t)
                playerPosition.x = playerPosition.x + playerWalkSpd*(dT)*(math.cos(playerRotation))
                playerPosition.z = playerPosition.z + playerWalkSpd*(dT)*(math.sin(playerRotation))
            elseif lovr.keyboard.isDown('s') or lovr.keyboard.isDown('down')  then 
                playerPosition.x = playerPosition.x - playerWalkSpd*(dT)*(math.cos(playerRotation))
                playerPosition.z = playerPosition.z - playerWalkSpd*(dT)*(math.sin(playerRotation))
            end
            if lovr.keyboard.isDown('a')  then 
                playerPosition.x = playerPosition.x + playerWalkSpd*(dT)*(math.cos(playerRotation-(math.pi/2)))
                playerPosition.z = playerPosition.z + playerWalkSpd*(dT)*(math.sin(playerRotation-(math.pi/2)))
            elseif lovr.keyboard.isDown('d')  then 
                playerPosition.x = playerPosition.x + playerWalkSpd*(dT)*(math.cos(playerRotation+(math.pi/2)))
                playerPosition.z = playerPosition.z + playerWalkSpd*(dT)*(math.sin(playerRotation+(math.pi/2)))
            end
        end
    end
    if playerRotation > 3.14 then playerRotation = -3.14 end 
    if playerRotation < -3.14 then playerRotation = 3.14 end 
end
