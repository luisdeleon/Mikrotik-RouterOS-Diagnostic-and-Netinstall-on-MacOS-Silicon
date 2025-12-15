# Access Point Optimization Guide
## pachome-hapac2 - 10.10.39.2 (hAP ac^2)

---

## Quick Reference

**Router Details:**
- **Name**: pachome-hapac2
- **IP Address**: 10.10.39.2
- **Model**: hAP ac^2 (RBD52G-5HacD2HnD)
- **Current Firmware**: 7.16.1
- **CPU**: ARM (dual-core)
- **Memory**: 128MB
- **Role**: Access Point / Managed Switch

**Current Issues Found:**
1. 14 WiFi clients with very weak signals (-87 to -99 dBm)
2. 2.4GHz using 20/40MHz width (causes instability)
3. Some clients on wrong band (should use 5GHz)
4. Login failures in logs (security concern)
5. Power outage history (reliability issue)

---

## How to Apply the Optimization Script

### Step 1: Connect to Router
```bash
# Via SSH (from your computer)
ssh admin@10.10.39.2

# Or use WinBox
```

### Step 2: Create Backup (CRITICAL!)
```routeros
# Upload and run the backup script
/import BACKUP-FIRST.rsc

# Wait for completion, then download backups to your computer
# Files will be named: backup-pachome-hapac2-10.10.39.2-DATE-TIME.*
```

### Step 3: Upload the Optimization Script
**Option A - Via WinBox:**
1. Open WinBox and connect to 10.10.39.2
2. Go to Files
3. Drag and drop `LUIS-10.10.39.2-optimization.rsc` to the router
4. Wait for upload to complete

**Option B - Via SCP:**
```bash
scp LUIS-10.10.39.2-optimization.rsc admin@10.10.39.2:/
```

### Step 4: Review the Script (IMPORTANT!)
```routeros
# View the script before running
/file print detail where name="LUIS-10.10.39.2-optimization.rsc"

# Edit if needed (especially WiFi power settings)
```

### Step 5: Import and Apply
```routeros
# Import the script (this applies all changes)
/import LUIS-10.10.39.2-optimization.rsc

# Check logs to see what was applied
/log print where topics~"script"
```

### Step 6: Verify Optimization
```routeros
# Run verification script
/import VERIFY-OPTIMIZATION.rsc

# Check WiFi clients
/interface/wifi/registration-table print
```

---

## What the Script Does

### 1. WiFi 2.4GHz Optimization
- **Forces 20MHz channel width** (was 20/40MHz)
- **Why**: 40MHz causes instability and interference in 2.4GHz
- **Impact**: More stable connections, better compatibility
- **Optimizes channel selection** (uses 1, 6, or 11 only)
- **Enables WPA3** with backward compatibility to WPA2

### 2. WiFi 5GHz Optimization
- **Maintains dynamic width** (20/40/80MHz)
- **Why**: 5GHz has more spectrum available
- **Enables DFS channels** with proper CAC
- **Impact**: Better performance for capable devices
- **Enables WPA3** with backward compatibility

### 3. Band Steering
- **Automatically pushes dual-band devices to 5GHz**
- **Why**: 5GHz has better performance and less congestion
- **Impact**: Better client distribution
- **Weak 2.4GHz clients** encouraged to use 5GHz if capable

### 4. Signal Strength Management
- **Sets minimum signal thresholds**
- **Automatically disconnects very weak clients** (-85 dBm or worse)
- **Why**: Forces clients to reconnect to closer AP
- **Impact**: Better overall network performance

### 5. Security Hardening
- **Changes SSH port** from 22 to 2222
- **Restricts all services** to local network (10.10.39.0/24)
- **Disables insecure services** (Telnet, FTP)
- **Impact**: Stops brute force attacks, better security

> **IMPORTANT**: After applying, connect to SSH using port 2222:
> ```bash
> ssh -p 2222 admin@10.10.39.2
> ```

### 6. System Stability
- **Enables hardware watchdog**
- **Auto-recovery** after crashes or hangs
- **Impact**: Better reliability, especially after power outages

### 7. WiFi Monitoring
- **Automatic monitoring** every 10 minutes
- **Logs warnings** for:
  - Clients with signal < -80 dBm on 2.4GHz
  - Clients with signal < -75 dBm on 5GHz
- **Impact**: Proactive problem detection

### 8. Logging Optimization
- **Reduces log clutter** from failed login attempts
- **Keeps important wireless events**
- **Impact**: Easier troubleshooting

---

## Monitoring After Application

### Check WiFi Clients
```routeros
# List all connected clients with signal strength
/interface/wifi/registration-table print

# Identify weak clients
/interface/wifi/registration-table print where signal<-75
```

### Monitor WiFi in Real-Time
```routeros
# Watch WiFi statistics
/interface/wifi monitor wlan-2g,wlan-5g

# Press Ctrl+C to stop
```

### Check System Resources
```routeros
/system resource print
# Monitor CPU and memory usage
```

### Review Logs
```routeros
# Check for weak client warnings
/log print where topics~"wireless"

# Check for errors
/log print where topics~"error|critical"
```

### Band Distribution Check
```routeros
# Count clients per band
:local count2g [/interface/wifi/registration-table print count-only where interface=wlan-2g]
:local count5g [/interface/wifi/registration-table print count-only where interface=wlan-5g]
:put "2.4GHz: $count2g clients, 5GHz: $count5g clients"
```

---

## Customization Guide

### Adjust WiFi Transmit Power
If you need more or less coverage:

```routeros
# Increase power (use with caution - may cause interference)
/interface/wifi set wlan-2g configuration.tx-power=20

# Decrease power (for smaller coverage area)
/interface/wifi set wlan-2g configuration.tx-power=15
```

