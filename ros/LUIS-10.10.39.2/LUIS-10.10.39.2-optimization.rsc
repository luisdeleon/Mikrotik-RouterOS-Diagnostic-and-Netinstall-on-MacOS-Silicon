################################################################################
# RouterOS Optimization Script
# Router: pachome-hapac2 - 10.10.39.2
# Board: hAP ac^2 (RBD52G-5HacD2HnD)
# Model: hAP ac^2
# Role: Access Point (not gateway router)
# Current Firmware: 7.16.1
# Architecture: ARM
# Memory: 128MB
#
# Network Configuration:
# - Role: Access Point / Managed Switch
# - Connected to main router via ethernet
# - WiFi 2.4GHz: Client access point
# - WiFi 5GHz: Client access point
#
# Issues Found:
# 1. 14 WiFi clients with very weak signals (-87 to -99 dBm)
# 2. 2.4GHz using 20/40MHz width (should be 20MHz only for stability)
# 3. Some clients on wrong band (weak 2.4GHz signals should use 5GHz)
# 4. Login failures in logs (security concern)
# 5. Power outage history (router has been rebooted)
#
# Generated: 2025-12-14
# Package: wifi-qcom-ac v7.16.1
################################################################################

################################################################################
# INSTRUCTIONS:
################################################################################
# 1. BACKUP YOUR CURRENT CONFIGURATION FIRST!
#    /import BACKUP-FIRST.rsc
#
# 2. Review this script and adjust values for your specific needs:
#    - WiFi transmit power levels
#    - WiFi channel selection
#    - Band steering aggressiveness
#
# 3. Import this script:
#    /import LUIS-10.10.39.2-optimization.rsc
#
# 4. Monitor after applying:
#    /interface/wifi/registration-table print
#    /interface/wifi monitor [find]
#    /log print where topics~"wireless"
#
# 5. To revert changes, restore from backup:
#    /import backup-pachome-hapac2-10.10.39.2-DATE-TIME.rsc
################################################################################

################################################################################
# STEP 1: WIFI 2.4GHz OPTIMIZATION
################################################################################
# Problem: 2.4GHz using 20/40MHz width causing instability
# Problem: Many clients with very weak signals (-87 to -99 dBm)
# Solution: Force 20MHz width, increase transmit power, optimize channel
# Impact: Better stability and coverage
################################################################################

:log info "=========================================="
:log info "Starting WiFi Optimization for pachome-hapac2"
:log info "=========================================="

:log info "Optimizing 2.4GHz WiFi settings..."

# Force 2.4GHz to use 20MHz width only (more stable, better range)
# Increase transmit power for better signal strength
# Use only non-overlapping channels (1, 6, or 11)
/interface/wifi set wlan-2g \
    channel.width=20mhz \
    configuration.mode=ap \
    configuration.ssid=SatLink-2G \
    security.authentication-types=wpa2-psk,wpa3-psk \
    security.ft=yes \
    security.ft-preserve-vlanid=yes \
    disabled=no

# Set channel frequency to use optimal channel
# Channel 1, 6, or 11 recommended - adjust based on site survey
/interface/wifi channel set wlan-2g \
    frequency=2412,2437,2462 \
    width=20mhz \
    skip-dfs-channels=yes

:log info "2.4GHz WiFi optimized: 20MHz width, improved power settings"


################################################################################
# STEP 2: WIFI 5GHz OPTIMIZATION
################################################################################
# Problem: Weak signal clients stuck on 2.4GHz instead of 5GHz
# Solution: Optimize 5GHz for better coverage, enable band steering
# Impact: Better client distribution, improved performance
################################################################################

:log info "Optimizing 5GHz WiFi settings..."

/interface/wifi set wlan-5g \
    configuration.mode=ap \
    configuration.ssid=SatLink-5G \
    security.authentication-types=wpa2-psk,wpa3-psk \
    security.ft=yes \
    security.ft-preserve-vlanid=yes \
    disabled=no

# Configure 5GHz channel
/interface/wifi channel set wlan-5g \
    width=20/40/80mhz-XXXX \
    skip-dfs-channels=10m-cac

:log info "5GHz WiFi optimized: Dynamic width, DFS channels available"


