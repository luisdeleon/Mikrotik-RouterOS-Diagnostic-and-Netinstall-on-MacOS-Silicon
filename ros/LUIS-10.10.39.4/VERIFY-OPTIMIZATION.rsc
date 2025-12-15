################################################################################
# POST-OPTIMIZATION VERIFICATION SCRIPT
# Router: pachome-rb493g - 10.10.39.4
################################################################################
# This script checks if the optimization was applied successfully
# and provides a performance report.
#
# USAGE:
#   /import VERIFY-OPTIMIZATION.rsc
#
# Or run directly:
#   /system script run verify-optimization-rb493g
################################################################################

:log info "=========================================="
:log info "OPTIMIZATION VERIFICATION REPORT"
:log info "Router: pachome-rb493g - 10.10.39.4"
:log info "=========================================="

# Check 1: System Resources
:log info ""
:log info "1. SYSTEM RESOURCES:"
:local cpuLoad [/system resource get cpu-load]
:local freeMemory [/system resource get free-memory]
:local totalMemory [/system resource get total-memory]
:local uptime [/system resource get uptime]
:local memUsedMB (($totalMemory - $freeMemory) / 1048576)
:local memTotalMB ($totalMemory / 1048576)
:local badBlocks [/system resource get bad-blocks]

:log info "   CPU Load: $cpuLoad% (single-core MIPS)"
:log info "   Memory: $memUsedMB MB / $memTotalMB MB used"
:log info "   Uptime: $uptime"
:log info "   Storage bad blocks: $badBlocks%"

:if ($cpuLoad < 50) do={
    :log info "   Status: CPU load is GOOD for single-core"
} else={
    :if ($cpuLoad < 70) do={
        :log warning "   Status: CPU load is MODERATE"
    } else={
        :log warning "   Status: CPU load is HIGH - investigate"
    }
}

:if ([:tonum $badBlocks] > 5) do={
    :log error "   Status: Bad blocks CRITICAL - plan replacement!"
} else={
    :if ([:tonum $badBlocks] > 3) do={
        :log warning "   Status: Bad blocks ELEVATED - monitor closely"
    } else={
        :log info "   Status: Bad blocks acceptable (but monitor)"
    }
}

# Check 2: Wireless Configuration (Legacy)
:log info ""
:log info "2. WIRELESS CONFIGURATION (LEGACY):"
:local wirelessCount [/interface wireless print count-only]

:if ($wirelessCount > 0) do={
    :log info "   Wireless interfaces: $wirelessCount"

    :foreach wlan in=[/interface wireless find] do={
        :local wlanName [/interface wireless get $wlan name]
        :local wlanDisabled [/interface wireless get $wlan disabled]
        :local wlanMode [/interface wireless get $wlan mode]
        :local wlanSSID [/interface wireless get $wlan ssid]

        :if ($wlanDisabled = false) do={
            :log info "   $wlanName: ENABLED"
            :log info "     Mode: $wlanMode"
            :log info "     SSID: $wlanSSID"

            :local clients [/interface wireless registration-table print count-only where interface=$wlanName]
            :log info "     Clients: $clients"
        } else={
            :log warning "   $wlanName: DISABLED"
        }
    }

    :log info "   Status: Wireless configured"
} else={
    :log info "   No wireless interfaces found"
    :log info "   Status: Wired-only device (normal for some RB493G configs)"
}

# Check 3: Connection Tracking
:log info ""
:log info "3. CONNECTION TRACKING:"
:local tcpTimeout [/ip firewall connection tracking get tcp-established-timeout]
:local udpTimeout [/ip firewall connection tracking get udp-timeout]
:log info "   TCP timeout: $tcpTimeout"
:log info "   UDP timeout: $udpTimeout"

:if ($tcpTimeout = "1h") do={
    :log info "   Status: Timeouts OPTIMIZED"
} else={
    :log warning "   Status: Timeouts NOT optimized"
}

# Check 4: Security Settings
:log info ""
:log info "4. SECURITY:"
:local sshPort [/ip service get ssh port]
:local sshAddress [/ip service get ssh address]
:local telnetDisabled [/ip service get telnet disabled]
:local ftpDisabled [/ip service get ftp disabled]

:log info "   SSH Port: $sshPort"
:log info "   SSH Allowed from: $sshAddress"
:log info "   Telnet disabled: $telnetDisabled"
:log info "   FTP disabled: $ftpDisabled"

:if ($sshPort = 2222) do={
    :log info "   Status: SSH port CHANGED (secure)"
} else={
    :log warning "   Status: SSH still on default port 22"
}

:if ($telnetDisabled = true && $ftpDisabled = true) do={
    :log info "   Status: Insecure services DISABLED (good)"
} else={
    :log warning "   Status: Some insecure services still enabled"
}

# Check 5: Watchdog
:log info ""
:log info "5. SYSTEM STABILITY:"
:local watchdog [/system watchdog get watchdog-timer]
:log info "   Watchdog: $watchdog"

:if ($watchdog = true) do={
    :log info "   Status: Watchdog ENABLED (good for reliability)"
} else={
    :log warning "   Status: Watchdog DISABLED"
}

