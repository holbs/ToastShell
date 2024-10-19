# ToastShell
A selection of PowerShell scripts that allow an administrator to prompt end users to complete an action through a toast notification. These actions can then run PowerShell cmdlets or functions definied within the scripts. This example prompts an end user to restart their workstation if it has an uptime of 7+ days
## Installation
- Using Microsoft Configuration Manager, Microsoft Intune, or another Remote Monitoring and Management tool create a package that contains
  - ToastShell.cmd
  - ToastShell.ps1
  - ToastShellMain.ps1
- Set up an application that uses script detection to determine if the workstation has restarted in the last 7 days using the below code
```
$KernelEvents = Get-WinEvent -ProviderName 'Microsoft-Windows-Kernel-Boot'
$KernelReboot = $KernelEvents | Where-Object {$_.Id -eq 27 -and $_.Message -eq "The boot type was 0x0."}
If ($KernelReboot[0].TimeCreated -ge (Get-Date).AddDays(-7)) {
    Return "The workstation has restarted in the last 7 days"
    Exit 0
}
```
- If the above does not return "The workstation has restarted in the last 7 days", the detection is failed, and ToastShellMain.ps1 can execute
## End User Experience
The end user will see a prompt as below

![ToastShell Example](https://github.com/holbs/ToastShell/blob/main/Images/ExampleNotification.png)

If they select Restart, then Restart-Computer is ran and the workstation reboots. If they select Snooze nothing happens, however, if detection runs again at some point and it still does not return "The workstation has restarted in the last 7 days" they'll see the prompt again
