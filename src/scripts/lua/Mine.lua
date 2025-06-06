local minFuelLevel = 400
local maintenance = { refuel = false, fullInventory = false, stop = false }
local section = 1

local function handleFuel()
    turtle.select(1)
    turtle.drop()
    turtle.select(2)
    turtle.drop()

    turtle.up()

    turtle.select(1)
    turtle.suck()
    turtle.refuel()
    turtle.select(2)
    turtle.refuel()
    turtle.select(1) --reset select just in case
    while turtle.getFuelLevel() < minFuelLevel do
        print("low fuel")
        turtle.select(1)
        turtle.refuel()
    end
    maintenance.refuel = false
    turtle.down()
end

local function handleInventory()
    for i = 1, 16 do
        turtle.select(i)
        turtle.drop()
    end
    maintenance.fullInventory = false
end

local function handleMaintenance(currentIteration, width)
    if maintenance.refuel or maintenance.fullInventory then
        if currentIteration ~= i then
            for i = 1, currentIteration - 1 do
                turtle.up()
            end
        end
        turtle.turnRight()
        turtle.turnRight()
        for i = 1, (section - 1) * width do
            turtle.forward()
        end
        if maintenance.refuel then
            handleFuel()
        end
        if maintenance.fullInventory then
            handleInventory()
        end
        for i = 1, (section - 1) * width do
            turtle.back()
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
        local sendId, request = rednet.receive()
        if request.command == "stop" then
            print("stopping after current iteration...")
            maintenance.stop = true
            rednet.close("left")
            return
        end
    end
end

local function mine(width, length, depth, initPadding, sectionBegin, sectionMax)
    section = sectionBegin
    minFuelLevel = minFuelLevel * sectionMax + 64
    for i = 1, width * (section - 1) do
        if section ~= 1 then
            turtle.dig()
            turtle.forward()
        end
    end
    for i = 1, initPadding do
        turtle.digDown()
        turtle.down()
    end
    --for each section do... 
    for k = 1, sectionMax do
        --for the padding + depth do...
        modifiedDepth = 1 + initPadding
        if k ~= 1 then
            modifiedDepth = 1
        end
        for i = modifiedDepth, depth do
            if maintenance.stop then
                for j = 1, i + initPadding - 1 do
                    turtle.up()
                end
                for j = 1, width * (section - 1) do
                    if section ~= 1 then
                        turtle.back()
                    end
                end
                print("Stopped")
                return
            end
            checkFuel()
            checkInventory()
            handleMaintenance(i, width)
            mineLayer(width, length)
            turtle.down()
        end
        for i = 1, depth do
            turtle.up()
        end
        section = section + 1
        if k ~= sectionMax then
            for i = 1, width do
                turtle.dig()
                turtle.forward()
            end
        end
    end
    for j = 1, width * (section - 2) do
        if section ~= 1 then
            turtle.back()
        end
    end
end

parallel.waitForAll(function() mine(12, 12, 64, 0, 1, 2) end, checkStop)
