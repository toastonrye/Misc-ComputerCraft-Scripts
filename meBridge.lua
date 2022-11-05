local filePath = "basalt.lua"
if not(fs.exists(filePath))then
    shell.run("wget run https://basalt.madefor.cc/install.lua packed basalt.lua master")
end
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
local basalt = require("basalt")

local me = peripheral.find("meBridge")
if not me then error("meBridge not found") end

local pollCraftable = false
masterTable = {}

local w, h = term.getSize()
local mainF = basalt.createFrame():show():setBackground(colours.purple)
local pollF = mainF.addFrame():setSize(w-2,h):setPosition(2,5):setBackground(colours.yellow)

local function fancyButton(self, event, button, x, y)
    self:onClick(function()
        self:setBackground(colours.black)
        self:setForeground(colours.lightGrey)
    end)
    self:onClickUp(function()
        self:setBackground(colours.grey)
        self:setForeground(colours.black)
    end)
    self:onLoseFocus(function()
        self:setBackground(colours.grey)
        self:setForeground(colours.black)
    end)
end

local function pollPatterns()
	basalt.debug("in pollPatterns")
	redstone.setOutput("back", true)
	os.sleep(2)
	local patterns = me.listCraftableItems()
	local p = {}
	local c, r = 2, 1
	for k, items in pairs(patterns) do
		basalt.debug(items.name, items.amount)
		p[k] = pollF:addLabel():setSize(26,1):setPosition(c,r+k):setValue(items.name .. " | " .. items.amount):setBackground(colours.cyan)
		table.insert(masterTable, k, {name = items.name, amount = items.amount, setpoint = 0})
	end
	redstone.setOutput("back", false)
end

local function printMe()
	basalt.debug("in printDebug")
	for k, v in pairs(masterTable) do
		for k2, v2 in pairs(v) do
			basalt.debug(k2, v2)
		end
	end
	
	local f = fs.open("testy", "w")
	f.write(textutils.serialize(masterTable))
	f.close()
end

local function loadMe()
	local f = fs.open("testy", "r")
	local d = f.readAll()
	f.close()
	masterTable = textutils.unserialize(d)
	
	for k, v in pairs(masterTable) do
		basalt.debug(v.name, v.amount, v.setpoint)
	end
end


local buttonPolling = mainF:addButton():onClick(pollPatterns):setSize(10,3):setPosition(1,1):setValue("Poll AE2")
local buttonSave = mainF:addButton():onClick(printMe):setSize(10,3):setPosition(12,1):setValue("Save")
local buttonLoad = mainF:addButton():onClick(loadMe):setSize(10,3):setPosition(23,1):setValue("Load")
fancyButton(buttonPolling)
fancyButton(buttonSave)
fancyButton(buttonLoad)

local function myMain()
	while true do
		os.sleep(1)
	end
end
	
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--basalt.debug("Hi")
parallel.waitForAll(basalt.autoUpdate(), myMain())
