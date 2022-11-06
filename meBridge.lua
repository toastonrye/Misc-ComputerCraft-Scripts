local filePath = "basalt.lua"
if not(fs.exists(filePath))then
    shell.run("wget run https://basalt.madefor.cc/install.lua packed basalt.lua master")
end
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
local basalt = require("basalt")

local me = peripheral.find("meBridge")
if not me then error("meBridge not found") end

local pollCraftable = false
local tPatterns = {}

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
	redstone.setOutput("back", true)
	local raw
	local parsed = {}
	os.sleep(1)
	raw = me.listCraftableItems()
	for k, v in pairs(raw) do
		table.insert(parsed, {name = v.name, amount = v.amount, setpoint = 1})
	end
	redstone.setOutput("back", false)
	basalt.debug("Redstone Off")
	return parsed
end

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
	local load = textutils.unserialize(f.readAll())
	f.close()
	basalt.debug("COMPARISON")
	local m = false
	if not load then
		load = p
	else
		for k, v in pairs(p) do
			if v.name == load[k].name and not m then
				--basalt.debug(v.name .. " = " .. load[k].name)
				m = true
			end
			if not m then
				table.insert(load, v)
				basalt.debug("Adding " .. v.name .. " | " .. v.amount .. " | " .. v.setpoint)
			end
			m = false
		end
	end
	local f = fs.open("meBridge.txt", "w")
	f.write(textutils.serialize(load))
	f.close()
	basalt.debug("Appended!")
end

local function loadMe()
	local f = fs.open("meBridge.txt", "r")
	local d = f.readAll()
	f.close()
	local p = textutils.unserialize(d)
	--table.remove(p, 2)
	
	if not p then
		return -- Does this return have the potential to break parallel.waiteForAll ???
	end
	for k, v in pairs(p) do
		basalt.debug(k, v.name, v.amount)
	end
end


local buttonPolling = mainF:addButton():onClick(basalt.schedule(function() tPatterns = pollPatterns() end)):setSize(10,3):setPosition(1,1):setValue("Poll AE2")
local buttonSave = mainF:addButton():onClick(function() saveMe(tPatterns) end):setSize(10,3):setPosition(12,1):setValue("Save")
local buttonAppend = mainF:addButton():onClick(function() appendMe(tPatterns) end):setSize(10,3):setPosition(36,1):setValue("Append")
local buttonLoad = mainF:addButton():onClick(loadMe):setSize(10,3):setPosition(23,1):setValue("Load")
fancyButton(buttonPolling)
fancyButton(buttonSave)
fancyButton(buttonLoad)
fancyButton(buttonAppend)

local function myMain()
	while true do
		os.sleep(1)
	end
end
	
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--basalt.debug("Hi")
parallel.waitForAll(basalt.autoUpdate, myMain)
