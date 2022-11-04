local filePath = "basalt"
if not(fs.exists(filePath))then
    shell.run("wget run https://basalt.madefor.cc/install.lua packed basalt.lua master")
end
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
local basalt = require(filePath)

local function fancyButton(button)
    button:onClick(function(self)
        button:setBackground(colours.black)
        button:setForeground(colours.lightGrey)
    end)
    button:onClickUp(function(self)
        button:setBackground(colours.grey)
        button:setForeground(colours.black)
    end)
    button:onLoseFocus(function(self)
        button:setBackground(olours.grey)
        button:setForeground(colours.black)
    end)
end

fancyButton(mainF:addButton("testButton"):setPosition(3,2):setValue("test button")

local me = peripheral.find("meBridge")
if not me then error("meBridge not found") end

patterns = me.listCraftableItems()

for k, items in pairs(patterns) do
 print(items.name, items.amount)
end

local mainF = basalt.createFrame("mainF")
    :show()
    :setBackground(colours.purple)

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
basalt.debug("Hi")
basalt.autoUpdate()
