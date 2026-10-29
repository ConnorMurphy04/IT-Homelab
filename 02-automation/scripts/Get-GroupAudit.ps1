Get-MgGroup -Filter "startsWith(displayName,'SG-')" -All | ForEach-Object {
    $group = $_
    Get-MgGroupMember -GroupId $group.Id -All | ForEach-Object {
        [PSCustomObject]@{
            Group  = $group.DisplayName
            Member = $_.AdditionalProperties.displayName
            UPN    = $_.AdditionalProperties.userPrincipalName
        }
    }
} | Sort-Object Group, Member |
    Export-Csv "$PSScriptRoot/../reports/group-audit-$(Get-Date -Format yyyyMMdd).csv" -NoTypeInformation