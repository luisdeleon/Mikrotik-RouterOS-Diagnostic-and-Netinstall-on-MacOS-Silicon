---
description: Run diagnostics on routers from a specific group
---

Run diagnostics on all routers belonging to a specific group (WIFILINK, WISP, PAC, SARTEK, LUIS, MONSTER, WEBZY, SMARTWIFI, or LAWNDALE).

Steps:
1. Ask the user which group they want to diagnose
2. Read `routers.json` to filter routers by group name
3. Create a temporary config file with only those routers
4. Run diagnostics on that subset
5. Display the results

Available groups:
- WIFILINK (11 routers) - WiFiLink network sites
- WISP (8 routers) - WISP infrastructure
- PAC (6 routers) - PAC network sites
- SARTEK (5 routers) - Sartek locations
- LUIS (4 routers) - Luis's personal routers
- MONSTER (3 routers) - Monster network
- WEBZY (2 routers) - Webzy sites
- SMARTWIFI (1 router) - SmartWiFi location
- LAWNDALE (1 router) - Lawndale site
