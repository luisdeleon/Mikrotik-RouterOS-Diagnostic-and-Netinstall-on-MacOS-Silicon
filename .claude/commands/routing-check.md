---
description: Run routing diagnostics only
---

Run routing diagnostics on all routers to check:
- Routing table entries
- Firewall filter rules count
- NAT rules count
- BGP peers status (if configured)
- OSPF neighbors (if configured)

Execute: `npm start -- --category routing`

Useful for verifying routing configurations and peering status.
