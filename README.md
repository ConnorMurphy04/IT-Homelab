# IT Homelab: Ridgeline Builders

This is a homelab where I built and ran the IT environment for a made-up construction company called Ridgeline Builders. The company has one office, two jobsites, and about a dozen employees. Each project lines up with the day-to-day work of an IT support role: managing accounts and access, scripting repetitive tasks, deploying laptops, and setting up jobsite networks.

I built everything in a Microsoft 365 Business Premium trial tenant, a Windows 11 virtual machine, and Cisco Packet Tracer. Each project's README covers what I set up, what broke along the way, and how I tracked down the cause.

## Projects

| # | Project | What it covers | Status |
| --- | --- | --- | --- |
| 1 | [Microsoft 365 / Entra ID tenant](01-m365-tenant/) | Users, group-based licensing, admin roles, break-glass account, Conditional Access MFA, Exchange, Teams | Done |
| 2 | [PowerShell automation](02-automation/) | Onboarding, offboarding, stale accounts, MFA gaps, and group audits with Microsoft Graph | Done |
| 3 | [Intune and Autopilot](03-intune-autopilot/) | Device enrollment, compliance, BitLocker, update rings, app deployment, Autopilot, asset inventory | Done |
| 4 | [Jobsite trailer network](04-jobsite-network/) | VLANs, DHCP, guest isolation, NAT, and a site-to-site VPN in Packet Tracer | Done |
| 5 | [Help desk and documentation](05-help-desk/) | Jira Service Management queue, SLAs, tickets from the lab, problem records, runbooks | In progress |
| 6 | Backup and restore testing | Veeam Agent, Microsoft 365 recovery tests | Planned |

## Some things I'm proud of

- Licenses are assigned by group membership, and IT work happens from a separate admin account with only the roles it needs.
- I rolled out MFA with Conditional Access in report-only mode first, with an emergency account excluded so a bad policy couldn't lock everyone out.
- Five PowerShell scripts that are safe to rerun, support `-WhatIf` dry runs, and log what they did.
- A Windows laptop registered in Autopilot sets itself up when a new hire signs in.
- Three troubleshooting write-ups (BitLocker compliance, Autopilot, and the VPN) where I followed the evidence to the actual cause.

## Tools

- Microsoft 365 Business Premium (Entra ID P1, Intune, Exchange Online, Teams)
- PowerShell 7 with the Microsoft Graph and Exchange Online modules, on macOS
- Windows 11 Pro (Arm64) in VMware Fusion on an M3 Mac
- Cisco Packet Tracer
- Jira Service Management

All names, users, and devices are fictional, and no credentials are stored in this repo.
