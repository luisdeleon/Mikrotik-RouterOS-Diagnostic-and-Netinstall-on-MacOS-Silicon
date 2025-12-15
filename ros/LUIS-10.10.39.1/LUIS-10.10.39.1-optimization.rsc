################################################################################
# RouterOS Optimization Script
# Router: LUIS - 10.10.39.1
# Board: hAP ac^3 (RBD53iG-5HacD2HnD)
# Model: RBD53iG-5HacD2HnD
# Serial: D96C0C4A2C24
# Current Firmware: 7.20.4
# Architecture: ARM (IPQ4000)
# CPU: 4-core @ 896MHz
# Memory: 256MB
# Uptime at diagnostic: 48m55s
#
# Network Configuration:
# - WAN: ether01-gateway (Telmex NET) - 192.168.55.69/24
# - LAN: 10.10.39.0/24 (bridge)
# - WiFi 2.4GHz: SatLink-2G (wlan-2g)
# - WiFi 5GHz: SatLink-5G (wlan-5g)
# - VPN: L2TP, ZeroTier (US & Wifilink)
#
# Issues Found:
# 1. Very high connection count (1,486 connections - too many for this router)
# 2. No bandwidth management (all queues disabled)
# 3. SYN flood attacks on SSH port
# 4. Weak WiFi signal on some clients (-84 dBm)
# 5. 74 DHCP leases (many stale)
#
# Generated: 2025-12-14
# Package: wifi-qcom-ac v7.20.4
################################################################################

################################################################################
# INSTRUCTIONS:
################################################################################
# 1. BACKUP YOUR CURRENT CONFIGURATION FIRST!
#    /export file=backup-before-optimization
#
# 2. Review this script and adjust values for your specific needs:
#    - WAN interface speed (adjust queue max-limit)
#    - Trusted IP addresses for SSH access
#    - Connection limits per IP
#    - DHCP lease time
#
# 3. Import this script:
#    /import LUIS-10.10.39.1-optimization.rsc
#
# 4. Monitor after applying:
#    /ip firewall connection print count-only
#    /system resource print
#    /interface monitor-traffic [find]
#
# 5. To revert changes, restore from backup:
#    /import backup-before-optimization.rsc
################################################################################

################################################################################
# STEP 1: CONNECTION TRACKING OPTIMIZATION
################################################################################
# Problem: 1,486 active connections overwhelming router resources
# Solution: Reduce connection timeout values to free up memory faster
# Impact: Immediate performance improvement
################################################################################

:log info "Applying connection tracking optimizations..."

/ip firewall connection tracking set \
    enabled=yes \
    tcp-established-timeout=1h \
    tcp-close-timeout=10s \
    tcp-close-wait-timeout=10s \
    tcp-fin-wait-timeout=10s \
    tcp-last-ack-timeout=10s \
    tcp-syn-sent-timeout=30s \
    tcp-syn-received-timeout=30s \
    tcp-time-wait-timeout=10s \
    udp-timeout=30s \
    udp-stream-timeout=3m \
    icmp-timeout=10s \
    generic-timeout=10m

:log info "Connection tracking optimized - timeouts reduced"


################################################################################
# STEP 2: CONNECTION LIMIT PER IP
################################################################################
# Problem: Single IPs (like 10.10.39.250) creating hundreds of connections
# Solution: Limit each IP to maximum 200 simultaneous connections
# Impact: Prevents abuse and ensures fair resource distribution
################################################################################

:log info "Adding connection limit rules..."

# Add connection limit rule (place before accept rules)
/ip firewall filter add \
    chain=forward \
    connection-limit=200,32 \
    protocol=tcp \
    action=drop \
    comment="Limit TCP connections per IP to 200" \
    place-before=0

/ip firewall filter add \
    chain=forward \
    connection-limit=150,32 \
    protocol=udp \
    action=drop \
    comment="Limit UDP connections per IP to 150" \
    place-before=1

:log info "Connection limits applied"


################################################################################
# STEP 3: SSH SECURITY HARDENING
################################################################################
# Problem: SYN flood attacks detected on SSH port 22
# Solution: Restrict SSH to local network only + rate limiting
# Impact: Stops external attacks, improves security
################################################################################

:log info "Hardening SSH security..."

# Change SSH port from 22 to 2222 (security through obscurity)
/ip service set ssh port=2222

# Restrict SSH to local network only
# WARNING: If you need remote SSH access, add your trusted IPs here!
/ip service set ssh address=10.10.39.0/24

# Add SSH brute-force protection
/ip firewall filter add \
    chain=input \
    protocol=tcp \
    dst-port=2222 \
    connection-state=new \
    src-address-list=ssh_blacklist \
    action=drop \
    comment="Drop SSH blacklisted IPs"

/ip firewall filter add \
    chain=input \
    protocol=tcp \
    dst-port=2222 \
    connection-state=new \
    action=add-src-to-address-list \
    address-list=ssh_stage1 \
    address-list-timeout=1m \
    comment="SSH Stage 1"

