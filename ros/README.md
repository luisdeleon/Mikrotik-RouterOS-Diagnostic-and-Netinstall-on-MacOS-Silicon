# RouterOS Optimization Scripts

Complete collection of router-specific optimization scripts, guides, and utilities for all MikroTik routers in your network.

---

## 📁 Directory Structure

```
/ros/
├── README.md                    # This file - master index
└── LUIS-10.10.39.1/            # Router-specific directory
    ├── BACKUP-FIRST.rsc        # Backup script
    ├── LUIS-10.10.39.1-optimization.rsc  # Main optimization script
    ├── VERIFY-OPTIMIZATION.rsc # Verification script
    ├── REMOVE-back-to-home-vpn.rsc # VPN removal script
    ├── README.md               # Complete router guide
    └── INDEX.md                # Quick reference
```

---

## 🖥️ Router Inventory

### Active Routers with Optimization Scripts

| Router Name | IP Address | Model | Location | Status | Scripts Available |
|-------------|------------|-------|----------|--------|-------------------|
| LUIS - 10.10.39.1 | 10.10.39.1 | hAP ac^3 | Home/Office | ✅ Active | ✅ Complete |

### All Configured Routers (from routers.json)

#### LUIS Group (4 routers)
- ✅ **10.10.39.1** - hAP ac^3 - *Scripts Available*
- 10.10.30.1 - Offline
- home.ebluenet.com - Offline
- rb5009up-fosterwheeler (172.16.100.205) - Connection refused

#### MONSTER Group (3 routers)
- 45.32.201.232 - Connection refused
- Freeman Abe (173.95.100.226) - Timeout
- Freeman Fay (216.82.18.114) - Timeout

#### WISP Group (8 routers)
- KAMA DFW21 (104.129.130.99) - Timeout
- ✅ **KAMA DFW00 (138.128.244.228)** - Online
- KAMA DFW22 (104.129.130.93) - Connection refused
- KAMA DFW01 (104.129.131.145) - Auth failed
- TLAHUE - Jonna LHG - Timeout
- TLAHUE - Jonna RB2011 - Unreachable
- TLAHUE - Timeout
- TURBONET TAMAZOLAPA - Unreachable

#### WIFILINK Group (11 routers)
- BODEGA (10.10.200.1) - Timeout
- vpnpac.wifilink.mx - Timeout
- ✅ **GUADALUPE (172.16.16.102)** - Online
- ✅ **HOME PAC (172.16.16.103)** - Online
- HOME LAX (172.16.16.104) - Unreachable
- TLAHUE (172.16.16.106) - Connection refused
- ✅ **PIE LOMA (172.16.16.107)** - Online
- LA LOMA (172.16.16.108) - Connection refused
- PACHUQUILLA (172.16.16.109) - Connection refused
- DON CARLOS (172.16.16.105) - Unreachable
- DON CARLOS (62c046603d37ca2a.sn.mynetname.net) - Timeout

#### PAC Group (7 routers)
- 10.24.0.1 - Connection refused
- 10.24.8.1 - Connection refused
- ✅ **10.24.16.1** - Online
- 10.24.24.1 - Timeout
- 10.24.40.1 - Connection refused
- ✅ **10.24.48.1** - Online

#### SARTEK Group (5 routers)
- hed08mqfnpn.sn.mynetname.net - Timeout
- 201.168.171.155 - Connection refused
- 187.188.202.178 - Timeout
- 916908810392.sn.mynetname.net - Timeout
- 187.188.202.226 - Timeout

#### WEBZY Group (2 routers)
- UARANDY (172.16.100.201) - Unreachable
- ✅ **UANORDAN (172.16.100.202)** - Online

#### Other (2 routers)
- SMARTWIFI (186.96.167.66) - Timeout
- LAWNDALE (6f4b05ae79c6.sn.mynetname.net) - Timeout

**Summary**: 8 routers online, 33 routers offline/unreachable

