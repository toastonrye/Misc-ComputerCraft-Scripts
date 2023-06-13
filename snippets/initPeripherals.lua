-- Made in 1.19.2 CC:Tweaked - Things may break or change
--[[
    This example script has two main objectives
    1. to demonstrate the use of parallel.waitforAll
        a. the main() loop yields at os.sleep()
        b. the other functions yield at os.pullEvent()
    2. to demonstrate automatically detecting new/removed peripherals

    Bonus objective: To remind myself, I seem to always forget...
]]

local tlib = require("toastonryeLib")

local detectedPeripherals -- global?
local count = 0

local function initPeripherals()
    detectedPeripherals = {} -- clear table
    shell.run("clear")
    print("Initializing list of detected peripherals:")

    for k, v in pairs(peripheral.getNames()) do
        detectedPeripherals[k] = {side = v, type = peripheral.getType(v)}
    end
    if not detectedPeripherals[1] then
        print("No peripherals detected! :(")
    end
    
    tlib.printPeripherals(detectedPeripherals)
    count = count + 1
end

local function peripheralAdd()
    while true do 
        local pAdd = {os.pullEvent("peripheral")}
        initPeripherals()
    end
end

local function peripheralRemove()
    while true do
        local pRemove = {os.pullEvent("peripheral_detach")}
        initPeripherals()
    end
end

local function main()
    initPeripherals() -- this only runs once
    print()
    print("initPeripherals() only runs once at startup: " .. count) -- proof 
    while true do -- this is the main loop
        for k, v in pairs(detectedPeripherals) do
            if v.type == "minecraft:chest" then
                print("There is a chest on the " .. v.side)
            end
        end
        os.sleep(2)
    end
end



parallel.waitForAll(peripheralAdd, peripheralRemove, main)
