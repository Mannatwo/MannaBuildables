-- engine
MannaBuildables.omniEngines = {}
MannaBuildables.signalReceivedMethods.mb_omniengine = function(signal,connection)

    -- register engine
    if MannaBuildables.omniEngines[connection.Item] == nil then
        MannaBuildables.omniEngines[connection.Item] = connection.Item
    end

    if connection.Name == "vel_x" then
        local memComponents = MannaBuildables.HF.EnumerableToTable(connection.Item.GetComponents(Components.MemoryComponent))
        if memComponents[1] ~= nil then
            memComponents[1].Value = signal.value
        end
    elseif connection.Name == "vel_y" then
        local memComponents = MannaBuildables.HF.EnumerableToTable(connection.Item.GetComponents(Components.MemoryComponent))
        if memComponents[2] ~= nil then
            memComponents[2].Value = signal.value
        end
    end
end

Hook.Add("think", "mb_omniengine", function ()
    if MannaBuildables.HF.GameIsPaused() then return end

    for item in MannaBuildables.omniEngines do
        if item ~= nil and item.Submarine ~= nil then
            
            local memComponents = MannaBuildables.HF.EnumerableToTable(item.GetComponents(Components.MemoryComponent))
            local PoweredComponent = item.GetComponent(Components.Powered)

            local maxForce = math.max(tonumber(memComponents[3].Value) or 2000,0)
            local powerConsumption = math.max(tonumber(memComponents[4].Value) or 4000,0)

            local forceX = MannaBuildables.HF.Clamp(tonumber(memComponents[1].Value) or 0,-100,100)
            local forceY = MannaBuildables.HF.Clamp(-(tonumber(memComponents[2].Value) or 0),-100,100)

            PoweredComponent.PowerConsumption = (math.abs(forceX)+math.abs(forceY)) / 200 * powerConsumption;
            PoweredComponent.IsActive = true
            
            local Voltage = PoweredComponent.Voltage
            local MinVoltage = 0.5

            if (Voltage < MinVoltage) then forceX = 0 forceY = 0 end

            if (math.abs(forceX) > 1 or math.abs(forceY) > 1) then
            
                local voltageFactor = math.min(Voltage, 1)
                if MinVoltage <= 0 then voltageFactor= 1 end

                local currForceX = forceX * voltageFactor
                local currForceY = forceY * voltageFactor

                -- arbitrary multiplier that was added to changes in submarine mass without having to readjust all engines
                local forceMultiplier = 0.1

                currForceX = currForceX * maxForce * forceMultiplier
                currForceY = currForceY * maxForce * forceMultiplier

                if (item.Submarine.FlippedX) then currForceX = -currForceX end
                local forceVector = Vector2(currForceX, currForceY)
                item.Submarine.ApplyForce(forceVector)

            end
        end
    end
end)
