Function Show-DownloadsFolder {
    Invoke-Item -Path "$env:USERPROFILE\Downloads"
}

Function Remove-DownloadsItemsOlderThan30Days {
    # Get the files that are older than 30 days and remove them
    $DownloadsContent = Get-ChildItem "$env:USERPROFILE\Downloads" -File -Recurse
    $DownloadsContentOlderThan30Days = $DownloadsContent | Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-30)}
    $DownloadsContentOlderThan30Days | Remove-Item -Force -Confirm:$false
    # Remove any now empty folders from Downloads
    $DownloadsFolders = Get-ChildItem -Path "$env:USERPROFILE\Downloads" -Directory -Recurse
    Foreach ($Folder in $DownloadsFolders) {
        # Check if the folder has items in still, or is now empty
        $FolderContents = Get-ChildItem -Path $Folder.FullName -Recurse -File
        $FolderContentsCount = $FolderContents.Count
        If ($FolderContentsCount -gt 0) {
            # Folder has items in still, do nothing
        } Else {
            Remove-Item $Folder.FullName -Recurse -Force -Confirm:$false
        }
    }
}