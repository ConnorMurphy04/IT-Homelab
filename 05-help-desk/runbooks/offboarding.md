# Runbook: Offboarding a Departing Employee

Use this when a manager or HR reports that someone is leaving. The goal is to cut off access on their last day without losing any company data, and to get their equipment back.

Owner: IT Specialist
Last reviewed: November 2026

## Before you start

- A Jira ticket with the employee's name, last day, and manager
- Access to the IT admin account with the Exchange Administrator role
- PowerShell 7 with the Microsoft Graph and Exchange Online modules

## Steps

1. Assign the ticket to yourself and set it to In Progress.
2. Confirm the last day and the manager who should get access to the mailbox.
3. On the last day, after the employee finishes work (by 5 pm), connect and do a dry run:

   ```powershell
   Connect-MgGraph -Scopes "User.ReadWrite.All","Group.ReadWrite.All","Directory.ReadWrite.All"
   ./Remove-RidgelineUser.ps1 -UserPrincipalName first.last@ridgeline.example -ManagerUpn manager@ridgeline.example -WhatIf
   ```

4. Run it for real (the same command without `-WhatIf`). It signs in to Exchange Online partway through. The script:
   - blocks sign-in and signs the user out of every device
   - converts their mailbox to a shared mailbox and gives the manager access
   - removes them from all groups, which frees their license
   - sets their department to `OFFBOARDED <date>`
5. Collect their laptop, phone, and any other equipment. Wipe the laptop in Intune, and either retire it or return it to the spare pool. Update the asset inventory.
6. Reply to the manager on the ticket that it's done and how to open the shared mailbox in Outlook.

## Why the order matters

The mailbox has to be converted before the license is removed. If the license goes first, Microsoft deletes the mailbox data after a grace period. Signing the user out matters too: disabling an account doesn't sign out a phone that's already logged in.

## Check that it worked

- The user shows "Sign-in blocked" in the admin center.
- Their mailbox is listed under Shared mailboxes, and the manager can open it.
- They no longer have a license, and the available license count went up by one.
- The `logs` folder has a new offboarding transcript.

## If something goes wrong

- If nothing changed after running the script, check whether `-WhatIf` was still on the command, and whether a new log file was created.
- A warning that the mailbox is "already Shared" means an earlier run already converted it. It isn't an error.
- To bring someone back, re-enable sign-in, convert the mailbox back with `Set-Mailbox -Type Regular`, and add them back to their groups. The account is disabled, not deleted, so this works as long as it hasn't been removed.
