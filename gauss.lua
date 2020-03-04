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
local factor = 1
local dRow = nil
---------------------------- R O W S -------------------------
Row = {n = 0, gems = 0, state = 0, flag = 0}
-- n - num of row
-- gems - table with gems
-- state : 0 duplicate, 1 in matrix, 2 transmutation
function Row:new (n, gems, state, flag)
    self.__index = self
    o = {}
    o.n = n
    o.gems = gems
    o.state = state
    o.flag = flag
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
    end
end

function drawDuplicate()
    if dRow ~= nil then
        dRow:draw()
    end
end

function _draw()
 cls(1)
 drawMatrix()
 drawDuplicate()
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
function duplicateRow(r)
    dRow = Row:new(r.n, r.gems, 0, r.n)
end

function addRows(r)
    if r.n ~= dRow.flag then
        for i = 1,nRows do
            local gem1 = matrix[r.n].gems[i]
            local gem2 = dRow.gems[i]
            gem1 = gem1 + gem2
            if gem1 > 2 then
                gem1 = -2
            elseif gem1 < -2 then
                gem1 = 2
            end
            matrix[r.n].gems[i] = gem1
        end
    end
end

-- d - 1 to the right
-- d - 0 to the left
function moveRow(d)
    local r = matrix[Sel.n+1]
    if d == 1 and Sel.state == 0 then
        addRows(r)
        dRow = nil    
        Sel.state = 1
    elseif d == 1 and Sel.state < 2 then
        r.state = r.state + 1
        Sel.state = r.state
    elseif d == 0 and Sel.state > 1 then
        r.state = r.state - 1
        Sel.state = r.state
    elseif d == 0 and Sel.state == 1 then
        duplicateRow(r)
        dRow.state = 0
        Sel.state = dRow.state
    end
end

function transmuteRow(r)
    for i=1, nRows do
        local rowG = matrix[r].gems
        local gem = rowG[i]
        gem = gem + factor
        if gem < -2 then
            gem = 2
        elseif gem > 2 then
            gem = -2
        end
        matrix[r].gems[i] = gem
        printh(gem, 'debug.txt', true)
    end
end

function processUp()
    if Sel.n > 0 and Sel.state == 1 then
        Sel.n = Sel.n - 1
    elseif Sel.state == 2 then -- Transmutation
        factor = 1
        transmuteRow(Sel.n+1)
    elseif Sel.state == 0 and Sel.n > 0 then -- Duplicate and add
        Sel.n = Sel.n - 1
        dRow.n = Sel.n + 1
    end
end

function processDown()
    if Sel.n < 2 and Sel.state == 1 then
        Sel.n = Sel.n + 1
    elseif Sel.state == 2 then -- Transmutation
        factor = -1
        transmuteRow(Sel.n+1)
    elseif Sel.state == 0 and Sel.n < 2 then
        Sel.n = Sel.n + 1
        dRow.n = Sel.n + 1
    end
end

function _update()
 if btnp(3) then
  processDown()
 elseif btnp(2) then
  processUP()
 elseif btnp(1) then
  moveRow(1)
 elseif btnp(0) then
  moveRow(0)
 end
end