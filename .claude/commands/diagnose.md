---
description: Run full diagnostics on all configured routers
---

Run the RouterOS diagnostics tool on all routers in the configuration file. This will execute system, interface, and routing diagnostics concurrently.

Execute: `npm start`

Display the results in a formatted table showing:
- Connection status
- System information (CPU, memory, uptime, version)
- Interface statistics
- Routing table and firewall rules
- BGP/OSPF neighbors (if configured)
