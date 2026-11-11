# Runbook: Setting Up a Jobsite Trailer Network

Use this when a new jobsite opens and its trailer needs internet, staff Wi-Fi, guest Wi-Fi, and a connection back to the office. The design is the one from Project 4.

Owner: IT Specialist
Last reviewed: November 2026

## Equipment

- Router or firewall for the trailer (the internet link and the VPN back to the office)
- Switch with at least one trunk port
- Two access points: one for staff, one for guests
- Plan printer
- Internet connection for the trailer, usually a cellular gateway or fixed wireless

## Address plan

| Network | VLAN | Subnet | Gateway |
| --- | --- | --- | --- |
| Staff | 10 | 10.20.10.0/24 | 10.20.10.1 |
| Devices (printer, cameras) | 20 | 10.20.20.0/24 | 10.20.20.1 |
| Guest | 30 | 10.20.30.0/24 | 10.20.30.1 |

Each new site gets its own 10.x range so it doesn't overlap with the office (10.10.10.0/24) or other sites.

## Steps

1. Cable it: router G0/0 to switch G0/1 (trunk), staff access point to switch Fa0/1, guest access point to Fa0/2, printer to Fa0/3.
2. On the switch, create VLANs 10, 20, and 30. Set G0/1 as a trunk, and set Fa0/1 to VLAN 10, Fa0/2 to VLAN 30, and Fa0/3 to VLAN 20.
3. On the router, create a subinterface for each VLAN on G0/0 with its gateway address, and set up a DHCP pool for each one. Exclude the first ten addresses in each pool.
4. Apply the guest isolation ACL inbound on the guest subinterface: deny guest traffic to any 10.x address, then permit everything else.
5. Set up NAT on the internet interface. Exclude staff-to-office traffic from NAT so it can use the VPN.
6. Enable the router's security license if needed (`securityk9`, then save and reload), and configure the site-to-site VPN to the office. The pre-shared key and peer address must point at the office router, and the office router needs a matching entry pointing back at this site.
7. Name each access point's SSID (`Ridgeline-Staff`, `Ridgeline-Guest`) with separate WPA2 passphrases. Do this before anyone connects, so no guest device joins the staff network by accident.
8. Save the running config on every device (`write memory`) and copy it to the configs folder.

## Sign-off tests

Every row has to match before the trailer is handed over to the site.

| From | Test | Expected |
| --- | --- | --- |
| Staff laptop | Ping the office file server | Works, through the VPN |
| Staff laptop | Open a website | Works |
| Guest laptop | Open a website | Works |
| Guest laptop | Ping the office file server | Fails |
| Guest laptop | Ping the printer | Fails |
| Trailer router | `show crypto ipsec sa` | Encrypted packet counts above 0 |

## If something goes wrong

- A device with a 169.254 address never got a response from DHCP. Check its Wi-Fi connection and SSID first, then the VLAN on its switch port, the router subinterface, and the DHCP pool.
- If the VPN won't come up, see the VPN troubleshooting runbook.
