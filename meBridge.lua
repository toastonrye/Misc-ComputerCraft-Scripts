-- -------------------------------------------------------------------------------------------------------------------
local filePath = "basalt.lua"
if not(fs.exists(filePath))then
    shell.run("wget run https://basalt.madefor.cc/install.lua packed basalt.lua master")
end
-- -------------------------------------------------------------------------------------------------------------------
local basalt = require("basalt")

local me = peripheral.find("meBridge")
if not me then error("meBridge not found") end

-- meBridge peripheral, isItemCraftable table variable. Bug: Only returns if item amount >=1 ?
local parsedData = {}

local w, h = term.getSize()
local mainF = basalt.createFrame():show():setBackground(colours.purple)
local pollF = mainF:addFrame("test"):setSize(w-2,h):setPosition(2,5):setBackground(colours.yellow)
--local itemF = pollF.addFrame():setSize(w-4,1):setPosition(2,2):setBackground(colours.red)
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
local function loadInterface(parsed, frame)
	local items = {}
	local labelName = {}
	local labelAmount = {}
	local inputSetpoint = {}
	local w, h = frame:getSize() -- of pollF frame
	local tempParsed = parsed
	basalt.debug(w, h)
	for i=1, #tempParsed do
		--basalt.debug(i)
		--basalt.debug("loadInterface " .. k, v.name, v.setpoint)
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
			:onClick(function(self)
				self:setValue("")
			end)
			
	end
	
	

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

-- scans ae2 and loads user setpoints if they exist or sets to 1
-- need to explain why the redstone pulse
local function scanCraftableItems(frame)
	local parsed = {} -- new table to hold name, amount, setpoint
	local config = loadConfig() -- load any existing user setpoints, or set to 1
	local ae2Raw, loadedSetpoint
	
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
	basalt.debug("Redstone Off")
	
	local f = fs.open("meBridge.txt", "w")
	f.write(textutils.serialize(parsed))
	f.close()
	basalt.debug("Saved!")
	
	local interface = loadInterface(parsed, frame) -- pass the data and frame to draw it on
	
	return parsed
end

local buttonRescan = mainF:addButton():onClick(basalt.schedule(function() parsedData = scanCraftableItems(pollF) end)):setSize(10,3):setPosition(1,1):setValue("Rescan")
fancyButton(buttonRescan)

local function myMain()
	while true do
		os.sleep(1)
	end
end

parsedData = scanCraftableItems(pollF) -- try to read meBridge.txt if it exists, if not call scanCraftableItems() function
-- -------------------------------------------------------------------------------------------------------------------
--basalt.debug("Hi")
parallel.waitForAll(basalt.autoUpdate, myMain)

--[[

for k,v in pairs(p) do
	basalt.debug("init " .. k, v.name, v.setpoint)
end

local buttonAppend = mainF:addButton():onClick(function() appendMe(ae2RawData) end):setSize(10,3):setPosition(36,1):setValue("Append")
fancyButton(buttonAppend)

local buttonSave = mainF:addButton():onClick(function() saveMe(ae2RawData) end):setSize(10,3):setPosition(12,1):setValue("Save")
fancyButton(buttonSave)

local function saveMe(p)
	for k, v in pairs(p) do
		--p[k].setpoint = 32
	end
	

	local f = fs.open("meBridge.txt", "w")
	f.write(textutils.serialize(p))
	f.close()
	basalt.debug("Saved!")
end

local function appendMe(p)
	local f = fs.open("meBridge.txt", "r")
	local d = f.readAll()
	f.close()
	local load = textutils.unserialize(d)
	
	local m = false
	if load == nil then -- if meBridge empty/non-existent, set it to recent polling data
		load = p
	else -- if file not empty, try to append missing keys
		for k, v in pairs(p) do
			for k2, v2 in pairs(load) do
				if v.name == v2.name and not m then
					--basalt.debug(v.name .. " = " .. load[k].name)
					m = true
				end
				if not m then
					table.insert(load, v) -- THE PROBLEM??
					basalt.debug("Adding " .. v.name .. " | " .. v.amount .. " | " .. v.setpoint)
				end
				m = false
			end
		end
	end
	
	local f = fs.open("meBridge.txt", "w") -- do not append, values inserted into "load"
	f.write(textutils.serialize(load))
	--f.write(load)
	f.close()
	basalt.debug("Appended!")
end
--]]
