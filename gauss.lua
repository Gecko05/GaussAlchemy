-- gauss alchemy
-- by Gecko05

local matrix = {}
local expected = {}
local debug = 1
local minI = -2
local maxI = 2
local dbMatrix = {{0,-1, -1},{1, 2, 1},{2, 2, -2}}
local nRows = 3
local sprInc = 32
local cursorSpr = 160
local initialState = 1
local Sel = {n = 1, state = initialState}
local dRow = nil
local swapRow = nil
local addGauge = 8
local swapGauge = 8
local gemColors = {12, 3, 9, 4, 8}
local currLevel = 1
local winState = 0
local finalLevel = 8
local isTutorial = 0
local tutCursor = 23
local tutorialPhase = 1
-- Tutorial Levels
local levelGoal =  {
                {--1
                    {1,1,1},
                    {0,0,0},
                    {1,1,1}
                },
                {--2
                    {1,0,1},
                    {1,0,1},
                    {1,0,1}
                },
                {--3
                    {1,0,0},
                    {0,1,0},
                    {0,0,1}
                },
                {--4
                    {1,0,1},
                    {0,1,0},
                    {1,0,1}
                },
                {--5
                    {0,1,0},
                    {1,0,1},
                    {0,1,0}
                },
                {--6
                    {1,-2,1},
                    {-2,-2,-2},
                    {1,-2,1}
                },
                {--7
                    {-2,0,-2},
                    {0,2,0},
                    {-2,0,-2}
                },
                {--8
                    {-2,-1,0},
                    {1,2,-2},
                    {-1,0,1}
                }
}

local levelStart =  {
                {
                    {2,2,2},
                    {1,1,1},
                    {-2,-2,-2}
                },
                {
                    {2,1,2},
                    {-1,-1,-1},
                    {-1,-1,-1}
                },
                {
                    {-2,-1,-2},
                    {1,1,2},
                    {1,0,0}
                },
                levelGoal[3],
                levelGoal[4],
                levelGoal[5],
                levelGoal[6],
                levelGoal[7],
                levelGoal[8]
}

local tileW = 9
local matrixSize = tileW * nRows
local sx0 = 64 - ((matrixSize)/2)
local msx0 = 64 - ((4*nRows)/2) - 1
local sy0 = 34
local msy0 = 50 + matrixSize + 10
local blockMargin = 11
local gaugeMargin = 16
local tx0 = matrixSize + blockMargin
local mx0 = (4*nRows) + blockMargin
local wh = 5
-- For tutorial cursor animations
local bl = 0
local tutBl = 0
---------------------------- R O W S -------------------------
Row = {n = 0, gems = 0, state = 0, orig = 0}
-- n - num of row
-- gems - table with gems
-- state : 0 duplicate, 1 in matrix, 2 swap
function Row:new (n, gems, state, orig)
    self.__index = self
    o = {}
    o.n = n
    o.gems = gems
    o.state = state
    o.orig = orig
    return setmetatable(o, self)
end

function Row:draw()
    for i = 0, nRows-1 do
        local dx = (i %3) * tileW
        if self.state == 2 then
            dx = dx + tx0
        elseif self.state == 0 then
            dx = dx - tx0
        end
        local dy = (self.n - 1) * tileW
        local x0 = sx0 + dx
        local y0 = sy0 + dy
        local sprGem = (self.gems[i+1] + 2)*32
        spr(sprGem, x0, y0)
        --rect(x0, y0, x0+wh, y0+wh, -self.gems[i+1]+10)
    end
end

miniRow = {n = 0, gems = 0}

function miniRow:new(n, gems)
    self.__index = self
    o = {}
    o.n = n
    o.gems = gems
    return setmetatable(o, self)
end

function miniRow:draw()
    for i = 0, nRows-1 do
        local dx = (i % 3) * 4
        local dy = (self.n - 1) * 4
        local x0 = msx0 + dx
        local y0 = msy0 + dy
        rectfill(x0, y0, x0+2, y0+2, gemColors[self.gems[i+1]+3])
    end
end

---------------------------- D R A W -------------------------
function drawInstruction1()
    print("Press X or Z to transmute a row", 2,2,0)
    spr(tutCursor, 50, 30 + tutBl)
end

function drawInstructions()
    if bl % 10 == 0 then
        if tutBl == 1 then
            tutBl = 0
        else
            tutBl = 1
        end
    end
    bl = bl + 1
    drawInstruction1()
end

function drawSel()
    local w = 3 * tileW
    local h = tileW
    local margin = 10
    local y0 = ((Sel.n - 1)*(h)) + sy0
    local x0 = sx0 - margin
    local x1 = sx0 + matrixSize
    local color = 0
    if Sel.state == 0 and Sel.n > 0 then
        x0 = x0 - tx0
        x1 = x1 - tx0
        color = 1
    elseif Sel.state == 1 and Sel.n == 0 then
        x0 = x0 + 9
        x1 = x1 - 9
        y0 = y0 - 7
    elseif Sel.state == 2 then
        x0 = x0 + tx0
        x1 = x1 + tx0
        color = 2
    end
    spr(cursorSpr+color, x0, y0, 1, 1, true)
    spr(cursorSpr+color, x1, y0)
