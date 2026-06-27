local redInputSide = require("sides").right

local cmp = require("component"); local serial; local fs; local comp = require("computer"); local active = true; local gpu =
    cmp.gpu; local ox, oy =
    gpu.getResolution(); local term; local RoR; local input; local rednet; local threading = require("thread"); gpu
    .setResolution(60, 40); local resX, resY = gpu.getResolution(); gpu.setBackground(0); gpu.fill(1, 1, resX, resY, ' '); gpu
    .setForeground(0xffffff); gpu.setBackground(0);
gpu.set(1, 1, '╒') --corners of bounding box. 'set' command sets the text given in the third argument to the location given by the first two; (x, y, 'text')
gpu.set(resX, 1, '╕') --since this is stinky Lua, everything is one-indexed... telling it to print at (0,0) is outside the bounds of the screen.
gpu.set(1, resY, '╘')
gpu.set(resX, resY, '╛')
os.sleep(.01) -- short wait for flavor
gpu.fill(2, 1, resX - 2, 1, '═') --sides of bounding box. 'fill' command makes copies of the character given in the fifth argument to the location given by the first two, and
--                             with the size defined by the second two. (x,y,sizeX,sizeY,'char')
gpu.fill(2, resY, resX - 2, 1, '═')
gpu.fill(1, 2, 1, resY - 2, '│')
gpu.fill(resX, 2, 1, resY - 2, '│')
os.sleep(.15)

local hang = false
local icl = ""
local lty = 3
local function newCheck(name, toLoad)
    threading.create(function()
        local cy =
            lty --stores current Y coordinate as a new variable as to not rely on the mutable 'lty' for future reference
        gpu.set(3, lty, '☐ ' .. name) --prints out new undefined variable check
        lty = lty + 1 --advances Y variable so subsequent newChecks do not overwrite previous ones
        if lty > resY - 2 then lty = 3 end --resets lty to original value if it would otherwise run into bounding box
        os.sleep(math.random() + .6) --creates the illusion of the check taking time for fun
        local s, e = pcall(toLoad) --protected call to silence errors when running the provided function, will check if it suceeded
        local of = gpu.getForeground()
        if s then --if it did suceed
            gpu.setForeground(0x00ff00) -- solid green
            gpu.set(3, cy, '☑')
            gpu.setForeground(of)
        else --if it did not
            icl = icl .. name .. ", "
            hang = true
            gpu.setForeground(0xff0000) -- solid red
            gpu.set(3, cy, '☒')
            gpu.setForeground(of)
            os.sleep(1)
            local cy0 = cy
            local m = ""
            for x = 3, resX - 4 do m = m .. gpu.get(x, cy0) end
            repeat
                local of0 = gpu.getForeground()
                gpu.setForeground(0xffffff)
                gpu.fill(3, cy0, resX - 4, 1, ' ')
                gpu.set(3, cy0, e)
                gpu.setForeground(of0)
                os.sleep(.8)
                of0 = gpu.getForeground()
                gpu.setForeground(0xff0000)
                gpu.fill(3, cy0, resX - 4, 1, ' ')
                gpu.set(3, cy0, m)
                gpu.setForeground(of0)
                os.sleep(.8)
            until not active --NOTE: relies on soft exit!
        end; of = nil
    end)
end

newCheck("GPU API", function() end)       --we already know the gpu works if this is being displayed, so no need to ask it to do more
os.sleep(math.random() * .3 + .1)
newCheck("COMPONENT API", function() end) --same here, cmp is a prerequisite for gpu
os.sleep(math.random() * .3 + .1)
newCheck("THREADING API", function() end) --the same
os.sleep(math.random() * .3 + .1)
newCheck("COMPUTER API", function() end)  --how are you running a computer program with no computer?
os.sleep(math.random() * .3 + .1)
newCheck("TERMINAL API", function() term = require("term") end)
os.sleep(math.random() * .3 + .1)
newCheck("REDSTONE API", function() rednet = cmp.redstone end)
os.sleep(math.random() * .3 + .1)
newCheck("SERIALIZATION API", function() serial = require("serialization") end)
os.sleep(math.random() * .3 + .1)
newCheck("FILESYSTEM API", function() fs = require("filesystem") end)
os.sleep(math.random() * .3 + .1)
newCheck("TORCH ADDRESS INDEX",
    function()
        local fh = io.open("/rbmk/torches.add", "r"); RoR = cmp.proxy(fh:read("*l")); input = cmp.proxy(fh:read("*l")); if fh then
            fh:close()
        end
    end)
