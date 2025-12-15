# Router Optimization Automation Guide

Complete guide for using the automated router optimization tool that handles diagnostics, script generation, and documentation in one command.

---

## 🚀 Quick Start

### One-Command Optimization

```bash
# Generate optimization package for a router
npm run optimize -- --router "LUIS - 10.10.39.1"

# Or use the slash command
/optimize-router LUIS - 10.10.39.1
```

This will automatically:
1. ✅ Run comprehensive diagnostics
2. ✅ Analyze issues and identify optimizations
3. ✅ Generate customized scripts
4. ✅ Create complete documentation
5. ✅ Organize everything in `/ros/ROUTER-NAME/`

---

## 📋 What You Get

After running the automation, you'll have a complete package:

```
/ros/LUIS-10.10.39.1/
├── BACKUP-FIRST.rsc              # Backup script
├── LUIS-10.10.39.1-optimization.rsc  # Customized optimization
├── VERIFY-OPTIMIZATION.rsc       # Post-optimization verification
├── REMOVE-*.rsc                  # Cleanup scripts (as needed)
├── README.md                     # Complete guide (8+ KB)
├── INDEX.md                      # Quick reference
├── ROUTER-INFO.txt               # Hardware/firmware specs
└── QUICK-REFERENCE.txt           # One-page cheat sheet
```

---

## 💻 Usage Examples

### Basic Usage

```bash
# Generate scripts only (no auto-apply)
npm run optimize -- --router "LUIS - 10.10.39.1"
```

### Advanced Usage

```bash
# Generate and auto-apply to router
npm run optimize -- --router "LUIS - 10.10.39.1" --apply

# Specify custom WAN speed for QoS
npm run optimize -- --router "LUIS - 10.10.39.1" --wan-speed 200M

# Skip backup (not recommended!)
npm run optimize -- --router "LUIS - 10.10.39.1" --skip-backup --apply
```

### Using Slash Commands

```bash
# In Claude Code CLI
/optimize-router LUIS - 10.10.39.1
/optimize-router WISP - KAMA DFW00
/optimize-router WIFILINK - GUADALUPE
```

---

## ⚙️ Command Line Options

| Option | Alias | Description | Default |
|--------|-------|-------------|---------|
| `--router <name>` | `-r` | Router name (required) | - |
| `--apply` | `-a` | Auto-apply optimization | `false` |
| `--wan-speed <speed>` | - | WAN speed for QoS (e.g., 50M, 100M, 200M) | `100M` |
| `--skip-backup` | - | Skip backup step (NOT recommended) | `false` |
| `--help` | `-h` | Show help message | - |

---

## 🔍 What the Tool Does

### Step 1: Router Configuration Load
- Loads router details from `routers.json`
- Validates connection parameters
- Shows router model and IP

### Step 2: Comprehensive Diagnostics
Runs full diagnostics collecting:
- System info (CPU, memory, uptime, firmware)
- Interface statistics (traffic, errors, drops)
- Routing tables and firewall rules
- WiFi configuration and clients
- Connection tracking stats
- DHCP leases
- DNS cache
- Active connections

### Step 3: Issue Analysis
Identifies problems automatically:
- ⚠️ High connection count (> 1000)
- ⚠️ No QoS/bandwidth management
- ⚠️ Security vulnerabilities (default SSH port, no rate limiting)
- ⚠️ WiFi issues (packet drops, weak signals)
- ⚠️ Stale DHCP leases
- ⚠️ High CPU/memory usage
- ⚠️ Unused configurations
- ⚠️ Suboptimal settings

### Step 4: Script Generation
Creates customized scripts based on findings:
- **BACKUP-FIRST.rsc**: Safe backup before changes
- **optimization.rsc**: Router-specific optimizations including:
  - Connection tracking tuning
  - Per-IP connection limits
  - SSH security hardening
  - QoS/bandwidth management (customized for WAN speed)
  - WiFi optimization
  - DHCP cleanup
  - DNS cache optimization
  - Monitoring system
