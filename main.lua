local ShutdownServer = {}

ShutdownServer.scriptName = "ShutdownServer"

ShutdownServer.defaultConfig = {
    commandName= "shutdown",
    announcePrefix = "#FF0000[Server]: Server shutting down in ",
    announceSuffix = " minutes!\n",
    timeUnit = 60,
    announcePeriods = {0.5, 1, 2 , 3 , 4, 5},
    shutdownDelay = 5,
    requiredRank = 2
}

ShutdownServer.config = DataManager.loadConfiguration(ShutdownServer.scriptName, ShutdownServer.defaultConfig)

function ShutdownServer.kickEveryone()
    for pid, player in pairs(Players) do
        player:Save()
        tes3mp.Kick(pid)
    end
end

function ShutdownServer.unloadCells()
    for cellDescription, cell in pairs(LoadedCells) do
        logicHandler.UnloadCell(cellDescription)
    end
end

function ShutdownServerStopServer()
    ShutdownServer.kickEveryone()
    ShutdownServer.unloadCells()
    tes3mp.StopServer(0)
end

function ShutdownServerAnnounce(time)
    time = time / ShutdownServer.config.timeUnit
    for pid, player in pairs(Players) do
        tes3mp.SendMessage(
            pid,
            ShutdownServer.config.announcePrefix .. time .. ShutdownServer.config.announceSuffix
        )
    end
end

function ShutdownServer.setupTimers(shutdownDelay)
    
    for i, time in pairs(ShutdownServer.config.announcePeriods) do
        time = time * ShutdownServer.config.timeUnit
        if time < shutdownDelay then
            tes3mp.StartTimer(tes3mp.CreateTimerEx(
                "ShutdownServerAnnounce",
                1000 * (shutdownDelay - time),
                "i",
                time
            ))
        end
    end
    
    tes3mp.StartTimer(tes3mp.CreateTimer(
        "ShutdownServerStopServer",
        1000 * (shutdownDelay)
    ))

    ShutdownServerAnnounce(shutdownDelay)
end

function ShutdownServer.processCommand(pid, cmd)
    if Players[pid].data.settings.staffRank >= ShutdownServer.config.requiredRank then
        local shutdownDelay = ShutdownServer.config.shutdownDelay
        if cmd[2] ~= nil then
            shutdownDelay = tonumber(cmd[2])
        end
        shutdownDelay = shutdownDelay * ShutdownServer.config.timeUnit

        ShutdownServer.setupTimers(shutdownDelay)
    else
        tes3mp.SendMessage(pid, "You are not allowed to use this command!\n")
    end
end

customCommandHooks.registerCommand(ShutdownServer.config.commandName, ShutdownServer.processCommand)

return ShutdownServer