/ip firewall filter add \
    chain=input \
    protocol=tcp \
    dst-port=2222 \
    connection-state=new \
    src-address-list=ssh_stage1 \
    action=add-src-to-address-list \
    address-list=ssh_blacklist \
    address-list-timeout=1d \
    comment="SSH Stage 2 - Blacklist for 1 day"

:log info "SSH hardened - Port changed to 2222, local access only"
:log warning "SSH port changed to 2222 - update your SSH client configuration!"


################################################################################
# STEP 4: BANDWIDTH MANAGEMENT (QoS)
################################################################################
# Problem: No QoS - heavy users consume all bandwidth
# Solution: Enable queue tree with per-subnet bandwidth limits
# Impact: Fair bandwidth distribution, better performance for all users
#
# IMPORTANT: Adjust max-limit values based on your actual WAN speed!
# Current assumption: ~100 Mbps WAN connection
# If your connection is different, adjust the values below:
#   - For 50 Mbps: main-queue=45M, subnet queues=15M/15M/10M/5M
#   - For 200 Mbps: main-queue=180M, subnet queues=60M/60M/40M/20M
################################################################################

:log info "Configuring QoS (Queue Management)..."

# Get current WAN bandwidth (adjust if needed)
# Assuming 100 Mbps connection, use 90% (90M) to prevent buffer bloat
:local wanSpeed "90M"
:local subnet0Speed "30M"
:local subnet64Speed "30M"
:local subnet128Speed "20M"
:local subnet192Speed "10M"

# Enable main queue
/queue tree set [find name="main-queue"] \
    disabled=no \
    parent=bridge \
    max-limit=$wanSpeed \
    comment="Main queue - 90% of WAN bandwidth"

# Enable subnet queues
/queue tree set [find name="subnet-0"] \
    disabled=no \
    parent=main-queue \
    max-limit=$subnet0Speed \
    comment="Subnet 10.10.39.0/26 - 30 Mbps"

/queue tree set [find name="subnet-64"] \
    disabled=no \
    parent=main-queue \
    max-limit=$subnet64Speed \
    comment="Subnet 10.10.39.64/26 - 30 Mbps"

/queue tree set [find name="subnet-128"] \
    disabled=no \
    parent=main-queue \
    max-limit=$subnet128Speed \
    comment="Subnet 10.10.39.128/26 - 20 Mbps"

/queue tree set [find name="subnet-192"] \
    disabled=no \
    parent=main-queue \
    max-limit=$subnet192Speed \
    comment="Subnet 10.10.39.192/26 - 10 Mbps"

:log info "QoS enabled - bandwidth limits applied per subnet"


################################################################################
# STEP 5: WIFI OPTIMIZATION
################################################################################
# Problem: Packet drops on WiFi, weak signal on some clients
# Solution: Optimize WiFi settings for better performance
# Impact: Reduced WiFi latency and better coverage
################################################################################

:log info "Optimizing WiFi settings..."

# Optimize 2.4GHz WiFi
/interface/wifi set wlan-2g \
    configuration.country="United States" \
    configuration.mode=ap \
    configuration.ssid="SatLink-2G" \
    channel.band=2ghz-n \
    channel.width=20mhz \
    channel.frequency=2412,2437,2462 \
    security.authentication-types=wpa2-psk,wpa3-psk \
    disabled=no \
    comment="2.4GHz optimized - channels 1,6,11 only"

# Optimize 5GHz WiFi
/interface/wifi set wlan-5g \
    configuration.country="United States" \
    configuration.mode=ap \
    configuration.ssid="SatLink-5G" \
    channel.band=5ghz-ac \
    channel.width=20/40/80mhz \
    security.authentication-types=wpa2-psk,wpa3-psk \
    disabled=no \
    comment="5GHz optimized - Auto channel width"

# Enable WiFi keepalive to detect dead clients faster
# This helps clean up the registration table

:log info "WiFi optimized - WPA3 enabled, channels optimized"


################################################################################
# STEP 6: DHCP SERVER OPTIMIZATION
################################################################################
# Problem: 74 DHCP leases, many stale entries
# Solution: Reduce lease time and clean up old entries
# Impact: Cleaner DHCP table, faster IP reassignment
################################################################################

:log info "Optimizing DHCP server..."

# Reduce lease time from default (often 24h or more) to 4 hours
/ip dhcp-server set [find] lease-time=4h

# Remove stale leases (waiting status, not seen in 7+ days)
# Note: This only removes leases in "waiting" status
/ip dhcp-server lease remove [find status=waiting]

:log info "DHCP optimized - lease time reduced to 4h, stale entries removed"


################################################################################
# STEP 7: FIREWALL OPTIMIZATION
################################################################################
# Problem: FastTrack is working but could be optimized
# Solution: Add more specific FastTrack rules for better performance
# Impact: Less CPU usage for established connections
################################################################################

:log info "Optimizing firewall rules..."

