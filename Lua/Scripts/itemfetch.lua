
local function fetchAllCustomItems()

    local itemsfound = {
        mb_inertiainhibitor={},
        mb_omniengine={},
        blankloader={},
        coilgunloader={},
        pulselaserloader={},
        chaingunloader={},
        depthchargeloader={},
        railgunloadersmall={},
        flakcannonloader={},
        mb_startupcomponent={},
    }
    MannaBuildables.omniEngines = {}
    MannaBuildables.inhibitors = {}
    MannaBuildables.turretloaders = {}

    for item in Item.ItemList do
        for identifier,itemtable in pairs(itemsfound) do
            if identifier == item.Prefab.Identifier.Value then
                table.insert(itemtable,item)
                break
            end
        end 
    end

    for item in itemsfound.mb_omniengine do MannaBuildables.omniEngines[item] = item end
    for item in itemsfound.mb_inertiainhibitor do MannaBuildables.inhibitors[item] = item end
    for item in itemsfound.mb_startupcomponent do item.SendSignal("1", "roundstart_out") end

    for item in itemsfound.blankloader do MannaBuildables.turretloaders[#MannaBuildables.turretloaders+1] = item end
    for item in itemsfound.coilgunloader do MannaBuildables.turretloaders[#MannaBuildables.turretloaders+1] = item end
    for item in itemsfound.pulselaserloader do MannaBuildables.turretloaders[#MannaBuildables.turretloaders+1] = item end
    for item in itemsfound.chaingunloader do MannaBuildables.turretloaders[#MannaBuildables.turretloaders+1] = item end
    for item in itemsfound.depthchargeloader do MannaBuildables.turretloaders[#MannaBuildables.turretloaders+1] = item end
    for item in itemsfound.railgunloadersmall do MannaBuildables.turretloaders[#MannaBuildables.turretloaders+1] = item end
    for item in itemsfound.flakcannonloader do MannaBuildables.turretloaders[#MannaBuildables.turretloaders+1] = item end
end

Hook.Add("roundStart", "Mannabuildables.RoundStart", function()
    fetchAllCustomItems()
end)

fetchAllCustomItems()