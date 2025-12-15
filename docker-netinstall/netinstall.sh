#!/bin/bash
################################################################################
# MikroTik Netinstall Helper Script (Docker + macOS)
################################################################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Configuration
STATIC_IP="192.168.88.2"
ROUTER_IP="192.168.88.1"

echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     MikroTik Netinstall via Docker (macOS)              ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Function to show interface details
show_interface_info() {
    local iface=$1
    local status=$(ifconfig $iface | grep "status:" | awk '{print $2}')
    local ip=$(ifconfig $iface | grep "inet " | grep -v "inet6" | awk '{print $2}' | head -n 1)
    local media=$(ifconfig $iface | grep "media:" | sed 's/.*media: //' | cut -d'(' -f1)

    echo -n "  $iface"

    if [[ "$status" == "active" ]]; then
        echo -ne " ${GREEN}[ACTIVE]${NC}"
    else
        echo -ne " [inactive]"
    fi

    if [[ -n "$ip" ]]; then
        echo -n " - IP: $ip"
    fi

    if [[ -n "$media" ]]; then
        echo -n " ($media)"
    fi

    echo ""
}

# If interface not provided as argument, show menu
if [[ -z "$1" ]]; then
    echo -e "${YELLOW}Available Network Interfaces:${NC}"
    echo ""

    # Get all ethernet interfaces
    INTERFACES=($(ifconfig | grep "^en" | awk '{print $1}' | sed 's/://'))

    for iface in "${INTERFACES[@]}"; do
        show_interface_info "$iface"
    done

    echo ""
    echo -e "${YELLOW}Select the interface connected to your router:${NC}"
    echo "  (Usually the one that is ACTIVE with Ethernet cable)"
    echo ""
    read -p "Enter interface name (e.g., en7): " INTERFACE

    # Validate input
    if [[ -z "$INTERFACE" ]]; then
        echo -e "${RED}No interface specified. Exiting.${NC}"
        exit 1
    fi

    if ! ifconfig "$INTERFACE" &>/dev/null; then
        echo -e "${RED}Interface $INTERFACE does not exist. Exiting.${NC}"
        exit 1
    fi
else
    INTERFACE="$1"
fi

echo ""
echo -e "${GREEN}Selected interface: $INTERFACE${NC}"
echo ""

# Function to show usage
usage() {
    echo "Usage: $0 [ethernet_interface]"
    echo ""
    echo "Examples:"
    echo "  $0           # Shows interactive menu to select interface"
    echo "  $0 en7       # Directly uses en7 interface (skip menu)"
    echo ""
    echo "Available interfaces:"
    ifconfig | grep "^en" | awk '{print "  " $1}' | sed 's/://'
    exit 1
}

# Check if help requested
if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    usage
fi

# Step 1: Check prerequisites
echo -e "${YELLOW}Step 1: Checking prerequisites...${NC}"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}✗ Docker is not running. Please start Docker Desktop.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker is running${NC}"

# Check if packages directory exists
if [ ! -d "packages" ]; then
    echo -e "${YELLOW}Creating packages directory...${NC}"
    mkdir -p packages
fi

# Check if RouterOS package exists
if [ ! -f "packages/routeros-7.20.6-arm.npk" ]; then
    echo -e "${YELLOW}⚠ RouterOS package not found. Downloading...${NC}"
    curl -L https://download.mikrotik.com/routeros/7.20.6/routeros-7.20.6-arm.npk \
      -o packages/routeros-7.20.6-arm.npk
    echo -e "${GREEN}✓ Downloaded RouterOS 7.20.6 ARM${NC}"
else
    echo -e "${GREEN}✓ RouterOS package found${NC}"
fi

# Step 2: Check if image exists, build if not
echo ""
echo -e "${YELLOW}Step 2: Checking Docker image...${NC}"
if ! docker images | grep -q "mikrotik-netinstall"; then
    echo -e "${YELLOW}Building Docker image (this may take a few minutes)...${NC}"
    docker-compose build
    echo -e "${GREEN}✓ Image built successfully${NC}"
