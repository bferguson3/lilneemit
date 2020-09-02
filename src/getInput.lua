
function GetInput(dT)

    if lovr.headset.isDown('right', 'touchpad') then
        local tpx, tpy = lovr.headset.getAxis('right', 'touchpad')
        --if tpy > 0.8 then player.pos.z = player.pos.z + 0.1 end 
        --if tpy < 0.2 then player.pos.z = player.pos.z - 0.1 end 
        --if tpx > 0.8 then player.pos.x = player.pos.x - 0.1 end 
        --if tpx < 0.2 then player.pos.x = player.pos.x + 0.1 end 
    end 
    if lovr.headset.isDown('right', 'trigger') then
        --player.pos.z = (player.pos.z + 0.1) 
    end
    local playerRotSpd = 2
    local playerWalkSpd = 5
    if lovrVer <= 13 then 
        if lovr.keyboard then 
            if lovr.keyboard.isDown('k') then 
                player.pos.x = player.pos.x - playerWalkSpd*(dT)*(math.cos(player.rot))
                player.pos.z = player.pos.z - playerWalkSpd*(dT)*(math.sin(player.rot))
            elseif lovr.keyboard.isDown('i') then 
                player.pos.x = player.pos.x + playerWalkSpd*(dT)*(math.cos(player.rot))
                player.pos.z = player.pos.z + playerWalkSpd*(dT)*(math.sin(player.rot))
            end
            if lovr.keyboard.isDown('j') then 
                player.pos.x = player.pos.x + playerWalkSpd*(dT)*(math.cos(player.rot-(math.pi/2)))
                player.pos.z = player.pos.z + playerWalkSpd*(dT)*(math.sin(player.rot-(math.pi/2)))
            elseif lovr.keyboard.isDown('l') then 
                player.pos.x = player.pos.x + playerWalkSpd*(dT)*(math.cos(player.rot+(math.pi/2)))
                player.pos.z = player.pos.z + playerWalkSpd*(dT)*(math.sin(player.rot+(math.pi/2)))
            end
            if lovr.keyboard.isDown('o') then 
                player.rot = player.rot + playerRotSpd*dT
            elseif lovr.keyboard.isDown('u') then 
                player.rot = player.rot - playerRotSpd*dT
            end
        end
    else
        if lovr.keyboard then 
            if (player.state == PLAYERSTATE.NORMAL) or (player.state == PLAYERSTATE.JUMPING) or (player.state == PLAYERSTATE.FALLING) then 
                if lovr.keyboard.isDown('q')  or lovr.keyboard.isDown('left') then 
                    player.rot = player.rot - playerRotSpd*dT
                elseif lovr.keyboard.isDown('e')  or lovr.keyboard.isDown('right') then 
                    player.rot = player.rot + playerRotSpd*dT
                end
                if lovr.keyboard.isDown('w') or lovr.keyboard.isDown('up') then 
                    --given a direction, we need to find x (cos t) and y (sin t)
                    player.pos.x = player.pos.x + playerWalkSpd*(dT)*(math.cos(player.rot))
                    player.pos.z = player.pos.z + playerWalkSpd*(dT)*(math.sin(player.rot))
                elseif lovr.keyboard.isDown('s') or lovr.keyboard.isDown('down')  then 
                    player.pos.x = player.pos.x - playerWalkSpd*(dT)*(math.cos(player.rot))
                    player.pos.z = player.pos.z - playerWalkSpd*(dT)*(math.sin(player.rot))
                end
                if lovr.keyboard.isDown('a')  then 
                    player.pos.x = player.pos.x + playerWalkSpd*(dT)*(math.cos(player.rot-(math.pi/2)))
                    player.pos.z = player.pos.z + playerWalkSpd*(dT)*(math.sin(player.rot-(math.pi/2)))
                elseif lovr.keyboard.isDown('d')  then 
                    player.pos.x = player.pos.x + playerWalkSpd*(dT)*(math.cos(player.rot+(math.pi/2)))
                    player.pos.z = player.pos.z + playerWalkSpd*(dT)*(math.sin(player.rot+(math.pi/2)))
                end
            end 
            if player.state == PLAYERSTATE.NORMAL then 
                if lovr.keyboard.isDown('space') then 
                    player.jumpBase = player.pos.y
                    player.state = PLAYERSTATE.JUMPING
                end
            end -- PLAYERSTATE.NORMAL
        end -- END KEYBOARD
    end
    if player.rot > 3.14 then player.rot = -3.14 end 
    if player.rot < -3.14 then player.rot = 3.14 end 
end