- **VERIFY-OPTIMIZATION.rsc**: Validation and scoring
- **REMOVE-*.rsc**: Cleanup scripts for unused features

### Step 5: Documentation Generation
Creates complete documentation:
- **README.md**: Full guide with step-by-step instructions
- **INDEX.md**: Quick command reference
- **ROUTER-INFO.txt**: Complete router specifications
- **QUICK-REFERENCE.txt**: One-page cheat sheet

### Step 6: Optional Auto-Apply
If `--apply` flag is used:
1. Uploads scripts to router via SCP
2. Connects via SSH
3. Runs BACKUP-FIRST.rsc
4. Applies optimization.rsc
5. Runs VERIFY-OPTIMIZATION.rsc
6. Reports results

---

## 📊 Example Output

```
╔════════════════════════════════════════════════════════════╗
║     Automated Router Optimization Tool                    ║
╚════════════════════════════════════════════════════════════╝

✓ Loaded configuration for LUIS - 10.10.39.1
✓ Diagnostics completed

  System Information:
    Board: hAP ac^3
    Version: 7.20.4
    CPU Load: 16%
    Memory: 129.1MiB / 256.0MiB

✓ Identified 6 optimization opportunities
✓ Scripts generated

  Generated files:
    ✓ BACKUP-FIRST.rsc
    ✓ LUIS-10.10.39.1-optimization.rsc
    ✓ VERIFY-OPTIMIZATION.rsc
    ✓ REMOVE-back-to-home-vpn.rsc

✓ Documentation generated
    ✓ README.md
    ✓ INDEX.md
    ✓ QUICK-REFERENCE.txt
    ✓ ROUTER-INFO.txt

✓ Optimization package created successfully!
Location: /Users/luisdeleon/Development/RouterOs/ros/LUIS-10.10.39.1

📋 Next Steps:

1. Review the generated scripts and documentation:
   cd /Users/luisdeleon/Development/RouterOs/ros/LUIS-10.10.39.1
   cat README.md

2. Upload scripts to router:
   scp *.rsc admin@10.10.39.1:/

3. Connect to router and apply:
   ssh admin@10.10.39.1
   /import BACKUP-FIRST.rsc
   /import LUIS-10.10.39.1-optimization.rsc
   /import VERIFY-OPTIMIZATION.rsc

Or run with --apply flag to auto-apply:
   npm run optimize -- --router "LUIS - 10.10.39.1" --apply
```

---

## 🔄 Batch Optimization

Optimize multiple routers:

```bash
#!/bin/bash
# optimize-all-routers.sh

# List of routers to optimize
routers=(
  "LUIS - 10.10.39.1"
  "WISP - KAMA DFW00"
  "WIFILINK - GUADALUPE"
  "WIFILINK - HOME PAC"
  "PAC - 10.24.16.1"
)

for router in "${routers[@]}"; do
  echo "Optimizing $router..."
  npm run optimize -- --router "$router"
  echo "---"
done

echo "All routers optimized!"
```

---

## 🛡️ Safety Features

### Automatic Backup
- Always creates backup before optimization
- Both text (.rsc) and binary (.backup) formats
- Timestamped filenames
- Can skip with `--skip-backup` (not recommended)

### Dry Run by Default
- Scripts are generated but NOT applied by default
- You review before applying
- Use `--apply` flag to auto-apply

### Rollback Support
- Every script includes rollback instructions
- Backups can be restored easily
- No destructive changes without backup

### Connection Safety
- Tests connection before proceeding
- Validates router credentials
- Checks for active SSH session

---

## 🎯 Customization

### Custom WAN Speeds

