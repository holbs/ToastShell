##*=============================================
##* Import custom functions from $env:WINDIR\ToastShell\ToastShellCustomScripts
##*=============================================

Get-ChildItem -Path "$env:WINDIR\ToastShell\ToastShellCustomScripts" -Filter "*.ps1" | Foreach-Object {
    . $($_.FullName)
}

##*=============================================
##* Execute the passed argument from the XML, with toastshell:// trimmed off
##*=============================================

$PassedArgument = $Args.Trim('/').Replace('toastshell://',"")
& $PassedArgument