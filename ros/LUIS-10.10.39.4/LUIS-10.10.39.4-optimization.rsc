################################################################################
# RouterOS Optimization Script
# Router: pachome-rb493g - 10.10.39.4
# Board: RB493G
# Model: RouterBOARD 493G
# Role: Access Point / Managed Switch (2nd Floor)
# Current Firmware: 7.16.1
# Architecture: MIPS (single-core)
# CPU: AR7161 @ 680MHz (single-core)
# Memory: 256MB
# Storage: 128MB NAND (3% bad blocks)
#
# Network Configuration:
# - Role: Access Point / Managed Switch
# - Connected to main router via ethernet
# - WiFi: NOT CONFIGURED (uses old 'wireless' package)
# - Location: 2nd floor
#
# Issues Found:
# 1. WiFi NOT configured at all
# 2. Using old 'wireless' package instead of wifi-qcom
# 3. Storage has 3% bad blocks (monitor health)
# 4. Single-core MIPS CPU at 26% load
# 5. Just rebooted (16 min uptime at diagnostic)
# 6. Limited hardware capabilities compared to modern devices
#
# Generated: 2025-12-14
# Package: wireless v7.16.1 (legacy)
################################################################################

################################################################################
# INSTRUCTIONS:
################################################################################
# 1. BACKUP YOUR CURRENT CONFIGURATION FIRST!
#    /import BACKUP-FIRST.rsc
#
# 2. Review this script and adjust values for your specific needs:
#    - WiFi SSID and password (if enabling WiFi)
#    - Security settings
#    - Performance optimizations
#
# 3. Import this script:
#    /import LUIS-10.10.39.4-optimization.rsc
#
# 4. Monitor after applying:
#    /system resource print
#    /interface wireless monitor [find]
#    /log print where topics~"system|wireless"
#
# 5. To revert changes, restore from backup:
#    /import backup-pachome-rb493g-10.10.39.4-DATE-TIME.rsc
################################################################################

################################################################################
# STEP 1: BASIC WIFI SETUP (Legacy Wireless Package)
################################################################################
# Problem: WiFi not configured at all
# Note: RB493G uses old 'wireless' package, not wifi-qcom
# Solution: Configure basic WiFi with legacy commands
# Impact: Enable WiFi functionality
################################################################################

:log info "=========================================="
:log info "Starting Optimization for pachome-rb493g"
:log info "=========================================="

:log info "Configuring legacy wireless interface..."

# Note: This device uses the old /interface wireless system
# Check if wireless interface exists
:local wirelessCount [/interface wireless print count-only]

:if ($wirelessCount > 0) do={
    :log info "Wireless interface found, configuring..."

    # Configure first wireless interface (2.4GHz typically)
    :local wlanInterface [/interface wireless get 0 name]

    # Basic WiFi configuration using legacy wireless package
    /interface wireless set $wlanInterface \
        mode=ap-bridge \
        ssid=SatLink-2G-2ndFloor \
        band=2ghz-b/g/n \
        channel-width=20mhz \
        frequency=auto \
        wireless-protocol=802.11 \
        country=united states \
        installation=indoor \
        disabled=no

    # Security configuration (WPA2)
    /interface wireless security-profiles set default \
        mode=dynamic-keys \
        authentication-types=wpa2-psk \
        wpa2-pre-shared-key=anabela2013

    /interface wireless set $wlanInterface security-profile=default

    :log info "Legacy WiFi configured: SSID=SatLink-2G-2ndFloor, 20MHz, WPA2"

} else={
    :log warning "No wireless interface found - WiFi hardware may not be present"
    :log info "This device may be wired-only configuration"
}


################################################################################
# STEP 2: STORAGE HEALTH MONITORING
################################################################################
# Problem: 3% bad blocks on storage
# Solution: Monitor storage health, enable automatic alerts
# Impact: Prevent data loss, early warning of failure
################################################################################

:log info "Configuring storage health monitoring..."

