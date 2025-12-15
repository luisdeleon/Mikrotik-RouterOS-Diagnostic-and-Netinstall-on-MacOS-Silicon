################################################################################
# COMPLETE REMOVAL: back-to-home-vpn (All References)
# Router: LUIS - 10.10.39.1
################################################################################
# This script removes ALL references to back-to-home-vpn including:
# - Interface lists
# - Firewall rules (filter, NAT, mangle, raw)
# - Routes
# - IP addresses
# - Bridge ports
# - Queue rules
# - Scheduler tasks
# - Scripts
# - And finally the interface itself
################################################################################

:log info "=========================================="
:log info "COMPLETE REMOVAL: back-to-home-vpn"
:log info "=========================================="

################################################################################
# STEP 1: Remove from Interface Lists
################################################################################
:log info "Step 1: Checking interface lists..."

# Remove from any interface list membership
:foreach member in=[/interface list member find where interface="back-to-home-vpn"] do={
    :local listName [/interface list member get $member list]
    :log info "  Removing from interface list: $listName"
    /interface list member remove $member
}

:log info "Interface lists cleaned"


################################################################################
# STEP 2: Remove Firewall Filter Rules
################################################################################
:log info "Step 2: Removing firewall filter rules..."

# By comment
:foreach rule in=[/ip firewall filter find where comment~"back-to-home-vpn"] do={
    :local comment [/ip firewall filter get $rule comment]
    :log info "  Removing filter rule: $comment"
    /ip firewall filter remove $rule
}

# By interface (in-interface)
:foreach rule in=[/ip firewall filter find where in-interface="back-to-home-vpn"] do={
    :local chain [/ip firewall filter get $rule chain]
    :log info "  Removing filter rule (in-interface) from chain: $chain"
    /ip firewall filter remove $rule
}

# By interface (out-interface)
:foreach rule in=[/ip firewall filter find where out-interface="back-to-home-vpn"] do={
    :local chain [/ip firewall filter get $rule chain]
    :log info "  Removing filter rule (out-interface) from chain: $chain"
    /ip firewall filter remove $rule
}

:log info "Firewall filter rules removed"


################################################################################
# STEP 3: Remove NAT Rules
################################################################################
:log info "Step 3: Removing NAT rules..."

# By comment
:foreach rule in=[/ip firewall nat find where comment~"back-to-home-vpn"] do={
    :local comment [/ip firewall nat get $rule comment]
    :log info "  Removing NAT rule: $comment"
    /ip firewall nat remove $rule
}

# By interface (in-interface)
:foreach rule in=[/ip firewall nat find where in-interface="back-to-home-vpn"] do={
    :local chain [/ip firewall nat get $rule chain]
    :log info "  Removing NAT rule (in-interface) from chain: $chain"
    /ip firewall nat remove $rule
}

# By interface (out-interface)
:foreach rule in=[/ip firewall nat find where out-interface="back-to-home-vpn"] do={
    :local chain [/ip firewall nat get $rule chain]
    :log info "  Removing NAT rule (out-interface) from chain: $chain"
    /ip firewall nat remove $rule
}

:log info "NAT rules removed"


################################################################################
# STEP 4: Remove Mangle Rules
################################################################################
:log info "Step 4: Removing mangle rules..."

:foreach rule in=[/ip firewall mangle find where comment~"back-to-home-vpn"] do={
    :local comment [/ip firewall mangle get $rule comment]
    :log info "  Removing mangle rule: $comment"
    /ip firewall mangle remove $rule
}

:foreach rule in=[/ip firewall mangle find where in-interface="back-to-home-vpn"] do={
    :log info "  Removing mangle rule (in-interface)"
    /ip firewall mangle remove $rule
}

:foreach rule in=[/ip firewall mangle find where out-interface="back-to-home-vpn"] do={
    :log info "  Removing mangle rule (out-interface)"
    /ip firewall mangle remove $rule
}

:log info "Mangle rules removed"


################################################################################
# STEP 5: Remove Raw Firewall Rules (if any)
################################################################################
:log info "Step 5: Checking raw firewall rules..."

