# Quick Command Index - Example Router

## Essential Commands

### Connect
```bash
ssh -p 2222 admin@192.168.88.1
```

### Backup
```routeros
/import file=BACKUP-FIRST.rsc
```

### Optimize
```routeros
/import file=EXAMPLE-192.168.88.1-optimization.rsc
```

### Verify
```routeros
/import file=VERIFY-OPTIMIZATION.rsc
```

---

## System Commands

| Command | Description |
|---------|-------------|
| `/system resource print` | Show CPU, memory, uptime |
| `/system routerboard print` | Hardware information |
| `/system identity print` | Router name |
| `/system package print` | Installed packages |
| `/system reboot` | Restart router |

---

## Network Commands

| Command | Description |
|---------|-------------|
| `/interface print` | List all interfaces |
| `/ip address print` | Show IP addresses |
| `/ip route print` | Routing table |
| `/ip dns print` | DNS settings |
| `/ping 8.8.8.8` | Test connectivity |

---

## WiFi Commands

| Command | Description |
|---------|-------------|
| `/interface/wifi print` | WiFi interfaces |
| `/interface/wifi registration-table print` | Connected clients |
| `/interface/wifi scan wlan-2g` | Scan 2.4GHz channels |
| `/interface/wifi access-list print` | Access control list |

---

## Security Commands

| Command | Description |
|---------|-------------|
| `/ip firewall filter print` | Firewall rules |
| `/ip firewall connection print` | Active connections |
| `/ip service print` | Network services status |
| `/user print` | User accounts |

---

## Monitoring Commands

| Command | Description |
|---------|-------------|
| `/log print` | View system logs |
| `/tool bandwidth-test address=X.X.X.X` | Bandwidth test |
| `/interface print stats` | Interface statistics |
| `/system resource monitor` | Real-time resource usage |

---

## Files in This Package

| File | Purpose |
|------|---------|
| `BACKUP-FIRST.rsc` | Create backup before changes |
| `EXAMPLE-192.168.88.1-optimization.rsc` | Main optimization script |
| `VERIFY-OPTIMIZATION.rsc` | Check optimization score |
| `ROUTER-INFO.txt` | Complete router specifications |
| `QUICK-REFERENCE.txt` | One-page command reference |
| `README.md` | Detailed installation guide |
| `INDEX.md` | This file - quick navigation |

---

## Emergency Commands

### Restore from Backup
```routeros
/system backup load name=backup-YYYYMMDD
```

### Factory Reset (CAUTION!)
```routeros
/system reset-configuration no-defaults=yes
```

### Reset Admin Password (Console/Physical Access Required)
1. Reboot router
2. Press any key when "press any key" appears
3. Type: `e` (extra set of commands)
4. Type: `passwd` and follow prompts

---

## Support Links

- [RouterOS Documentation](https://help.mikrotik.com/docs/)
- [MikroTik Wiki](https://wiki.mikrotik.com/)
- [Community Forum](https://forum.mikrotik.com/)
- [Download WinBox](https://mikrotik.com/download)

---

**Router:** Example Router
**IP:** 192.168.88.1
**SSH Port:** 2222
**Generated:** Example Package
