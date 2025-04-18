local minFuelLevel = 300
local maintenance = { refuel = false, fullInventory = false, stop = false }

local function handleFuel()
    while turtle.getFuelLevel() < minFuelLevel do
        print("low fuel")
        turtle.select(1)
        turtle.refuel()
    end
    maintenance.refuel = false
end

local function handleInventory()
    for i = 1, 16 do
        turtle.select(i)
        turtle.drop()
    end
    maintenance.fullInventory = false
end

local function handleMaintenance(currentIteration)
    if maintenance.refuel or maintenance.fullInventory then
        if currentIteration ~= i then
            for i = 1, currentIteration - 1 do
                turtle.up()
            end
        end
        turtle.turnRight()
        turtle.turnRight()
        if maintenance.refuel then
            handleFuel()
        end
        if maintenance.fullInventory then
            handleInventory()
        end
        for i = 1, currentIteration - 1 do
            turtle.digDown()
            turtle.down()
        end
        turtle.turnLeft()
        turtle.turnLeft()
    end
end

local function checkFuel()
    if turtle.getFuelLevel() < minFuelLevel then
        for i = 1, 16 do
            turtle.select(i)
            turtle.refuel()
        end
        if turtle.getFuelLevel() > minFuelLevel then
            print("self refueled")
            return
        end
        maintenance.refuel = true
    end
    maintenance.refuel = false
end

local function checkInventory()
    for i = 1, 16 do
        turtle.select(i)
        if turtle.getItemCount() == 0 then
            maintenance.fullInventory = false
            return
        end
    end
    maintenance.fullInventory = true
end

local function layerReset(width, length)
    if width % 2 == 0 then
        turtle.turnRight()
        for i = 1, width - 1 do
            turtle.forward()
        end
        turtle.turnRight()
    else
        turtle.turnLeft()
        for i = 1, width - 1 do
            turtle.forward()
        end
        turtle.turnLeft()
        for i = 1, length - 1 do
            turtle.forward()
        end
        turtle.turnRight()
        turtle.turnRight()
    end
end

local function mineLayer(width, length)
    for i = 1, width do
        for j = 1, length do
            turtle.digDown()
            if j ~= length then
                turtle.dig()
                turtle.forward()
            end
        end
        if i ~= width then
            if i % 2 == 0 then
                turtle.turnLeft()
                turtle.dig()
                turtle.forward()
                turtle.turnLeft()
            else
                turtle.turnRight()
                turtle.dig()
                turtle.forward()
                turtle.turnRight()
            end
        end
    end
    layerReset(width, length)
end

local function checkStop()
    rednet.open("left")
    while true do
        local command, content = rednet.receive()
        if command == "stop" then
            print("stopping after current iteration...")
            maintenance.stop = true
            rednet.close("left")
            return
        end
    end
end

local function mine(width, length, depth, initPadding)
    for i = 1, initPadding do
        turtle.digDown()
        turtle.down()
    end
    for i = 1 + initPadding, depth do
        if maintenance.stop then
            print("Stopped")
            return
        end
        checkFuel()
        checkInventory()
        handleMaintenance(i)
        mineLayer(width, length)
        turtle.down()
    end
    for i = 1, depth do
        turtle.up()
    end
end

parallel.waitForAny(function() mine(12, 12, 64, 0) end, checkStop)
