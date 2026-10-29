# Project 4: Jobsite Trailer Network (Cisco Packet Tracer)

In this project I designed and configured the network for a jobsite trailer and connected it back to the office. It has separate networks for staff, devices, and guests, hands out addresses automatically, keeps guests away from everything internal, gets everyone online, and connects staff to the office over an encrypted site-to-site VPN.

![Topology](images/topology.png)

The Packet Tracer project is `ridgeline-jobsite.pkt`. The `configs/` folder has each router's and switch's running config as plain text, so you can read them without Packet Tracer. The VPN pre-shared key shows up in those configs. It's a lab-only key that isn't used anywhere else, and a real key would never go in a repo.

## Address plan

| Network | VLAN | Subnet | Gateway | Used for |
| --- | --- | --- | --- | --- |
| Trailer staff | 10 | 10.20.10.0/24 | 10.20.10.1 | Laptops, tablets |
| Trailer devices | 20 | 10.20.20.0/24 | 10.20.20.1 | Plan printer, cameras |
| Trailer guest | 30 | 10.20.30.0/24 | 10.20.30.1 | Subs, inspectors, visitors |
| Office LAN | n/a | 10.10.10.0/24 | 10.10.10.1 | Office PCs, file server |
| Office WAN | n/a | 198.51.100.0/30 | ISP .1, office .2 | Office internet link |
| Trailer WAN | n/a | 203.0.113.0/30 | ISP .1, trailer .2 | Trailer internet link |
| "Internet" | n/a | 8.8.8.0/24 | 8.8.8.1 | Public test server (.8) |

The 198.51.100.x and 203.0.113.x ranges are reserved for documentation, so they're safe stand-ins for real public addresses.

Why three VLANs in the trailer: this was intentional in case an "infected" device joins the guest Wi-Fi. That device wouldn't be able to see the staff network, the printer, or anything else sensitive.

## Internet and office

R-ISP stands in for the internet. It has three interfaces: one facing the office (198.51.100.1), one facing the trailer (203.0.113.1), and one for the public test server (8.8.8.1). It has no routes to any 10.x network on purpose, because the real internet doesn't know about a company's private addresses. That's why the trailer needs NAT to get online and a VPN to reach the office.

The public test server is at 8.8.8.8 with HTTP and DNS turned on, so I can test web access from the jobsite.

On R-OFFICE, G0/0 is the gateway for the office LAN (10.10.10.1) and G0/1 is the office's internet link (198.51.100.2). A default route sends everything else to R-ISP. I also turned off domain lookup so a typo in the CLI doesn't freeze the router while it tries to look the typo up as a hostname.

![R-OFFICE LAN interface](images/r-office-lan.png)
![R-OFFICE WAN interface](images/r-office-wan.png)

The file server (10.10.10.10) and office PC (10.10.10.20) have static IPs with 10.10.10.1 as their gateway. The file server is what staff at the trailer reach over the VPN.

## Trailer switch

SWITCH-TRAILER has three VLANs: 10 for staff, 20 for devices like the plan printer, and 30 for guests. Fa0/1 goes to the staff access point (VLAN 10), Fa0/2 to the guest access point (VLAN 30), and Fa0/3 to the printer (VLAN 20). G0/1 is a trunk to the router, carrying all three VLANs over one cable with tags so the router knows which network each frame belongs to.

Which port each device plugs into matters for security. If the guest access point were plugged into the staff port, guests would end up on the staff network.

## Trailer router

R-TRAILER uses one physical port, G0/0, split into three subinterfaces, one per VLAN: G0/0.10 (10.20.10.1), G0/0.20 (10.20.20.1), and G0/0.30 (10.20.30.1). Each one is the gateway for its VLAN, so one router port can serve all three networks over the trunk. G0/1 is the trailer's internet link (203.0.113.2), with a default route to R-ISP.

![R-TRAILER WAN interface](images/r-trailer-wan.png)

There's a DHCP pool for each VLAN with its own gateway and 8.8.8.8 for DNS. I excluded the first ten addresses in each subnet to leave room for devices that need a fixed address.

To keep guests isolated, ACL 130 is applied inbound on the guest subinterface. It drops guest traffic going to any 10.x address and allows everything else, so guests can get online but can't reach the staff network, the printer, or the office. ACLs are checked top to bottom and stop at the first match, so the deny line has to come before the permit.

NAT lets every device in the trailer share the one public address on G0/1. The NAT ACL (ACL 120) has an exception for staff traffic going to the office (10.20.10.0 to 10.10.10.0). That traffic needs to keep its real addresses so it goes through the VPN instead of getting translated.

## Wi-Fi

Each access point has its own SSID, `Ridgeline-Staff` and `Ridgeline-Guest`, using WPA2-PSK with different passphrases. The access points don't handle VLANs themselves; each one just passes along whatever VLAN its switch port is in. The laptops use WPC300N wireless cards and get their addresses from DHCP.