else
    echo -e "${GREEN}✓ Docker image exists${NC}"
fi

# Step 3: Network setup
echo ""
echo -e "${YELLOW}Step 3: Network configuration...${NC}"

# Verify interface status before configuration
INTERFACE_STATUS=$(ifconfig $INTERFACE | grep "status:" | awk '{print $2}')
if [[ "$INTERFACE_STATUS" == "active" ]]; then
    echo -e "${GREEN}✓ Interface $INTERFACE is active${NC}"
else
    echo -e "${RED}⚠ Warning: Interface $INTERFACE status is: $INTERFACE_STATUS${NC}"
    echo "  Make sure your Ethernet cable is plugged in"
    read -p "Continue anyway? [y/N]: " continue_anyway
    if [[ "$continue_anyway" != "y" ]] && [[ "$continue_anyway" != "Y" ]]; then
        exit 1
    fi
fi

echo ""
echo -e "${RED}IMPORTANT: Put your router in Netinstall mode NOW:${NC}"
echo "  1. Unplug power from hAP ac²"
echo "  2. Hold RESET button"
echo "  3. Plug in power while holding RESET"
echo "  4. Keep holding for 5-10 seconds"
echo "  5. Release button"
echo "  6. Router is now in Etherboot mode"
echo ""
read -p "Press Enter when router is in Netinstall mode..."

echo ""
echo -e "${YELLOW}Setting static IP on $INTERFACE...${NC}"
echo "This requires sudo password:"

# Check if 192.168.88.2 is already assigned to another interface
EXISTING_IF=$(ifconfig | grep -B 5 "inet 192.168.88.2" | grep "^en" | awk '{print $1}' | sed 's/://' | head -n 1)
if [[ -n "$EXISTING_IF" ]] && [[ "$EXISTING_IF" != "$INTERFACE" ]]; then
    echo -e "${YELLOW}Removing 192.168.88.2 from $EXISTING_IF first...${NC}"
    sudo ifconfig $EXISTING_IF -alias 192.168.88.2
fi

# Set the static IP
sudo ifconfig $INTERFACE $STATIC_IP netmask 255.255.255.0

echo -e "${GREEN}✓ Network configured: $INTERFACE = $STATIC_IP${NC}"

# Step 4: Test connectivity
echo ""
echo -e "${YELLOW}Step 4: Testing connectivity...${NC}"
echo "Waiting for router (this may take 10-15 seconds)..."
sleep 5

if ping -c 3 -t 5 $ROUTER_IP > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Router detected at $ROUTER_IP${NC}"
else
    echo -e "${YELLOW}⚠ Router not responding yet (this is often normal)${NC}"
    echo "  The router may appear after starting Netinstall"
fi

# Step 5: Start Netinstall
echo ""
echo -e "${YELLOW}Step 5: Starting Netinstall server...${NC}"
echo ""

# Start container
docker-compose up -d

# Wait for container to start
sleep 3

echo ""
echo -e "${GREEN}✓ DHCP/TFTP server started${NC}"
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Installation in Progress                                ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "The router should now:"
echo "  1. Send DHCP request (you'll see it in logs)"
echo "  2. Get IP: $ROUTER_IP"
echo "  3. Download RouterOS package via TFTP"
echo "  4. Install automatically"
echo "  5. Reboot with RouterOS 7.20.6"
echo ""
echo "This takes 2-5 minutes. Watch the logs below:"
echo ""
echo -e "${YELLOW}Press Ctrl+C to stop watching (installation continues)${NC}"
echo ""
echo "════════════════════════════════════════════════════════════"
echo ""

# Follow logs
docker-compose logs -f

echo ""
echo -e "${GREEN}Installation process started!${NC}"
echo ""
echo "To stop the server when done:"
echo "  ./cleanup.sh"