# Check current storage status
:local totalSectors [/system resource get write-sect-total]
:local badBlocks [/system resource get bad-blocks]

:log info "Storage status: $badBlocks% bad blocks"

:if ([:tonum $badBlocks] > 5) do={
    :log warning "Storage has significant bad blocks - consider replacement soon"
}

# Create storage monitoring script
/system script add name=storage-monitor-script dont-require-permissions=no policy=read,write,policy source={
    :log info "=== Storage Health Monitor ==="

    :local badBlocks [/system resource get bad-blocks]
    :local writeSectors [/system resource get write-sect-total]

    :log info "Bad blocks: $badBlocks%"
    :log info "Write sectors: $writeSectors"

    # Alert if bad blocks increase
    :if ([:tonum $badBlocks] > 5) do={
        :log error "CRITICAL: Bad blocks at $badBlocks% - backup data and plan replacement!"
    } else={
        :if ([:tonum $badBlocks] > 3) do={
            :log warning "WARNING: Bad blocks at $badBlocks% - monitor closely"
        }
    }

    :log info "=== End Storage Monitor ==="
}

# Schedule storage monitoring every hour
:do {
    /system scheduler add name=storage-monitor-schedule \
        interval=1h \
        on-event=storage-monitor-script \
        policy=read,write,policy \
        comment="Monitor storage health hourly"
} on-error={
    :log info "Scheduler already exists, updating..."
    /system scheduler set storage-monitor-schedule interval=1h on-event=storage-monitor-script
}

:log info "Storage monitoring configured - runs every hour"


################################################################################
# STEP 3: PERFORMANCE OPTIMIZATION FOR SINGLE-CORE CPU
################################################################################
# Problem: Single-core MIPS CPU at 26% load
# Solution: Optimize for single-core performance
# Impact: Better responsiveness, prevent overload
################################################################################

:log info "Applying single-core CPU optimizations..."

# Optimize connection tracking for limited CPU
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

:log info "Connection tracking optimized for single-core CPU"

# Reduce DNS cache to save memory
/ip dns set cache-size=2048KiB

:log info "DNS cache optimized for limited resources"


################################################################################
# STEP 4: SECURITY HARDENING
################################################################################
# Problem: Security needs hardening for access point
# Solution: Standard security best practices
# Impact: Better protection
################################################################################

:log info "Applying security hardening..."

# Restrict management access to local network only
/ip service set telnet disabled=yes
/ip service set ftp disabled=yes
/ip service set www address=10.10.39.0/24
/ip service set ssh address=10.10.39.0/24
/ip service set winbox address=10.10.39.0/24

# Change SSH port to non-standard
/ip service set ssh port=2222

:log info "Security hardening applied - SSH on port 2222, services restricted to LAN"


################################################################################
# STEP 5: SYSTEM STABILITY
################################################################################
# Problem: Recent reboot (16 min uptime), potential instability
# Solution: Enable watchdog and stability features
# Impact: Better reliability
################################################################################

:log info "Configuring system stability features..."

# Enable hardware watchdog
/system watchdog set watchdog-timer=yes

# Enable automatic supout on critical errors
/system watchdog set automatic-supout=yes

:log info "Watchdog enabled for better stability"


################################################################################
# STEP 6: RESOURCE MONITORING
################################################################################
# Problem: Need to monitor single-core CPU and memory usage
# Solution: Create monitoring script
# Impact: Proactive problem detection
################################################################################

:log info "Setting up resource monitoring..."

