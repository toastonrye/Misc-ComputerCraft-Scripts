--[[
toastonrye's AE2 Setpoint Controller

Developed with:
-Basalt UI: https://basalt.madefor.cc/#/
-minecraft-forge 1.19.2-43.1.47
-cc-tweaked-1.19.2-1.101.1.jar
-appliedenergistics2-forge-12.8.4.jar
-AdvancedPeripherals-0.7.21b.jar

v0.1 - 2022-11-06 - partially working proof of concept. YT:

bugs:
- when clicking off an input box, without entering a number leaves it blank. Can't figure out onLoseFocus event..
- many more

--]]
-- -------------------------------------------------------------------------------------------------------------------
local filePath = "basalt.lua"
if not(fs.exists(filePath))then
    shell.run("wget run https://basalt.madefor.cc/install.lua packed basalt.lua master")
end
-- -------------------------------------------------------------------------------------------------------------------
local basalt = require("basalt")

local me = peripheral.find("meBridge")
if not me then error("meBridge not found") end


-- meBridge peripheral, isItemCraftable table variable. Bug?: Only returns pattern item info if item amount >=1
local parsedData = {}

local w, h = term.getSize()
local mainF = basalt.createFrame():show():setBackground(colours.purple)
local pollF = mainF:addFrame("test"):setSize(w-2,h):setPosition(2,5):setBackground(colours.yellow)
local pollingProgress = mainF:addProgressbar():setPosition(1,4):setBackground(colours.white):setProgress(10)
-- -------------------------------------------------------------------------------------------------------------------
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

local function updateConfig(parsed)
	local f = fs.open("meBridge.txt", "w")
	f.write(textutils.serialize(parsed))
	f.close()
	basalt.debug("Updated!")
end

-- -------------------------------------------------------------------------------------------------------------------
local function loadInterface(parsed, frame) -- parsedData, pollF
	local items = {}
	local labelName = {}
	local labelAmount = {}
	local inputSetpoint = {}
	local w, h = frame:getSize()
	local tempParsed = parsed
	for i=1, #tempParsed do
		items[i] = frame:addFrame():setBackground(colours.cyan):setPosition(2,i*2):setSize(w-4,1)
		labelName = items[i]:addLabel():setText(tempParsed[i].name)
		labelAmount = items[i]:addLabel():setText(tempParsed[i].amount):setPosition(w*0.75, 1)
		inputSetpoint = items[i]:addInput():setInputType("number"):setValue(tempParsed[i].setpoint)
			:setPosition(w*0.8, 1):setBackground(colours.lightBlue)
			:onKey(function(self, event, key)
				if key == keys.enter or key == keys.numPadEnter then
					local t = self.getValue()
					if t == "" or t < 0 or t > 10000 then
						t = 0
						self:setValue(0)
					end
					tempParsed[i].setpoint = t
					updateConfig(tempParsed)
				end
			end)
			--[[:onLoseFocus(function(self)
				if key == keys.enter or key == keys.numPadEnter then
					local t = self.getValue()
					if t == "" or t < 0 or t > 10000 then
						t = 0
						self:setValue(0)
					end
					tempParsed[i].setpoint = t
					updateConfig(tempParsed)
				end
			end)--]]
			:onClick(function(self)
				self:setValue("")
			end)
			
	end
	
	--return items

end
-- -------------------------------------------------------------------------------------------------------------------
local function loadConfig()
	local cfg
	local f = fs.open("meBridge.txt", "r")
	if f ~= nil then -- if meBridge.txt exists, load it
		local data = f.readAll()
		f.close()
		cfg = textutils.unserialize(data)
	end
	return cfg
end

-- scans ae2 for craftable patterns and loads user setpoints if they exist or set to 1
-- quirk: redstone to pulse AE2 temporary inventory on/off because me.listCraftableItems doesn't find a pattern if there is 0 items...
local function scanCraftableItems(frame)
	local parsed = {} -- new table: name, amount, setpoint
	local config = loadConfig()
	local ae2Raw, loadedSetpoint
	
	--basalt.debug("Redstone On")
	redstone.setOutput("back", true)
	os.sleep(1)
	
	ae2Raw = me.listCraftableItems()
	
	for k, v in pairs(ae2Raw) do
		if config ~= nil then
			for k2, v2 in pairs(config) do
				if v.name == v2.name then
					loadedSetpoint = v2.setpoint
				end
			end
		end
		table.insert(parsed, {name = v.name, amount = v.amount, setpoint = loadedSetpoint or 1})
	end
	
	redstone.setOutput("back", false)
	--basalt.debug("Redstone Off")
	
	local f = fs.open("meBridge.txt", "w")
	f.write(textutils.serialize(parsed))
	f.close()
	basalt.debug("Saved Setpoints!")
	
	local interface = loadInterface(parsed, frame) -- parsedData and pollF
	
	return parsed
end


local function testCraft()
	basalt.debug("calling testCraft()")
	for k, v in pairs(parsedData) do
		if v.amount < v.setpoint then
			basalt.debug(v.amount, v.setpoint)
			me.craftItem(v)
			os.sleep(1)
		end
	end
end

local buttonRescan = mainF:addButton():onClick(basalt.schedule(function() parsedData = scanCraftableItems(pollF) end)):setSize(10,3):setPosition(1,1):setValue("Rescan")
fancyButton(buttonRescan)

local buttonTestCraft = mainF:addButton():onClick(basalt.schedule(function() testCraft() end)):setSize(10,3):setPosition(15,1):setValue("Test Craft")
fancyButton(buttonRescan)

local function myMain() -- why can this function see parsedData, shouldn't it be out of scope?
	while true do
		os.sleep(1)
		
		--[[for k, v in pairs(parsedData) do
			basalt.debug(k ,v.name, v.setpoint)
		end--]]
	
		
	end
end

parsedData = scanCraftableItems(pollF)

parallel.waitForAll(basalt.autoUpdate, myMain)
--basalt.schedule(function() basalt.debug("testting") os.sleep(1)end)
