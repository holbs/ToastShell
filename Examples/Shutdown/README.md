# Shutdown
Shutdown is used with ToastShell to show a toast notification prompt to the end user that their workstation has a scheduled shutdown in 30 minutes
- If the user hits Snooze, the scheduled shutdown job is stopped, by running Stop-Shutdown, which is part of ShutdownCustonFunctions.ps1
- If the user hits Dismiss, the scheduled shutdown job is stopped, and then shutdown.exe is used to shutdown the workstation, by running Start-Shutdown, which is part of ShutdownCustonFunctions.ps1
- If the user does nothing, or if they have walked away from their workstation then the shutdown job continues to run for 30 minutes then shutdowns when the timer is reached