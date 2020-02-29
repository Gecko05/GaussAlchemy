pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- gauss alchemy
-- puzzle game inspired by gauss jordan

local matrix = {-2,-1,0,
                0,2,-2,
                1,0,1}

local sx0 = 40
local sy0 = 40
local wh = 5

local selrow = 0

function drawchems()
    for i=0,#matrix-1 do
        local dx = (i%3) * 10
        local dy = flr(i/3) * 10
        local x0 = sx0 + dx
        local y0 = sy0 + dy
        rect(x0, y0, x0 + wh, y0 + wh, matrix[i+1]+10)
    end    
end

function drawsel()
    local w = 29
    local h = 9
    local margin = 2
    y0 = (selrow*(h + 1)) + sy0 - margin
    x0 = sx0 - margin
    rect(x0, y0, x0 + w, y0 + h, 7)
end

function wait(a)
 for i = 0, a do
  flip()
 end
end

function _draw()
 cls(1)
 drawchems()
 drawsel()
end

function _init()

end

function _update()
 if btnp(3) and selrow < 2 then
  selrow = selrow + 1
 elseif btnp(2) and selrow > 0 then
  selrow = selrow - 1
 end

end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