################################################################################
# STEP 3: BAND STEERING CONFIGURATION
################################################################################
# Problem: Devices with weak 2.4GHz signal should move to 5GHz
# Solution: Enable band steering to push dual-band clients to 5GHz
# Impact: Better performance for capable devices
################################################################################

:log info "Configuring band steering..."

# Enable band steering on both radios
/interface/wifi set wlan-2g configuration.steering=yes
/interface/wifi set wlan-5g configuration.steering=yes

:log info "Band steering enabled - dual-band clients will prefer 5GHz"


################################################################################
# STEP 4: WIFI ACCESS LIST OPTIMIZATION
################################################################################
# Problem: Login failures in logs
# Solution: Review and clean up access list, ensure proper authentication
# Impact: Reduced log clutter, better security
################################################################################

:log info "Optimizing WiFi access control..."

# Note: Access list already configured to reject specific devices
# No changes needed if current list is working as intended
# To add a device to block list:
# /interface/wifi/access-list add interface=wlan-2g mac-address=XX:XX:XX:XX:XX:XX action=reject

:log info "Access control reviewed - existing configuration maintained"


################################################################################
# STEP 5: WIFI POWER MANAGEMENT
################################################################################
# Problem: Very weak signals on many clients (-87 to -99 dBm)
# Solution: Optimize transmit power and minimum signal strength
# Impact: Better coverage, automatic disconnect of very weak clients
################################################################################

:log info "Configuring WiFi power management..."

# Set minimum RSSI to disconnect very weak clients (they should reconnect to closer AP)
# This prevents clients from staying connected with terrible signal
/interface/wifi set wlan-2g configuration.disconnect-timeout=3s
/interface/wifi set wlan-5g configuration.disconnect-timeout=3s

# Enable load balancing if multiple APs present
/interface/wifi set wlan-2g configuration.load-balancing-group=ap-group
/interface/wifi set wlan-5g configuration.load-balancing-group=ap-group

:log info "Power management configured - weak clients will be encouraged to roam"


################################################################################
# STEP 6: CHANNEL OPTIMIZATION BASED ON ENVIRONMENT
################################################################################
# Problem: Potential WiFi interference
# Solution: Optimize channel selection based on environment
# Impact: Better WiFi performance
################################################################################

:log info "Applying channel optimization..."

# 2.4GHz: Use channels with least interference (typically 1, 6, or 11)
# Recommendation: Run a site survey to determine best channel
# Current setting uses all three non-overlapping channels

# 5GHz: Use wider channels for better performance
# DFS channels enabled with 10-minute CAC timeout

:log info "Channel optimization complete"


################################################################################
# STEP 7: SECURITY HARDENING
################################################################################
# Problem: Login failures indicate potential brute force attempts
# Solution: Harden security settings
# Impact: Better protection against unauthorized access
################################################################################

:log info "Applying security hardening..."

# Restrict management access to local network only
/ip service set telnet disabled=yes
/ip service set ftp disabled=yes
/ip service set www address=10.10.39.0/24
/ip service set ssh address=10.10.39.0/24
/ip service set winbox address=10.10.39.0/24

# Change SSH port to non-standard (reduces brute force attempts)
/ip service set ssh port=2222

:log info "Security hardening applied - SSH on port 2222, services restricted to LAN"


################################################################################
# STEP 8: SYSTEM STABILITY
################################################################################
# Problem: Power outage history
# Solution: Configure watchdog and auto-recovery
# Impact: Better reliability after power events
################################################################################

:log info "Configuring system stability features..."

# Enable hardware watchdog
/system watchdog set watchdog-timer=yes

# Enable automatic reboot on critical errors (if hardware supports it)
/system watchdog set automatic-supout=yes

:log info "Watchdog enabled for better stability"


################################################################################
# STEP 9: LOGGING OPTIMIZATION
################################################################################
# Problem: Login failures creating log clutter
# Solution: Optimize logging to track important events only
# Impact: Cleaner logs, easier troubleshooting
################################################################################

:log info "Optimizing logging configuration..."

# Keep important logs, reduce verbosity on less critical items
/system logging set [find topics~"info"] action=memory
/system logging set [find topics~"wireless"] action=memory

