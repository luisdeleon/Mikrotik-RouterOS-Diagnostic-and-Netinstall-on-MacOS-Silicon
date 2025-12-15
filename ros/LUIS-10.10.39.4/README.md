# Access Point Optimization Guide
## pachome-rb493g - 10.10.39.4 (RB493G)

---

## Quick Reference

**Router Details:**
- **Name**: pachome-rb493g
- **IP Address**: 10.10.39.4
- **Model**: RouterBOARD 493G
- **Current Firmware**: 7.16.1
- **CPU**: MIPS AR7161 @ 680MHz (single-core)
- **Memory**: 256MB
- **Storage**: 128MB NAND (3% bad blocks)
- **Role**: Access Point / Managed Switch (2nd Floor)

**Current Issues Found:**
1. WiFi NOT configured at all
2. Using old 'wireless' package (not wifi-qcom)
3. 3% bad blocks on storage (hardware degradation)
4. Single-core CPU at 26% load (limited capacity)
5. Just rebooted (16 min uptime - stability concern)
6. Legacy hardware with limited capabilities

---

## CRITICAL WARNING

**Storage Health**: This device has **3% bad blocks** on its NAND storage. While this is currently acceptable, it indicates hardware degradation.

**Action Required**:
- Create backups **weekly** (automated reminder included in script)
- Monitor bad block percentage monthly
- Plan for device replacement if bad blocks exceed 5%
- Never store critical data only on this device

---

## How to Apply the Optimization Script

### Step 1: Connect to Router
```bash
# Via SSH (from your computer)
ssh admin@10.10.39.4

# Or use WinBox
```

### Step 2: Create Backup (ABSOLUTELY CRITICAL!)
```routeros
# Upload and run the backup script
/import BACKUP-FIRST.rsc

# Wait for completion, then download backups to your computer
# Files will be named: backup-pachome-rb493g-10.10.39.4-DATE-TIME.*

# IMPORTANT: Store backups off-device due to storage issues!
```

### Step 3: Upload the Optimization Script
**Option A - Via WinBox:**
1. Open WinBox and connect to 10.10.39.4
2. Go to Files
3. Drag and drop `LUIS-10.10.39.4-optimization.rsc` to the router
4. Wait for upload to complete

**Option B - Via SCP:**
```bash
scp LUIS-10.10.39.4-optimization.rsc admin@10.10.39.4:/
```

### Step 4: Review the Script
```routeros
# View the script before running
/file print detail where name="LUIS-10.10.39.4-optimization.rsc"
```

### Step 5: Import and Apply
```routeros
# Import the script (this applies all changes)
/import LUIS-10.10.39.4-optimization.rsc

# Check logs to see what was applied
/log print where topics~"script"
```

### Step 6: Verify Optimization
```routeros
# Run verification script
/import VERIFY-OPTIMIZATION.rsc

# Check system resources
/system resource print
```

---

## What the Script Does

### 1. Basic WiFi Setup (Legacy Wireless Package)
- **Configures WiFi** using old 'wireless' package (not wifi-qcom)
- **SSID**: SatLink-2G-2ndFloor
- **Security**: WPA2-PSK
- **Channel Width**: 20MHz (forced for stability)
- **Note**: RB493G uses legacy wireless system
- **Impact**: Enables basic WiFi functionality

> **Note**: Some RB493G devices may not have WiFi hardware. If WiFi is not needed, this is normal and safe.

### 2. Storage Health Monitoring
- **Monitors bad blocks** hourly
- **Logs warnings** if bad blocks increase
- **Critical alerts** if bad blocks exceed 5%
- **Impact**: Early warning of storage failure

> **CRITICAL**: This is the most important optimization given 3% bad blocks!

### 3. Single-Core CPU Optimization
- **Optimizes connection tracking** for single-core performance
- **Reduces timeouts** to prevent overload
- **Limits DNS cache** to save memory
- **Impact**: Better performance on limited hardware

> **Note**: This is a single-core MIPS CPU - don't overload with heavy tasks!

### 4. Security Hardening
- **Changes SSH port** from 22 to 2222
- **Restricts all services** to local network (10.10.39.0/24)
- **Disables insecure services** (Telnet, FTP)
- **Impact**: Better security posture

> **IMPORTANT**: After applying, connect to SSH using port 2222:
> ```bash
> ssh -p 2222 admin@10.10.39.4
> ```

### 5. System Stability
- **Enables hardware watchdog**
- **Auto-recovery** after crashes or hangs
- **Automatic supout** on critical errors
- **Impact**: Better reliability (important given recent reboot)

### 6. Resource Monitoring
- **Monitors CPU and memory** every 10 minutes
- **Logs warnings** for:
  - CPU load > 60% (critical for single-core)
  - Memory usage > 75%
