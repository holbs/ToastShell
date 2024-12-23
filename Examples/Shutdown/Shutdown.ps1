<#
.DESCRIPTION
    Shutdown is used with ToastShell to show a toast notification prompt to the end user that their workstation has a scheduled shutdown in 30 minutes
    * If the user hits Snooze, the scheduled shutdown job is stopped, by running Stop-Shutdown, which is part of ShutdownCustomFunctions.ps1
    * If the user hits Shutdown, the scheduled shutdown job is stopped, and then shutdown.exe is used to shutdown the workstation, by running Start-Shutdown, which is part of ShutdownCustomFunctions.ps1
    * If the user does nothing, or if they have walked away from their workstation then the shutdown job continues to run for 30 minutes then shutdowns when the timer is reached
.NOTES
    Author : Aran Holbrook
    BlueSky: https://bsky.app/profile/holbs.bsky.social
    GitHub : https://github.com/holbs
.LINK
    Source : https://github.com/holbs/ToastShell
#>

##*=============================================
##* Import ToastShell functions
##*=============================================

. "$env:WINDIR\ToastShell\ToastShellFunctions.ps1"

##*=============================================
##* Copy any custom functions to ToastShellCustomFunctions folders here
##*=============================================

$IsAdministrator = Test-IsAdministrator
Switch ($IsAdministrator) {
    $true {
        Copy-Item -Path "$PSScriptRoot\ShutdownCustomFunctions.ps1" -Destination "$env:WINDIR\ToastShell\ToastShellCustomFunctions\ShutdownCustomFunctions.ps1" -Force -Confirm:$false
    }
    $false {
        New-Item -Path "$env:USERPROFILE\ToastShell\ToastShellCustomFunctions" -ItemType Directory -Force
        Copy-Item -Path "$PSScriptRoot\ShutdownCustomFunctions.ps1" -Destination "$env:USERPROFILE\ToastShell\ToastShellCustomFunctions\ShutdownCustomFunctions.ps1" -Force -Confirm:$false
    }
}

##*=============================================
##* Build out any data you want to use in the notification here
##*=============================================

$ScheduledShutdownTime = (Get-Date).AddSeconds(1800)
$ScheduledShutdownTime = Get-Date $ScheduledShutdownTime -Format "HH:mm"
& $env:WINDIR\System32\shutdown.exe /s /t 1800

##*=============================================
##* Build the contents of the notification here
##*=============================================

$Title = "Shutdown Notification"
$Body  = "This workstation will shutdown at $ScheduledShutdownTime. Click Snooze to cancel, or Shutdown to shutdown now"
$Image = "$PSScriptRoot\Shutdown.png" # Ensure this path is correct. If it's not the notification will not display

##*=============================================
##* ToastShell XML content used to display the notification. The arguments can be native PowerShell cmdlets, or can call functions from scripts you place in $env:WINDIR\ToastShell\ToastShellCustomScripts
##*=============================================

$ToastXml = @"
<toast>
    <visual>
        <binding template="ToastGeneric">
            <text>$Title</text>
            <text>$Body</text>
            <image placement="applogooverride" src="$Image" />
        </binding>
    </visual>
    <actions>
        <action content="Snooze" activationType="protocol" arguments="toastshell://Clear-ScheduledShutdown" />
        <action content="Shutdown" activationType="protocol" arguments="toastshell://Push-ScheduledShutdown" />
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