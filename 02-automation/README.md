# Project 2: PowerShell Automation with Microsoft Graph

**Goal:** Automate Ridgeline's repetitive identity work so it's fast, consistent, and doesn't depend on one person remembering every step.

**What it shows:** onboarding and offboarding, checks on stale accounts and MFA enrollment, and standardized workflows that reduce single-point-of-failure risk.

## Scripts

| Script | What it does |
| --- | --- |
| `New-RidgelineUser.ps1` | Creates users from an HR-style CSV and adds them to their role group and license group |
| `Remove-RidgelineUser.ps1` | Offboards a user securely: blocks sign-in, revokes sessions, converts the mailbox to shared, removes group memberships |
| `Get-StaleAccounts.ps1` | Reports enabled accounts with no sign-in for N days |
| `Get-MfaGaps.ps1` | Reports users without MFA registered |
| `Get-GroupAudit.ps1` | Lists every member of every `SG-` group for access reviews |

## Setup

- **PowerShell 7** on macOS, with VS Code and the PowerShell extension
- Modules: `Microsoft.Graph` and `ExchangeOnlineManagement` (the older `MSOnline` and `AzureAD` modules are retired)
- Connected with only the scopes these scripts need:

```powershell
Connect-MgGraph -Scopes "User.ReadWrite.All","Group.ReadWrite.All","Directory.ReadWrite.All","AuditLog.Read.All","UserAuthenticationMethod.Read.All"
```

The first connection in a tenant must be made by a Global Admin to consent to the Graph PowerShell app for the organization. After that, the scripts can run under the IT admin account, which can only do what its admin roles allow: a script can't exceed the permissions of the account running it.

```
02-automation/
├── scripts/   # the .ps1 files
├── data/      # input CSVs (sample data only)
├── reports/   # output CSVs (not committed: contain user names)
└── logs/      # transcripts (not committed)
```

All file paths use `$PSScriptRoot`, so the scripts work no matter which folder they're run from.

## 1. Onboarding: `New-RidgelineUser.ps1`

Reads a CSV of new hires, creates each account with a temporary password that must be changed at first sign-in, and adds the user to their role group and to `SG-Licensed-BusinessPremium`, which licenses them automatically.

**Design choices:**
- **`-WhatIf` dry run:** shows exactly what would be created without changing anything.
- **Idempotent:** skips users who already exist, so it's safe to run twice.
- **Logged:** `Start-Transcript` records every run.

The second run of the same CSV skipped both users with warnings instead of creating duplicates:

![Onboarding run and idempotent rerun](images/onboarding-idempotent.png)

<!-- TODO: blur the temporary passwords and the lab-credentials file name in this screenshot before adding it. -->

**Security note:** the script prints each temporary password, which means the transcript log captures it too. That's acceptable in a lab, but in production the password would be delivered securely to the manager, or replaced with a Temporary Access Pass, and never written to a log.

## 2. Offboarding: `Remove-RidgelineUser.ps1`

The steps run in a deliberate order:

1. **Block sign-in and revoke sessions.** Disabling an account doesn't log out a phone that's already signed in; `Revoke-MgUserSignInSession` does.
2. **Convert the mailbox to shared and give the manager access**, *before* removing licenses. If the license is removed first, the mailbox data is deleted after a grace period. Converting first preserves it.
3. **Remove all group memberships**, which also frees the group-based license.
4. **Stamp the department field** with `OFFBOARDED <date>` so the next admin knows what happened.

The account is disabled, not deleted, so it's easy to reverse: re-enable it, convert the mailbox back, and re-add groups.

![User offboarded](images/offboarding-result.png)

**Problems I hit:**
- **"Successful" run, but nothing changed.** I had rerun the command with `-WhatIf` still on the end. A dry run prints output with no errors, so it *looks* successful. The clue was that no log file was created. Lesson: verify the result, don't trust the absence of errors.
- **"Couldn't convert the mailbox, it is already Shared"** on a later run. This was a warning, not an error: the earlier run had worked, and the admin center was showing a cached page. Querying Graph directly confirmed the account was disabled and stamped.

## 3. Stale accounts: `Get-StaleAccounts.ps1`

Exports enabled accounts that haven't signed in within N days (default 90). New accounts under 14 days old are skipped so new hires aren't flagged on their first day.

To test it in a brand-new tenant, I ran it with `-Days 0` and the 14-day filter temporarily disabled. Every enabled account appeared, and the offboarded (disabled) user correctly did not.

![Stale account report](images/stale-accounts.png)

**Notes:**
- **Debugging an empty report:** at first the CSV stayed empty. I tested each stage of the pipeline separately and found my `#` had commented out only the end of the line, leaving the 14-day filter active.
- The **LastSignIn** column was blank even for users who had signed in. Sign-in activity data lags, so a brand-new tenant shows little of it.
- **In production** I'd exclude the break-glass account, which will always look stale by design and should be watched with a sign-in alert instead.

## 4. MFA gaps: `Get-MfaGaps.ps1`

Uses Microsoft's authentication-methods registration report to list users without MFA.

**Problem:** the report returned nothing. Microsoft builds it in the background, and in a new tenant it can take up to a day to populate. An empty file was ambiguous: did it mean "everyone has MFA" or "no data"? I changed the script to:
- warn and stop when the report returns no data
- print a summary ("X users checked, Y without MFA")

For a real-time answer, I also checked each user's registered methods directly, one Graph call per user:

![Live MFA check](images/mfa-live-check.png)

<!-- TODO: this result shows the admin account with 0 MFA methods. Re-run it and either document fixing it or explain the result. -->

**Trade-off:** the report is fast and scales to thousands of users but is cached; the per-user lookup is always current but makes one call per user. I'd use the report for a weekly review and the live lookup for one user on the phone.

## 5. Group audit: `Get-GroupAudit.ps1`

Lists every member of every `SG-` group to a CSV. I wrote it after an app deployment in Project 3 failed because a superintendent had never been added to `SG-Field`. A monthly access review catches mistakes like that before they become tickets.

![Group audit](images/group-audit.png)

## Lessons

- A dry run and a quiet success look the same. Build in clear output and verify against the source of truth.
- Relative paths depend on where you run a script from; `$PSScriptRoot` makes them reliable.
- Reports built on Microsoft's cached data lag in new tenants. Know which data is live and which isn't.
- When a command complains about an empty value, check whether the variable was ever set.
