# Runbook: Onboarding a New Employee

Use this when HR or a manager submits an "Onboard new employees" request. Following it means a new hire has an account, the right access, a working laptop, and MFA set up before their first day.

Owner: IT Specialist
Last reviewed: November 2026

## Before you start

- A Jira ticket from HR or the hiring manager with the new hire's name, job title, department, start date, and manager
- At least two business days before the start date
- Access to the IT admin account (User Administrator and License Administrator roles)
- PowerShell 7 with the Microsoft Graph module

## Steps

1. Assign the ticket to yourself and set it to In Progress.
2. Add the new hire to `02-automation/data/new-hires.csv` with their first name, last name, job title, department, and role group (for example, `SG-Field`).
3. Connect to Microsoft Graph:

   ```powershell
   Connect-MgGraph -Scopes "User.ReadWrite.All","Group.ReadWrite.All","Directory.ReadWrite.All"
   ```

4. Do a dry run and check the output:

   ```powershell
   ./New-RidgelineUser.ps1 -CsvPath ../data/new-hires.csv -WhatIf
   ```

5. Run it for real. Copy each temporary password into a secure note right away, since it's only shown once.

   ```powershell
   ./New-RidgelineUser.ps1 -CsvPath ../data/new-hires.csv
   ```

6. If the new hire needs a laptop, assign one from the spare pool in the asset inventory. Company laptops are registered in Autopilot, so they set themselves up on first sign-in. Update the inventory with the assigned user and location.
7. If they need access to a shared mailbox or a jobsite Teams team, ask the mailbox owner or team owner to add them.
8. Reply to the manager on the ticket with what's ready and what the new hire needs to bring (their phone, for MFA). Don't put the temporary password in the ticket. Give it to the manager by phone or in person.

## Check that it worked

- The user appears in the Microsoft 365 admin center with the right job title and department.
- Their Business Premium license shows as "Inherited" from `SG-Licensed-BusinessPremium`. Licensing can take a few minutes.
- Their mailbox exists. A new mailbox can take up to an hour; an Exchange "recipient not found" error before then is normal.
- On the first day, they're required to change their password and set up Microsoft Authenticator.

## If something goes wrong

- If the script says the user already exists, it skipped them on purpose. Check whether they were created on an earlier run.
- If the license or apps don't show up, check that the user is in both their role group and `SG-Licensed-BusinessPremium`. Run `Get-GroupAudit.ps1` to see every group's members.
- If the account was created by mistake, disable it rather than deleting it, and note it on the ticket.
