local ShutdownServer = {}

ShutdownServer.scriptName = "ShutdownServer"

ShutdownServer.defaultConfig = {
    commandName= "shutdown",
    announceMessage = "#FF0000[Server]: Server shutting down in %s minutes!\n",
    timeUnit = 60,
    announcePeriods = {0.5, 1, 2 , 3 , 4, 5},
    shutdownDelay = 5,
    requiredRank = 2,
    scheduledShutdownEnabled = false,
    scheduledShutdownTime = 6*60
}

ShutdownServer.config = DataManager.loadConfiguration(ShutdownServer.scriptName, ShutdownServer.defaultConfig)

function ShutdownServerStopServer(stage)
    tes3mp.StopServer(0)
end

function ShutdownServerAnnounce(time)
    time = time / ShutdownServer.config.timeUnit
    for pid, player in pairs(Players) do
        tes3mp.SendMessage(
            pid,
            string.format(ShutdownServer.config.announceMessage, time)
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

function ShutdownServer.savePlayers()
    for pid, player in pairs(Players) do
        player:DeleteSummons()
        player:Save()
        tes3mp.Kick(pid)
    end
end

function ShutdownServer.saveCells()
    for cellDescription, cell in pairs(LoadedCells) do
        cell:SaveActorPositions()
        cell:SaveActorStatsDynamic()
        logicHandler.UnloadCell(cellDescription)
    end
end

function ShutdownServer.saveRecordStores()
    for _, recordStore in pairs(RecordStores) do
        recordStore:Save()
    end
end


function ShutdownServer.OnServerPostInit()
    if ShutdownServer.config.scheduledShutdownEnabled then
        ShutdownServer.setupTimers(ShutdownServer.config.scheduledShutdownTime * ShutdownServer.config.timeUnit)
    end
end

function ShutdownServer.OnServerExit()
    ShutdownServer.savePlayers()
    ShutdownServer.saveCells()
    ShutdownServer.saveRecordStores()
    World:Save()
end


customEventHooks.registerHandler("OnServerPostInit", ShutdownServer.OnServerPostInit)
customEventHooks.registerHandler("OnServerExit", ShutdownServer.OnServerExit)


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