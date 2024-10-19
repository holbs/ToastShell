##*=============================================
##* ToastShell main functions
##*=============================================



##*=============================================
##* Add any custom functions here that can be called through the XML in ToastShellMain.ps1
##*=============================================

Function Test-Function {
    # Your code here
}

##*=============================================
##* Execute the passed argument from the XML, with toastshell:// trimmed off
##*=============================================

$PassedArgument = $Args.Trim('/').Replace('toastshell://',"")
& $PassedArgument