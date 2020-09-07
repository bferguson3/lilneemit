rad = 360/(math.pi*2)
pmx, pmy = 0, 0
--player.yaw = 0

function GetInput(dT)
    local p = player 
    local an, ax, ay, az = lovr.headset.getOrientation()
    local playerRotSpd = 2
    local playerWalkSpd = 5
    
    if lovr.mouse then 
        local mx, my = lovr.mouse.getPosition()
        local deltax, deltay = (mx-pmx), (my-pmy)
        pmx, pmy = mx, my 
        p.rot = p.rot + (deltax * 0.01)
        p.yaw = p.yaw - (deltay * 0.01)
        --print(deltax, deltay)
    end

    --if DESKTOP==0 then 
        --if totalFrames % 60 == 0 then 
            --6.28 = 360
            --local r = 57.3 * an 
            --print(round(ax*r,1), round(ay*r,1), round(az*r,1))
        --end
    --end

    if an ~= 0.0 then -- If not desktop mode  
        p.facing = an * ay -- set HMD facing to the Y component in radians 
    end    
    
    -- * DESKTOP mode input * -- 
    if DESKTOP == 1 then 
        if lovrVer <= 13 then 
            if lovr.keyboard then 
                if lovr.keyboard.isDown('k') then 
                    p.pos.x = p.pos.x - playerWalkSpd*(dT)*(math.cos(p.rot))
                    p.pos.z = p.pos.z - playerWalkSpd*(dT)*(math.sin(p.rot))
                elseif lovr.keyboard.isDown('i') then 
                    p.pos.x = p.pos.x + playerWalkSpd*(dT)*(math.cos(p.rot))
                    p.pos.z = p.pos.z + playerWalkSpd*(dT)*(math.sin(p.rot))
                end
                if lovr.keyboard.isDown('j') then 
                    p.pos.x = p.pos.x + playerWalkSpd*(dT)*(math.cos(p.rot-(math.pi/2)))
                    p.pos.z = p.pos.z + playerWalkSpd*(dT)*(math.sin(p.rot-(math.pi/2)))
                elseif lovr.keyboard.isDown('l') then 
                    p.pos.x = p.pos.x + playerWalkSpd*(dT)*(math.cos(p.rot+(math.pi/2)))
                    p.pos.z = p.pos.z + playerWalkSpd*(dT)*(math.sin(p.rot+(math.pi/2)))
                end
                if lovr.keyboard.isDown('o') then 
                    p.rot = p.rot + playerRotSpd*dT
                elseif lovr.keyboard.isDown('u') then 
                    p.rot = p.rot - playerRotSpd*dT
                end
            end
        else
            if lovr.keyboard then 
                if (p.state == PLAYERSTATE.NORMAL) or (p.state == PLAYERSTATE.JUMPING) or (p.state == PLAYERSTATE.FALLING) then 
                    if lovr.keyboard.isDown('q')  or lovr.keyboard.isDown('left') then 
                        p.rot = p.rot - playerRotSpd*dT
                    elseif lovr.keyboard.isDown('e')  or lovr.keyboard.isDown('right') then 
                        p.rot = p.rot + playerRotSpd*dT
                    end
                    if lovr.keyboard.isDown('w') or lovr.keyboard.isDown('up') then 
                        --given a direction, we need to find x (cos t) and y (sin t)
                        p.pos.x = p.pos.x + playerWalkSpd*(dT)*(math.cos(p.rot))
                        p.pos.z = p.pos.z + playerWalkSpd*(dT)*(math.sin(p.rot))
                    elseif lovr.keyboard.isDown('s') or lovr.keyboard.isDown('down')  then 
                        p.pos.x = p.pos.x - playerWalkSpd*(dT)*(math.cos(p.rot))
                        p.pos.z = p.pos.z - playerWalkSpd*(dT)*(math.sin(p.rot))
                    end
                    if lovr.keyboard.isDown('a')  then 
                        p.pos.x = p.pos.x + playerWalkSpd*(dT)*(math.cos(p.rot-(math.pi/2)))
                        p.pos.z = p.pos.z + playerWalkSpd*(dT)*(math.sin(p.rot-(math.pi/2)))
                    elseif lovr.keyboard.isDown('d')  then 
                        p.pos.x = p.pos.x + playerWalkSpd*(dT)*(math.cos(p.rot+(math.pi/2)))
                        p.pos.z = p.pos.z + playerWalkSpd*(dT)*(math.sin(p.rot+(math.pi/2)))
                    end
                end 
                if player.state == PLAYERSTATE.NORMAL then 
                    if lovr.keyboard.isDown('space') then 
                        player.jumpBase = p.pos.y
                        player.state = PLAYERSTATE.JUMPING
                    end
                end -- PLAYERSTATE.NORMAL
            end -- END KEYBOARD
        end
    end -- end desktop

    -- ** VR Mode input **
    if DESKTOP == 0 then  
        if lovr.headset.isDown('right', 'touchpad') then
            local tpx, tpy = lovr.headset.getAxis('right', 'touchpad')
            if tpy < -0.5 then 
                p.pos.x = p.pos.x + playerWalkSpd*(dT)*(math.cos(-p.facing))
                p.pos.z = p.pos.z + playerWalkSpd*(dT)*(math.sin(-p.facing))
            elseif tpy > 0.5 then 
                p.pos.x = p.pos.x - playerWalkSpd*(dT)*(math.cos(-p.facing))
                p.pos.z = p.pos.z - playerWalkSpd*(dT)*(math.sin(-p.facing))    
            end
            if tpx > 0.5 then 
                p.pos.x = p.pos.x + playerWalkSpd*(dT)*(math.cos(-p.facing+(math.pi/2)))
                p.pos.z = p.pos.z + playerWalkSpd*(dT)*(math.sin(-p.facing+(math.pi/2)))
            elseif tpx < -0.5 then 
                p.pos.x = p.pos.x + playerWalkSpd*(dT)*(math.cos(-p.facing-(math.pi/2)))
                p.pos.z = p.pos.z + playerWalkSpd*(dT)*(math.sin(-p.facing-(math.pi/2)))
            end
        end 
        if lovr.headset.isDown('right', 'trigger') then
            if player.state == PLAYERSTATE.NORMAL then 
                player.jumpBase = p.pos.y
                player.state = PLAYERSTATE.JUMPING
            end -- PLAYERSTATE.NORMAL
        end
    end -- end vr mode input
    
    -- reset rotation within proper range
    if p.rot > 3.14 then p.rot = -3.14 end 
    if p.rot < -3.14 then p.rot = 3.14 end
    --print(p.yaw)
    if p.yaw < -2 then p.yaw = -2 end
    if p.yaw > 2 then p.yaw = 2 end 
    
    -- * Collision * --  
    if p.state == PLAYERSTATE.FALLING then -- CATCHME CODE
        -- iterate through all platforms
        -- platform object should have 'height offset' and 'platform size'
        local pfpos, pfs = platforms[1].pos, platforms[1].platform_size/2 -- position and size of platform 
        local x1, z1, x2, z2 = pfpos.x - pfs, pfpos.z - pfs, pfpos.x + pfs, pfpos.z + pfs -- rectangle of platform collider
        local h = pfpos.y + platforms[1].platform_ofs  -- height of collider
        if (p.pos.x > x1) and (p.pos.x < x2) and (p.pos.z > z1) and (p.pos.z < z2) and ((p.pos.y < (h+0.1))and((p.pos.y > (h-0.1)))) then
            -- if the player 'feet' is within the collider height +/- 1dm
            p.pos.y = pfpos.y + platforms[1].platform_ofs -- lock the player height
            p.jumpTimer = 0 -- reset timer
            p.state = PLAYERSTATE.NORMAL -- set player state
        end
    elseif p.state == PLAYERSTATE.NORMAL then -- FALLING CODE 
        -- save a little effort by filter by player state, get vars as above
        local pfpos, pfs = platforms[1].pos, platforms[1].platform_size/2 
        local x1, z1, x2, z2 = pfpos.x - pfs, pfpos.z - pfs, pfpos.x + pfs, pfpos.z + pfs
        local h = pfpos.y + platforms[1].platform_ofs  
        if (p.pos.x < x1) or (p.pos.x > x2) or (p.pos.z < z1) or (p.pos.z > z2) then
            -- if OUT of bounds of collider rect in any of the 4 directions
            p.state = PLAYERSTATE.FALLING
            p.jumpTimer = 0
            p.fallBase = p.pos.y -- to determine fall acceleration
        end
    end
end
