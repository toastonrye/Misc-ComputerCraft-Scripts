local filePath = "basalt.lua"
if not(fs.exists(filePath))then
    shell.run("wget run https://basalt.madefor.cc/install.lua packed basalt.lua master")
end

local me = peripheral.find("meBridge")
if not me then error("meBridge not found") end

patterns = me.listCraftableItems()

for k, items in pairs(patterns) do
 print(items.name, items.amount)
end
