<#
.DESCRIPTION
    ToastShell is a tool that allows you to push prompts users to take an action from a Windows toast notification, and then run PowerShell commands or functions on a click event
.EXAMPLE
    This example uses prompts the user to restart their computer by passing the cmdlet Restart-Computer through to the main execution script. Pair with a detection script in ConfigMgr or Intune to run on workstations with an uptime greater than 7 days
.DESCRIPTION
    ToastShell can be used to prompt users to complete actions such as
        * Reboot once every 7 days at a minimum, by using a detection method that checks for uptime
        * Reboot to complete a repair on Windows corruption, by using a detection method that checks for Windows corruption, then repairing it first before using ToastShell to prompt to reboot
        * Restart their browsers if there is a queued update, by checking for new_msedge.exe, and prompting the browser to close, then open again (if you are reopening this should be done in user context)
.NOTES
    This can be deployed through Microsoft Configuration Manager, Microsoft Intune, or other remote monitoring and management tools
.NOTES
    Depending on what your scripts do, you can deploy as SYSTEM, or user. If you need to run as SYSTEM with Intune then use ServiceUI to bring the notifications into the user session
.NOTES
    If you are using Microsoft Intune or your other remote monitoring and management tool runs as a x86 process, use %sysnative% to ensure that the scripts run in an x64 process
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
New-ItemProperty -Path "HKLM:\SOFTWARE\Classes\toastshell\shell\open\command" -Name "(default)" -Value "`"$env:WINDIR\ToastShell\ToastShell.cmd`" %1" -Type String -Force # This file is part of the tool source, and arguments from toastshell:// are passed to this to execute

##*=============================================
##* Copy ToastShell.cmd and ToastShell.ps1 to C:\WINDOWS\ToastShell
##*=============================================

New-Item -Path "$env:WINDIR\ToastShell" -ItemType Directory -Force
Copy-Item -Path "$PSScriptRoot\ToastShell.cmd" -Destination "$env:WINDIR\ToastShell\ToastShell.cmd" -Force -Confirm:$false
Copy-Item -Path "$PSScriptRoot\ToastShell.ps1" -Destination "$env:WINDIR\ToastShell\ToastShell.ps1" -Force -Confirm:$false

##*=============================================
##* Build out any data you want to use in the notification here
##*=============================================

$KernelEvents = Get-WinEvent -ProviderName 'Microsoft-Windows-Kernel-Boot'
$KernelReboot = $KernelEvents | Where-Object {$_.Id -eq 27 -and $_.Message -eq "The boot type was 0x0."}
$KernelUpTime = New-TimeSpan -Start $KernelReboot[0].TimeCreated -End (Get-Date)

##*=============================================
##* ToastShell XML content used to design the notification. Edit as required. Snooze doesn't do anything and works as a dismiss. If the detection still fails the next time this runs the user will see the same popup
##*=============================================

$ToastXml = @"
<toast>
    <visual>
        <binding template="ToastGeneric">
            <text>Restart Notification</text>
            <text>Your computer has not been restarted for $($KernelUpTime.Days) days. Please complete a restart as soon as possible.</text>
        </binding>
    </visual>
    <actions>
        <action content="Snooze" activationType="protocol" arguments="" />
        <action content="Restart" activationType="protocol" arguments="toastshell://Restart-Computer" />
    </actions>
</toast>
"@

##*=============================================
##* Show the notification using the XML above
##*=============================================

$XmlDocument = [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime]::New()
$XmlDocument.LoadXml($ToastXml)
$AppId = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'
[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]::CreateToastNotifier($AppId).Show($XmlDocument)