---

## 🚀 Quick Start Guide

### For LUIS - 10.10.39.1

1. **Navigate to router directory**:
   ```bash
   cd /Users/luisdeleon/Development/RouterOs/ros/LUIS-10.10.39.1
   ```

2. **Read the documentation**:
   ```bash
   cat README.md
   ```

3. **Upload scripts to router**:
   ```bash
   scp *.rsc admin@10.10.39.1:/
   ```

4. **Connect and apply**:
   ```bash
   ssh admin@10.10.39.1
   ```

   On router:
   ```routeros
   /import BACKUP-FIRST.rsc
   /import LUIS-10.10.39.1-optimization.rsc
   /import VERIFY-OPTIMIZATION.rsc
   ```

---

## 📊 Router Statistics (Last Diagnostic: 2025-12-14)

### LUIS - 10.10.39.1 (hAP ac^3)
- **Status**: ✅ Online
- **Issues Found**: 6 critical issues
- **Connection Count**: 1,486 (⚠️ Very High)
- **CPU Load**: 15-21%
- **Memory Usage**: 129 MB / 256 MB (50%)
- **WiFi Clients**: 3 (2x 2.4GHz, 1x 5GHz)
- **Scripts**: ✅ Complete optimization package available

**Critical Issues**:
1. ⚠️ Very high connection count (1,486)
2. ⚠️ No bandwidth management (QoS disabled)
3. ⚠️ SYN flood attacks on SSH
4. ⚠️ Weak WiFi signal on some clients
5. ⚠️ 74 DHCP leases (many stale)
6. ⚠️ Unused VPN configuration (back-to-home-vpn)

---

## 🛠️ Creating Scripts for Other Routers

To create optimization scripts for other routers:

1. **Run diagnostics**:
   ```bash
   npm start -- --router "ROUTER_NAME"
   ```

2. **Analyze the output** and identify issues

3. **Create router-specific directory**:
   ```bash
   mkdir -p ros/ROUTER-NAME-IP
   ```

4. **Generate scripts** based on diagnostic results

5. **Test on the router** in a controlled manner

---

## 📋 Standard Script Set (Per Router)

Each router directory should contain:

| File | Purpose | Required |
|------|---------|----------|
| `BACKUP-FIRST.rsc` | Creates backup before changes | ✅ Yes |
| `{ROUTER}-optimization.rsc` | Main optimization script | ✅ Yes |
| `VERIFY-OPTIMIZATION.rsc` | Post-optimization verification | ✅ Yes |
| `README.md` | Complete guide and documentation | ✅ Yes |
| `INDEX.md` | Quick reference card | ✅ Yes |
| `REMOVE-*.rsc` | Cleanup scripts (as needed) | Optional |
| `QUICK-REFERENCE.txt` | One-page cheat sheet | Optional |

---

## 🎯 Common Optimization Areas

Optimization scripts typically address:

### 1. **Connection Tracking**
- Reduce timeout values
- Limit connections per IP
- Prevent connection table overflow

### 2. **QoS/Bandwidth Management**
- Enable queue trees
- Set per-subnet limits
- Prevent bandwidth hogging

### 3. **Security Hardening**
- Change SSH port
- Restrict access
- Add brute-force protection
- Rate limiting

### 4. **WiFi Optimization**
- Channel selection
- TX power adjustment
- WPA3 enablement
- Client steering

### 5. **System Cleanup**
- Remove stale DHCP leases
- Clean up old firewall rules
- Remove unused configurations
- Optimize DNS cache

### 6. **Performance Tuning**
- FastTrack optimization
- Hardware offloading
- ARP timeout adjustment
- Connection tracking tuning

### 7. **Monitoring**
- Scheduled health checks
- Alert thresholds
- Log rotation
- Performance metrics

---

## 📝 Script Naming Convention

Follow this naming convention for consistency:

