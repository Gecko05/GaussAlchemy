-- gauss alchemy
-- puzzle game inspired by gauss jordan

local sx0 = 60
local sy0 = 40
local tx0 = 3*16
local wh = 5

local matrix = {}
local debug = 1
local minI = -2
local maxI = 2
local dbMatrix = {{0,-1, -1},{1, 2, 1},{2, 2, -2}}
local nRows = 3
local sprInc = 32
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
        local dx = (i %3) * 16
        if self.state == 2 then
            dx = dx + tx0
        elseif self.state == 0 then
            dx = dx - tx0
        end
        local dy = (self.n - 1) * 17
        local x0 = sx0 + dx
        local y0 = sy0 + dy
        local sprGem = (self.gems[i+1] + 2) * 32
        spr(sprGem, x0, y0, 2, 2)
        --rect(x0, y0, x0+wh, y0+wh, -self.gems[i+1]+10)
    end
end

function drawSel()
    local w = 48
    local h = 16
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
 cls(0)
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
function cloneTable(t)
    x = {}
    for k, v in pairs(t) do
        add(x, v)
    end
    return x
end

function duplicateRow(r)
    newGems = cloneTable(r.gems)
    dRow = Row:new(r.n, newGems, 0, r.n)
end

function addRows(r)
    if r.n ~= dRow.flag then
        for i = 1,nRows do
            local gem1 = matrix[r.n].gems[i]
            local gem2 = dRow.gems[i]
            if gem1 ~= gem2 then
                gem1 = gem1 + gem2
            end
            -- Control overflow
            if gem1 > maxI then
                gem1 = minI
            elseif gem1 < minI then
                gem1 = maxI
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
    elseif d == 0 and Sel.state > 1 then
        r.state = r.state - 1
        Sel.state = r.state
    elseif d == 0 and Sel.state == 1 then
        duplicateRow(r)
        dRow.state = 0
        Sel.state = dRow.state
    end
end

function transmuteRow()
    if Sel.state == 1 then
        for i=1, nRows do
            local rowG = matrix[Sel.n + 1].gems
            local gem = rowG[i]
            gem = gem + factor
            if gem < minI then
                gem = maxI
            elseif gem > maxI then
                gem = minI
            end
            matrix[Sel.n + 1].gems[i] = gem
        end
    elseif Sel.state == 0 then
        for i=1, nRows do
            local rowG = dRow.gems
            local gem = rowG[i]
            gem = gem + factor
            if gem < minI then
                gem = maxI
            elseif gem > maxI then
                gem = minI
            end
            dRow.gems[i] = gem
        end
    end
end

function processUp()
    if Sel.n > 0 and Sel.state == 1 then
        Sel.n = Sel.n - 1
    elseif Sel.state == 0 and Sel.n > 0 then -- Duplicate and add
        Sel.n = Sel.n - 1
        dRow.n = Sel.n + 1
    end
end

function processDown()
    if Sel.n < 2 and Sel.state == 1 then
        Sel.n = Sel.n + 1
    elseif Sel.state == 0 and Sel.n < 2 then
        Sel.n = Sel.n + 1
        dRow.n = Sel.n + 1
    end
end

function _update()
 if btnp(4) then
  transmuteRow()
 elseif btnp(3) then
  processDown()
 elseif btnp(2) then
  processUP()
 elseif btnp(1) then
  moveRow(1)
 elseif btnp(0) then
  moveRow(0)
 end
end