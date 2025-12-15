# RouterOS Diagnostics Tool - Usage Guide

## Quick Start

### Run diagnostics on all routers
```bash
npm start
# or
npm run diagnose
```

### Run specific diagnostic categories

```bash
# System info only (CPU, memory, uptime)
npm run diagnose:system

# Interfaces only
npm run diagnose:interfaces

# Routing info only (routes, firewall, BGP/OSPF)
npm run diagnose:routing
```

### Run diagnostics on a specific router

```bash
npm start -- --router "WIFILINK - GUADALUPE"
```

### List all routers

```bash
npm run list
```

### Show router groups summary

```bash
npm run groups
```

## Claude Code Slash Commands

When using Claude Code, you have access to these slash commands:

### `/diagnose`
Run full diagnostics on all configured routers.

### `/diagnose-router`
Run diagnostics on a specific router. Claude will ask which router to diagnose.

### `/diagnose-group`
Run diagnostics on all routers in a specific group (e.g., WIFILINK, WISP, PAC, etc.).

### `/list-routers`
Display all configured routers organized by group.

### `/system-check`
Quick health check - system diagnostics only (fastest).

### `/interface-check`
Check all network interfaces and traffic stats.

### `/routing-check`
Check routing tables, firewall rules, and BGP/OSPF status.

## Filter by Router Group

Use the filter script to run diagnostics on a specific group:

```bash
# Filter by group
node filter-routers-by-group.js WIFILINK

# Then run diagnostics on the filtered config
npm start -- --config routers-temp.json
```

Available groups:
- **WIFILINK** (11 routers) - WiFiLink network sites
- **WISP** (8 routers) - WISP infrastructure
- **PAC** (6 routers) - PAC network sites
- **SARTEK** (5 routers) - Sartek locations
- **LUIS** (4 routers) - Personal routers
- **MONSTER** (3 routers) - Monster network
- **WEBZY** (2 routers) - Webzy sites
- **SMARTWIFI** (1 router) - SmartWiFi location
- **LAWNDALE** (1 router) - Lawndale site

## Advanced Usage

### Custom configuration file

```bash
npm start -- --config /path/to/custom-config.json
```

### Combine filters

```bash
# System diagnostics on specific router
npm start -- --router "LUIS - 10.10.30.1" --category system

# Routing diagnostics on group
node filter-routers-by-group.js PAC
npm start -- --config routers-temp.json --category routing
```

## Understanding the Output

### System Information
- **Version**: RouterOS version number
- **Board**: Hardware model
- **CPU**: Processor type and load percentage
- **Memory**: Free/Total memory
- **Uptime**: How long the router has been running

### Interface Status
- **UP** (green): Interface is running
- **DOWN** (red): Interface is not running
- **DISABLED** (gray): Interface is administratively disabled
- **RX/TX**: Received/Transmitted bytes and packets

### Routing Information
- **Routes**: Total routing table entries
- **Firewall Rules**: Number of filter and NAT rules
- **BGP Peers**: Border Gateway Protocol peering status
- **OSPF Neighbors**: OSPF routing protocol neighbors

## Exit Codes

- **0**: All routers connected successfully
- **1**: One or more routers failed to connect or had errors

## Troubleshooting

### Connection failures

If a router shows "Connection failed":
1. Verify the router is online
2. Check SSH is enabled on port configured in `routers.json`
3. Verify credentials are correct
4. Test network connectivity: `ping <router-host>`
5. For VPN/ZeroTier routers, ensure VPN is connected

### Timeout errors

Increase SSH timeout in `src/ssh-client.ts` if needed:
```typescript
readyTimeout: 20000,  // Increase from 10000
```

### Permission errors

Ensure the router user has sufficient permissions to run:
- `/system resource print`
- `/interface print`
- `/ip route print`
- `/routing bgp peer print`
- `/routing ospf neighbor print`

## Performance Tips

1. **Run system checks first** - Fastest way to verify connectivity
2. **Use groups** - Diagnose specific groups instead of all routers
3. **Parallel execution** - The tool runs diagnostics concurrently
4. **Filter by category** - Only run the diagnostics you need

## Automation

### Schedule with cron

```bash
# Run diagnostics daily at 6 AM
0 6 * * * cd /path/to/RouterOs && npm start > /var/log/routeros-diag.log 2>&1
```

### Save output to file

```bash
npm start > diagnostics-$(date +%Y%m%d).log 2>&1
```

### Monitor specific routers

```bash
# Monitor critical routers every 5 minutes
*/5 * * * * cd /path/to/RouterOs && npm start -- --router "CRITICAL-ROUTER" --category system
```
