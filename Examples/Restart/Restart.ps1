<#
.DESCRIPTION
    Restart is used with ToastShell to show a toast notification prompt to the end user that their workstation has not been restarted for x days
    * If the user hits Snooze then the notification simply disappears and nothing happens
    * If the user hits Restart then Restart-Computer (native to PowerShell) is passed through ToastShell and executed
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
##* Copy any custom function scripts to ToastShellCustomScripts folders here
##*=============================================



##*=============================================
##* Build out any data you want to use in the notification here
##*=============================================

$KernelEvents = Get-WinEvent -ProviderName 'Microsoft-Windows-Kernel-Boot'
$KernelReboot = $KernelEvents | Where-Object {$_.Id -eq 27 -and $_.Message -eq "The boot type was 0x0."}
$KernelUpTime = New-TimeSpan -Start $KernelReboot[0].TimeCreated -End (Get-Date)

##*=============================================
##* Build the contents of the notification here
##*=============================================

$Title = "Restart Notification"
$Body  = "Your computer has not been restarted for $($KernelUpTime.Days) days. Please complete a restart as soon as possible."
$Image = "$PSScriptRoot\Restart.png" # Ensure this path is correct. If it's not the notification will not display

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