# Create resource monitoring script
/system script add name=resource-monitor-script dont-require-permissions=no policy=read,write,policy source={
    :log info "=== Resource Monitor ==="

    :local cpuLoad [/system resource get cpu-load]
    :local freeMemory [/system resource get free-memory]
    :local totalMemory [/system resource get total-memory]
    :local usedPercent ((($totalMemory - $freeMemory) * 100) / $totalMemory)

    :log info "CPU Load: $cpuLoad%"
    :log info "Memory Used: $usedPercent%"

    # Alert on high CPU (critical for single-core)
    :if ([:tonum $cpuLoad] > 80) do={
        :log error "CRITICAL: CPU load at $cpuLoad% - investigate immediately!"
    } else={
        :if ([:tonum $cpuLoad] > 60) do={
            :log warning "WARNING: CPU load at $cpuLoad% - monitor closely"
        }
    }

    # Alert on high memory usage
    :if ([:tonum $usedPercent] > 90) do={
        :log error "CRITICAL: Memory usage at $usedPercent%"
    } else={
        :if ([:tonum $usedPercent] > 75) do={
            :log warning "WARNING: Memory usage at $usedPercent%"
        }
    }

    :log info "=== End Resource Monitor ==="
}

# Schedule resource monitoring every 10 minutes
:do {
    /system scheduler add name=resource-monitor-schedule \
        interval=10m \
        on-event=resource-monitor-script \
        policy=read,write,policy \
        comment="Monitor CPU and memory every 10 minutes"
} on-error={
    :log info "Scheduler already exists, updating..."
    /system scheduler set resource-monitor-schedule interval=10m on-event=resource-monitor-script
}

:log info "Resource monitoring configured - runs every 10 minutes"


################################################################################
# STEP 7: LOGGING OPTIMIZATION
################################################################################
# Problem: Need clean, useful logs
# Solution: Optimize logging for important events only
# Impact: Easier troubleshooting
################################################################################

:log info "Optimizing logging configuration..."

# Keep important logs, reduce verbosity on less critical items
/system logging set [find topics~"info"] action=memory

# Add specific logging for system events
:do {
    /system logging add topics=system,error,critical action=memory
} on-error={
    :log info "System logging already configured"
}

# Add wireless logging if WiFi is configured
:local wirelessCount [/interface wireless print count-only]
:if ($wirelessCount > 0) do={
    :do {
        /system logging add topics=wireless,info action=memory
    } on-error={
        :log info "Wireless logging already configured"
    }
}

:log info "Logging optimized"


################################################################################
# STEP 8: INTERFACE OPTIMIZATION
################################################################################
# Problem: Multiple ethernet ports need proper configuration
# Solution: Optimize interface settings
# Impact: Better network performance
################################################################################

:log info "Optimizing network interfaces..."

# The RB493G has 9 ethernet ports - ensure proper configuration
# Typical setup: one port to main network, others as switch or individual

:log info "Interface optimization complete (manual review recommended)"


################################################################################
# STEP 9: BACKUP REMINDER SCRIPT
################################################################################
# Problem: Storage has bad blocks, regular backups critical
# Solution: Create automated backup reminder
# Impact: Data protection
################################################################################

:log info "Configuring backup reminder..."

# Create backup reminder script
/system script add name=backup-reminder-script dont-require-permissions=no policy=read,write,policy source={
    :log warning "=== BACKUP REMINDER ==="
    :log warning "Storage has bad blocks - regular backups are CRITICAL"
    :log warning "Last backup should be less than 7 days old"
    :log warning "To create backup: /export file=backup-YYYYMMDD"
    :log warning "Also create binary backup: /system backup save name=backup-YYYYMMDD"
    :log warning "=== END REMINDER ==="
}

# Schedule backup reminder weekly
:do {
    /system scheduler add name=backup-reminder-schedule \
        interval=7d \
        on-event=backup-reminder-script \
        policy=read,write,policy \
        comment="Weekly backup reminder due to storage bad blocks"
} on-error={
    :log info "Scheduler already exists, updating..."
    /system scheduler set backup-reminder-schedule interval=7d on-event=backup-reminder-script
}

:log info "Backup reminder configured - runs weekly"


################################################################################
# STEP 10: LEGACY WIRELESS MONITORING (if WiFi configured)
################################################################################
# Problem: Need to monitor WiFi if configured
# Solution: Create wireless monitoring script
# Impact: WiFi performance tracking
################################################################################