:foreach rule in=[/ip firewall raw find where comment~"back-to-home-vpn"] do={
    :local comment [/ip firewall raw get $rule comment]
    :log info "  Removing raw rule: $comment"
    /ip firewall raw remove $rule
}

:log info "Raw firewall rules checked"


################################################################################
# STEP 6: Remove Routes
################################################################################
:log info "Step 6: Removing routes..."

:foreach route in=[/ip route find where gateway="back-to-home-vpn"] do={
    :local dst [/ip route get $route dst-address]
    :log info "  Removing route: $dst via back-to-home-vpn"
    /ip route remove $route
}

:foreach route in=[/ip route find where comment~"back-to-home-vpn"] do={
    :local dst [/ip route get $route dst-address]
    :log info "  Removing route (by comment): $dst"
    /ip route remove $route
}

:log info "Routes removed"


################################################################################
# STEP 7: Remove IP Addresses
################################################################################
:log info "Step 7: Removing IP addresses..."

:foreach addr in=[/ip address find where interface="back-to-home-vpn"] do={
    :local address [/ip address get $addr address]
    :log info "  Removing IP address: $address"
    /ip address remove $addr
}

# Also check for the specific 192.168.216.x network
:foreach addr in=[/ip address find where address~"192.168.216"] do={
    :local address [/ip address get $addr address]
    :local iface [/ip address get $addr interface]
    :if ($iface = "back-to-home-vpn") do={
        :log info "  Removing IP address: $address"
        /ip address remove $addr
    }
}

:log info "IP addresses removed"


################################################################################
# STEP 8: Remove from Bridge Ports
################################################################################
:log info "Step 8: Checking bridge ports..."

:foreach port in=[/interface bridge port find where interface="back-to-home-vpn"] do={
    :local bridge [/interface bridge port get $port bridge]
    :log info "  Removing from bridge: $bridge"
    /interface bridge port remove $port
}

:log info "Bridge ports checked"


################################################################################
# STEP 9: Remove Queue Rules
################################################################################
:log info "Step 9: Checking queue rules..."

# Queue Tree
:foreach queue in=[/queue tree find where parent="back-to-home-vpn"] do={
    :local name [/queue tree get $queue name]
    :log info "  Removing queue tree: $name"
    /queue tree remove $queue
}

:foreach queue in=[/queue tree find where comment~"back-to-home-vpn"] do={
    :local name [/queue tree get $queue name]
    :log info "  Removing queue tree (by comment): $name"
    /queue tree remove $queue
}

# Simple Queue
:foreach queue in=[/queue simple find where target~"192.168.216"] do={
    :local name [/queue simple get $queue name]
    :log info "  Removing simple queue: $name"
    /queue simple remove $queue
}

:foreach queue in=[/queue simple find where comment~"back-to-home-vpn"] do={
    :local name [/queue simple get $queue name]
    :log info "  Removing simple queue (by comment): $name"
    /queue simple remove $queue
}

:log info "Queue rules checked"


################################################################################
# STEP 10: Remove from Scripts
################################################################################
:log info "Step 10: Checking scripts for references..."

:foreach script in=[/system script find where source~"back-to-home-vpn"] do={
    :local scriptName [/system script get $script name]
    :log warning "  Found script with reference: $scriptName"
    :log warning "  Please manually review and update this script!"
}

:log info "Scripts checked (manual review may be needed)"


################################################################################
# STEP 11: Remove Scheduler Tasks
################################################################################
:log info "Step 11: Checking scheduler tasks..."

:foreach task in=[/system scheduler find where comment~"back-to-home-vpn"] do={
    :local taskName [/system scheduler get $task name]
    :log info "  Removing scheduler task: $taskName"
    /system scheduler remove $task
}

:log info "Scheduler tasks checked"


################################################################################
# STEP 12: Remove PPP Secrets (if applicable)
################################################################################
:log info "Step 12: Checking PPP secrets..."

:foreach secret in=[/ppp secret find where comment~"back-to-home-vpn"] do={
    :local secretName [/ppp secret get $secret name]
    :log info "  Removing PPP secret: $secretName"
    /ppp secret remove $secret
}

:log info "PPP secrets checked"


