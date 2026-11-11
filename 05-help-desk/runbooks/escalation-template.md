# Escalation Template

Use this whenever you pass an issue to a vendor, the internet provider, or the IT Director. The goal is that they can start working on it right away without having to come back with questions.

Copy it into the email or the Jira ticket and fill in every line.

```
Summary: One sentence on what's broken and who it affects.

Ticket: RIT-___

Impact: Who can't work, how many people, and since when.

Environment: Site, device, user, and app or firmware version.

Steps to reproduce: What someone does to see the problem.

What I've tried:
1. ___ (result: ___)
2. ___ (result: ___)

What I need: The decision, access, or action I'm asking for.

Contact: Who to call back, and when they're available.
```

## Example

```
Summary: The Maple St trailer can't reach the office file server over the site-to-site VPN. Internet access at the trailer is working.

Ticket: RIT-8

Impact: 6 field staff can't open project drawings on the file server, since 7:30 am today.

Environment: Maple St trailer router (Cisco 2911) to the office router, IPsec site-to-site VPN.

Steps to reproduce: From a staff laptop on Ridgeline-Staff, ping 10.10.10.10.

What I've tried:
1. Pinged the office router's public address from the trailer router (result: works, so the internet link is up)
2. Checked show crypto map on both routers (result: config present and applied to G0/1)
3. Checked show crypto isakmp sa (result: MM_KEY_EXCH, then deleted)

What I need: Confirmation of the pre-shared key and peer address configured on the office router.

Contact: Connor Murphy, IT, available all day.
```
