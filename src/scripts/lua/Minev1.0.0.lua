local minFuelLevel = 300

local function handleFuel(currentIteration)
    if turtle.getFuelLevel() < minFuelLevel then
        for i = 1, 16 do
            turtle.select(i)
            turtle.refuel()
        end
        if turtle.getFuelLevel() > minFuelLevel then
            print("self refueled")
            return
        end
        if currentIteration ~= i then
            for i = 1, currentIteration - 1 do
                turtle.up()
            end
        end
        while turtle.getFuelLevel() < minFuelLevel do
            print("low fuel")
            turtle.select(1)
            turtle.refuel()
        end
        for i = 1, currentIteration - 1 do
            turtle.down()
        end
    end
end

local function handleInventory(currentIteration)
    for i = 1, 16 do
        turtle.select(i)
        if turtle.getItemCount() == 0 then
            return
        end
    end
    if currentIteration ~= 1 then
        for i = 1, currentIteration - 1 do
            turtle.up()
        end
    end
    turtle.turnRight()
    turtle.turnRight()
    for i = 1, 16 do
        turtle.select(i)
        turtle.drop()
    end
    turtle.turnLeft()
    turtle.turnLeft()
    for i = 1, currentIteration - 1 do
        turtle.down()
    end
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

local function mine(width, length, depth)
    for i = 1, depth do
        handleFuel(i)
        handleInventory(i)
        mineLayer(width, length)
        turtle.down()
    end
end

mine(12, 12, 64)

