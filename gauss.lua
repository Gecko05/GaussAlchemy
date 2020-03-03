-- gauss alchemy
-- puzzle game inspired by gauss jordan

local sx0 = 40
local sy0 = 40
local tx0 = 3*10
local wh = 5

local matrix = {}
local debug = 1
local dbMatrix = {{-2, -1, -1},{0, 1, 0},{2, 2, 1}}
local nRows = 3
local initialState = 1
local Sel = {n = 0, state = initialState}
---------------------------- R O W S -------------------------
Row = {n = 0, gems = 0, state = 0}
-- n - num of row
-- gems - table with gems
-- state : 0 duplicate, 1 in matrix, 2 transmutation
function Row:new (n, gems, state)
    self.__index = self
    o = {}
    o.n = n
    o.gems = gems
    o.state = state
    return setmetatable(o, self)
end

function Row:draw()
    for i = 0, nRows-1 do
        local dx = (i %3) * 10
        if self.state == 2 then
            dx = dx + tx0
        elseif self.state == 0 then
            dx = dx - tx0
        end
        local dy = (self.n - 1) * 10
        local x0 = sx0 + dx
        local y0 = sy0 + dy
        rect(x0, y0, x0+wh, y0+wh, self.gems[i+1]+10)
    end
end

function drawSel()
    local w = 29
    local h = 9
    local margin = 2
    local y0 = (Sel.n*(h + 1)) + sy0 - margin
    local x0 = sx0 - margin
    if Sel.state == 0 then
        x0 = x0 - tx0
    elseif Sel.state == 2 then
        x0 = x0 + tx0
    end
    rect(x0, y0, x0 + w, y0 + h, 7)
end
---------------------------- D R A W -------------------------
function drawMatrix()  
    for i = 1, nRows do
        matrix[i]:draw()
        print(matrix[i].n)
    end
end

function _draw()
 cls(1)
 drawMatrix()
 drawSel()
end
---------------------------- I N I T ------------------------
function _init()
    for i = 1, nRows do
        if debug == 1 then
        local newRow = Row:new(i, dbMatrix[i], initialState)
        add(matrix, newRow)
        end
    end
end
---------------------------- U P D A T E --------------------
-- d - 1 to the right
-- d - 0 to the left
function moveRow(d)
    local r = matrix[Sel.n+1]
    if d == 1 and r.state < 2 then
        r.state = r.state + 1
    elseif d == 0 and r.state > 0 then
        r.state = r.state - 1
    end
    Sel.state = r.state
end

function _update()
 if btnp(3) and Sel.n < 2 and Sel.state == 1 then
  Sel.n = Sel.n + 1
 elseif btnp(2) and Sel.n > 0 and Sel.state == 1 then
  Sel.n = Sel.n - 1
 elseif btnp(1) then
  moveRow(1)
 elseif btnp(0) then
  moveRow(0)
 end
end