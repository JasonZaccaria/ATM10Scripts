local function mineServer()
    rednet.open("left")
    while true do
        local command, content = rednet.receive()
        if command == "start" then
            shell.run("Mine.lua")
        elseif command == "update" then
            shell.run("delete Mine.lua")
            shell.run(content)
        end
    end
    rednet.close("left")
end

mineServer()