# Check 6: Storage Monitoring Script
:log info ""
:log info "6. STORAGE MONITORING:"
:local storageMonitor [/system scheduler print count-only where name="storage-monitor-schedule"]
:if ($storageMonitor > 0) do={
    :log info "   Status: Storage monitoring script INSTALLED"
    :local nextRun [/system scheduler get storage-monitor-schedule next-run]
    :log info "   Next run: $nextRun"
    :log info "   Frequency: Hourly (critical due to bad blocks)"
} else={
    :log warning "   Status: Storage monitoring NOT installed"
}

# Check 7: Resource Monitoring Script
:log info ""
:log info "7. RESOURCE MONITORING:"
:local resourceMonitor [/system scheduler print count-only where name="resource-monitor-schedule"]
:if ($resourceMonitor > 0) do={
    :log info "   Status: Resource monitoring script INSTALLED"
    :local nextRun [/system scheduler get resource-monitor-schedule next-run]
    :log info "   Next run: $nextRun"
    :log info "   Frequency: Every 10 minutes"
} else={
    :log warning "   Status: Resource monitoring NOT installed"
}

# Check 8: Backup Reminder
:log info ""
:log info "8. BACKUP REMINDER:"
:local backupReminder [/system scheduler print count-only where name="backup-reminder-schedule"]
:if ($backupReminder > 0) do={
    :log info "   Status: Backup reminder INSTALLED"
    :local nextRun [/system scheduler get backup-reminder-schedule next-run]
    :log info "   Next run: $nextRun"
    :log info "   Frequency: Weekly (CRITICAL due to storage issues)"
} else={
    :log warning "   Status: Backup reminder NOT installed"
}

# Check 9: DNS Cache
:log info ""
:log info "9. DNS CONFIGURATION:"
:local dnsCache [/ip dns get cache-size]
:log info "   DNS cache: $dnsCache"

:if ($dnsCache = "2048KiB") do={
    :log info "   Status: DNS cache OPTIMIZED for limited resources"
} else={
    :log info "   DNS cache: $dnsCache"
}

# Check 10: Recent Errors
:log info ""
:log info "10. RECENT ERRORS:"
:local errorCount [/log print count-only where topics~"error|critical"]
:local warningCount [/log print count-only where topics~"warning"]
:log info "   Errors: $errorCount"
:log info "   Warnings: $warningCount"

:if ($errorCount = 0) do={
    :log info "   Status: No errors - GOOD"
} else={
    :log warning "   Status: $errorCount errors found - review logs"
}

# Summary
:log info ""
:log info "=========================================="
:log info "SUMMARY"
:log info "=========================================="

:local score 0

# Calculate optimization score
:if ($cpuLoad < 50) do={ :set score ($score + 1) }
:if ($tcpTimeout = "1h") do={ :set score ($score + 1) }
:if ($sshPort = 2222) do={ :set score ($score + 1) }
:if ($telnetDisabled = true && $ftpDisabled = true) do={ :set score ($score + 1) }
:if ($watchdog = true) do={ :set score ($score + 1) }
:if ($storageMonitor > 0) do={ :set score ($score + 1) }
:if ($resourceMonitor > 0) do={ :set score ($score + 1) }
:if ($backupReminder > 0) do={ :set score ($score + 1) }
:if ($dnsCache = "2048KiB") do={ :set score ($score + 1) }
:if ($errorCount = 0) do={ :set score ($score + 1) }

:local scorePercent (($score * 100) / 10)
:log info "Optimization Score: $score/10 ($scorePercent%)"

:if ($score >= 8) do={
    :log info "Status: EXCELLENT - Device is well optimized"
} else={
    :if ($score >= 6) do={
        :log info "Status: GOOD - Most optimizations applied"
    } else={
        :if ($score >= 4) do={
            :log warning "Status: FAIR - Some optimizations missing"
        } else={
            :log warning "Status: POOR - Review optimization script"
        }
    }
}

:log info "=========================================="
:log info "RECOMMENDATIONS:"
:log info "=========================================="

:if ([:tonum $badBlocks] > 3) do={
    :log warning "- CRITICAL: Monitor storage bad blocks closely"
    :log warning "- Create backups weekly (automated reminder in place)"
    :log warning "- Plan device replacement if bad blocks increase"
}

:if ($cpuLoad > 50) do={
    :log info "- High CPU: This is a single-core device"
    :log info "- Check /system resource cpu print"
    :log info "- Consider offloading tasks to other devices"
}

:if ($errorCount > 0) do={
    :log info "- Review errors: /log print where topics~\"error\""
}

:local wirelessCount [/interface wireless print count-only]
:if ($wirelessCount = 0) do={
    :log info "- No wireless configured - this may be intentional"
    :log info "- Device can function as wired switch/AP"
}

:log info ""
:log info "To monitor performance continuously:"
:log info "  /system resource print"
:log info "  /system resource cpu print"
:log info "  /log print where topics~\"system|error\""

:local wirelessCount [/interface wireless print count-only]
:if ($wirelessCount > 0) do={
    :log info "  /interface wireless monitor [find]"
    :log info "  /interface wireless registration-table print"
}

:log info ""
:log info "=========================================="
:log info "CRITICAL REMINDERS"
:log info "=========================================="
:log info "1. This device has $badBlocks% bad blocks on storage"
:log info "2. Create regular backups (weekly minimum)"
:log info "3. Monitor bad block percentage monthly"
:log info "4. Plan replacement if bad blocks exceed 5%"
:log info "5. Single-core CPU - don't overload with tasks"
:log info ""
:log info "=========================================="
:log info "VERIFICATION COMPLETE"
:log info "=========================================="