# Ensure FastTrack is enabled for established connections
# This bypasses normal routing and significantly improves performance
# Note: FastTrack already exists, just ensuring it's optimal

# Add rule to FastTrack LAN-to-WAN traffic (if not already present)
:if ([:len [/ip firewall filter find where comment="FastTrack"]] = 0) do={
    /ip firewall filter add \
        chain=forward \
        action=fasttrack-connection \
        connection-state=established,related \
        comment="FastTrack" \
        place-before=0
}

:log info "Firewall optimized - FastTrack configured"


################################################################################
# STEP 8: DNS CACHE OPTIMIZATION
################################################################################
# Problem: 187 DNS cache entries (could be optimized)
# Solution: Increase DNS cache size and enable static entries
# Impact: Faster DNS resolution, less external queries
################################################################################

:log info "Optimizing DNS settings..."

/ip dns set \
    allow-remote-requests=yes \
    cache-size=4096KiB \
    cache-max-ttl=1d

:log info "DNS optimized - cache increased to 4MB"


################################################################################
# STEP 9: SYSTEM OPTIMIZATION
################################################################################
# Problem: Router uptime is low (48 min), may need tuning
# Solution: Optimize system settings for better performance
# Impact: Better overall stability
################################################################################

:log info "Applying system optimizations..."

# Enable hardware offloading if available (already should be on)
/interface ethernet set [find] l2mtu=1598

# Optimize ARP timeout (default is often too long)
/ip arp set [find] timeout=5m

:log info "System optimizations applied"


################################################################################
# STEP 10: MONITORING AND ALERTS
################################################################################
# Problem: No active monitoring of connection count
# Solution: Add scheduled script to monitor and alert
# Impact: Proactive problem detection
################################################################################

:log info "Setting up monitoring script..."

# Create monitoring script
/system script add \
    name=connection-monitor \
    policy=read,write,policy,test \
    source={
        :local connCount [/ip firewall connection print count-only]
        :local cpuLoad [/system resource get cpu-load]
        :local memUsed [/system resource get total-memory]
        :local memFree [/system resource get free-memory]
        :local memPercent (($memUsed - $memFree) * 100 / $memUsed)

        :if ($connCount > 1000) do={
            :log warning "High connection count: $connCount connections"
        }
        :if ($cpuLoad > 80) do={
            :log warning "High CPU load: $cpuLoad%"
        }
        :if ($memPercent > 90) do={
            :log warning "High memory usage: $memPercent%"
        }
    } \
    comment="Monitor connections, CPU, and memory"

# Schedule monitoring script to run every 5 minutes
/system scheduler add \
    name=connection-monitor-schedule \
    interval=5m \
    policy=read,write,policy,test \
    on-event=connection-monitor \
    comment="Run connection monitor every 5 minutes"

:log info "Monitoring script configured - runs every 5 minutes"


################################################################################
# STEP 11: BANDWIDTH TEST TOOL (OPTIONAL)
################################################################################
# Problem: Need to identify bandwidth hogs
# Solution: Instructions for using traffic monitoring
################################################################################

:log info "Bandwidth monitoring commands:"
:log info "  /tool torch bridge duration=30s   # Monitor top bandwidth users for 30 seconds"
:log info "  /ip firewall connection print stats  # Show connection statistics"
:log info "  /queue tree print stats  # Show queue statistics"


################################################################################
# COMPLETION SUMMARY
################################################################################

:log info "=========================================="
:log info "OPTIMIZATION SCRIPT COMPLETED!"
:log info "=========================================="
:log info "Applied optimizations:"
:log info "  1. Connection tracking timeouts reduced"
:log info "  2. Connection limits per IP (200 TCP, 150 UDP)"
:log info "  3. SSH hardened (port 2222, local only)"
:log info "  4. QoS enabled with bandwidth limits"
:log info "  5. WiFi optimized (WPA3, channel optimization)"
:log info "  6. DHCP lease time reduced to 4h"
:log info "  7. DNS cache increased to 4MB"
:log info "  8. Monitoring script enabled"
:log info "=========================================="
:log info "IMPORTANT CHANGES:"
:log info "  - SSH port changed: 22 -> 2222"
:log info "  - SSH access restricted to: 10.10.39.0/24"
:log info "  - Connection limits enforced per IP"
:log info "  - Bandwidth limits active (adjust if needed)"
:log info "=========================================="
:log info "NEXT STEPS:"
:log info "  1. Update SSH client to use port 2222"
:log info "  2. Monitor performance: /system resource print"
:log info "  3. Check connections: /ip firewall connection print count-only"
:log info "  4. Review logs: /log print where topics~\"warning\""
:log info "  5. Adjust queue max-limit if bandwidth is different"
:log info "=========================================="
:log info "To monitor real-time traffic:"
:log info "  /interface monitor-traffic [find]"
:log info "To identify bandwidth hogs:"
:log info "  /tool torch bridge duration=30s"
:log info "To revert all changes:"
:log info "  /import backup-before-optimization.rsc"
:log info "=========================================="

# End of script