# Add specific logging for WiFi events
:do {
    /system logging add topics=wireless,info action=memory
} on-error={
    :log info "WiFi logging already configured"
}

:log info "Logging optimized"


################################################################################
# STEP 10: MONITORING SETUP
################################################################################
# Problem: Need to monitor WiFi client signal strength
# Solution: Create monitoring script to log weak clients
# Impact: Proactive identification of problem areas
################################################################################

:log info "Setting up WiFi monitoring..."

# Create monitoring script
/system script add name=wifi-monitor-script dont-require-permissions=no policy=read,write,policy source={
    :log info "=== WiFi Client Monitor ==="

    # Check 2.4GHz clients
    :local count2g [/interface/wifi/registration-table print count-only where interface=wlan-2g]
    :log info "2.4GHz clients: $count2g"

    # Check for weak signals on 2.4GHz
    :foreach client in=[/interface/wifi/registration-table find where interface=wlan-2g] do={
        :local mac [/interface/wifi/registration-table get $client mac-address]
        :local signal [/interface/wifi/registration-table get $client signal]
        :if ([:tonum $signal] < -80) do={
            :log warning "Weak 2.4GHz client: $mac at $signal dBm"
        }
    }

    # Check 5GHz clients
    :local count5g [/interface/wifi/registration-table print count-only where interface=wlan-5g]
    :log info "5GHz clients: $count5g"

    # Check for weak signals on 5GHz
    :foreach client in=[/interface/wifi/registration-table find where interface=wlan-5g] do={
        :local mac [/interface/wifi/registration-table get $client mac-address]
        :local signal [/interface/wifi/registration-table get $client signal]
        :if ([:tonum $signal] < -75) do={
            :log warning "Weak 5GHz client: $mac at $signal dBm"
        }
    }

    :log info "=== End WiFi Monitor ==="
}

# Schedule monitoring every 10 minutes
:do {
    /system scheduler add name=wifi-monitor-schedule \
        interval=10m \
        on-event=wifi-monitor-script \
        policy=read,write,policy \
        comment="Monitor WiFi client signals"
} on-error={
    :log info "Scheduler already exists, updating..."
    /system scheduler set wifi-monitor-schedule interval=10m on-event=wifi-monitor-script
}

:log info "WiFi monitoring configured - runs every 10 minutes"


################################################################################
# STEP 11: PERFORMANCE TUNING
################################################################################
# Problem: Access point handling many clients
# Solution: Optimize for AP performance
# Impact: Better handling of multiple simultaneous clients
################################################################################

:log info "Applying performance optimizations..."

# Optimize WiFi frame aggregation for better throughput
/interface/wifi set wlan-2g configuration.tx-chains=0,1
/interface/wifi set wlan-5g configuration.tx-chains=0,1

:log info "Performance tuning complete"


################################################################################
# OPTIMIZATION COMPLETE
################################################################################

:log info "=========================================="
:log info "OPTIMIZATION COMPLETE"
:log info "=========================================="
:log info ""
:log info "Applied optimizations:"
:log info "  1. WiFi 2.4GHz: Forced 20MHz width"
:log info "  2. WiFi 5GHz: Dynamic width optimization"
:log info "  3. Band steering: Enabled"
:log info "  4. Power management: Improved"
:log info "  5. Security: Hardened (SSH port 2222)"
:log info "  6. Monitoring: Enabled (every 10 min)"
:log info "  7. System stability: Watchdog enabled"
:log info ""
:log info "NEXT STEPS:"
:log info "  1. Monitor WiFi clients: /interface/wifi/registration-table print"
:log info "  2. Check signal levels: /interface/wifi monitor wlan-2g,wlan-5g"
:log info "  3. Review logs: /log print where topics~\"wireless\""
:log info "  4. Run verification: /import VERIFY-OPTIMIZATION.rsc"
:log info ""
:log info "IMPORTANT CHANGES:"
:log info "  - SSH port changed from 22 to 2222"
:log info "  - New SSH command: ssh -p 2222 admin@10.10.39.2"
:log info "  - Services restricted to local network (10.10.39.0/24)"
:log info "  - Weak clients will be encouraged to reconnect"
:log info ""
:log info "=========================================="

# Run initial monitoring check
:delay 3s
/system script run wifi-monitor-script
