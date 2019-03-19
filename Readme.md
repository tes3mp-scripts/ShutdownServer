Allows you to exit the server in orderly fashion, while triggering the `OnServerExit` event (important for most my scripts).

Simply use `/shutdown` (configurable) to exit the server.

You can find the configuration file in `server/data/custom/__config_ShutdownServer.json`.
* `commandName` name of the chat command. `shutdown` by default.
* `announceMessage` message displayed before the reboot.
* `timeUnit` defines what `1` in `announcePeriods`, `shutdownDelay` and `scheduledShutdownTime` mean. Equals to `60` (a minute) by default.
* `announcePeriods` for each value, server will be notified about the shutdown that many minutes prior to it.
* `shutdownDelay` how many minutes after `/shutdown` with no arguments will the server exit.
* `requiredRank` rank required to use `/shutdown`, `2` (Admin) by default.
* `scheduledShutdownEnabled` whether server should power off (e.g. to be automatically restarted) after some amount of time. Off by default.
* `scheduledShutdownTime` delay until automated shutdown. 6 hours by default.