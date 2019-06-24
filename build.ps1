Push-Location $PSScriptRoot

if (!(Get-Module PSDepend -ListAvailable)) {
    Write-Verbose "Installing PSDepend..." -Verbose
    Install-Module PSDepend
}

Write-Verbose "Installing dependencies..." -Verbose
Invoke-PSDepend -Force

Pop-Location
