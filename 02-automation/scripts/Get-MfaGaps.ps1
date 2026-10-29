$all = Get-MgReportAuthenticationMethodUserRegistrationDetail -All

if (-not $all) {
    Write-Warning "The registration report returned no data. If this tenant is new, try again later."
    return
}

$gaps = $all | Where-Object { -not $_.IsMfaRegistered }

$gaps | Select-Object UserPrincipalName, IsMfaRegistered,
        @{ n = 'Methods'; e = { $_.MethodsRegistered -join ', ' } } |
    Export-Csv "$PSScriptRoot/../reports/mfa-gaps-$(Get-Date -Format yyyyMMdd).csv" -NoTypeInformation

Write-Host "$(@($all).Count) users checked, $(@($gaps).Count) without MFA." -ForegroundColor Cyan