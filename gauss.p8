pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- gauss alchemy
-- puzzle game inspired by gauss jordan

local sx0 = 40
local sy0 = 40
local tx0 = 3*10
local wh = 5

local matrix = {}
local debug = 1
local dbmatrix = {{-2, -1, -1},{0, 1, 0},{2, 2, 1}}
local nrows = 3
local initialstate = 1
local sel = {n = 0, state = initialstate}
local factor = 1
local drow = nil
---------------------------- r o w s -------------------------
row = {n = 0, gems = 0, state = 0, flag = 0}
-- n - num of row
-- gems - table with gems
-- state : 0 duplicate, 1 in matrix, 2 transmutation
function row:new (n, gems, state, flag)
    self.__index = self
    o = {}
    o.n = n
    o.gems = gems
    o.state = state
    o.flag = flag
    return setmetatable(o, self)
end

function row:draw()
    for i = 0, nrows-1 do
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

function drawsel()
    local w = 29
    local h = 9
    local margin = 2
    local y0 = (sel.n*(h + 1)) + sy0 - margin
    local x0 = sx0 - margin
    if sel.state == 0 then
        x0 = x0 - tx0
    elseif sel.state == 2 then
        x0 = x0 + tx0
    end
    rect(x0, y0, x0 + w, y0 + h, 7)
end
---------------------------- d r a w -------------------------
function drawmatrix()  
    for i = 1, nrows do
        matrix[i]:draw()
    end
end

function drawduplicate()
    if drow ~= nil then
        drow:draw()
    end
end

function _draw()
 cls(1)
 drawmatrix()
 drawduplicate()
 drawsel()
end
---------------------------- i n i t ------------------------
function _init()
    for i = 1, nrows do
        if debug == 1 then
        local newrow = row:new(i, dbmatrix[i], initialstate)
        add(matrix, newrow)
        end
    end
end
---------------------------- u p d a t e --------------------
function duplicaterow(r)
    drow = row:new(r.n, r.gems, 0, r.n)
end

function addrows(r)
    if r.n ~= drow.flag then
        for i = 1,nrows do
            local gem1 = matrix[r.n].gems[i]
            local gem2 = drow.gems[i]
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
function moverow(d)
    local r = matrix[sel.n+1]
    if d == 1 and sel.state == 0 then
        addrows(r)
        drow = nil    
        sel.state = 1
    elseif d == 1 and sel.state < 2 then
        r.state = r.state + 1
        sel.state = r.state
    elseif d == 0 and sel.state > 1 then
        r.state = r.state - 1
        sel.state = r.state
    elseif d == 0 and sel.state == 1 then
        duplicaterow(r)
        drow.state = 0
        sel.state = drow.state
    end
end

function transmuterow(r)
    for i=1, nrows do
        local rowg = matrix[r].gems
        local gem = rowg[i]
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

function processup()
    if sel.n > 0 and sel.state == 1 then
        sel.n = sel.n - 1
    elseif sel.state == 2 then -- transmutation
        factor = 1
        transmuterow(sel.n+1)
    elseif sel.state == 0 and sel.n > 0 then -- duplicate and add
        sel.n = sel.n - 1
        drow.n = sel.n + 1
    end
end

function processdown()
    if sel.n < 2 and sel.state == 1 then
        sel.n = sel.n + 1
    elseif sel.state == 2 then -- transmutation
        factor = -1
        transmuterow(sel.n+1)
    elseif sel.state == 0 and sel.n < 2 then
        sel.n = sel.n + 1
        drow.n = sel.n + 1
    end
end

function _update()
 if btnp(3) then
  processdown()
 elseif btnp(2) then
  processup()
 elseif btnp(1) then
  moverow(1)
 elseif btnp(0) then
  moverow(0)
 end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
