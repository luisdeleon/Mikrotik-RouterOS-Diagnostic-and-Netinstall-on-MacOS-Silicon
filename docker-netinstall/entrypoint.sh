#!/bin/bash
################################################################################
# MikroTik Netinstall Entrypoint - ARM Compatible (No Wine)
################################################################################

set -e

echo "════════════════════════════════════════════════════════════"
echo "  MikroTik Netinstall Server (ARM Compatible)"
echo "════════════════════════════════════════════════════════════"
echo ""

# Configuration
ROUTER_IP="${ROUTER_IP:-192.168.88.1}"
SERVER_IP="${SERVER_IP:-192.168.88.2}"
NETMASK="255.255.255.0"
PACKAGE_DIR="/packages"

# Find RouterOS package
PACKAGE_FILE=$(find $PACKAGE_DIR -name "*.npk" | head -n 1)

if [ -z "$PACKAGE_FILE" ]; then
    echo "ERROR: No .npk package found in $PACKAGE_DIR"
    echo "Please download RouterOS package to ./packages/"
    exit 1
fi

echo "✓ Found package: $(basename $PACKAGE_FILE)"
echo "  Router IP: $ROUTER_IP"
echo "  Server IP: $SERVER_IP"
echo ""

# Copy packages to TFTP directory
echo "Setting up TFTP server..."
cp -v $PACKAGE_DIR/*.npk /tftpboot/ 2>/dev/null || true
chmod 644 /tftpboot/*.npk
ls -lh /tftpboot/

# Configure dnsmasq for DHCP + TFTP
echo ""
echo "Configuring DHCP/BOOTP server..."

cat > /etc/dnsmasq.conf <<EOF
# Disable DNS server (we only need DHCP)
port=0

# Enable DHCP server
dhcp-range=$ROUTER_IP,$ROUTER_IP,255.255.255.0,12h

# BOOTP options for Netinstall
dhcp-boot=$(basename $PACKAGE_FILE)

# Enable TFTP
enable-tftp
tftp-root=/tftpboot

# Logging
log-dhcp
log-facility=-

# DHCP options
# Option 3: Router (gateway) - leave blank for netinstall
# Option 6: DNS server - leave blank for netinstall
dhcp-option=3
dhcp-option=6

# Listen on all interfaces (Docker uses host network)
listen-address=0.0.0.0
except-interface=lo
EOF

echo "✓ dnsmasq configured"
echo ""

# Start dnsmasq (DHCP + TFTP server combined)
echo "Starting DHCP/TFTP server..."
dnsmasq -d -C /etc/dnsmasq.conf &
DNSMASQ_PID=$!

echo ""
echo "════════════════════════════════════════════════════════════"
echo "  Server Ready!"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "1. Make sure your router is in Netinstall mode:"
echo "   - Unplug power"
echo "   - Hold RESET button"
echo "   - Plug power while holding RESET (5-10 seconds)"
echo "   - Release button"
echo ""
echo "2. Router should now:"
echo "   - Get IP: $ROUTER_IP via DHCP"
echo "   - Download: $(basename $PACKAGE_FILE) via TFTP"
echo "   - Install RouterOS automatically"
echo ""
echo "3. Watch for DHCP requests and TFTP transfers below:"
echo ""
echo "════════════════════════════════════════════════════════════"
echo ""

# Monitor connections
echo "Waiting for router to connect..."
echo "Press Ctrl+C to stop"
echo ""

# Keep container running and show logs
tail -f /var/log/dnsmasq.log 2>/dev/null &

# Wait for dnsmasq process
wait $DNSMASQ_PID
