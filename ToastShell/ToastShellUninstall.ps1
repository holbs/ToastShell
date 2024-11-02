##*=============================================
##* Removal of toastshell:// URI from the registry
##*=============================================

Get-Item -Path "HKLM:\SOFTWARE\Classes\toastshell" -Force | Remove-Item -Recurse -Force -Confirm:$false

##*=============================================
##* Removal of ToastShell folder from $env:WINDIR
##*=============================================

Get-Item -Path "$env:WINDIR\ToastShell" -Force | Remove-Item -Recurse -Force -Confirm:$false

##*=============================================
##* Removal of ToastShell folder from $env:USERPROFILE
##*=============================================

Get-Item -Path "$env:SystemDrive\Users\*\ToastShell" -Force  | Remove-Item -Recurse -Force -Confirm:$false