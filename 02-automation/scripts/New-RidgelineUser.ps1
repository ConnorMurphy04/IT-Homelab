[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)] [string]$CsvPath,
    [string]$Domain = "ridgeline.example",
    [string]$LicenseGroup = "SG-Licensed-BusinessPremium"
)

Start-Transcript -Path "$PSScriptRoot\..\logs\onboarding-$(Get-Date -Format yyyyMMdd-HHmm).log"
$licenseGroupId = (Get-MgGroup -Filter "displayName eq '$LicenseGroup'").Id

foreach ($hire in Import-Csv $CsvPath) {
    $upn = "$($hire.FirstName).$($hire.LastName)@$Domain".ToLower()

    # Skip anyone who already exists so the script is safe to re-run
    if (Get-MgUser -Filter "userPrincipalName eq '$upn'" -ErrorAction SilentlyContinue) {
        Write-Warning "$upn already exists - skipping"
        continue
    }

    $tempPassword = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 14 | ForEach-Object { [char]$_ }) + "!7"

    if ($PSCmdlet.ShouldProcess($upn, "Create user")) {
        $user = New-MgUser -DisplayName "$($hire.FirstName) $($hire.LastName)" `
            -GivenName $hire.FirstName -Surname $hire.LastName `
            -UserPrincipalName $upn -MailNickname "$($hire.FirstName).$($hire.LastName)".ToLower() `
            -JobTitle $hire.JobTitle -Department $hire.Department `
            -UsageLocation "US" -AccountEnabled `
            -PasswordProfile @{ Password = $tempPassword; ForceChangePasswordNextSignIn = $true }

        $roleGroupId = (Get-MgGroup -Filter "displayName eq '$($hire.Group)'").Id
        New-MgGroupMember -GroupId $roleGroupId -DirectoryObjectId $user.Id
        New-MgGroupMember -GroupId $licenseGroupId -DirectoryObjectId $user.Id

        Write-Host "Created $upn | temp password: $tempPassword" -ForegroundColor Green
    }
}
Stop-Transcript