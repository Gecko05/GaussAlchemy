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
---------------------------- r o w s -------------------------
row = {n = 0, gems = 0, state = 0}
-- n - num of row
-- gems - table with gems
-- state : 0 duplicate, 1 in matrix, 2 transmutation
function row:new (n, gems, state)
    self.__index = self
    o = {}
    o.n = n
    o.gems = gems
    o.state = state
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
        print(matrix[i].n)
    end
end

function _draw()
 cls(1)
 drawmatrix()
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
-- d - 1 to the right
-- d - 0 to the left
function moverow(d)
    local r = matrix[sel.n+1]
    if d == 1 and r.state < 2 then
        r.state = r.state + 1
    elseif d == 0 and r.state > 0 then
        r.state = r.state - 1
    end
    sel.state = r.state
end

function _update()
 if btnp(3) and sel.n < 2 and sel.state == 1 then
  sel.n = sel.n + 1
 elseif btnp(2) and sel.n > 0 and sel.state == 1 then
  sel.n = sel.n - 1
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
