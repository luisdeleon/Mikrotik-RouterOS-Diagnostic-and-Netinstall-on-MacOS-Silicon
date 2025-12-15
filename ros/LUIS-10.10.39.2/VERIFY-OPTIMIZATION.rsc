################################################################################
# POST-OPTIMIZATION VERIFICATION SCRIPT
# Router: pachome-hapac2 - 10.10.39.2
################################################################################
# This script checks if the optimization was applied successfully
# and provides a performance report.
#
# USAGE:
#   /import VERIFY-OPTIMIZATION.rsc
#
# Or run directly:
#   /system script run verify-optimization-hapac2
################################################################################

:log info "=========================================="
:log info "OPTIMIZATION VERIFICATION REPORT"
:log info "Router: pachome-hapac2 - 10.10.39.2"
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

:if ($cpuLoad < 40) do={
    :log info "   Status: CPU load is GOOD"
} else={
    :log warning "   Status: CPU load is HIGH - investigate"
}

# Check 2: WiFi 2.4GHz Configuration
:log info ""
:log info "2. WIFI 2.4GHz CONFIGURATION:"
:local wifi2gDisabled [/interface/wifi get wlan-2g disabled]
:local wifi2gChannel [/interface/wifi channel get wlan-2g width]

:if ($wifi2gDisabled = false) do={
    :log info "   Status: ENABLED"
    :log info "   Channel width: $wifi2gChannel"

    :if ($wifi2gChannel = "20mhz") do={
        :log info "   Status: Channel width OPTIMIZED (20MHz)"
    } else={
        :log warning "   Status: Channel width NOT optimized (should be 20MHz)"
    }
} else={
    :log warning "   Status: DISABLED"
}

# Check 3: WiFi 5GHz Configuration
:log info ""
:log info "3. WIFI 5GHz CONFIGURATION:"
:local wifi5gDisabled [/interface/wifi get wlan-5g disabled]

:if ($wifi5gDisabled = false) do={
    :log info "   Status: ENABLED"
} else={
    :log warning "   Status: DISABLED"
}

# Check 4: WiFi Client Count and Signals
:log info ""
:log info "4. WIFI CLIENTS:"
:local wifi2gClients [/interface/wifi/registration-table print count-only where interface=wlan-2g]
:local wifi5gClients [/interface/wifi/registration-table print count-only where interface=wlan-5g]

:log info "   2.4GHz clients: $wifi2gClients"
:log info "   5GHz clients: $wifi5gClients"
:log info "   Total clients: ($wifi2gClients + $wifi5gClients)"

# Check for weak signals
:local weakClients 0
:foreach client in=[/interface/wifi/registration-table find where interface=wlan-2g] do={
    :local signal [/interface/wifi/registration-table get $client signal]
    :if ([:tonum $signal] < -80) do={
        :set weakClients ($weakClients + 1)
    }
}

:foreach client in=[/interface/wifi/registration-table find where interface=wlan-5g] do={
    :local signal [/interface/wifi/registration-table get $client signal]
    :if ([:tonum $signal] < -75) do={
        :set weakClients ($weakClients + 1)
    }
}

:log info "   Weak signal clients: $weakClients"

:if ($weakClients = 0) do={
    :log info "   Status: All clients have GOOD signals"
} else={
    :if ($weakClients < 3) do={
        :log warning "   Status: Few weak clients (acceptable)"
    } else={
        :log warning "   Status: Many weak clients - check AP placement"
    }
}

# Check 5: Band Steering
:log info ""
:log info "5. BAND STEERING:"
:local steering2g [/interface/wifi get wlan-2g configuration.steering]
:local steering5g [/interface/wifi get wlan-5g configuration.steering]

:if ($steering2g = true && $steering5g = true) do={
    :log info "   Status: Band steering ENABLED"
} else={
    :log warning "   Status: Band steering NOT fully enabled"
}

# Check 6: Security Settings
:log info ""
:log info "6. SECURITY:"
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

# Check 7: Watchdog
:log info ""
:log info "7. SYSTEM STABILITY:"
:local watchdog [/system watchdog get watchdog-timer]
:log info "   Watchdog: $watchdog"

:if ($watchdog = true) do={
    :log info "   Status: Watchdog ENABLED (good for reliability)"
} else={
    :log warning "   Status: Watchdog DISABLED"
}

# Check 8: Monitoring Script
:log info ""
:log info "8. MONITORING:"
:local monitorScript [/system scheduler print count-only where name="wifi-monitor-schedule"]
:if ($monitorScript > 0) do={
    :log info "   Status: WiFi monitoring script INSTALLED"
    :local nextRun [/system scheduler get wifi-monitor-schedule next-run]
    :log info "   Next run: $nextRun"
} else={
    :log warning "   Status: Monitoring script NOT installed"
}

# Check 9: Authentication Types
:log info ""
:log info "9. WIFI SECURITY:"
:local auth2g [/interface/wifi get wlan-2g security.authentication-types]
:local auth5g [/interface/wifi get wlan-5g security.authentication-types]

:log info "   2.4GHz auth: $auth2g"
:log info "   5GHz auth: $auth5g"

:if ($auth2g ~ "wpa3" && $auth5g ~ "wpa3") do={
    :log info "   Status: WPA3 ENABLED (excellent security)"
} else={
    :log warning "   Status: WPA3 NOT enabled on all radios"
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
:if ($cpuLoad < 40) do={ :set score ($score + 1) }
:if ($wifi2gChannel = "20mhz") do={ :set score ($score + 1) }
:if ($wifi2gDisabled = false && $wifi5gDisabled = false) do={ :set score ($score + 1) }
:if ($weakClients < 5) do={ :set score ($score + 1) }
:if ($steering2g = true && $steering5g = true) do={ :set score ($score + 1) }
:if ($sshPort = 2222) do={ :set score ($score + 1) }
:if ($telnetDisabled = true && $ftpDisabled = true) do={ :set score ($score + 1) }
:if ($watchdog = true) do={ :set score ($score + 1) }
:if ($monitorScript > 0) do={ :set score ($score + 1) }
:if ($errorCount = 0) do={ :set score ($score + 1) }

:local scorePercent (($score * 100) / 10)
:log info "Optimization Score: $score/10 ($scorePercent%)"

:if ($score >= 8) do={
    :log info "Status: EXCELLENT - Access Point is well optimized"
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

:if ($weakClients > 5) do={
    :log info "- Many weak clients: Consider AP repositioning"
    :log info "- Or add additional access points for coverage"
}

:if ($wifi2gClients > ($wifi5gClients * 3)) do={
    :log info "- Too many 2.4GHz clients vs 5GHz"
    :log info "- Encourage dual-band devices to use 5GHz"
}

:if ($cpuLoad > 40) do={
    :log info "- High CPU: Check /system resource cpu print"
}

:if ($errorCount > 0) do={
    :log info "- Review errors: /log print where topics~\"error\""
}

:log info ""
:log info "To monitor WiFi performance continuously:"
:log info "  /interface/wifi/registration-table print"
:log info "  /interface/wifi monitor wlan-2g,wlan-5g"
:log info "  /log print where topics~\"wireless\""
:log info ""
:log info "=========================================="
:log info "VERIFICATION COMPLETE"
:log info "=========================================="
