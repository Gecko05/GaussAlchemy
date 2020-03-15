pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- gauss alchemy
-- puzzle game inspired by gauss jordan

local matrix = {}
local debug = 1
local mini = -2
local maxi = 2
local dbmatrix = {{0,-1, -1},{1, 2, 1},{2, 2, -2}}
local nrows = 3
local sprinc = 32
local cursorspr = 160
local initialstate = 1
local sel = {n = 0, state = initialstate}
local factor = 1
local drow = nil
local addgauge = 8
local swapgauge = 8

local tilew = 9
local matrixsize = tilew * nrows
local sx0 = 64 - ((matrixsize)/2)
local sy0 = 40
local blockmargin = 11
local tx0 = matrixsize + blockmargin
local wh = 5
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
        local dx = (i %3) * tilew
        if self.state == 2 then
            dx = dx + tx0
        elseif self.state == 0 then
            dx = dx - tx0
        end
        local dy = (self.n - 1) * tilew
        local x0 = sx0 + dx
        local y0 = sy0 + dy
        local sprgem = (self.gems[i+1] + 2)*32
        spr(sprgem, x0, y0)
        --rect(x0, y0, x0+wh, y0+wh, -self.gems[i+1]+10)
    end
end

function drawsel()
    local w = 3 * tilew
    local h = tilew
    local margin = 10
    local y0 = (sel.n*(h)) + sy0
    local x0 = sx0 - margin
    local x1 = sx0 + matrixsize
    if sel.state == 0 then
        x0 = x0 - tx0
        x1 = x1 - tx0
    elseif sel.state == 2 then
        x0 = x0 + tx0
        x1 = x1 + tx0
    end
    spr(cursorspr, x0, y0, 1, 1, true)
    spr(cursorspr, x1, y0)
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

function drawbackground()
    local margin = 2
    local margin1 = 11
    local x0 = sx0 - margin
    local x1 = x0 + matrixsize + 1
    local y0 = sy0 - margin
    local y1 = y0 + matrixsize + 1
    rectfill(x0, y0, x1, y1, 13) 
    rect(x0-1, y0-1, x1+1, y1+1, 7) 

    x0 = x0 - blockmargin - matrixsize
    x1 = x1 - blockmargin - matrixsize
    rectfill(x0, y0, x1, y1, 13) 
    rect(x0-1, y0-1, x1+1, y1+1, 7) 

    x0 = x0 + blockmargin * 2 + matrixsize * 2
    x1 = x1 + blockmargin * 2 + matrixsize * 2
    rectfill(x0, y0, x1, y1, 13) 
    rect(x0-1, y0-1, x1+1, y1+1, 7) 
end

function drawswapgauge()
    local x0 = sx0 + matrixsize + blockmargin - 1
    spr(28, x0, sy0 - blockmargin)
    spr(29, x0+7, sy0 - blockmargin)
    spr(29, x0+13, sy0 - blockmargin)
    spr(28, x0+19, sy0 - blockmargin, 1, 1, true)
    local x0 = x0
    local y0 = sy0 - blockmargin + 1
    local y1 = y0 + 4
    local dx = (8 - swapgauge) * 3
    local x1 = x0 + dx
    rectfill(x0, y0, x1, y1, 5)
end

function drawaddgauge()
    local x0 = sx0 - matrixsize - blockmargin - 1
    spr(12, x0, sy0 - blockmargin)
    spr(13, x0+7, sy0 - blockmargin)
    spr(13, x0+13, sy0 - blockmargin)
    spr(12, x0+19, sy0 - blockmargin, 1, 1, true)
    local x0 = x0 + 26
    local y0 = sy0 - blockmargin + 1
    local y1 = y0 + 4
    local dx = (8 - addgauge) * 3
    local x1 = x0 - dx
    rectfill(x0, y0, x1, y1, 5)
end

function drawgauges()
    drawaddgauge()
    drawswapgauge()
end

function _draw()
 cls(6)
 drawbackground()
 drawgauges()
 drawmatrix()
 drawduplicate()
 drawsel()
