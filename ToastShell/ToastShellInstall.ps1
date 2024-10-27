<#
.SYNOPSIS
    ToastShell is a set of scripts that allows you to push prompts users to take an action from a Windows toast notification, and then run PowerShell commands or functions on a click event
.EXAMPLE
    This repositry contains the ToastShell base scripts, an installation script and has three examples in the Examples folder
    * Prompting the user to restart their workstation if it has not restarted for 7 or more days, by checking the last time the Windows kernel was booted
    * Prompting the user to shutdown at a set time, with the option to cancel it, and if no action is taken the workstation shuts down
    * Prompting the user to review the contents of the downloads folder, as there are items older than 30 days
.DESCRIPTION
    ToastShell sets up a custom URI (toastshell://). Pass strings to this URI, which then passes to a CMD script, which then launches a PowerShell script and executes the string passed to it. Put any custom functions in ToastShellCustomScripts
.NOTES
    This can be deployed through Microsoft Configuration Manager, Microsoft Intune, or other remote monitoring and management tools
.NOTES
    Depending on what your scripts do, you can deploy as SYSTEM, or user. If you need to run as SYSTEM with Intune then use ServiceUI to bring the notifications into the user session
.NOTES
    If you are using Microsoft Intune or your other remote monitoring and management tool runs as a x86 process, use %sysnative% to ensure that the scripts run in an x64 process
.NOTES
    When these scripts run will depend on your own logic. You could trigger then at set times with Scheduled Tasks, or you could use detection scripts before running the installation where detection criteria is not met
.NOTES
    Author : Aran Holbrook
    BlueSky: https://bsky.app/profile/holbs.bsky.social
    GitHub : https://github.com/holbs
.LINK
    Source : https://github.com/holbs/ToastShell
#>

##*=============================================
##* Creation of toastshell:// URI by adding to the registry
##*=============================================

New-Item "HKLM:\SOFTWARE\Classes\toastshell" -Force
New-Item "HKLM:\SOFTWARE\Classes\toastshell\DefaultIcon" -Force
New-Item "HKLM:\SOFTWARE\Classes\toastshell\shell" -Force
New-Item "HKLM:\SOFTWARE\Classes\toastshell\shell\open" -Force
New-Item "HKLM:\SOFTWARE\Classes\toastshell\shell\open\command" -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Classes\toastshell" -Name "(default)" -Value "URL:PowerShell Toast Notification Protocol" -Type String -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Classes\toastshell" -Name "URL Protocol" -Value "" -Type String -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Classes\toastshell\DefaultIcon" -Name "(default)" -Value "$env:WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe,1" -Type String -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Classes\toastshell\shell" -Name "(default)" -Value "open" -Type String -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Classes\toastshell\shell\open\command" -Name "(default)" -Value "`"$env:WINDIR\ToastShell\ToastShell.cmd`" %1" -Type String -Force # This file is placed here by this installation script, and should be part of your installation source

##*=============================================
##* Create ToastShell folder then copy ToastShell.cmd, ToastShell.ps1, & ToastShellFunctions.ps1 to the folder
##*=============================================

New-Item -Path "$env:WINDIR\ToastShell" -ItemType Directory -Force
Copy-Item -Path "$PSScriptRoot\ToastShell.cmd" -Destination "$env:WINDIR\ToastShell\ToastShell.cmd" -Force -Confirm:$false
Copy-Item -Path "$PSScriptRoot\ToastShell.ps1" -Destination "$env:WINDIR\ToastShell\ToastShell.ps1" -Force -Confirm:$false
Copy-Item -Path "$PSScriptRoot\ToastShellFunctions.ps1" -Destination "$env:WINDIR\ToastShell\ToastShell.ps1" -Force -Confirm:$false

##*=============================================
##* Create folders for custom functions and grant Users access to the User folder, so ToastShell in user context can write to this folder
##*=============================================

New-Item -Path "$env:WINDIR\ToastShell\ToastShellCustomFunctions" -ItemType Directory -Force
New-Item -Path "$env:WINDIR\ToastShell\ToastShellCustomFunctions\Administrator" -ItemType Directory -Force
New-Item -Path "$env:WINDIR\ToastShell\ToastShellCustomFunctions\User" -ItemType Directory -Force
# Grant the Users group access to write to the User folder, so if ToastShell is ran in User context any custom functions can be copied to the folder
$Acl = Get-Acl -Path "$env:WINDIR\ToastShell\ToastShellCustomFunctions\User"
$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("Users","Modify,Write","ContainerInherit,ObjectInherit","None","Allow")
$Acl.SetAccessRule($AccessRule)
Set-Acl -Path "$env:WINDIR\ToastShell\ToastShellCustomFunctions\User" -AclObject $Acl