```
BACKUP-FIRST.rsc                    # Backup script (same for all)
{GROUP}-{IP}-optimization.rsc       # Main optimization
VERIFY-OPTIMIZATION.rsc             # Verification (same for all)
REMOVE-{feature}.rsc                # Cleanup scripts
README.md                           # Router-specific guide
INDEX.md                            # Quick reference
ROUTER-INFO.txt                     # Hardware/firmware details
```

**Examples**:
- `LUIS-10.10.39.1-optimization.rsc`
- `WISP-KAMA-DFW00-optimization.rsc`
- `WIFILINK-GUADALUPE-optimization.rsc`

---

## 🔍 Diagnostic Commands Reference

### Run Full Diagnostics on Single Router
```bash
npm start -- --router "ROUTER_NAME"
```

### Run Category-Specific Diagnostics
```bash
npm start -- --router "ROUTER_NAME" --category system
npm start -- --router "ROUTER_NAME" --category interfaces
npm start -- --router "ROUTER_NAME" --category routing
```

### Run on All Routers
```bash
npm start -- --category all
```

### List Available Routers
```bash
npm run list
```

### List Routers by Group
```bash
npm run groups
```

---

## 📖 Documentation Standards

Each router directory should include:

### README.md Contents
1. Router specifications and metadata
2. Issues found during diagnostics
3. Step-by-step application instructions
4. Customization guide
5. Expected results
6. Troubleshooting guide
7. Rollback procedures

### INDEX.md Contents
1. Quick file reference
2. Command reference
3. Monitoring commands
4. Emergency procedures

### Script Comments
- Full header with router metadata
- Section dividers
- Inline explanations
- Impact descriptions
- Rollback instructions

---

## 🆘 Emergency Procedures

### If Router Becomes Unreachable After Script

1. **Wait 5 minutes** - Some changes need time to apply
2. **Physical access** - Connect via WinBox MAC address
3. **Restore backup**:
   ```routeros
   /import backup-{router}-{date}.rsc
   ```
4. **Factory reset** (last resort):
   ```routeros
   /system reset-configuration no-defaults=yes
   ```

### If Performance Degrades

1. **Check logs**:
   ```routeros
   /log print where topics~"error|warning|critical"
   ```
2. **Disable QoS temporarily**:
   ```routeros
   /queue tree set [find] disabled=yes
   ```
3. **Check connection count**:
   ```routeros
   /ip firewall connection print count-only
   ```
4. **Restore from backup** if issues persist

---

## 📚 Additional Resources

- **MikroTik Wiki**: https://wiki.mikrotik.com/
- **RouterOS Manual**: https://help.mikrotik.com/docs/
- **Community Forum**: https://forum.mikrotik.com/
- **YouTube Channel**: https://www.youtube.com/user/MikroTikTips

---

## 🔄 Maintenance Schedule

### Weekly
- Review system logs
- Check connection counts
- Monitor bandwidth usage
- Verify backup scripts ran

### Monthly
- Update RouterOS firmware
- Review firewall rules
- Clean up DHCP leases
- Optimize queue configurations

### Quarterly
- Full backup to external storage
- Review all configurations
- Update optimization scripts
- Performance benchmarking

---

## ✅ Checklist for New Router Scripts

When creating scripts for a new router:

- [ ] Run comprehensive diagnostics
- [ ] Create router-specific directory
- [ ] Generate BACKUP-FIRST.rsc
- [ ] Create optimization script with full metadata
- [ ] Create verification script
- [ ] Write complete README.md
- [ ] Create quick reference INDEX.md
- [ ] Test on router in safe environment
- [ ] Document any issues encountered
- [ ] Add router to main README inventory
- [ ] Commit to version control

---

**Last Updated**: 2025-12-14
**Total Routers**: 41 configured, 8 online
**Scripts Available**: 1 router (LUIS - 10.10.39.1)
**Next Priority**: Create scripts for online routers (KAMA DFW00, GUADALUPE, HOME PAC, etc.)
