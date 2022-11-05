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
	local p, temp
	os.sleep(1)
	p = me.listCraftableItems()
	local c, r = 2, 1
	for k, items in pairs(p) do
		--basalt.debug(k, items)
		--p[k] = pollF:addLabel():setSize(26,1):setPosition(c,r+k):setValue(items.name .. " | " .. items.amount):setBackground(colours.cyan)
		--table.insert(masterTable, {name = items.name, amount = items.amount, setpoint = 2})
	end
	redstone.setOutput("back", false)
	basalt.debug("Redstone Off")
	return p
end

local function saveMe(p)
	for k, v in pairs(p) do
		p[k].setpoint = 32
	end
	

	local f = fs.open("testy", "w")
	f.write(textutils.serialize(p))
	f.close()
	basalt.debug("Saved!")
end

local function appendMe(p)
	local f = fs.open("testy", "r")
	local load = textutils.unserialize(f.readAll())
	f.close()
	basalt.debug("COMPARISON")
	for k, v in pairs(load) do
		for k2, v2 in pairs(p) do
			if v2.name == v.name then
				basalt.debug("match found " .. v.name)
				break
			else
				basalt.debug("does not exist " .. v.name)
			end
		end
	end
	--local f = fs.open("testy", "a")
	--f.write(textutils.serialize(p))
	--f.close()
end

local function loadMe()
	local f = fs.open("testy", "r")
	local d = f.readAll()
	f.close()
	local p = textutils.unserialize(d)
	table.remove(p, 2)
	
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
