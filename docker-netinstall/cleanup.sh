#!/bin/bash
################################################################################
# MikroTik Netinstall Cleanup Script
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

INTERFACE="${1:-en7}"

echo "╔══════════════════════════════════════════════════════════╗"
echo "║     MikroTik Netinstall Cleanup                         ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# Stop and remove container
echo "Stopping Docker container..."
docker-compose down 2>/dev/null || true

# Remove Docker image (optional)
read -p "Remove Docker image? [y/N]: " remove_image
if [[ "$remove_image" == "y" ]] || [[ "$remove_image" == "Y" ]]; then
    echo "Removing Docker image..."
    docker rmi docker-netinstall-netinstall 2>/dev/null || true
    docker rmi mikrotik-netinstall 2>/dev/null || true
fi

# Reset network interface to DHCP
echo ""
echo "Resetting network interface $INTERFACE to DHCP..."
echo "This requires sudo password:"
sudo ipconfig set $INTERFACE DHCP

echo ""
echo "✓ Cleanup complete!"
echo ""
echo "Your network should now be back to normal."
echo "To use DHCP, you may need to reconnect your Ethernet cable."
