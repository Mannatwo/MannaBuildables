
MannaBuildables.signalReceivedMethods = {}
MannaBuildables.signalProcessingMethods = {}
MannaBuildables.signalCache = {}

MannaBuildables.addSignalToCache = function(signal, connection)
    -- create empty data for the item if not present
    if MannaBuildables.signalCache[connection.Item] == nil then MannaBuildables.signalCache[connection.Item] = {} end

    MannaBuildables.signalCache[connection.Item][connection.Name] = signal.value

    -- lets just hope i am not dumb enough to call one of the connections "Dirty"
    MannaBuildables.signalCache[connection.Item].Dirty = true
end


-- signal received hook
Hook.Add("signalReceived", "mb_signalReceived", function (signal, connection)
    local m = MannaBuildables.signalReceivedMethods[connection.Item.Prefab.Identifier.Value]
    if m then m(signal, connection) end
end)

-- signal processing
-- required for components with >1 input
Hook.Add("think", "mb_signalProcessing", function ()
    for item, data in pairs(MannaBuildables.signalCache) do
        if data.Dirty then
            local m = MannaBuildables.signalProcessingMethods[item.Prefab.Identifier.Value]
            if m then m(item,data) end
            data.Dirty = false
        end
    end
end)

-- max
MannaBuildables.signalReceivedMethods.mb_maxcomponent = MannaBuildables.addSignalToCache
MannaBuildables.signalProcessingMethods.mb_maxcomponent = function(item,data)
    local arg1 = tonumber(data.signal_in1)
    local arg2 = tonumber(data.signal_in2)
    if arg1==nil or arg2==nil then return end

    item.SendSignal(tostring(math.max(arg1,arg2)), "signal_out")
end

-- min
MannaBuildables.signalReceivedMethods.mb_mincomponent = MannaBuildables.addSignalToCache
MannaBuildables.signalProcessingMethods.mb_mincomponent = function(item,data)
    local arg1 = tonumber(data.signal_in1)
    local arg2 = tonumber(data.signal_in2)
    if arg1==nil or arg2==nil then return end

    item.SendSignal(tostring(math.min(arg1,arg2)), "signal_out")
end

-- contains
MannaBuildables.signalReceivedMethods.mb_containscomponent = MannaBuildables.addSignalToCache
MannaBuildables.signalProcessingMethods.mb_containscomponent = function(item,data)
    local arg1 = data.signal_in1
    local arg2 = data.signal_in2
    if arg1==nil or arg2==nil then return end

    item.SendSignal(tostring(MannaBuildables.HF.BoolToNum(MannaBuildables.HF.StringContains(arg1,arg2))), "signal_out")
end

-- starts with
MannaBuildables.signalReceivedMethods.mb_startswithcomponent = MannaBuildables.addSignalToCache
MannaBuildables.signalProcessingMethods.mb_startswithcomponent = function(item,data)
    local arg1 = data.signal_in1
    local arg2 = data.signal_in2
    if arg1==nil or arg2==nil then return end

    item.SendSignal(tostring(MannaBuildables.HF.BoolToNum(MannaBuildables.HF.StartsWith(arg1,arg2))), "signal_out")
end

-- ends with
MannaBuildables.signalReceivedMethods.mb_endswithcomponent = MannaBuildables.addSignalToCache
MannaBuildables.signalProcessingMethods.mb_endswithcomponent = function(item,data)
    local arg1 = data.signal_in1
    local arg2 = data.signal_in2
    if arg1==nil or arg2==nil then return end

    item.SendSignal(tostring(MannaBuildables.HF.BoolToNum(MannaBuildables.HF.EndsWith(arg1,arg2))), "signal_out")
end

-- repeat
MannaBuildables.signalReceivedMethods.mb_repeatcomponent = MannaBuildables.addSignalToCache
MannaBuildables.signalProcessingMethods.mb_repeatcomponent = function(item,data)
    local arg1 = data.signal_in1
    local arg2 = tonumber(data.signal_in2)
    if arg1==nil or arg2==nil then return end
    local res = ""
    if arg1~="" then
        while arg2 > 0 and string.len(res) < 255 do
            res=res..arg1
            arg2 = arg2-1
        end
    end

    item.SendSignal(res, "signal_out")
end

-- water
Hook.Add("mb_watercomponent", "mb_watercomponent", function (effect, deltaTime, item, targets, worldPosition)

    if item == nil or item.Submarine == nil or item.Submarine.SubBody == nil then return 0 end
    local submarine = item.Submarine.SubBody
    local waterVolume = 0
    local volume = 0
    for hull in Hull.HullList do
        if hull.Submarine == item.Submarine then
            waterVolume = waterVolume+hull.WaterVolume
            volume = volume+hull.Volume
        end
    end

    local waterPercentage = 0
    if volume > 0 then waterPercentage = waterVolume / volume end
    
    local buoyancy = 0.07 - waterPercentage

    if buoyancy > 0 then
        buoyancy = buoyancy*2
    else
        buoyancy = math.max(buoyancy, -0.5)
    end
    --print(tostring(waterVolume).."|"..tostring(volume).."|"..tostring(waterPercentage).."|"..tostring(buoyancy))
    local buoyancyForce = buoyancy * submarine.Body.Mass * 10

    item.SendSignal(tostring(MannaBuildables.HF.Round(buoyancyForce)), "buoyancy_out")
    item.SendSignal(tostring(MannaBuildables.HF.Round(waterPercentage*100)), "waterpercent_out")
end)

-- length
MannaBuildables.signalReceivedMethods.mb_lengthcomponent = function(signal, connection)
    if signal.value == nil then return end
    connection.Item.SendSignal(tostring(string.len(signal.value)), "signal_out")
end

-- reactor
MannaBuildables.signalReceivedMethods.mb_reactorcomponent = MannaBuildables.addSignalToCache
MannaBuildables.signalProcessingMethods.mb_reactorcomponent = function(item,data)
    local in_temp = tonumber(data.in_temp)
    local in_power = tonumber(data.in_power)
    local in_load = tonumber(data.in_load)
    local in_maxoutput = tonumber(data.in_maxoutput)
    if in_temp==nil or in_power==nil or in_load==nil or in_maxoutput==nil then return end

    local fission = 0
    local turbine = 0

    -- we've got load, lets get this reactor started!
    if in_load > 5 then
        if in_temp < 5000 then fission = 100 end -- keep the reactor at a steady 5k temperature
        turbine =
            (in_load/in_maxoutput
            -(math.max(0,in_power/in_load-1)) -- reduce turbine output if theres more power than load
            )*100

        if in_power < turbine/100*in_maxoutput then -- adjusting turbine output up
            -- exaggerate requested turbine output so it reaches it faster
            local requestedQuotient = in_power/(turbine/100*in_maxoutput)
            turbine=turbine+(1-requestedQuotient)*1000
        end
    end

    item.SendSignal(fission, "out_fission")
    item.SendSignal(turbine, "out_turbine")
end