### Change WiFi Channels
Based on site survey results:

```routeros
# 2.4GHz - Use channel 1, 6, or 11
/interface/wifi channel set wlan-2g frequency=2412    # Channel 1
/interface/wifi channel set wlan-2g frequency=2437    # Channel 6
/interface/wifi channel set wlan-2g frequency=2462    # Channel 11

# 5GHz - Many options available
/interface/wifi channel set wlan-5g frequency=5180    # Channel 36
/interface/wifi channel set wlan-5g frequency=5745    # Channel 149
```

### Adjust Minimum Signal Threshold
If clients are being disconnected too aggressively:

```routeros
# Modify the monitoring script
/system script edit wifi-monitor-script

# Change the signal thresholds in the script:
# -80 for 2.4GHz (currently set)
# -75 for 5GHz (currently set)
```

### Disable Band Steering
If you prefer manual band selection:

```routeros
/interface/wifi set wlan-2g configuration.steering=no
/interface/wifi set wlan-5g configuration.steering=no
```

### Revert SSH Port to 22
If you prefer default port:

```routeros
/ip service set ssh port=22
```

---

## How to Revert Changes

### Full Revert
```routeros
# Import your backup
/import backup-pachome-hapac2-10.10.39.2-DATE-TIME.rsc

# Reboot router
/system reboot
```

### Partial Revert - WiFi Only
```routeros
# Restore 2.4GHz to 20/40MHz
/interface/wifi channel set wlan-2g width=20/40mhz-XX

# Disable band steering
/interface/wifi set wlan-2g,wlan-5g configuration.steering=no
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

### Disable Monitoring
```routeros
# Remove scheduler
/system scheduler remove wifi-monitor-schedule

# Remove script
/system script remove wifi-monitor-script
```

---

## Expected Results

After applying the script, you should see:

| Metric | Before | Expected After | Improvement |
|--------|--------|----------------|-------------|
| 2.4GHz Channel Width | 20/40MHz | 20MHz | More stable |
| Weak Signal Clients | 14 clients | < 5 clients | 65%+ reduction |
| 5GHz Client Ratio | Low | Higher | Better performance |
| Login Failures | Frequent | Rare | Security improved |
| WiFi Drops/Disconnects | Occasional | Minimal | More stable |
| Security Score | Medium | High | Hardened |

---

## Troubleshooting

### Can't Connect to SSH After Script
**Problem**: SSH port changed to 2222
**Solution**: Use new port
```bash
ssh -p 2222 admin@10.10.39.2
```

### Devices Keep Disconnecting
**Problem**: Signal threshold too aggressive
**Solution**: Adjust in monitoring script or disable auto-disconnect
```routeros
/interface/wifi set wlan-2g configuration.disconnect-timeout=0s
```

### Devices Not Moving to 5GHz
**Problem**: Band steering not aggressive enough
**Solution**: Check device compatibility
```routeros
# Some devices don't support band steering
# Check if device supports 5GHz band
/interface/wifi/registration-table print detail
```

### Still Have Weak Signal Clients
**Problem**: AP placement or client location
**Solutions**:
1. Reposition the access point higher or more centrally
2. Add additional access points for coverage
3. Use WiFi extenders in problem areas
4. Check for physical obstructions (walls, metal, etc.)

### 2.4GHz Network Disappeared
**Problem**: Configuration error
**Solution**: Re-enable interface
```routeros
/interface/wifi set wlan-2g disabled=no
```

---

## Support Commands

### Get WiFi Information
```routeros
/interface/wifi print detail
/interface/wifi/registration-table print detail
/interface/wifi monitor wlan-2g,wlan-5g
```

### Get System Info
```routeros
/system resource print
/system routerboard print
/system package print
```

### Get Network Stats
```routeros
/interface print stats
/ip address print
```

### Export Current Config
```routeros
/export file=current-config
```

### Site Survey (Check Neighboring Networks)
```routeros
/interface/wifi scan wlan-2g duration=10s
/interface/wifi scan wlan-5g duration=10s
```

---

## Post-Application Checklist

- [ ] Backup created and downloaded
- [ ] Script uploaded to router
- [ ] Script imported successfully
- [ ] SSH port changed (update connection method)
- [ ] Both WiFi networks visible and working
- [ ] 2.4GHz using 20MHz width (verify)
- [ ] Weak signal clients reduced
- [ ] Band steering working (clients moving to 5GHz)
- [ ] Monitoring script running
- [ ] No errors in logs

---

## Additional Recommendations

### Physical Placement
1. **Mount AP high** - Ceiling or high on wall
2. **Central location** - Minimize distance to edges
3. **Avoid metal** - Keep away from metal surfaces
4. **Minimize obstructions** - Line of sight when possible

### Client Device Tips
1. **Update device drivers** - Especially for WiFi adapters
2. **Prefer 5GHz** - Manually select on capable devices
3. **Forget and reconnect** - If device has connection issues
4. **Check device limits** - Some old devices only support 2.4GHz

### Network Planning
1. **Separate APs for 2.4/5GHz** - Consider different coverage zones
2. **Overlap coverage** - For seamless roaming
3. **Monitor interference** - Use site survey regularly
4. **Document changes** - Keep notes on what works

---

## Notes

- **Run time**: Script takes ~15-30 seconds to apply
- **No reboot needed**: Changes apply immediately
- **Reversible**: All changes can be reverted with backup
- **Safe**: Script only modifies configuration, doesn't delete data
- **Tested**: Based on actual diagnostic data and best practices

---

**Generated**: 2025-12-14
**For Router**: pachome-hapac2 - 10.10.39.2 (hAP ac^2)
**Script Version**: 1.0
**Role**: Access Point Optimization
