# IT Homelab: Ridgeline Builders

A hands-on lab where I built and ran the IT environment for a fictional construction company, **Ridgeline Builders**: one office, two jobsites, about a dozen employees. Each project maps to the day-to-day work of an IT Support Specialist: identity and access, automation, device deployment, jobsite networking, documentation, and backups.

Everything here was built in a real Microsoft 365 Business Premium tenant (trial), a Windows 11 VM, and Cisco Packet Tracer. Every project README documents not just what I built, but what broke and how I tracked down the cause.

## Projects

| # | Project | What it covers | Status |
| --- | --- | --- | --- |
| 1 | [Microsoft 365 / Entra ID tenant](01-m365-tenant/) | Users, group-based licensing, least-privilege admin roles, break-glass account, Conditional Access MFA, Exchange, Teams | ✅ Complete |
| 2 | [PowerShell automation](02-automation/) | Onboarding, offboarding, stale-account, MFA-gap, and group-audit scripts using Microsoft Graph | ✅ Complete |
| 3 | [Intune and Autopilot](03-intune-autopilot/) | Device enrollment, compliance, BitLocker, update rings, app deployment, zero-touch Autopilot, asset inventory | ✅ Complete |
| 4 | [Jobsite trailer network](04-jobsite-network/) | VLAN segmentation, DHCP, guest isolation, NAT, site-to-site IPsec VPN in Packet Tracer | 🚧 In progress |
| 5 | Documentation and ticketing | Help desk queue, runbooks, escalation template | Planned |
| 6 | Backup and restore verification | Veeam Agent, M365 recovery tests, verification log | Planned |

## Highlights

- **Group-based licensing and least privilege:** licenses follow group membership; IT works from a separate, unlicensed admin account with only the roles each task requires.
- **Conditional Access rolled out safely:** MFA and legacy-auth blocking piloted in report-only mode, with a break-glass account excluded from my own policies.
- **Five PowerShell scripts** that are idempotent, support `-WhatIf` dry runs, and log what they did.
- **Zero-touch Windows deployment:** a laptop registered in Autopilot configures itself when a new hire signs in.
- **Two full troubleshooting write-ups** (BitLocker compliance and Autopilot profile delivery) traced from symptom to root cause with evidence.

## Environment

- Microsoft 365 Business Premium (Entra ID P1, Intune, Exchange Online, Teams)
- PowerShell 7 with the Microsoft Graph and ExchangeOnlineManagement modules, on macOS
- Windows 11 Pro (Arm64) in VMware Fusion on an Apple Silicon (M3) Mac
- Cisco Packet Tracer

> All names, users, and devices are fictional. Domains in this repo are replaced with `ridgeline.example`, and no credentials are stored here.
