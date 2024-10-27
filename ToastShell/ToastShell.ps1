##*=============================================
##* Import custom scripts from $env:WINDIR\ToastShell\ToastShellCustomScripts, depending on context script is ran
##*=============================================

$IsAdministrator = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$IsAdministrator = $IsAdministrator.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
If ($IsAdministrator) {
    Get-ChildItem -Path "$env:WINDIR\ToastShell\ToastShellCustomScripts\Administrator" -Filter "*.ps1" | Foreach-Object {
        . $_.FullName
    }
} Else {
    Get-ChildItem -Path "$env:WINDIR\ToastShell\ToastShellCustomScripts\User" -Filter "*.ps1" | Foreach-Object {
        . $_.FullName
    }
}

##*=============================================
##* Execute the passed argument from the XML, with toastshell:// trimmed off
##*=============================================

$PassedArgument = $Args.Trim('/').Replace('toastshell://',"")
& $PassedArgument