# MikroTik Netinstall via Docker (ARM Compatible)

Run MikroTik Netinstall on Apple Silicon Macs using Docker with native TFTP/DHCP server (no Wine needed).

## Quick Start

### 1. Setup

```bash
cd /Users/luisdeleon/Development/RouterOs/docker-netinstall

# Download RouterOS 7.20.6 ARM package for hAP ac²
# (netinstall.sh will do this automatically if missing)
curl -L https://download.mikrotik.com/routeros/7.20.6/routeros-7.20.6-arm.npk \
  -o packages/routeros-7.20.6-arm.npk
```

### 2. Prepare Your Router

1. **Connect Ethernet cable** from Mac to **ether1** on hAP ac²
2. **Put router in Netinstall mode**:
   - Unplug power from router
   - Hold RESET button
   - Plug in power while holding RESET
   - Keep holding for 5-10 seconds
   - Release button
   - Router is now in Etherboot mode

### 3. Run Automated Installation

```bash
# Run the automated script (handles everything)
./netinstall.sh

# Or specify your Ethernet interface:
./netinstall.sh en5

# The script will:
# 1. Check prerequisites (Docker running)
# 2. Download RouterOS package if needed
# 3. Build Docker image if needed
# 4. Configure your network interface
# 5. Start DHCP/TFTP server
# 6. Wait for router to netboot and install
```

### 4. What Happens

The installation is fully automatic:

1. Your Mac's Ethernet interface gets static IP: 192.168.88.2
2. Docker container starts DHCP server (listens for router)
3. Docker container starts TFTP server (serves .npk package)
4. Router boots in Netinstall mode and requests IP via BOOTP
5. Router gets IP 192.168.88.1 from DHCP
6. Router downloads .npk package via TFTP
7. Router installs RouterOS automatically
8. Router reboots with fresh RouterOS 7.20.6

**Watch the container logs** to see DHCP requests and TFTP transfers in real-time.

## How It Works

This solution uses **native TFTP/DHCP** instead of Wine (which doesn't work on Apple Silicon):

1. **Alpine Linux container** - Lightweight, ARM-compatible
2. **dnsmasq** - Provides DHCP/BOOTP service for the router
3. **in.tftpd** - Serves the RouterOS .npk package file
4. **Automatic process** - Router netboots, downloads package, installs

### Why Not Wine?

Wine requires x86 architecture and doesn't run on Apple Silicon Macs. The original Windows Netinstall.exe tool is also not needed - MikroTik routers can netboot and install directly via TFTP/DHCP, which is what Netinstall does behind the scenes.

## Troubleshooting

### Router not getting IP / No DHCP requests in logs

```bash
# 1. Verify router is in Netinstall mode
#    - LED should be blinking rapidly
#    - Hold RESET for full 5-10 seconds during boot

# 2. Check network interface is configured
ifconfig en0 | grep "192.168.88.2"

# 3. Check container is running
docker ps | grep mikrotik-netinstall

# 4. Check container logs
docker-compose logs -f

# 5. Verify Ethernet cable is good and connected to ether1
```

### Router not downloading package

```bash
# Check TFTP server has the package
docker exec mikrotik-netinstall ls -lh /tftpboot/

# Should show: routeros-7.20.6-arm.npk

# Test TFTP from Mac
brew install tftp-hpa
tftp 192.168.88.2
> get routeros-7.20.6-arm.npk
```

### Network interface issues

```bash
# List all Ethernet interfaces on Mac
ifconfig | grep "^en"

# Find which one is connected (look for "status: active")
ifconfig en0 | grep status
ifconfig en5 | grep status

# Use the correct interface with netinstall.sh
./netinstall.sh en5
```

### Container won't start

```bash
# Rebuild from scratch
docker-compose down
docker-compose build --no-cache
docker-compose up

# Check Docker has permission for privileged mode
# Docker Desktop → Settings → Resources → Advanced
```

## Clean Up

```bash
# Use the cleanup script (recommended)
./cleanup.sh

# Or manually:
docker-compose down
sudo ipconfig set en0 DHCP

# Optional: Remove Docker image
docker rmi docker-netinstall-netinstall
```

## Files Structure

```
docker-netinstall/
├── Dockerfile              # Alpine Linux + TFTP/DHCP server
├── docker-compose.yml      # Docker Compose config
├── entrypoint.sh          # Container startup script
├── netinstall.sh          # Automated installation script
├── cleanup.sh             # Network cleanup script
├── README.md              # This file
└── packages/              # Put RouterOS .npk files here
    └── routeros-7.20.6-arm.npk
```

## Download RouterOS Packages

```bash
# ARM (for hAP ac², hAP ac³)
curl -L https://download.mikrotik.com/routeros/7.20.6/routeros-7.20.6-arm.npk \
  -o packages/routeros-7.20.6-arm.npk

# MIPSBE (for RB493G)
curl -L https://download.mikrotik.com/routeros/7.20.6/routeros-7.20.6-mipsbe.npk \
  -o packages/routeros-7.20.6-mipsbe.npk

# With wifi-qcom package (for hAP ac²)
curl -L https://download.mikrotik.com/routeros/7.20.6/wifi-qcom-ac-7.20.6-arm.npk \
  -o packages/wifi-qcom-ac-7.20.6-arm.npk
```

## After Installation

1. **Reset Mac network** back to DHCP or your normal settings
2. **Access router**:
   ```bash
   # Via SSH (no password initially)
   ssh admin@192.168.88.1

   # Via WinBox
   # Download from https://mikrotik.com/download

   # Via WebFig
   open http://192.168.88.1
   ```

3. **Initial setup**:
   ```routeros
   # Set identity
   /system identity set name=pachome-hapac2

   # Set password
   /user set admin password=YOUR_PASSWORD

   # Set IP for your network
   /ip address add address=10.10.39.2/24 interface=bridge
   ```

## Notes

- This setup uses **native TFTP/DHCP** - no Wine, no Windows needed
- Works on **Apple Silicon Macs** (ARM architecture)
- Requires **privileged mode** and **host networking** for DHCP/TFTP to work
- Fully automated - just run `./netinstall.sh` and watch the logs
- Installation takes 2-5 minutes after router netboots

## Support

For issues:
1. Check Docker logs: `docker-compose logs -f`
2. Verify container is running: `docker ps | grep mikrotik-netinstall`
3. Check TFTP files: `docker exec mikrotik-netinstall ls -lh /tftpboot/`
4. Verify network config: `ifconfig en0 | grep 192.168.88.2`
5. Test router connectivity: `ping 192.168.88.1`
