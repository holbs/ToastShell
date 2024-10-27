<#
.DESCRIPTION
    Downloads is used with ToastShell to show a toast notification prompt to the end user that they have items in their downloads older than 30 days
    * If the user hits Review then the downloads folder is opened for the user to review the contents, by running Show-Downloads, which is part of DownloadsCustomScripts.ps1
    * If the user hits Remove then any item older than 30 days in the downloads folder is deleted, by running Remove-Downloads, which is part of DownloadsCustomScripts.ps1
.NOTES
    Author : Aran Holbrook
    BlueSky: https://bsky.app/profile/holbs.bsky.social
    GitHub : https://github.com/holbs
.LINK
    Source : https://github.com/holbs/ToastShell
#>

##*=============================================
##* Copy any custom scripts to $env:WINDIR\ToastShell\ToastShellCustomScripts here
##*=============================================

Copy-Item -Path "$PSScriptRoot\DownloadsCustomScripts.ps1" -Destination "$env:WINDIR\ToastShell\ToastShellCustomScripts\DownloadsCustomScripts.ps1" -Force -Confirm:$false

##*=============================================
##* Build out any data you want to use in the notification here
##*=============================================

$DownloadsContent = Get-ChildItem "$env:USERPROFILE\Downloads" -File -Recurse -Force
$DownloadsContentOlderThan30Days = $DownloadsContent | Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-30)}
$DownloadsContentOlderThan30DaysCount = $DownloadsContentOlderThan30Days.Count

##*=============================================
##* Build the contents of the notification here
##*=============================================

$Title = "Disk Cleanup Required"
$Body  = "Your downloads folder has $DownloadsContentOlderThan30DaysCount items that are older than 30 days. Do you want to remove these items?"
$Image = "$PSScriptRoot\TSDownloads.png" # Ensure this path is correct. If it's not the notification will not display

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
        <action content="Review" activationType="protocol" arguments="toastshell://Show-Downloads" />
        <action content="Remove" activationType="protocol" arguments="toastshell://Remove-Downloads" />
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