end

function drawMatrix()  
    for i = 1, nRows do
        if matrix[i] ~= nil then
            matrix[i]:draw()
        end
    end
end

function drawExpected()  
    spr(202, msx0 - 11, msy0 - 7, 4, 4)
    for i = 1, nRows do
        if expected[i] ~= nil then
            expected[i]:draw()
        end
    end
end

function drawDuplicate()
    if dRow ~= nil then
        dRow:draw()
    end
end

function drawBackground()
    local margin = 2
    local margin1 = 11
    local x0 = sx0 - margin
    local x1 = x0 + matrixSize + 1
    local y0 = sy0 - margin
    local y1 = y0 + matrixSize + 1
    -- Draw the background squares
    rectfill(x0, y0, x1, y1, 13) 
    rect(x0-1, y0-1, x1+1, y1+1, 7) 

    x0 = x0 - blockMargin - matrixSize
    x1 = x1 - blockMargin - matrixSize
    rectfill(x0, y0, x1, y1, 13) 
    rect(x0-1, y0-1, x1+1, y1+1, 7) 

    x0 = x0 + blockMargin * 2 + matrixSize * 2
    x1 = x1 + blockMargin * 2 + matrixSize * 2
    rectfill(x0, y0, x1, y1, 13) 
    rect(x0-1, y0-1, x1+1, y1+1, 7) 

    -- Draw the desk
    line(30, 102, 98, 102, 5)
    line(30, 102, 30-15, 102+15)
    line(98, 102, 98+15, 102+15)
    line(30-15,102+15, 98+15, 102+15)
    line(30-15,102+15+2, 98+15, 102+15+2)
    line(30-15,102+15,30-15,102+15+11)
    line(98+15,102+15,98+15,102+15+11)
    spr(206, 35, 92, 2, 2)
    spr(231, 79, 94, 3, 2)

    -- Show level
    print("Level ".. currLevel, 49, 8)
    -- Draw lose message
    if winState == -1 then
        print("You lose :(", 40, 4)
    end
    if currLevel == 1 then
        if winState == 1 then
            print("Good job! Select and press Z\non the green dude to advance", 7,65,0)
        elseif winState == 0 then
            print("      Press Z or X \nto change the row colors",15,65,0)
        elseif winState == 1 then
            print("      Press the red dude to restart",15,65,0)
        end
    elseif currLevel == 2 then
        if winState == 1 then
            print("If the orange bar runs empty\nyou won't be able to add rows", 8,65,0)
        else
            if Sel.state == 0 then
                print("Select where to add the row\n then press right to add it", 8,65,0)
            else
                print("Select a row and press left\n to add it to another row", 8,65,0)
            end
        end
    elseif currLevel == 3 then
        if winState == 1 then
            print("  If the blue bar runs empty\nyou won't be able to swap rows", 4,65,0)
        else
            print("Select a row and press right\nto swap it with another one", 8,65,0)
        end
    elseif currLevel == 4 then
        print("        Great job!\n Now try to reach Level 8!",10,65,0)
    end
end

function drawSwapGauge()
    local x0 = sx0 + matrixSize + blockMargin - 1
    spr(28, x0, sy0 - gaugeMargin)
    spr(29, x0+7, sy0 - gaugeMargin)
    spr(29, x0+13, sy0 - gaugeMargin)
    spr(28, x0+19, sy0 - gaugeMargin, 1, 1, true)
    local x0 = x0
    local y0 = sy0 - gaugeMargin + 1
    local y1 = y0 + 4
    local dx = (8 - swapGauge) * 3
    local x1 = x0 + dx
    rectfill(x0, y0, x1, y1, 5)
end

function drawAddGauge()
    local x0 = sx0 - matrixSize - blockMargin - 1
    spr(12, x0, sy0 - gaugeMargin)
    spr(13, x0+7, sy0 - gaugeMargin)
    spr(13, x0+13, sy0 - gaugeMargin)
    spr(12, x0+19, sy0 - gaugeMargin, 1, 1, true)
    local x0 = x0 + 26
    local y0 = sy0 - gaugeMargin + 1
    local y1 = y0 + 4
    local dx = (8 - addGauge) * 3
    local x1 = x0 - dx
    rectfill(x0, y0, x1, y1, 5)
end

function drawGauges()
    drawAddGauge()
    drawSwapGauge()
end

function drawButton()
    local x0 = 59
    -- Draw the submit button
    spr(18+(winState*2), x0, sy0 - gaugeMargin)
    rect(x0-1, sy0 - gaugeMargin-1, x0+7, sy0 - gaugeMargin + 7, 5)
end

function _draw()
 cls(6)
 drawBackground()
 drawButton()
 drawGauges()
 drawMatrix()
 drawExpected()
 drawDuplicate()
 drawSel()
 if isTutorial == 1 then
    drawInstructions()
 end
end
---------------------------- I N I T ------------------------
function fillExpected()
    expected = {}
    for i = 1, nRows do
        local newMiniRow = miniRow:new(i, levelGoal[currLevel][i])
        add(expected, newMiniRow)
     end
