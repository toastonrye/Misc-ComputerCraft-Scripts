local filePath = "basalt.lua"
if not(fs.exists(filePath))then
    shell.run("wget run https://basalt.madefor.cc/install.lua packed basalt.lua master")
end
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
local basalt = require("basalt")

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

local me = peripheral.find("meBridge")
if not me then error("meBridge not found") end

patterns = me.listCraftableItems()

for k, items in pairs(patterns) do
 print(items.name, items.amount)
end

local mainF = basalt.createFrame("mainF")
    :show()
    :setBackground(colours.purple)

fancyButton(mainF:addButton("redstoneOn"):setPosition(3,2):setValue("Redstone On")
    :onClick(function()
        redstone.setOutput("back", true)
        basalt.debug("Redstone On") 
    end))
fancyButton(mainF:addButton("redstoneOff"):setPosition(6,2):setValue("Redstone Off")
    :onClick(function()
        redstone.setOutput("back", false)
        basalt.debug("Redstone Off") 
    end))

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
basalt.debug("Hi")
basalt.autoUpdate()
