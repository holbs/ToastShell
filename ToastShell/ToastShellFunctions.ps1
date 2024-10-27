Function Test-IsAdministrator {
    $TestIsAdministrator = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $TestIsAdministrator = $TestIsAdministrator.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    If ($TestIsAdministrator) {
        Return $true
    } Else {
        Return $false
    }
}