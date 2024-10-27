# Downloads
Downloads is used with ToastShell to show a toast notification prompt to the end user that they have items in their downloads older than 30 days
- If the user hits Review then the downloads folder is opened for the user to review the contents, by running Show-Downloads, which is part of DownloadsCustomFunctions.ps1
- If the user hits Remove then any item older than 30 days in the downloads folder is deleted, by running Remove-Downloads, which is part of DownloadsCustomFunctions.ps1