os.sleep(math.random() * .3 + .1)
--TODO; more checks for other elements
os.sleep(3.5)
if hang then
    comp.beep(1800, .35) --(frequency in hz, time). FULLY BLOCKING! will pause all threads until complete.
    os.sleep(.15)
    comp.beep(1800, .35)
    gpu.setForeground(0xffffff)
    gpu.set(resX / 2 - 10, 1, "PRESS ANY KEY TO EXIT")
    local _ = require("event").pull("key_down") -- wait until user presses any key
    active = false
    term.clear()
    error("Error loading required components: " .. icl:sub(1, #icl - 2))
end

term.clear()

local controlRodRegistry = {
    { "b26599b0", "RED" },
    { "37000bc7", "YELLOW" },
    { "",         "GREEN" },
    { "",         "BLUE" },
    { "",         "PURPLE" }
}

local dataRegistry = { -- these values need to be 'chewed' by a logic reciever and resent on a seperate channel
    { "2753b1b8" },    -- col heat
    { "93061e02" },    -- fuel heat
    { "f0a60078" },    -- depletion
    { "c2f2282c" }     -- xenon poison
}
local lrh = {
    { 0, "RED" },
    { 0, "YELLOW" },
    { 0, "GREEN" },
    { 0, "BLUE" },
    { 0, "PURPLE" }
}

local function setRods(color, level) end

local function textInput(button)
    gpu.setForeground(0)
    gpu.set(button[1], button[2], "000")
    local etrd = ""
    local color = button[7]
    repeat
        term.setCursor(0, 1)
        local _, _, char = require("event").pull("key_down")
        if char == 13 then
            setRods(color, tonumber(etrd) or 0); if not tonumber(etrd) then gpu.set(button[1], button[2], "000") end
            break
        end
        if #etrd > 0 and char == 8 then
            etrd = etrd:sub(1, #etrd - 1); gpu.set(button[1], button[2], "   "); gpu.set(button[1], button[2],
                string.rep('0', 3 - #etrd) .. etrd)
        end
        char = string.char(char)
        if tonumber(char) and #etrd < 3 then
            etrd = etrd .. char
            if tonumber(etrd) > 100 then etrd = "100" end
            gpu.set(button[1], button[2], "   ")
            gpu.set(button[1], button[2], string.rep('0', 3 - #etrd) .. etrd)
            comp.beep(tonumber(etrd) * 10 + 100, .1)
        elseif #etrd >= 3 then
            comp.beep(2000, .075)
        end
    until not active
    comp.beep(1100, .05)
end
local buttonRegistry = {}
local function popButtons()
    local of=gpu.getForeground();local ob=gpu.getBackground()
    for _, v in pairs(buttonRegistry) do
        gpu.setBackground(v[3])
        gpu.setForeground(v[4])
        gpu.set(v[1], v[2], v[5])
    end
    gpu.setForeground(of);gpu.setBackground(ob)
end
local function loadPreset(btn) end
local function checkPresets()
    lty = 5
    if fs.exists("/rbmk/presets.rbmk") then
        local ln=0
        for _ in io.lines("/rbmk/presets.rbmk") do ln=ln+1 end
        gpu.setBackground(0xc3c3c3)
        gpu.fill(21,3,15,ln+3,' ')
        gpu.set(25,3,"PRESETS")
        table.insert(buttonRegistry,{26,4,0xff0000,0,"DELETE",function() fs.remove("/rbmk/presets.rbmk");checkPresets() end,nil})
        for i, v in pairs(buttonRegistry) do if v[6] == loadPreset then table.remove(buttonRegistry, i) end end
        for line in io.lines("/rbmk/presets.rbmk") do
            gpu.setBackground(0xd2d2d2)
            gpu.setForeground(0)
            gpu.fill(21, lty, 10, 1, ' ')
            local data = serial.unserialize(line)
            if data then
                gpu.set(21, lty, data[1])
                table.insert(buttonRegistry, { 32, lty, 0x00ff00, 0, "LOAD", loadPreset, data[2] })
                gpu.set(21, lty, data[1])
                lty = lty + 1
            end
        end
    end
end
local function saveAsPreset(_)
    local etrd = ""
    comp.beep(500, .05)
    repeat
        local _, _, char = require("event").pull("key_down")
        if char == 13 then break end
        if char == 8 then
            etrd = etrd:sub(1, #etrd - 1); comp.beep(650, .05)
        end
        if #etrd > 9 then
            comp.beep(1750, .05)
        else
            if string.char(char) then
                etrd = etrd .. string.char(char)
                comp.beep(750, .1)
            end
        end
    until not active
    local fh = io.open("/rbmk/presets.rbmk", "a")
    if fh then
        local nt = {}
        for _, v in pairs(lrh) do table.insert(nt, v[1]) end
        fh:write(serial.serialize({ etrd, nt }) .. '\n')
        fh:close()
        comp.beep(1000, .05)
    else
        comp.beep(1500, .05)
    end
    os.sleep(.1)
    checkPresets()
    popButtons()
end

buttonRegistry = {
    --[[
    {X_pos,Y_pos,backColor,foreColor,"text",function}
    ]]
    { resX - 5, 1,  0x3c3c3c, 0xffffff, "SAVE", saveAsPreset,                  nil },
    { resX,     1,  0xff0000, 0,        "X",    function() active = false end, nil },
    { 2,        4,  0xd2d2d2, 0,        "---",  textInput,                     "RED" },
    { 2,        6,  0xd2d2d2, 0,        "---",  textInput,                     "YELLOW" },
    { 2,        8,  0xd2d2d2, 0,        "---",  textInput,                     "GREEN" },
    { 2,        10, 0xd2d2d2, 0,        "---",  textInput,                     "BLUE" },
    { 2,        12, 0xd2d2d2, 0,        "---",  textInput,                     "PURPLE" },
    {resX-11,1,0xff7000,0,"SCRAM",function()setRods("RED",0);setRods("YELLOW",0);setRods("GREEN",0);setRods("BLUE",0);setRods("PURPLE",0);comp.beep(1800,.75);comp.beep(2000,1)end,nil}
}
function loadPreset(btn)
    for i, v in pairs(btn[7]) do
        setRods(controlRodRegistry[i][2], v)
        local ob=gpu.getBackground();local of=gpu.getForeground()
        gpu.setBackground(0xd2d2d2);gpu.setForeground(0)
        for _,x in pairs(buttonRegistry) do
            if x[6]==textInput and x[7]==controlRodRegistry[i][2] then
                gpu.set(x[1]+13,x[2],string.rep('0',3-#tostring(v))..tostring(v))
                break
            end
        end
        gpu.setBackground(ob);gpu.setForeground(of)
    end
end

for _, v in pairs(buttonRegistry) do
    for _, x in pairs(controlRodRegistry) do
        if x[2] == v[7] and x[1] == '' then
            v[6] = function() comp.beep(1500, .05) end; v[5] = "XXX"
        end
    end
end
function setRods(color, level)
    RoR.setCustomMap(true)
    for _, v in pairs(controlRodRegistry) do
        if v[2] == color then
            RoR.setChannel(v[1])
            RoR.setCustomMapValues({ "setrods!" .. tostring(level), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil })
            os.sleep()
            RoR.setPolling(true)
            local rhr
            for _, x in pairs(lrh) do
                if x[2] == color then
                    rhr = x; break
                end
            end
            local btn
            for _, x in pairs(buttonRegistry) do
                if x[7] == color then
                    btn = x; break
                end
            end
            threading.create(function()
                local lh = rhr[1]
                local ttm = math.abs(lh - level) * .18
                rhr[1] = level
                local ob = gpu.getBackground()
                local of = gpu.getForeground()
                gpu.setBackground(0xff0000)
                gpu.setForeground(0x909000)
                gpu.set(13, btn[2], '░')
                gpu.setBackground(ob); gpu.setForeground(of)
                os.sleep(ttm / 3)
                if not active then error() end
                ob = gpu.getBackground()
                of = gpu.getForeground()
                gpu.setBackground(0xff0000)
                gpu.setForeground(0xffff00)
                gpu.set(13, btn[2], '▒')
                gpu.setBackground(ob); gpu.setForeground(of)
                os.sleep(ttm / 3)
                if not active then error() end
                ob = gpu.getBackground()
                of = gpu.getForeground()
                gpu.setBackground(0xffff00)
                gpu.setForeground(0x90ff50)
                gpu.set(13, btn[2], '▓')
                gpu.setBackground(ob); gpu.setForeground(of)
                os.sleep(ttm / 3)
                if not active then error() end
                ob = gpu.getBackground()
                gpu.setBackground(0x00ff00)
                gpu.set(13, btn[2], ' ')
                gpu.setBackground(ob)
            end)
            os.sleep(.05)
            RoR.setPolling(false)
            break
        end
    end
end

gpu.setBackground(0xaaaaff)
gpu.fill(1, 1, resX, resY, ' ')
gpu.setBackground(0xffffff)
gpu.fill(1, 1, resX, 2, ' ')
gpu.setForeground(0)
gpu.set(1, 1, "RBMK WRECKER 2000")
gpu.setBackground(0xc3c3c3); gpu.fill(1, 3, 19, 11, ' '); gpu.set(2, 3, "SET  COLOR P  LPV")
checkPresets();os.sleep();popButtons()
gpu.setBackground(0xa5a5a5)
gpu.setForeground(0xff0000); gpu.set(buttonRegistry[3][1] + 4, buttonRegistry[3][2], "   RED")
gpu.setForeground(0xffff00); gpu.set(buttonRegistry[4][1] + 4, buttonRegistry[4][2], "YELLOW")
gpu.setForeground(0x00ff00); gpu.set(buttonRegistry[5][1] + 4, buttonRegistry[5][2], " GREEN")
gpu.setForeground(0x0000ff); gpu.set(buttonRegistry[6][1] + 4, buttonRegistry[6][2], "  BLUE")
gpu.setForeground(0xff00ff); gpu.set(buttonRegistry[7][1] + 4, buttonRegistry[7][2], "PURPLE")
gpu.setBackground(0xd2d2d2);gpu.setForeground(0)
gpu.set(buttonRegistry[3][1] + 13, buttonRegistry[3][2],"---");gpu.set(buttonRegistry[4][1] + 13, buttonRegistry[4][2],"---");gpu.set(buttonRegistry[5][1] + 13, buttonRegistry[5][2],"---");gpu.set(buttonRegistry[6][1] + 13, buttonRegistry[6][2],"---");gpu.set(buttonRegistry[7][1] + 13, buttonRegistry[7][2],"---")

local function updateColHeat()
    input.setChannel(dataRegistry[1][1])
    input.setCustomMap(false)
    os.sleep(.1)
    local of = gpu.getForeground()
    local ob = gpu.getBackground()
    gpu.setForeground(0)
    gpu.setBackground(0xaaaaaa)
    gpu.set(5, resY - 15, "COL HT.")
    for y = resY - 16, resY - 1 do
        if y % 2 == 0 then
            gpu.setBackground(0x5a5a5a)
        else
            gpu.setBackground(0x969696)
        end
        gpu.set(3, y, ' ')
    end
    gpu.setBackground(0xff9000)
    for h = 0, rednet.getInput(redInputSide) do
        gpu.set(3, resY - 1 - h, ' ')
    end
    gpu.setForeground(of)
    gpu.setBackground(ob)
end
local function updateFuelHeat()
    input.setChannel(dataRegistry[2][1])
    input.setCustomMap(false)
    os.sleep(.1)
    local of = gpu.getForeground()
    local ob = gpu.getBackground()
    gpu.setForeground(0)
    gpu.setBackground(0xaaaaaa)
    gpu.set(15, resY - 15, "FUEL HEAT")
    for y = resY - 16, resY - 1 do
        if y % 2 == 0 then
            gpu.setBackground(0x009000)
        else
            gpu.setBackground(0x006000)
        end
        gpu.set(13, y, ' ')
    end
    gpu.setBackground(0xff9000)
    for h = 0, rednet.getInput(redInputSide) do
        gpu.set(13, resY - 1 - h, ' ')
    end
    gpu.setForeground(of)
    gpu.setBackground(ob)
end
local function updateDepletion()
    input.setChannel(dataRegistry[3][1])
    input.setCustomMap(false)
    os.sleep(.1)
    local of = gpu.getForeground()
    local ob = gpu.getBackground()
    gpu.setForeground(0)
    gpu.setBackground(0xaaaaaa)
    gpu.set(27, resY - 15, "FUEL DPL.")
    for y = resY - 16, resY - 1 do
        if y % 2 == 0 then
            gpu.setBackground(0x009000)
        else
            gpu.setBackground(0x006000)
        end
        gpu.set(25, y, ' ')
    end
    gpu.setBackground(0x4b4b4b)
    for h = 0, rednet.getInput(redInputSide) do
        gpu.set(25, resY - 1 - h, ' ')
    end
    gpu.setForeground(of)
    gpu.setBackground(ob)
end
local function updateXenon()
    input.setChannel(dataRegistry[4][1])
    input.setCustomMap(false)
    os.sleep(.1)
    local of = gpu.getForeground()
    local ob = gpu.getBackground()
    gpu.setForeground(0)
    gpu.setBackground(0xaaaaaa)
    gpu.set(39, resY - 15, "Xe PSN")
    for y = resY - 16, resY - 1 do
        if y % 2 == 0 then
            gpu.setBackground(0xc3c3c3)
        else
            gpu.setBackground(0xb4b4b4)
        end
        gpu.set(37, y, ' ')
    end
    gpu.setBackground(0x700070)
    for h = 0, rednet.getInput(redInputSide) do
        gpu.set(37, resY - 1 - h, ' ')
    end
    gpu.setForeground(of)
    gpu.setBackground(ob)
end

input.setPolling(true)
threading.create(function()
    repeat
        updateColHeat(); if not active then break end
        os.sleep(.25)
        updateFuelHeat(); if not active then break end
        os.sleep(.25)
        updateDepletion(); if not active then break end
        os.sleep(.25)
        updateXenon(); if not active then break end
        os.sleep(.25)
    until not active
end)

repeat
    local _, _, x, y = require("event").pull("touch")
    for _, v in pairs(buttonRegistry) do
        if #v[5] > 1 then
            local xMatch = false
            for i = v[1], #v[5] + v[1] do
                if x == i then
                    xMatch = true; break
                end
            end
            if xMatch and v[2] == y then
                v[6](v)
                comp.beep(1250, .05)
                break
            end
        else
            if v[1] == x and v[2] == y then
                v[6](v)
                comp.beep(1250, .05)
                break
            end
        end
    end
until not active

active = false --must always be the last instruction
os.sleep(1)
gpu.setBackground(0)
gpu.setForeground(0xffffff)
term.clear()
gpu.setResolution(ox, oy)

-- TODO: turbine data