end

function fillMatrix()
    matrix = {}
    for i = 1, nRows do
        local newRow = Row:new(i, cloneTable(levelStart[currLevel][i]), initialState, i)
        add(matrix, newRow)
    end
end

function _init()
    palt(0, false)
    palt(15, true)
    fillExpected()
    fillMatrix()
    music(0)
end
---------------------------- U P D A T E --------------------
function checkForWin()
    local w = 1
    for i=1,nRows do
        for k, v in pairs(expected[i].gems) do
            if v ~= matrix[i].gems[k] then
                w = 0
            end
        end
    end
    winState = w
    -- Lose
    if swapGauge <= 0 and addGauge <= 0 then
        winState = -1
    end
end

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
    if r.n ~= dRow.orig then
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
        -- Consume add power
        if addGauge > 0 then
            addGauge = addGauge - 1
        end
    end
end

-- Extract row to insert in a new position
function extractRow(r)
    r.orig = Sel.n
    swapRow = r
end

function insertRow()
    swapRow.state = 1
    Sel.state = swapRow.state
    -- Consume swap power
    if swapGauge > 0 and swapRow.orig ~= Sel.n then
        swapGauge = swapGauge - 1
    end
end

function updatePositions()
    local auxTable = {}
    for i = 1, nRows do
        matrix[i].orig = matrix[i].n
        auxTable[matrix[i].n] = matrix[i]
    end
    matrix = auxTable
end

-- d - 1 to the right
-- d - 0 to the left
function moveRow(d)
    local r = matrix[Sel.n]
    if d == 1 and Sel.state == 0 then
        addRows(r)
        dRow = nil    
        Sel.state = 1
    elseif d == 1 and Sel.state == 1 then
        extractRow(r)
        r.state = 2
        Sel.state = r.state
    elseif d == 0 and Sel.state == 2 then
        insertRow()
        updatePositions()
    elseif d == 0 and Sel.state == 1 then
        duplicateRow(r)
        dRow.state = 0
        Sel.state = dRow.state
    end
end

function transmuteRow(q)
    if Sel.state == 1 then
        for i=1, nRows do
            local rowG = matrix[Sel.n].gems
            local gem = rowG[i]
            gem = gem + q
            if gem < minI then
                gem = maxI
            elseif gem > maxI then
                gem = minI
            end
            matrix[Sel.n].gems[i] = gem
        end
    elseif Sel.state == 0 then
        for i=1, nRows do
            local rowG = dRow.gems
            local gem = rowG[i]
            gem = gem + q
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
    if Sel.n > 1 then
        Sel.n = Sel.n - 1
    elseif
       Sel.n > 0 and Sel.state == 1 then
       Sel.n = Sel.n - 1
    end
    if Sel.state == 0 then
        dRow.n = Sel.n
    end
    if Sel.state == 2 then
        swapRow.n = Sel.n
        for i=1,nRows do
            if matrix[i] ~= swapRow then
                matrix[i].n = matrix[i].orig
            end
        end
        matrix[Sel.n].orig = matrix[Sel.n].n
        matrix[Sel.n].n = swapRow.orig
    end
end

function processDown()
    if Sel.n < 3 then
        Sel.n = Sel.n + 1
    end
    if Sel.state == 0 then
        dRow.n = Sel.n
    end
    if Sel.state == 2 then
        swapRow.n = Sel.n
        for i=1,nRows do
            if matrix[i] ~= swapRow then
                matrix[i].n = matrix[i].orig
            end
        end
        matrix[Sel.n].orig = matrix[Sel.n].n
        matrix[Sel.n].n = swapRow.orig
    end
end

function advanceLevel()
    if currLevel < finalLevel then
        currLevel = currLevel + 1
        fillExpected()
        fillMatrix()
        winState = 0
        addGauge = 8
        swapGauge = 8
    end
end

function resetLevel()
    fillExpected()
    fillMatrix()
    addGauge = 8
    swapGauge = 8
    winState = 0
end

function processZet()
    if Sel.n > 0 and Sel.n < 4 then
        transmuteRow(-1)
    elseif Sel.n == 0 and winState == 1 then
        advanceLevel()
    elseif Sel.n == 0 and winState <= 0 then
        resetLevel()
    end
end

function processX()
    if Sel.n > 0 and Sel.n < 4 then
        transmuteRow(1)
    end
end

function processLeft()
    if Sel.n > 0 and winState >= 0 and (addGauge > 0 or Sel.state == 2) then
        moveRow(0)
    end
end

function processRight()
    if Sel.n > 0 and winState >= 0 and swapGauge > 0 then
        moveRow(1)
    elseif Sel.state == 0 then
        moveRow(1)
    end
end

function _update()
 checkForWin()
 -- Pressing Z
 if btnp(4) then
  processZet()
 -- Pressing X
 elseif btnp(5) then
  processX()
 elseif btnp(3) then
  processDown()
 elseif btnp(2) then
  processUP()
 elseif btnp(1) then
  processRight()
 elseif btnp(0) then
  processLeft()
 end
end