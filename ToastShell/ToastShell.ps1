##*=============================================
##* Import ToastShell functions
##*=============================================

. "$env:WINDIR\ToastShell\ToastShellFunctions"

##*=============================================
##* Import custom functions from $env:WINDIR\ToastShell\ToastShellCustomFunctions, depending on context this script is ran
##*=============================================

$IsAdministrator = Test-IsAdministrator
If ($IsAdministrator) {
    Get-ChildItem -Path "$env:WINDIR\ToastShell\ToastShellCustomFunctions\Administrator" -Filter "*.ps1" | Foreach-Object {
        . $($_.FullName)
    }
} Else {
    Get-ChildItem -Path "$env:WINDIR\ToastShell\ToastShellCustomFunctions\User" -Filter "*.ps1" | Foreach-Object {
        . $($_.FullName)
    }
}

##*=============================================
##* Execute the passed argument from the XML, with toastshell:// trimmed off
##*=============================================

$PassedArgument = $Args.Trim('/').Replace('toastshell://',"")
& $PassedArgument