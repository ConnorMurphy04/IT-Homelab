# Project 4: Jobsite Trailer Network (Cisco Packet Tracer)

> 🚧 In progress

**Goal:** Design and configure a jobsite trailer network that connects back to the office: separate networks for staff, devices, and guests, automatic addressing, guest isolation, internet access, and an encrypted site-to-site VPN.

**What it shows:** troubleshooting office and jobsite connectivity (Wi-Fi, switches, routers, trailer setups), firewalls, and VPN.

## Address plan

| Network | VLAN | Subnet | Gateway | Used for |
| --- | --- | --- | --- | --- |
| Trailer staff | 10 | 10.20.10.0/24 | 10.20.10.1 | Laptops, tablets |
| Trailer devices | 20 | 10.20.20.0/24 | 10.20.20.1 | Plan printer, cameras |
| Trailer guest | 30 | 10.20.30.0/24 | 10.20.30.1 | Subs, inspectors, visitors |
| Office LAN | n/a | 10.10.10.0/24 | 10.10.10.1 | Office PCs, file server |
| Office WAN | n/a | 198.51.100.0/30 | ISP .1, office .2 | Office internet link |
| Trailer WAN | n/a | 203.0.113.0/30 | ISP .1, trailer .2 | Trailer internet link |
| "Internet" | n/a | 8.8.8.0/24 | 8.8.8.1 | Public test server .8 |

The 198.51.100.x and 203.0.113.x ranges are reserved for documentation, so they stand in safely for real public addresses.

**Why three trailer VLANs:** This was intentional in the case of an “infected” device joining the public wifi. The infection would be unable to see any other sensitive information.

## Build


## Test results

| From | Test | Expected | Result |
| --- | --- | --- | --- |
| Staff laptop | ping office file server (10.10.10.10) | Success, via VPN | |
| Staff laptop | browse http://8.8.8.8 | Success, via NAT | |
| Guest laptop | browse http://8.8.8.8 | Success | |
| Guest laptop | ping office file server | **Fails** (by design) | |
| Guest laptop | ping trailer printer | **Fails** (by design) | |
| R-TRAILER | `show crypto ipsec sa` | Encrypted packet counters above 0 | |


