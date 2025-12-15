################################################################################
# POST-OPTIMIZATION VERIFICATION SCRIPT
# Router: LUIS - 10.10.39.1
################################################################################
# This script checks if the optimization was applied successfully
# and provides a performance report.
#
# USAGE:
#   /import VERIFY-OPTIMIZATION.rsc
#
# Or run directly:
#   /system script run verify-optimization
################################################################################

:log info "=========================================="
:log info "OPTIMIZATION VERIFICATION REPORT"
:log info "Router: LUIS - 10.10.39.1"
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

:log info "   CPU Load: $cpuLoad%"
:log info "   Memory: $memUsedMB MB / $memTotalMB MB used"
:log info "   Uptime: $uptime"

:if ($cpuLoad < 30) do={
    :log info "   Status: CPU load is GOOD"
} else={
    :log warning "   Status: CPU load is HIGH - investigate"
}

# Check 2: Connection Count
:log info ""
:log info "2. CONNECTION TRACKING:"
:local connCount [/ip firewall connection print count-only]
:log info "   Active connections: $connCount"

:if ($connCount < 800) do={
    :log info "   Status: Connection count is GOOD"
} else={
    :if ($connCount < 1200) do={
        :log warning "   Status: Connection count is MODERATE"
    } else={
        :log warning "   Status: Connection count is STILL HIGH"
    }
}

# Check 3: Connection Tracking Settings
:log info ""
:log info "3. CONNECTION TRACKING SETTINGS:"
:local tcpTimeout [/ip firewall connection tracking get tcp-established-timeout]
:local udpTimeout [/ip firewall connection tracking get udp-timeout]
:log info "   TCP timeout: $tcpTimeout"
:log info "   UDP timeout: $udpTimeout"

:if ($tcpTimeout = "1h") do={
    :log info "   Status: Timeouts OPTIMIZED"
} else={
    :log warning "   Status: Timeouts NOT optimized"
}

# Check 4: Connection Limit Rules
:log info ""
:log info "4. CONNECTION LIMIT RULES:"
:local connLimitRules [/ip firewall filter print count-only where comment~"Limit.*connections"]
:log info "   Connection limit rules: $connLimitRules"

:if ($connLimitRules >= 2) do={
    :log info "   Status: Connection limits ACTIVE"
} else={
    :log warning "   Status: Connection limits NOT configured"
}

# Check 5: SSH Security
:log info ""
:log info "5. SSH SECURITY:"
:local sshPort [/ip service get ssh port]
:local sshAddress [/ip service get ssh address]
:log info "   SSH Port: $sshPort"
:log info "   SSH Allowed from: $sshAddress"

:if ($sshPort = 2222) do={
    :log info "   Status: SSH port CHANGED (secure)"
} else={
    :log warning "   Status: SSH still on default port 22"
}

# Check 6: Queue Tree Status
:log info ""
:log info "6. BANDWIDTH MANAGEMENT (QoS):"
:local mainQueueStatus [/queue tree get [find name="main-queue"] disabled]
:local activeQueues [/queue tree print count-only where !disabled]
:log info "   Active queues: $activeQueues"

:if ($mainQueueStatus = false) do={
    :log info "   Status: QoS is ENABLED"
    :local mainLimit [/queue tree get [find name="main-queue"] max-limit]
    :log info "   Main queue limit: $mainLimit"
} else={
    :log warning "   Status: QoS is DISABLED"
}

# Check 7: WiFi Status
:log info ""
:log info "7. WIFI STATUS:"
:local wifi2g [/interface/wifi get wlan-2g disabled]
:local wifi5g [/interface/wifi get wlan-5g disabled]
:local wifi2gClients [/interface/wifi/registration-table print count-only where interface=wlan-2g]
:local wifi5gClients [/interface/wifi/registration-table print count-only where interface=wlan-5g]

:log info "   2.4GHz: $wifi2gClients clients connected"
:log info "   5GHz: $wifi5gClients clients connected"

:if ($wifi2g = false && $wifi5g = false) do={
    :log info "   Status: WiFi is ACTIVE"
} else={
    :log warning "   Status: Some WiFi disabled"
}

# Check 8: DHCP Leases
:log info ""
:log info "8. DHCP SERVER:"
:local dhcpLeases [/ip dhcp-server lease print count-only]
:local dhcpBound [/ip dhcp-server lease print count-only where status=bound]
:log info "   Total leases: $dhcpLeases"
:log info "   Active (bound): $dhcpBound"

:if ($dhcpLeases < 100) do={
    :log info "   Status: DHCP table is CLEAN"
} else={
    :log warning "   Status: DHCP table has many entries"
}

# Check 9: Firewall Stats
:log info ""
:log info "9. FIREWALL PERFORMANCE:"
:local fasttrackCount [/ip firewall connection print count-only where fasttrack=yes]
:local regularCount [/ip firewall connection print count-only where fasttrack=no]
:local fasttrackPercent (($fasttrackCount * 100) / $connCount)

:log info "   FastTrack connections: $fasttrackCount ($fasttrackPercent%)"
:log info "   Regular connections: $regularCount"

:if ($fasttrackPercent > 50) do={
    :log info "   Status: FastTrack is EFFECTIVE"
} else={
    :log warning "   Status: FastTrack usage is LOW"
}

# Check 10: Monitoring Script
:log info ""
:log info "10. MONITORING:"
:local monitorScript [/system scheduler print count-only where name="connection-monitor-schedule"]
:if ($monitorScript > 0) do={
    :log info "   Status: Monitoring script INSTALLED"
    :local nextRun [/system scheduler get connection-monitor-schedule next-run]
    :log info "   Next run: $nextRun"
} else={
    :log warning "   Status: Monitoring script NOT installed"
}

# Check 11: Recent Errors
:log info ""
:log info "11. RECENT ERRORS:"
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
:if ($cpuLoad < 30) do={ :set score ($score + 1) }
:if ($connCount < 800) do={ :set score ($score + 1) }
:if ($tcpTimeout = "1h") do={ :set score ($score + 1) }
:if ($connLimitRules >= 2) do={ :set score ($score + 1) }
:if ($sshPort = 2222) do={ :set score ($score + 1) }
:if ($mainQueueStatus = false) do={ :set score ($score + 1) }
:if ($wifi2g = false && $wifi5g = false) do={ :set score ($score + 1) }
:if ($fasttrackPercent > 50) do={ :set score ($score + 1) }
:if ($monitorScript > 0) do={ :set score ($score + 1) }
:if ($errorCount = 0) do={ :set score ($score + 1) }

:local scorePercent (($score * 100) / 10)
:log info "Optimization Score: $score/10 ($scorePercent%)"

:if ($score >= 8) do={
    :log info "Status: EXCELLENT - Router is well optimized"
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

:if ($connCount > 800) do={
    :log info "- High connections: Monitor with /tool torch"
}

:if ($cpuLoad > 30) do={
    :log info "- High CPU: Check /system resource cpu print"
}

:if ($mainQueueStatus = true) do={
    :log info "- QoS disabled: Enable with optimization script"
}

:if ($errorCount > 0) do={
    :log info "- Review errors: /log print where topics~\"error\""
}

:log info ""
:log info "To monitor performance continuously:"
:log info "  /interface monitor-traffic [find]"
:log info "  /tool torch bridge duration=30s"
:log info "  /ip firewall connection print stats"
:log info ""
:log info "=========================================="
:log info "VERIFICATION COMPLETE"
:log info "=========================================="
