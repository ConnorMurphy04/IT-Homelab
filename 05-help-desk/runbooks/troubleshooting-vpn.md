# Runbook: Jobsite Can't Reach the Office (Site-to-Site VPN)

Use this when staff at a jobsite can get on the internet but can't reach office resources like the file server. Work from the bottom up: the internet link first, then the VPN.

Owner: IT Specialist
Last reviewed: November 2026

## 1. Can the two routers reach each other?

From the trailer router, ping the office router's public address:

```
ping 198.51.100.2
```

If this fails, the problem is the internet connection, not the VPN. A tunnel can't run over a link that's down.

## 2. Is the router able to run a VPN at all?

```
show crypto ?
```

If it only offers `key`, the security license isn't active and every crypto command was rejected. Enable it, then save and reload:

```
license boot module c2900 technology-package securityk9
end
write memory
reload
```

After the reload, re-enter the crypto config and watch for `% Invalid input` errors.

## 3. Is the config there on both routers?

Run on both routers:

```
show crypto map
show access-lists
```

- The crypto map should list the peer, the transform set, ACL 110, and the internet interface it's applied to. If it's empty, the config was never saved.
- The key's address and the peer's address must point at the other router, never the router's own address.
- ACL 110 on each side should be the mirror of the other.
- On the trailer router, the NAT ACL must exclude staff-to-office traffic, or the packets get translated and never match the VPN.

## 4. How far is the tunnel getting?

Send a ping from a staff device, then run:

```
show crypto isakmp sa
```

| State | Meaning |
| --- | --- |
| Nothing | No traffic matched the VPN. Check ACL 110 and NAT. |
| MM_NO_STATE or MM_SA_SETUP | The routers disagree on the Phase 1 settings. Compare the ISAKMP policies. |
| MM_KEY_EXCH, then deleted | The pre-shared keys don't match, or a key points at the wrong address. |
| QM_IDLE | The tunnel is up. Check `show crypto ipsec sa` for packets in both directions. |

The first ping or two often time out while the tunnel builds, so always try a second time.

## 5. Still stuck?

In Packet Tracer, use Simulation mode to follow one packet and see exactly where it stops and why. On real equipment, check the router logs. If the office side isn't under your control, escalate with the escalation template and include the output of the commands above.
