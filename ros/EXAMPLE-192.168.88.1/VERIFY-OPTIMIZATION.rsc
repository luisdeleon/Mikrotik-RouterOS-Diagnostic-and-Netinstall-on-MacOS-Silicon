################################################################################
# OPTIMIZATION VERIFICATION SCRIPT
# Example Router - 192.168.88.1
################################################################################

:log info "Starting optimization verification..."

:local score 0
:local maxScore 100
:local checks 10

################################################################################
# Check 1: SSH Port Changed
################################################################################

:local sshPort [/ip service get ssh port]
:if ($sshPort = 2222) do={
    :set score ($score + 10)
    :log info "✓ SSH port changed to 2222 (10 points)"
} else={
    :log warning "✗ SSH still on default port $sshPort"
}

################################################################################
# Check 2: Connection Tracking Optimized
################################################################################

:local tcpTimeout [/ip firewall connection tracking get tcp-established-timeout]
:if ($tcpTimeout = "1h") do={
    :set score ($score + 10)
    :log info "✓ Connection tracking optimized (10 points)"
} else={
    :log warning "✗ Connection tracking not optimized"
}

################################################################################
# Check 3: Connection Limits Configured
################################################################################

:local connLimitCount [:len [/ip firewall filter find where comment~"connection"]]
:if ($connLimitCount > 0) do={
    :set score ($score + 10)
    :log info "✓ Connection limits configured (10 points)"
} else={
    :log warning "✗ Connection limits not found"
}

################################################################################
# Check 4: Unnecessary Services Disabled
################################################################################

:local telnetDisabled [/ip service get telnet disabled]
:local ftpDisabled [/ip service get ftp disabled]
:if ($telnetDisabled and $ftpDisabled) do={
    :set score ($score + 10)
    :log info "✓ Unnecessary services disabled (10 points)"
} else={
    :log warning "✗ Some unnecessary services still enabled"
}

################################################################################
# Check 5: QoS Configured
################################################################################

:local queueCount [:len [/queue tree find]]
:if ($queueCount > 0) do={
    :set score ($score + 10)
    :log info "✓ QoS queues configured (10 points)"
} else={
    :log warning "✗ No QoS queues found"
}

################################################################################
# Check 6: FastTrack Enabled
################################################################################

:local fasttrackCount [:len [/ip firewall filter find where action="fasttrack-connection"]]
:if ($fasttrackCount > 0) do={
    :set score ($score + 10)
    :log info "✓ FastTrack configured (10 points)"
} else={
    :log warning "✗ FastTrack not found"
}

################################################################################
# Check 7: WiFi Optimized (if applicable)
################################################################################

:do {
    :local wifiCount [:len [/interface/wifi find]]
    :if ($wifiCount > 0) do={
        :local channelWidth [/interface/wifi get wlan-2g channel.width]
        :if ($channelWidth = "20mhz") do={
            :set score ($score + 10)
            :log info "✓ WiFi optimized (10 points)"
        } else={
            :log warning "✗ WiFi not optimized"
        }
    } else={
        :set score ($score + 10)
        :log info "✓ No WiFi interfaces (10 points)"
    }
} on-error={
    :set score ($score + 10)
    :log info "✓ No WiFi interfaces (10 points)"
}

################################################################################
# Check 8: DNS Configured
################################################################################

:local dnsServers [/ip dns get servers]
:if ([:len $dnsServers] > 0) do={
    :set score ($score + 10)
    :log info "✓ DNS servers configured (10 points)"
} else={
    :log warning "✗ No DNS servers configured"
}

################################################################################
# Check 9: Logging Optimized
################################################################################

:local memoryLines [/system logging action get memory memory-lines]
:if ($memoryLines <= 100) do={
    :set score ($score + 10)
    :log info "✓ Logging optimized (10 points)"
} else={
    :log warning "✗ Logging not optimized"
}

################################################################################
# Check 10: System Identity Set
################################################################################

:local sysIdentity [/system identity get name]
:if ($sysIdentity != "MikroTik") do={
    :set score ($score + 10)
    :log info "✓ System identity customized (10 points)"
} else={
    :log warning "✗ System identity still default"
}

################################################################################
# FINAL SCORE
################################################################################

:local percentage (($score * 100) / $maxScore)

:log info "================================"
:log info "OPTIMIZATION SCORE: $score / $maxScore ($percentage%)"
:log info "================================"

:put ""
:put "================================"
:put "OPTIMIZATION VERIFICATION COMPLETE"
:put "================================"
:put "Score: $score / $maxScore ($percentage%)"
:put ""

:if ($percentage >= 90) do={
    :put "Rating: EXCELLENT ⭐⭐⭐"
    :put "Your router is highly optimized!"
}
:if ($percentage >= 70 and $percentage < 90) do={
    :put "Rating: GOOD ⭐⭐"
    :put "Your router is well optimized."
}
:if ($percentage >= 50 and $percentage < 70) do={
    :put "Rating: FAIR ⭐"
    :put "Some optimizations are missing."
}
:if ($percentage < 50) do={
    :put "Rating: NEEDS WORK"
    :put "Many optimizations are not applied."
}

:put ""
:put "Check the logs for details:"
:put "/log print where topics~\"system,info\""
:put "================================"
