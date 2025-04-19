local function main()
    rednet.open("right")
    if arg[1] == nil then
        print("Missing argument: e.x mine.lua start")
        rednet.close("right")
        return
    end
    if arg[1] == "start" then
        rednet.broadcast({
            command = "start",
            content = ""
        })
        rednet.close("right")
    elseif arg[1] == "stop" then
        rednet.broadcast({
            command = "stop",
            content = ""
        })
        rednet.close("right")
    elseif arg[1] == "update" then
        rednet.broadcast({
            command = "update",
            content = "wget https://raw.githubusercontent.com/JasonZaccaria/ATM10Scripts/refs/heads/main/src/scripts/lua/Mine.lua"
        })
        rednet.close("right")
    else
        print("invalid command, must be one of the following: [start, stop, update]")
        rednet.close("right")
        return
    end
end
