# Restart
Restart is used with ToastShell to show a toast notification prompt to the end user that their workstation has not been restarted for x days
- If the user hits Snooze then the notification simply disappears and nothing happens
- If the user hits Restart then Restart-Computer (native to PowerShell) is passed through ToastShell and executed