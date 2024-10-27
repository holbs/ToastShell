Function Start-Shutdown {
    # Cancel the job for the scheduled shutdown
    Get-Job -Name "Scheduled Shutdown" | Stop-Job
    Get-Job -Name "Scheduled Shutdown" | Remove-Job
    # Shutdown the computer now, with a 30 timer
    & $env:WINDIR\System32\shutdown.exe /s /t 30
}

Function Stop-Shutdown {
    # Cancel the job for the scheduled shutdown
    Get-Job -Name "Scheduled Shutdown" | Stop-Job
    Get-Job -Name "Scheduled Shutdown" | Remove-Job
}