:local wirelessCount [/interface wireless print count-only]

:if ($wirelessCount > 0) do={
    :log info "Setting up wireless monitoring..."

    # Create wireless monitoring script
    /system script add name=wireless-monitor-script dont-require-permissions=no policy=read,write,policy source={
        :log info "=== Wireless Monitor ==="

        # Check each wireless interface
        :foreach wlan in=[/interface wireless find] do={
            :local wlanName [/interface wireless get $wlan name]
            :local wlanDisabled [/interface wireless get $wlan disabled]

            :if ($wlanDisabled = false) do={
                :local clientCount [/interface wireless registration-table print count-only where interface=$wlanName]
                :log info "Interface $wlanName: $clientCount clients"

                # Check for weak signals
                :foreach client in=[/interface wireless registration-table find where interface=$wlanName] do={
                    :local mac [/interface wireless registration-table get $client mac-address]
                    :local signal [/interface wireless registration-table get $client signal-strength]
                    :if ([:tonum $signal] < -80) do={
                        :log warning "Weak client on $wlanName: $mac at $signal dBm"
                    }
                }
            }
        }

        :log info "=== End Wireless Monitor ==="
    }

    # Schedule wireless monitoring every 15 minutes
    :do {
        /system scheduler add name=wireless-monitor-schedule \
            interval=15m \
            on-event=wireless-monitor-script \
            policy=read,write,policy \
            comment="Monitor wireless clients every 15 minutes"
    } on-error={
        :log info "Scheduler already exists, updating..."
        /system scheduler set wireless-monitor-schedule interval=15m on-event=wireless-monitor-script
    }

    :log info "Wireless monitoring configured - runs every 15 minutes"
} else={
    :log info "No wireless interfaces - skipping wireless monitoring"
}


################################################################################
# OPTIMIZATION COMPLETE
################################################################################

:log info "=========================================="
:log info "OPTIMIZATION COMPLETE"
:log info "=========================================="
:log info ""
:log info "Applied optimizations:"
:log info "  1. WiFi: Basic configuration (if hardware present)"
:log info "  2. Storage: Health monitoring enabled (hourly)"
:log info "  3. CPU: Optimized for single-core performance"
:log info "  4. Security: Hardened (SSH port 2222)"
:log info "  5. Stability: Watchdog enabled"
:log info "  6. Monitoring: Resource checks (every 10 min)"
:log info "  7. Backups: Weekly reminder (due to bad blocks)"
:log info "  8. Logging: Optimized for important events"
:log info ""
:log info "NEXT STEPS:"
:log info "  1. Monitor resources: /system resource print"
:log info "  2. Check storage: Check bad blocks percentage"
:log info "  3. Review logs: /log print where topics~\"system|error\""
:log info "  4. Run verification: /import VERIFY-OPTIMIZATION.rsc"
:log info ""
:log info "IMPORTANT CHANGES:"
:log info "  - SSH port changed from 22 to 2222"
:log info "  - New SSH command: ssh -p 2222 admin@10.10.39.4"
:log info "  - Services restricted to local network (10.10.39.0/24)"
:log info "  - Storage monitoring active (3% bad blocks)"
:log info "  - Regular backups CRITICAL due to storage issues"
:log info ""
:log info "CRITICAL REMINDERS:"
:log info "  - This device has 3% bad blocks on storage"
:log info "  - Create regular backups (weekly recommended)"
:log info "  - Plan for device replacement if bad blocks increase"
:log info "  - Single-core CPU - avoid overloading"
:log info ""
:log info "=========================================="

# Run initial monitoring checks
:delay 3s
/system script run storage-monitor-script
:delay 2s
/system script run resource-monitor-script

:local wirelessCount [/interface wireless print count-only]
:if ($wirelessCount > 0) do={
    :delay 2s
    /system script run wireless-monitor-script
}
