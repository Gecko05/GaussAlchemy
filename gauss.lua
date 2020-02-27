-- gauss alchemy
-- puzzle game inspired by gauss jordan

local matrix = {-2,-1,0,
                0,2,-2,
                1,0,1}

local sx0 = 40
local sy0 = 40
local wh = 5

local selRow = 0

---------------------------- R O W S -------------------------
Row = {n, out, nGem, gems}

function Row:new (o, n, nGem, gems)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.n = n
    self.out = 0
    self.nGem = nGem
    self.gems = gems
    return o
end


---------------------------- D R A W -------------------------
function drawChems()
    for i=0,#matrix-1 do
        local dx = (i%3) * 10
        local dy = flr(i/3) * 10
        local x0 = sx0 + dx
        local y0 = sy0 + dy
        rect(x0, y0, x0 + wh, y0 + wh, matrix[i+1]+10)
    end    
end

function drawSel()
    local w = 29
    local h = 9
    local margin = 2
    y0 = (selRow*(h + 1)) + sy0 - margin
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
 drawChems()
 drawSel()
end

function _init()

end

function _update()
 if btnp(3) and selRow < 2 then
  selRow = selRow + 1
 elseif btnp(2) and selRow > 0 then
  selRow = selRow - 1
 elseif btnp(0) then
  
 end

end