end
---------------------------- i n i t ------------------------
function _init()
    palt(0, false)
    palt(15, true)
    for i = 1, nrows do
        if debug == 1 then
        local newrow = row:new(i, dbmatrix[i], initialstate)
        add(matrix, newrow)
        end
    end
end
---------------------------- u p d a t e --------------------
function clonetable(t)
    x = {}
    for k, v in pairs(t) do
        add(x, v)
    end
    return x
end

function duplicaterow(r)
    newgems = clonetable(r.gems)
    drow = row:new(r.n, newgems, 0, r.n)
end

function addrows(r)
    if r.n ~= drow.flag then
        for i = 1,nrows do
            local gem1 = matrix[r.n].gems[i]
            local gem2 = drow.gems[i]
            if gem1 ~= gem2 then
                gem1 = gem1 + gem2
            end
            -- control overflow
            if gem1 > maxi then
                gem1 = mini
            elseif gem1 < mini then
                gem1 = maxi
            end
            matrix[r.n].gems[i] = gem1
        end
    end
    if addgauge > 0 then
        addgauge = addgauge - 1
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
    elseif d == 0 and sel.state > 1 then
        r.state = r.state - 1
        sel.state = r.state
    elseif d == 0 and sel.state == 1 then
        duplicaterow(r)
        drow.state = 0
        sel.state = drow.state
    end
end

function transmuterow()
    if sel.state == 1 then
        for i=1, nrows do
            local rowg = matrix[sel.n + 1].gems
            local gem = rowg[i]
            gem = gem + factor
            if gem < mini then
                gem = maxi
            elseif gem > maxi then
                gem = mini
            end
            matrix[sel.n + 1].gems[i] = gem
        end
    elseif sel.state == 0 then
        for i=1, nrows do
            local rowg = drow.gems
            local gem = rowg[i]
            gem = gem + factor
            if gem < mini then
                gem = maxi
            elseif gem > maxi then
                gem = mini
            end
            drow.gems[i] = gem
        end
    end
    if swapgauge > 0 then
        swapgauge = swapgauge - 1
    end
end

function processup()
    if sel.n > 0 and sel.state == 1 then
        sel.n = sel.n - 1
    elseif sel.state == 0 and sel.n > 0 then -- duplicate and add
        sel.n = sel.n - 1
        drow.n = sel.n + 1
    end
end

function processdown()
    if sel.n < 2 and sel.state == 1 then
        sel.n = sel.n + 1
    elseif sel.state == 0 and sel.n < 2 then
        sel.n = sel.n + 1
        drow.n = sel.n + 1
    end
end

