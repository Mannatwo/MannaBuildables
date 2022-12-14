-- turret loaders
MannaBuildables.turretloaders = {}
MannaBuildables.TurretLoaderUpdate = {}

MannaBuildables.TurretLoaderUpdate.blankloader = function(item)
    item.SendSignal("0", "ammo_out")
end
MannaBuildables.TurretLoaderUpdate.coilgunloader = function(item)
    local amount = 0
    local containedItem = item.OwnInventory.GetItemAt(0)
    if containedItem~=nil then amount=containedItem.Condition end
    item.SendSignal(tostring(MannaBuildables.HF.Round(amount)), "ammo_out")
end
MannaBuildables.TurretLoaderUpdate.pulselaserloader = MannaBuildables.TurretLoaderUpdate.coilgunloader
MannaBuildables.TurretLoaderUpdate.chaingunloader = MannaBuildables.TurretLoaderUpdate.coilgunloader
MannaBuildables.TurretLoaderUpdate.flakcannonloader = MannaBuildables.TurretLoaderUpdate.coilgunloader

MannaBuildables.TurretLoaderUpdate.railgunloadersmall = function(item)
    local amount = 0
    local allitems = item.OwnInventory.AllItems
    for item in allitems do amount = amount+1 end
    item.SendSignal(tostring(amount), "ammo_out")
end

MannaBuildables.TurretLoaderUpdate.depthchargeloader = function(item)
    local amount = 0
    if item.OwnInventory.GetItemAt(0)~=nil then amount=1 end
    item.SendSignal(tostring(amount), "ammo_out")
end

-- signal processing
-- required for components with >1 input
Hook.Add("think", "mb_turretsignals", function ()
    for item in MannaBuildables.turretloaders do
        if MannaBuildables.TurretLoaderUpdate[item.Prefab.Identifier.Value] ~= nil then
            MannaBuildables.TurretLoaderUpdate[item.Prefab.Identifier.Value](item) end
    end
end)