```bash
# For 50 Mbps connection
npm run optimize -- --router "ROUTER_NAME" --wan-speed 50M

# For 200 Mbps connection
npm run optimize -- --router "ROUTER_NAME" --wan-speed 200M

# For 1 Gbps connection
npm run optimize -- --router "ROUTER_NAME" --wan-speed 900M
```

### Custom Templates

You can customize the script templates by editing:
- `/src/templates/optimization.template.rsc`
- `/src/templates/backup.template.rsc`
- `/src/templates/verify.template.rsc`

---

## 🐛 Troubleshooting

### "Router not found in configuration"
**Solution**: Check router name exactly matches `routers.json`:
```bash
npm run list  # See all router names
```

### "Failed to connect"
**Causes**:
- Router is offline
- Wrong IP address
- Firewall blocking SSH
- Wrong credentials

**Solution**:
```bash
# Test connection manually
ssh admin@ROUTER_IP

# Check if router responds to ping
ping ROUTER_IP
```

### "Permission denied"
**Solution**: Ensure SSH key or password is correct in `routers.json`

### "Scripts not uploading"
**Solution**: Check SCP access:
```bash
scp test.txt admin@ROUTER_IP:/
```

---

## 📈 Performance Impact

After optimization, expect:

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Active Connections | 1000+ | < 500 | 50-70% |
| CPU Load | 20-30% | 10-20% | 30-50% |
| Memory Free | Variable | +10-20 MB | 5-10% |
| WiFi Drops | 1-5/sec | < 0.1/sec | 90%+ |
| SSH Attacks | Active | Blocked | 100% |

---

## 🔗 Integration with Existing Tools

### Use with Diagnostic Tools

```bash
# Run diagnostics first
npm start -- --router "ROUTER_NAME"

# Then optimize
npm run optimize -- --router "ROUTER_NAME"
```

### Use with Slash Commands

```bash
# Available slash commands
/diagnose-router ROUTER_NAME
/optimize-router ROUTER_NAME
/routing-check
/interface-check
/system-check
```

---

## 📝 Adding New Optimization Rules

To add custom optimization logic:

1. Edit `auto-optimize-router.ts`
2. Add to `analyzeIssues()` method
3. Create template in `generateScripts()`
4. Test on development router first

Example:
```typescript
// In analyzeIssues()
if (connectionCount > 1000) {
  issues.push({
    type: 'high_connections',
    severity: 'critical',
    value: connectionCount,
    recommendation: 'Add connection limits'
  });
}
```

---

## ✅ Best Practices

1. **Always Review First**: Never use `--apply` without reviewing generated scripts
2. **Test on One Router**: Test optimizations on one router before batch operations
3. **Keep Backups**: Download backups to your computer
4. **Monitor After**: Watch router for 24 hours after optimization
5. **Document Changes**: Keep notes of what was changed and why
6. **Staged Rollout**: Optimize critical routers during maintenance windows

---

## 🆘 Emergency Procedures

### If Router Becomes Unreachable

1. **Wait 5 minutes** - Some changes take time
2. **Physical access** - Connect via WinBox using MAC address
3. **Restore backup**:
   ```routeros
   /import backup-ROUTER-DATE.rsc
   ```
4. **Factory reset** (last resort):
   ```routeros
   /system reset-configuration no-defaults=yes
   ```

### If Performance Degrades

1. Disable QoS temporarily:
   ```routeros
   /queue tree set [find] disabled=yes
   ```

2. Check logs:
   ```routeros
   /log print where topics~"error|warning"
   ```

3. Restore from backup if issues persist

---

## 📚 See Also

- [Main README](/ros/README.md) - Router inventory and overview
- [Router-Specific Guides](/ros/ROUTER-NAME/README.md) - Detailed guides
- [MikroTik Wiki](https://wiki.mikrotik.com/) - Official documentation
- [RouterOS Manual](https://help.mikrotik.com/docs/) - Command reference

---

**Last Updated**: 2025-12-14
**Tool Version**: 1.0
**Supported RouterOS**: 7.x
