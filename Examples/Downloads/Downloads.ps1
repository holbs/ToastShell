<#
.DESCRIPTION
    Downloads is used with ToastShell to show a toast notification prompt to the end user that they have items in their downloads older than 30 days
    * If the user hits Review then the downloads folder is opened for the user to review the contents, by running Show-Downloads, which is part of DownloadsCustomFunctions.ps1
    * If the user hits Remove then any item older than 30 days in the downloads folder is deleted, by running Remove-Downloads, which is part of DownloadsCustomFunctions.ps1
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

$IsAdministrator = Test-IsAdministrator
Switch ($IsAdministrator) {
    $true {
        Copy-Item -Path "$PSScriptRoot\DownloadsCustomFunctions.ps1" -Destination "$env:WINDIR\ToastShell\ToastShellCustomFunctions\DownloadsCustomFunctions.ps1" -Force -Confirm:$false
    }
    $false {
        New-Item -Path "$env:USERPROFILE\ToastShell\ToastShellCustomFunctions" -ItemType Directory -Force
        Copy-Item -Path "$PSScriptRoot\DownloadsCustomFunctions.ps1" -Destination "$env:WINDIR\ToastShell\ToastShellCustomFunctions\DownloadsCustomFunctions.ps1" -Force -Confirm:$false
    }
}

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
$Image = "$PSScriptRoot\Downloads.png" # Ensure this path is correct. If it's not the notification will not display

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
        <action content="Review" activationType="protocol" arguments="toastshell://Show-DownloadsFolder" />
        <action content="Remove" activationType="protocol" arguments="toastshell://Remove-DownloadsItemsOlderThan30Days" />
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