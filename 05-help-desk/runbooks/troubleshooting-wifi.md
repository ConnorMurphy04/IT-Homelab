# Runbook: "I'm Connected to Wi-Fi but Nothing Works"

Use this when someone at a jobsite says they're on the Wi-Fi but can't load anything. Work through the questions in order and stop when you find the problem.

Owner: IT Specialist
Last reviewed: November 2026

## 1. What IP address does the device have?

On Windows, run `ipconfig`. On a phone, check the Wi-Fi network details.

- 169.254.x.x: the device asked for an address and DHCP never answered. Go to step 2.
- The wrong range (for example, a guest device with a 10.20.10.x staff address): it joined the wrong network. Check which SSID it's connected to.
- The right range: go to step 4.

## 2. Is it actually connected to the right network?

- Check the SSID it's connected to. A one-character typo in an access point's SSID means devices can't find the network they're configured for.
- Changing an access point's settings disconnects everyone on it, so devices may need to rejoin.
- If only one device is affected, forget the network on that device and rejoin it.

## 3. Is the network side working?

On the switch:

```
show vlan brief
```

Make sure the access point's port is in the right VLAN.

On the router:

```
show ip interface brief
show ip dhcp binding
```

- The subinterface for that VLAN should be up/up. If it's down, check `no shutdown` on the physical port.
- The DHCP binding table shows which devices got addresses. Old leases stay in the table until they expire.

## 4. Can it reach anything?

From the device, ping its gateway, then a public address like 8.8.8.8, then open a website.

- Can't reach the gateway: it's a local problem (VLAN, switch port, Wi-Fi).
- Reaches the gateway but not the internet: check the router's NAT and its internet connection.
- Reaches 8.8.8.8 but websites don't load: check DNS.

## If it's site-wide

If everyone at the trailer is affected, treat it as Highest priority, since a whole crew can't work. Escalate to the internet provider or the IT Director using the escalation template if the router's internet link is down.
