
MannaBuildables = {} -- Manna Buildables
MannaBuildables.Path = table.pack(...)[1]

-- server-side code (also run in singleplayer)
-- clients dont need this to synchronize, so we dont want to run it in that case
if (Game.IsMultiplayer and SERVER) or not Game.IsMultiplayer then

    dofile(MannaBuildables.Path.."/Lua/Scripts/HF.lua")
    dofile(MannaBuildables.Path.."/Lua/Scripts/signalitems.lua")
    dofile(MannaBuildables.Path.."/Lua/Scripts/loaders.lua")
    dofile(MannaBuildables.Path.."/Lua/Scripts/itemfetch.lua")

    dofile(MannaBuildables.Path.."/Lua/Scripts/omniengine.lua")
    dofile(MannaBuildables.Path.."/Lua/Scripts/inertiainhibitor.lua")

end

-- client-side code
if CLIENT then

end