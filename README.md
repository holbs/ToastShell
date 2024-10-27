# ToastShell
ToastShell is a set of scripts that allows you to push prompts users to take an action from a Windows toast notification, and then run PowerShell commands or functions on a click event
## Installation
- Using Microsoft Configuration Manager, Microsoft Intune, or another Remote Monitoring and Management tool deploy a package that contains
  - ToastShell.cmd
  - ToastShell.ps1
  - ToastShellFunctions.ps1
  - ToastShellInstall.cmd
  - ToastShellInstall.ps1
- Using Task Scheduler, Microsoft Configuration Manager, Microsoft Intune, or another Remote Monitoring and Management tool deploy additional scripts to use this framework to show a notification
## Examples
There are three examples in the Examples folder
  - Restart, which prompts for a restart if the workstation has not restarted for 7 or more days
  - Shutdown, which prompts for a shutdown at a set time, with a scheduled shutdown 30 minutes later if not met
  - Downloads, which prompts for the Downloads folder content to be cleaned where content is aged
## End User Experience
In the restart scenario the end user will see a prompt as below

![ToastShell Example](https://github.com/holbs/ToastShell/blob/main/ReadMeImages/ExampleNotification.png)

If they select Restart, then Restart-Computer is passed from through the toastshell:// URI to ToastShell.ps1 and executes and the workstation reboots. If they select Snooze nothing happens and nothing is ran, but the notification is dismissed
