[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)] [string]$UserPrincipalName,
    [Parameter(Mandatory)] [string]$ManagerUpn
)

Start-Transcript -Path "$PSScriptRoot\..\logs\offboarding-$(Get-Date -Format yyyyMMdd-HHmm).log"
$user = Get-MgUser -UserId $UserPrincipalName

if ($PSCmdlet.ShouldProcess($UserPrincipalName, "Offboard")) {
    # 1. Block sign-in and kill active sessions (phones, browsers)
    Update-MgUser -UserId $user.Id -AccountEnabled:$false
    Revoke-MgUserSignInSession -UserId $user.Id

    # 2. Convert mailbox to shared and give the manager access
    Connect-ExchangeOnline -ShowBanner:$false
    Set-Mailbox -Identity $UserPrincipalName -Type Shared
    Add-MailboxPermission -Identity $UserPrincipalName -User $ManagerUpn -AccessRights FullAccess -InheritanceType All

    # 3. Remove from every group (this also frees the group-based license)
    $groups = Get-MgUserMemberOf -UserId $user.Id | Where-Object { $_.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.group' }
    foreach ($g in $groups) {
        Remove-MgGroupMemberByRef -GroupId $g.Id -DirectoryObjectId $user.Id
        Write-Host "Removed from $($g.AdditionalProperties.displayName)"
    }

    # 4. Stamp the account so the next admin knows what happened
    Update-MgUser -UserId $user.Id -Department "OFFBOARDED $(Get-Date -Format yyyy-MM-dd)"
}
Stop-Transcript