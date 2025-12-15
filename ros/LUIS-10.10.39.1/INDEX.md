# Router Optimization Scripts - Index

## Router: LUIS - 10.10.39.1 (hAP ac^3)

---

## 📁 Files in this Directory

### 1. **BACKUP-FIRST.rsc**
**Purpose**: Creates complete backup before making changes
**When to use**: Run this FIRST before any optimization
**What it does**:
- Creates text configuration export (.rsc)
- Creates binary backup (.backup)
- Both include timestamp in filename

**Usage**:
```routeros
/import BACKUP-FIRST.rsc
```

**Download backups**:
```bash
# Via SCP
scp admin@10.10.39.1:backup-LUIS-* .

# Or use WinBox Files menu
```

---

### 2. **LUIS-10.10.39.1-optimization.rsc** ⭐ MAIN SCRIPT
**Purpose**: Complete optimization for router performance
**When to use**: After creating backup
**What it does**:
- Optimizes connection tracking (reduces from 1,486 connections)
- Adds connection limits per IP (200 TCP, 150 UDP)
- Hardens SSH security (port 2222, local only)
- Enables QoS/bandwidth management
- Optimizes WiFi (adds WPA3, channel optimization)
- Reduces DHCP lease time
- Increases DNS cache
- Adds monitoring system

**Usage**:
```routeros
/import LUIS-10.10.39.1-optimization.rsc
```

**Time to apply**: ~10-30 seconds
**Reboot required**: No
**Reversible**: Yes (via backup)

---

### 3. **VERIFY-OPTIMIZATION.rsc**
**Purpose**: Verify optimization was successful
**When to use**: After running optimization script
**What it does**:
- Checks all 10 optimization areas
- Provides performance score (0-10)
- Lists recommendations
- Shows system health

**Usage**:
```routeros
/import VERIFY-OPTIMIZATION.rsc
```

**Expected score**: 8-10/10 = Excellent

---

### 4. **README-LUIS-10.10.39.1.md** 📚
**Purpose**: Complete guide and documentation
**Contents**:
- Step-by-step instructions
- What each optimization does
- Customization guide
- Troubleshooting
- Post-application checklist

**Read this**: Before applying any scripts

---

### 5. **INDEX.md** (this file)
**Purpose**: Quick reference for all files

---

## 🚦 Recommended Workflow

### Step 1: Read Documentation
```
✓ Read: README-LUIS-10.10.39.1.md
✓ Understand what will change
✓ Decide on any customizations needed
```

### Step 2: Backup
```bash
# Connect to router
ssh admin@10.10.39.1

# Run backup script
/import BACKUP-FIRST.rsc

# Download backups to your computer
# Via WinBox: Files > Download both .rsc and .backup files
```

### Step 3: (Optional) Customize Optimization Script
```
✓ Edit LUIS-10.10.39.1-optimization.rsc if needed
✓ Adjust bandwidth values for your WAN speed
✓ Modify SSH port if desired (default: 2222)
✓ Adjust connection limits if needed
```

### Step 4: Apply Optimization
```routeros
# Upload script to router (via WinBox or SCP)
# Import and apply
/import LUIS-10.10.39.1-optimization.rsc

# Check logs
/log print where topics~"script"
```

### Step 5: Verify
```routeros
# Run verification script
/import VERIFY-OPTIMIZATION.rsc

# Should see score 8-10/10
# Review any warnings
```

### Step 6: Monitor
```routeros
# Check connection count (should be < 800)
/ip firewall connection print count-only

# Check CPU load (should be < 20%)
/system resource print

# Monitor traffic
/interface monitor-traffic [find]

# Identify bandwidth users
/tool torch bridge duration=30s
```

### Step 7: Update SSH Client
```bash
# SSH port changed from 22 to 2222
ssh -p 2222 admin@10.10.39.1

# Update saved sessions in PuTTY/SSH config
```

---

## 🎯 Quick Reference Commands

### Performance Monitoring
```routeros
# System resources
/system resource print

# Connection count
/ip firewall connection print count-only

# Interface traffic
/interface print stats

# Queue statistics
/queue tree print stats

# Top bandwidth users
/tool torch bridge duration=30s
```

### Check Applied Optimizations
```routeros
# Connection tracking settings
/ip firewall connection tracking print

# Connection limit rules
/ip firewall filter print where comment~"Limit"

# SSH settings
/ip service print detail where name=ssh

# Queue status
/queue tree print

# WiFi status
/interface/wifi print
/interface/wifi/registration-table print
```

### Troubleshooting
```routeros
# View all logs
/log print

# Errors only
/log print where topics~"error|critical"

# Warnings only
/log print where topics~"warning"

# Script execution logs
/log print where topics~"script"
```

---

## 📊 Expected Results

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Connections | 1,486 | < 500 | 66%+ |
| CPU Load | 15-21% | 10-15% | 30% |
| Memory Free | 129 MB | 140+ MB | 10+ MB |
| WiFi Drops | 1/sec | < 0.1/sec | 90% |
| SSH Attacks | Active | Blocked | 100% |

---

## 🆘 Emergency Rollback

If something goes wrong:

```routeros
# Option 1: Import backup
/import backup-LUIS-10.10.39.1-YYYY-MM-DD-HH:MM:SS.rsc

# Option 2: Factory reset (LAST RESORT)
/system reset-configuration no-defaults=yes skip-backup=yes

# Then restore from backup
```

---

## 📝 File Modification Log

| File | Version | Date | Changes |
|------|---------|------|---------|
| BACKUP-FIRST.rsc | 1.0 | 2025-12-14 | Initial release |
| LUIS-10.10.39.1-optimization.rsc | 1.0 | 2025-12-14 | Initial release |
| VERIFY-OPTIMIZATION.rsc | 1.0 | 2025-12-14 | Initial release |
| README-LUIS-10.10.39.1.md | 1.0 | 2025-12-14 | Initial release |

---

## 🔗 Related Resources

- **MikroTik Wiki**: https://wiki.mikrotik.com/
- **RouterOS Manual**: https://help.mikrotik.com/docs/
- **hAP ac^3 Product Page**: https://mikrotik.com/product/hap_ac3
- **Community Forum**: https://forum.mikrotik.com/

---

## ✉️ Support

For issues or questions:
1. Check README-LUIS-10.10.39.1.md troubleshooting section
2. Review router logs: `/log print where topics~"error"`
3. Run verification script for diagnostics
4. Restore from backup if needed

---

**Generated**: 2025-12-14
**For Router**: LUIS - 10.10.39.1
**Firmware**: 7.20.4
**Board**: hAP ac^3
