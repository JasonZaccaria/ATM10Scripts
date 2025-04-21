local function mineServer()
    rednet.open("left")
    while true do
        rednet.open("left")
        print("server running")
        local sendId, request = rednet.receive()
        if request.command == "start" then
            shell.run("Mine.lua")
        elseif request.command == "update" then
            shell.run("delete Mine.lua")
            shell.run(request.content)
        end
    end
    rednet.close("left")
end

mineServer()