function _update()
 if btnp(4) then
  transmuterow()
 elseif btnp(3) then
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
6666666fbbbbbbbfaaaaaaaf9999999feeeeeeefffffffff000000600000000000000060000000000000006000000000f55555555555555f5555555f00000000
cccccccf3333333f9999999f4444444f8888888fffffffff0000067c0000000000000666000000000000066600000000544444444444444f4444444500000000
cccccccf3300033f9900099f4404044f8880888fffffffff0000767cc000000000007666600000000000766c60000000547747744774774f4774774500000000
cc000ccf3333333f9909099f4404044f8800088fffffffff0007767ccc00000000077676660000000007767cc6000000549949944994994f4994994500000000
cccccccf3300033f9900099f4404044f8880888fffffffff00776776ccc00000007767c766600000007767c6cc600000549949944994994f4994994500000000
cccccccf3333333f9999999f4444444f8888888fffffffff066677776ccc000006667ccc7666000006667ccc6cc60000544444444444444f4444444500000000
1111111f1111111f4444444f2222222f2222222fffffffff6677777776ccc0006667ccccc66660006667cccccc11c000f55555555555555f5555555f00000000
ffffffffffffffffffffffffffffffffffffffffffffffff0ccc67776c1100000ccc6ccc6cc600000ccc6cccc11c0000ffffffffffffffffffffffff00000000
ffffffffffffffffffffffffffffffffffffffffffffffff00ccc676c110000000ccc6c6cc60000000ccc6cc11c00000f55555555555555f5555555f00000000
ffffffffffffffffffffffffffffffffffffffffffffffff000ccc6c11000000000ccc6cc6000000000cccc11c000000511111111111111f4444444500000000
ffffffffffffffffffffffffffffffffffffffffffffffff0000cc61100000000000cc6cc00000000000cc11c0000000517717711771771f4774774500000000
ffffffffffffffffffffffffffffffffffffffffffffffff00000c610000000000000c6c0000000000000c1c0000000051cc1cc11cc1cc1f4994994500000000
ffffffffffffffffffffffffffffffffffffffffffffffff00000010000000000000006000000000000000100000000051cc1cc11cc1cc1f4994994500000000
ffffffffffffffffffffffffffffffffffffffffffffffff000000000000000000000000000000000000000000000000511111111111111f4444444500000000
ffffffffffffffffffffffffffffffffffffffffffffffff000000000000000000000000000000000000000000000000f55555555555555f5555555f00000000
ffffffffffffffffffffffffffffffffffffffffffffffff000000000000000000000000000000000000000000000000ffffffffffffffffffffffff00000000
bbbbbbbfbbbbbbffffffffbfffffffff000000b000000000000000b000000000000000b000000000000000b00000000000000000000000000000000000000000
3333333fbbbbbbfffffff7b3ffffffff000007b30000000000000b730000000000000bbb0000000000000bbb0000000000000000000000000000000000000000
3300033f333333ffffff7bb33fffffff000077b33000000000007b733000000000007bbbb000000000007bb3b000000000000000000000000000000000000000
3333333f333333fffff77b7333ffffff000777733300000000077b733300000000077b7bbb00000000077b733b00000000000000000000000000000000000000
3300033f003333ffff77b73b333fffff0077773b333000000077b77b333000000077b737bbb000000077b73b33b0000000000000000000000000000000000000
3333333f003333fff7bb7333b333ffff07777333b33300000bbb7777b33300000bbb73337bbb00000bbb7333b33b000000000000000000000000000000000000
1111111f333333ff7bb7333333111fff7777333333111000bb7777777b333000bbb733333bbbb000bbb733333311300000000000000000000000000000000000
ffffffff333333fffb33b3333111ffff07bbb333311100000333b777b31100000333b333b33b00000333b3333113000011c00000000000000000000000000000
33330000003333ffffb33b33111fffff007bbb331110000000333b7b3110000000333b3b33b0000000333b331130000000000000000000000000000000000000
33330000003333fffffb333111ffffff0007bb3111000000000333b311000000000333b33b000000000333311300000000000000000000000000000000000000
33333333333333ffffffb3111fffffff0000bb1110000000000033b110000000000033b330000000000033113000000000000000000000000000000000000000
33333333333333fffffff311ffffffff00000b1100000000000003b100000000000003b300000000000003130000000000000000000000000000000000000000
11111111111111ffffffff1fffffffff00000010000000000000001000000000000000b000000000000000100000000000000000000000000000000000000000
11111111111111ffffffffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffffffffffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffffffffffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaaafafaaaaff000000a000000000000000a000000000000000a000000000000000a000000000000000a00000000000000000000000000000000000000000
9999999f9faaaaff000007a900000000000007a90000000000000a790000000000000aaa0000000000000aaa0000000000000000000000000000000000000000
9900099f9f9999ff00007aa990000000000077a99000000000007a799000000000007aaaa000000000007aa9a000000000000000000000000000000000000000
9909099f9f9999ff00077a7999000000000777799900000000077a799900000000077a7aaa00000000077a799a00000000000000000000000000000000000000
9900099f9f9999ff0077a79a999000000077779a999000000077a77a999000000077a797aaa000000077a79a99a0000000000000000000000000000000000000
9999999f9f9999ff07aa7999a999000007777999a99900000aaa7777a99900000aaa79997aaa00000aaa7999a99a000000000000000000000000000000000000
4444444f4f9999ff7aa79999994440007777999999444000aa7777777a999000aaa799999aaaa000aaa799999944900000000000000000000000000000000000
ffffffffff9999ff0a99a9999444000007aaa999944400000999a777a94400000999a999a99a00000999a9999449000000000000000000000000000000000000
99990000009999ff00a99a9944400000007aaa994440000000999a7a9440000000999a9a99a0000000999a994490000000000000000000000000000000000000
99990000009999ff000a9994440000000007aa9444000000000999a944000000000999a99a000000000999944900000000000000000000000000000000000000
99999999999999ff0000a944400000000000aa4440000000000099a440000000000099a990000000000099449000000000000000000000000000000000000000
99999999999999ff000009440000000000000a4400000000000009a400000000000009a900000000000009490000000000000000000000000000000000000000
44444444444444ff000000400000000000000040000000000000004000000000000000a000000000000000400000000000000000000000000000000000000000
44444444444444ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9999999f999999ff000000e000000000000000e000000000000000e000000000000000e000000000000000e00000000000000000000000000000000000000000
4444444f999999ff000007e800000000000007e80000000000000e780000000000000eee0000000000000eee0000000000000000000000000000000000000000
4404044f444444ff00007ee880000000000077e88000000000007e788000000000007eeee000000000007ee8e000000000000000000000000000000000000000
4404044f444444ff00077e7888000000000777788800000000077e788800000000077e7eee00000000077e788e00000000000000000000000000000000000000
4404044f004444ff0077e78e888000000077778e888000000077e77e888000000077e787eee000000077e78e88e0000000000000000000000000000000000000
4444444f004444ff07ee7888e888000007777888e88800000eee7777e88800000eee78887eee00000eee7888e88e000000000000000000000000000000000000
2222222f004444ff7ee78888882220007777888888222000ee7777777e888000eee788888eeee000eee788888822800000000000000000000000000000000000
ffffffff004444ff0e88e8888222000007eee888822200000888e777e82200000888e888e88e00000888e8888228000000000000000000000000000000000000
44440044004444ff00e88e8822200000007eee882220000000888e7e8220000000888e8e88e0000000888e882280000000000000000000000000000000000000
44440044004444ff000e8882220000000007ee8222000000000888e822000000000888e88e000000000888822800000000000000000000000000000000000000
44444444444444ff0000e822200000000000ee2220000000000088e220000000000088e880000000000088228000000000000000000000000000000000000000
44444444444444ff000008220000000000000e2200000000000008e200000000000008e800000000000008280000000000000000000000000000000000000000
22222222222222ff000000200000000000000020000000000000002000000000000000e000000000000000200000000000000000000000000000000000000000
22222222222222ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeefeeeeeeff0000006000000000000000600000000000000060000000000000006000000000000000600000000000000000000000000000000000000000
8888888feeeeeeff0000076500000000000007650000000000000675000000000000066600000000000006660000000000000000000000000000000000000000
8880888f888888ff0000766550000000000077655000000000007675500000000000766660000000000076656000000000000000000000000000000000000000
8800088f888888ff0007767555000000000777755500000000077675550000000007767666000000000776755600000000000000000000000000000000000000
8880888f888888ff0077675655500000007777565550000000776776555000000077675766600000007767565560000000000000000000000000000000000000
8888888f888888ff0766755565550000077775556555000006667777655500000666755576660000066675556556000000000000000000000000000000000000
2222222f008888ff7667555555111000777755555511100066777777765550006667555556666000666755555511500000000000000000000000000000000000
ffffffff008888ff0655655551110000076665555111000005556777651100000555655565560000055565555115000000000000000000000000000000000000
88888800888888ff0065565511100000007666551110000000555676511000000055565655600000005556551150000000000000000000000000000000000000
88888800888888ff0006555111000000000766511100000000055565110000000005556556000000000555511500000000000000000000000000000000000000
88888888888888ff0000651110000000000066111000000000005561100000000000556550000000000055115000000000000000000000000000000000000000
88888888888888ff0000051100000000000006110000000000000561000000000000056500000000000005150000000000000000000000000000000000000000
22222222222222ff0000001000000000000000100000000000000010000000000000006000000000000000100000000000000000000000000000000000000000
22222222222222ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
fff555ffffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ff56675f55555fff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f566675f55555fff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5666675ffffff55f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f566675ffffff55f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ff56675ffffff55f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
fff555fffffff55f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
fffffffffffff55f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55fffffffffff55f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ff55fffffffff55f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ff55fffffffff55f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffff55fffffff55f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffff55fffffff55f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffff5555555fff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffff5555555fff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