################################################################################
# STEP 13: Remove IPsec (if applicable)
################################################################################
:log info "Step 13: Checking IPsec configuration..."

:foreach policy in=[/ip ipsec policy find where comment~"back-to-home-vpn"] do={
    :log info "  Removing IPsec policy"
    /ip ipsec policy remove $policy
}

:foreach peer in=[/ip ipsec peer find where comment~"back-to-home-vpn"] do={
    :log info "  Removing IPsec peer"
    /ip ipsec peer remove $peer
}

:foreach proposal in=[/ip ipsec proposal find where comment~"back-to-home-vpn"] do={
    :log info "  Removing IPsec proposal"
    /ip ipsec proposal remove $proposal
}

:log info "IPsec configuration checked"


################################################################################
# STEP 14: Remove the VPN Interface Itself
################################################################################
:log info "Step 14: Removing VPN interface..."

# Check and remove each VPN type
:if ([:len [/interface pptp-client find where name="back-to-home-vpn"]] > 0) do={
    :log info "  Removing PPTP client interface"
    /interface pptp-client remove [find where name="back-to-home-vpn"]
}

:if ([:len [/interface l2tp-client find where name="back-to-home-vpn"]] > 0) do={
    :log info "  Removing L2TP client interface"
    /interface l2tp-client remove [find where name="back-to-home-vpn"]
}

:if ([:len [/interface sstp-client find where name="back-to-home-vpn"]] > 0) do={
    :log info "  Removing SSTP client interface"
    /interface sstp-client remove [find where name="back-to-home-vpn"]
}

:if ([:len [/interface ovpn-client find where name="back-to-home-vpn"]] > 0) do={
    :log info "  Removing OpenVPN client interface"
    /interface ovpn-client remove [find where name="back-to-home-vpn"]
}

:if ([:len [/interface wireguard find where name="back-to-home-vpn"]] > 0) do={
    :log info "  Removing WireGuard interface"
    /interface wireguard remove [find where name="back-to-home-vpn"]
}

# Check for generic interface (shouldn't exist, but just in case)
:if ([:len [/interface find where name="back-to-home-vpn"]] > 0) do={
    :log warning "  Found generic interface - attempting removal"
    /interface remove [find where name="back-to-home-vpn"]
}

:log info "VPN interface removal checked"


################################################################################
# STEP 15: Final Verification
################################################################################
:log info ""
:log info "=========================================="
:log info "FINAL VERIFICATION"
:log info "=========================================="

# Count remaining references
:local interfaceExists [:len [/interface find where name="back-to-home-vpn"]]
:local interfaceListRefs [:len [/interface list member find where interface="back-to-home-vpn"]]
:local filterRefs [:len [/ip firewall filter find where comment~"back-to-home-vpn"]]
:local natRefs [:len [/ip firewall nat find where comment~"back-to-home-vpn"]]
:local ipAddresses [:len [/ip address find where interface="back-to-home-vpn"]]
:local routes [:len [/ip route find where gateway="back-to-home-vpn"]]

:log info "Verification Results:"
:log info "  Interface exists: $interfaceExists"
:log info "  Interface list references: $interfaceListRefs"
:log info "  Firewall filter references: $filterRefs"
:log info "  NAT references: $natRefs"
:log info "  IP addresses: $ipAddresses"
:log info "  Routes: $routes"

:if ($interfaceExists = 0 && $interfaceListRefs = 0 && $filterRefs = 0 && $natRefs = 0 && $ipAddresses = 0 && $routes = 0) do={
    :log info ""
    :log info "✓ SUCCESS: All back-to-home-vpn references removed!"
} else={
    :log warning ""
    :log warning "⚠ WARNING: Some references may still exist"
    :log warning "Please check manually:"
    :log warning "  /interface print where name~\"back-to-home\""
    :log warning "  /interface list member print where interface~\"back-to-home\""
    :log warning "  /ip firewall filter print where comment~\"back-to-home\""
    :log warning "  /ip firewall nat print where comment~\"back-to-home\""
}

:log info "=========================================="
:log info "REMOVAL COMPLETE"
:log info "=========================================="

# End of script
