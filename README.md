# ToastShell
ToastShell is a set of scripts that allows you to push prompts users to take an action from a Windows toast notification, and then run PowerShell commands or functions on a click event
## Installation
- Using Microsoft Configuration Manager, Microsoft Intune, or another Remote Monitoring and Management tool deploy a package that contains
  - ToastShell.cmd
  - ToastShell.ps1
  - ToastShellInstall.cmd
  - ToastShellInstall.ps1
- Using Task Scheduler, Microsoft Configuration Manager, Microsoft Intune, or another Remote Monitoring and Management tool deploy additional packages to use this framework to show notification. There are three examples in the Examples folder
  - Restart, to prompt the user to restart their workstation if it has not restarted for 7 or more days
  - Shutdown, to prompt the user to shutdown at a set time, with the option to cancel the shutdown if they are still working
  - Downloads, to prompt the user to review the contents of their downloads folder if it has items older than 30 days in
## End User Experience
In the restart scenario the end user will see a prompt as below

![ToastShell Example](https://github.com/holbs/ToastShell/blob/main/ReadMeImages/ExampleNotification.png)

If they select Restart, then Restart-Computer is passed from through the toastshell:// URI to ToastShell.ps1 and executes and the workstation reboots. If they select Snooze nothing happens and nothing is ran, but the notification is dismissed
