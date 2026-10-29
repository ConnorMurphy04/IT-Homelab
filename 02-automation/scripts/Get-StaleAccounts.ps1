param([int]$Days = 90)
$cutoff = (Get-Date).AddDays(-$Days)

Get-MgUser -All -Property DisplayName,UserPrincipalName,AccountEnabled,CreatedDateTime,SignInActivity |
    Select-Object DisplayName, UserPrincipalName, AccountEnabled, CreatedDateTime,
        @{ n = 'LastSignIn'; e = { $_.SignInActivity.LastSignInDateTime } } |
    Where-Object {
        $_.AccountEnabled -and
        $_.CreatedDateTime -lt (Get-Date).AddDays(-14) -and          # ignore brand-new accounts
        ($null -eq $_.LastSignIn -or $_.LastSignIn -lt $cutoff)
    } |
    Export-Csv "$PSScriptRoot\..\reports\stale-accounts-$(Get-Date -Format yyyyMMdd).csv" -NoTypeInformation