- **Impact**: Proactive problem detection

### 7. Backup Reminder System
- **Weekly reminders** to create backups
- **Critical due to storage bad blocks**
- **Impact**: Prevents data loss

### 8. Wireless Monitoring (if configured)
- **Monitors WiFi clients** every 15 minutes
- **Logs weak signal clients**
- **Impact**: WiFi performance tracking

---

## Monitoring After Application

### Check System Resources
```routeros
/system resource print
# Watch CPU load (single-core!) and memory usage
# Check bad blocks percentage
```

### Check Storage Health
```routeros
# Check bad blocks
/system resource print
# Look for "bad-blocks" percentage

# If bad blocks increase, backup immediately!
```

### Check WiFi (if configured)
```routeros
# List WiFi interfaces
/interface wireless print

# Monitor WiFi
/interface wireless monitor [find]

# List connected clients
/interface wireless registration-table print
```

### Review Monitoring Logs
```routeros
# Check storage monitoring output
/log print where message~"Storage Health"

# Check resource monitoring output
/log print where message~"Resource Monitor"

# Check for errors
/log print where topics~"error|critical"
```

### Check Scheduled Tasks
```routeros
# List all monitoring tasks
/system scheduler print

# Should see:
# - storage-monitor-schedule (hourly)
# - resource-monitor-schedule (10 min)
# - backup-reminder-schedule (weekly)
```

---

## Customization Guide

### Enable/Configure WiFi Manually
If WiFi hardware is present but not auto-configured:

```routeros
# Check for wireless interfaces
/interface wireless print

# Configure first wireless interface
/interface wireless set wlan1 \
    mode=ap-bridge \
    ssid=YourSSID \
    band=2ghz-b/g/n \
    channel-width=20mhz \
    frequency=auto \
    wireless-protocol=802.11 \
    disabled=no

# Set WiFi password
/interface wireless security-profiles set default \
    mode=dynamic-keys \
    authentication-types=wpa2-psk \
    wpa2-pre-shared-key=YourPassword
```

### Adjust Resource Monitoring Thresholds
If you get too many warnings:

```routeros
# Edit the resource monitoring script
/system script edit resource-monitor-script

# Change thresholds:
# - CPU warning: 60% (increase if needed)
# - CPU critical: 80%
# - Memory warning: 75%
# - Memory critical: 90%
```

### Change Monitoring Intervals
```routeros
# Storage monitoring (default: hourly)
/system scheduler set storage-monitor-schedule interval=30m

# Resource monitoring (default: 10 min)
/system scheduler set resource-monitor-schedule interval=5m

# Backup reminder (default: weekly)
/system scheduler set backup-reminder-schedule interval=3d
```

### Revert SSH Port to 22
```routeros
/ip service set ssh port=22
```

---

## How to Revert Changes

### Full Revert
```routeros
# Import your backup
/import backup-pachome-rb493g-10.10.39.4-DATE-TIME.rsc

# Reboot router
/system reboot
```

### Partial Revert - Remove Monitoring
```routeros
# Remove schedulers
/system scheduler remove storage-monitor-schedule
/system scheduler remove resource-monitor-schedule
/system scheduler remove backup-reminder-schedule
/system scheduler remove wireless-monitor-schedule

# Remove scripts
/system script remove storage-monitor-script
/system script remove resource-monitor-script
/system script remove backup-reminder-script
/system script remove wireless-monitor-script
```

### Partial Revert - Security
```routeros
# SSH back to port 22
/ip service set ssh port=22

# Remove address restrictions
/ip service set ssh address=""
/ip service set www address=""
/ip service set winbox address=""
```

---

## Expected Results

After applying the script, you should see:

| Metric | Before | Expected After | Improvement |
|--------|--------|----------------|-------------|
| WiFi Configured | No | Yes (if hardware present) | Basic functionality |
| Storage Monitoring | No | Hourly checks | Early warning system |
| CPU Optimization | No | Yes | Better performance |
| Security Score | Low | High | Hardened |
| Backup Reminders | No | Weekly | Data protection |
| Resource Monitoring | No | Active | Proactive alerts |
| System Stability | Unknown | Improved | Watchdog enabled |

---

## Troubleshooting

### Can't Connect to SSH After Script
**Problem**: SSH port changed to 2222
**Solution**: Use new port
```bash
ssh -p 2222 admin@10.10.39.4
```

### No WiFi Interface Found
**Problem**: Hardware may not have WiFi capability
**Solution**: This is normal for some RB493G configurations
- Device can still function as wired switch
- No action needed if WiFi not required