After setup, the guest laptop got a 10.20.30.x address, the staff laptop got a 10.20.10.x address, the printer got a 10.20.20.x address, and the guest laptop could load the test page at `http://8.8.8.8`.

### Guest laptop stuck on 169.254.8.201

The guest laptop first showed an address of 169.254.8.201. A 169.254 address means the device asked for DHCP, didn't hear back, and assigned itself one. I had misnamed the SSID on the guest access point, so the laptop couldn't find the network it was set to join and the wireless connection dropped. After I fixed the SSID, the laptop reconnected and got a 10.20.30.x address.

If someone says they're "connected but nothing works" and they have a 169.254 address, DHCP never answered. I'd check the Wi-Fi connection and SSID first, then the VLAN, the router subinterface, and the DHCP pool.

### Four DHCP leases instead of three

`show ip dhcp binding` on R-TRAILER listed four devices when I expected three. Both access points start with the same default SSID, so before I renamed them, the guest laptop most likely joined the staff network and got a staff lease. When it moved to the guest network it got a new lease, and the router held on to the old one until it expired.

I tried `clear ip dhcp binding *`, but Packet Tracer doesn't support it. Along the way I learned that `clear` commands only work in privileged EXEC mode (the `#` prompt), and that typing `?` after part of a command shows what options the device actually supports.

This also showed a real risk: a guest device ended up on the staff network for a while because of a naming mix-up. Giving each network a unique SSID and passphrase from the start, and checking the DHCP bindings, would prevent or catch that.

## Site-to-site VPN

An IPsec tunnel between R-TRAILER and R-OFFICE lets staff at the trailer reach the office file server, with their traffic encrypted while it crosses the internet. The pieces:

- The `securityk9` license, which turns on the router's encryption features and needs a reload.
- The ISAKMP policy (Phase 1), which is how the two routers verify each other and secure their negotiation: AES-256, SHA, a pre-shared key, and DH group 5. Group 5 is outdated and real setups use group 14 or higher, but Packet Tracer's options are limited.
- The pre-shared key, tied to the other router's public IP.
- The transform set (Phase 2), which is how the actual data gets encrypted: ESP with AES-256 and SHA-HMAC.
- ACL 110, which picks the traffic that goes through the tunnel. Only staff-to-office traffic qualifies, so guests and the printer never use it.
- The crypto map, which ties the peer, transform set, and ACL together and is applied to each router's internet-facing port.

The two routers mirror each other: the key's address, the peer, and ACL 110 on each side all point to the other router.

The staff laptop reached the office file server with 0% packet loss, and the tunnel shows as up (QM_IDLE) with packets being encrypted and decrypted in both directions. The one send error in the IPsec counters is the first packet, which got dropped while the tunnel was still being set up.

![Staff ping over the VPN](images/vpn-ping-success.png)
![ISAKMP SA](images/crypto-isakmp-sa.png)
![IPsec SA](images/crypto-ipsec-sa.png)

### Getting the VPN working

The pings from the staff laptop to the file server failed at first. Here's how I got to the bottom of it:

1. `show crypto ?` only offered `key`. The security license wasn't active, so every crypto command I'd pasted had been rejected without me noticing. I activated the license on both routers, saved, and reloaded.
2. `show crypto map` on R-TRAILER was empty. Only ACL 110 had stuck from the first paste, since plain access lists don't need the license. I re-entered the crypto config.
3. `show crypto isakmp sa` showed MM_KEY_EXCH and then deleted, meaning Phase 1 failed at the key exchange. On R-OFFICE, the pre-shared key and the peer both pointed at its own address (198.51.100.2) instead of the trailer's (203.0.113.2). I fixed both.
4. I compared the full crypto config on both routers side by side, and everything matched. Packet Tracer doesn't support `clear crypto`, so I reloaded both routers to get rid of the old failed attempts.
5. In Simulation mode I followed one packet hop by hop, and it reached the file server. The one "dropped" frame was just the laptop hearing its own wireless frame, which is normal. Since R-ISP has no route to 10.10.10.10, the packet could only have gotten to the office through the encrypted tunnel.

What I took away from this: read the router's output after pasting a config, not just the commands you typed. The key address and peer address always point to the other router. And when `show` commands aren't getting me anywhere, Simulation mode shows exactly where a packet stops and why.

## Test results

| From | Test | Expected | Result |
| --- | --- | --- | --- |
| Staff laptop | Ping office file server (10.10.10.10) | Works, through VPN | Works, 0% loss |
| Staff laptop | Browse to http://8.8.8.8 | Works, through NAT | <!-- TODO --> |
| Guest laptop | Browse to http://8.8.8.8 | Works | Works |
| Guest laptop | Ping office file server | Fails on purpose | <!-- TODO --> |
| Guest laptop | Ping trailer printer | Fails on purpose | <!-- TODO --> |
| R-TRAILER | `show crypto ipsec sa` | Encrypted packet counts above 0 | 13 encrypted, 12 decrypted |

<!-- TODO: add images/guest-blocked.png showing the failed guest ping, and link it here. -->
