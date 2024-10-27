Function Push-ScheduledShutdown {
    & $env:WINDIR\System32\shutdown.exe /a
    & $env:WINDIR\System32\shutdown.exe /s /t 5
}

Function Clear-ScheduledShutdown {
    & $env:WINDIR\System32\shutdown.exe /a
}