### High CPU Warnings
**Problem**: Single-core CPU is limited
**Solutions**:
1. This is normal for single-core device
2. Avoid running intensive tasks
3. Consider offloading to more powerful device
4. Increase warning threshold if false alarms

### Bad Blocks Increasing
**Problem**: Storage degradation
**Solutions**:
1. **Immediate**: Create full backup
2. **Short-term**: Increase backup frequency
3. **Long-term**: Plan device replacement
4. **If > 5%**: Replace device immediately

### Device Keeps Rebooting
**Problem**: Stability issues
**Solutions**:
1. Check power supply (ensure stable power)
2. Consider UPS if not present
3. Check logs before reboot: `/log print`
4. Watchdog may be recovering from hangs (this is good)

### Monitoring Scripts Not Running
**Problem**: Schedulers may be disabled
**Solution**:
```routeros
# Enable scheduler
/system scheduler set [find] disabled=no

# Check next run time
/system scheduler print
```

---

## Legacy Hardware Considerations

### Understanding RB493G Limitations

**This is Legacy Hardware**:
- Released: ~2008-2010
- CPU: Single-core MIPS (slow by modern standards)
- Wireless: Old 'wireless' package (if present)
- Storage: NAND with bad blocks developing

**What It Can Do Well**:
- Basic switching (9 ethernet ports)
- Simple access point (if WiFi hardware present)
- Light routing tasks
- Management/monitoring

**What to Avoid**:
- Heavy firewall rules
- Large routing tables
- Bandwidth-intensive QoS
- CPU-intensive VPN
- Large numbers of simultaneous connections

### Replacement Planning

**Consider Replacement When**:
- Bad blocks exceed 5%
- CPU constantly > 70%
- Device reboots frequently
- Newer features needed (WiFi 6, faster CPU, etc.)

**Recommended Replacements**:
- hAP ac^2 or ac^3 (similar to main router)
- Modern ARM-based devices
- Better WiFi performance
- More memory and storage

---

## Support Commands

### Get System Info
```routeros
/system resource print
/system routerboard print
/system package print
```

### Check Storage Health
```routeros
# Detailed resource info
/system resource print

# Look for these values:
# - bad-blocks: X%
# - write-sect-total: XXXXXX
```

### Get Network Stats
```routeros
/interface print stats
/ip address print
```

### WiFi Commands (if configured)
```routeros
/interface wireless print
/interface wireless monitor [find]
/interface wireless registration-table print
```

### Export Current Config
```routeros
/export file=current-config
```

---

## Post-Application Checklist

- [ ] Backup created and downloaded to safe location
- [ ] Backup stored OFF this device (critical!)
- [ ] Script uploaded to router
- [ ] Script imported successfully
- [ ] SSH port changed (update connection method)
- [ ] WiFi configured (if hardware present)
- [ ] Storage monitoring active
- [ ] Resource monitoring active
- [ ] Backup reminders enabled
- [ ] No errors in logs
- [ ] Bad blocks percentage noted for future comparison

---

## Regular Maintenance Schedule

### Daily (Automated)
- Storage health checks (hourly)
- Resource monitoring (every 10 min)

### Weekly
- Create full backup (reminder automated)
- Review monitoring logs
- Check for firmware updates

### Monthly
- Check bad blocks percentage (compare to baseline)
- Review system performance
- Clean up old files

### Quarterly
- Full configuration backup (off-device)
- Consider firmware upgrade (test first!)
- Evaluate device health for replacement planning

---

## Backup Procedures

### Creating Backups (CRITICAL for this device!)

```routeros
# Create configuration export
/export file=backup-YYYYMMDD

# Create binary backup
/system backup save name=backup-YYYYMMDD

# List files
/file print where name~"backup"

# Download via SCP
# scp admin@10.10.39.4:backup-YYYYMMDD.* .
```

### Restoring Backups

```routeros
# Restore configuration
/import backup-YYYYMMDD.rsc

# Or restore binary backup
/system backup load name=backup-YYYYMMDD

# Reboot after restore
/system reboot
```

---

## Notes

- **Run time**: Script takes ~20-40 seconds to apply
- **No reboot needed**: Changes apply immediately
- **Reversible**: All changes can be reverted with backup
- **Safe**: Script only modifies configuration
- **Tested**: Based on RouterOS 7.x on legacy hardware
- **Storage**: 3% bad blocks requires regular backups!
- **CPU**: Single-core limits performance - this is normal

---

**Generated**: 2025-12-14
**For Router**: pachome-rb493g - 10.10.39.4 (RB493G)
**Script Version**: 1.0
**Role**: Access Point / Managed Switch (Legacy Hardware)
**Hardware Status**: Functional with storage degradation (3% bad blocks)
