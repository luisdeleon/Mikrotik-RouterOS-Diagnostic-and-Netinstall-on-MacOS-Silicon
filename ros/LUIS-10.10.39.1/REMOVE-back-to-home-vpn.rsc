################################################################################
# Remove back-to-home-vpn Configuration
# Router: LUIS - 10.10.39.1
################################################################################
# This script removes all configuration related to the "back-to-home-vpn"
# interface including:
#   - VPN interface
#   - IP addresses
#   - Firewall rules
#   - NAT rules
#   - Routes
#   - Any related configuration
#
# USAGE:
#   1. Review what will be removed (see below)
#   2. Backup first: /export file=backup-before-vpn-removal
#   3. Import this script: /import REMOVE-back-to-home-vpn.rsc
################################################################################

:log info "=========================================="
:log info "REMOVING back-to-home-vpn CONFIGURATION"
:log info "=========================================="

################################################################################
# STEP 1: Remove Firewall Filter Rules
################################################################################
:log info "Removing firewall filter rules..."

# Remove all filter rules with "back-to-home-vpn" in comment
:foreach rule in=[/ip firewall filter find where comment~"back-to-home-vpn"] do={
    :local ruleComment [/ip firewall filter get $rule comment]
    :log info "  Removing filter rule: $ruleComment"
    /ip firewall filter remove $rule
}

# Remove dynamic filter rules related to the interface
:foreach rule in=[/ip firewall filter find where in-interface="back-to-home-vpn"] do={
    :log info "  Removing filter rule (in-interface)"
    /ip firewall filter remove $rule
}

:foreach rule in=[/ip firewall filter find where out-interface="back-to-home-vpn"] do={
    :log info "  Removing filter rule (out-interface)"
    /ip firewall filter remove $rule
}

:log info "Firewall filter rules removed"


################################################################################
# STEP 2: Remove NAT Rules
################################################################################
:log info "Removing NAT rules..."

# Remove all NAT rules with "back-to-home-vpn" in comment
:foreach rule in=[/ip firewall nat find where comment~"back-to-home-vpn"] do={
    :local ruleComment [/ip firewall nat get $rule comment]
    :log info "  Removing NAT rule: $ruleComment"
    /ip firewall nat remove $rule
}

# Remove NAT rules using the interface
:foreach rule in=[/ip firewall nat find where out-interface="back-to-home-vpn"] do={
    :log info "  Removing NAT rule (out-interface)"
    /ip firewall nat remove $rule
}

:foreach rule in=[/ip firewall nat find where in-interface="back-to-home-vpn"] do={
    :log info "  Removing NAT rule (in-interface)"
    /ip firewall nat remove $rule
}

:log info "NAT rules removed"


################################################################################
# STEP 3: Remove IP Routes
################################################################################
:log info "Removing routes..."

# Remove routes using the interface
:foreach route in=[/ip route find where gateway="back-to-home-vpn"] do={
    :local dst [/ip route get $route dst-address]
    :log info "  Removing route: $dst via back-to-home-vpn"
    /ip route remove $route
}

:log info "Routes removed"


################################################################################
# STEP 4: Remove IP Addresses
################################################################################
:log info "Removing IP addresses..."

# Remove IP addresses assigned to the interface
:foreach addr in=[/ip address find where interface="back-to-home-vpn"] do={
    :local address [/ip address get $addr address]
    :log info "  Removing IP address: $address"
    /ip address remove $addr
}

:log info "IP addresses removed"


################################################################################
# STEP 5: Remove Mangle Rules (if any)
################################################################################
:log info "Checking for mangle rules..."

:foreach rule in=[/ip firewall mangle find where comment~"back-to-home-vpn"] do={
    :local ruleComment [/ip firewall mangle get $rule comment]
    :log info "  Removing mangle rule: $ruleComment"
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

:log info "Mangle rules checked"


################################################################################
# STEP 6: Remove the VPN Interface
################################################################################
:log info "Removing VPN interface..."

# Determine the interface type and remove accordingly
# It could be PPTP, L2TP, SSTP, OpenVPN, WireGuard, or other

# Check if it's a PPTP client
:if ([:len [/interface pptp-client find where name="back-to-home-vpn"]] > 0) do={
    :log info "  Found PPTP client interface"
    /interface pptp-client remove [find where name="back-to-home-vpn"]
    :log info "  PPTP client removed"
}

# Check if it's a L2TP client
:if ([:len [/interface l2tp-client find where name="back-to-home-vpn"]] > 0) do={
    :log info "  Found L2TP client interface"
    /interface l2tp-client remove [find where name="back-to-home-vpn"]
    :log info "  L2TP client removed"
}

# Check if it's an SSTP client
:if ([:len [/interface sstp-client find where name="back-to-home-vpn"]] > 0) do={
    :log info "  Found SSTP client interface"
    /interface sstp-client remove [find where name="back-to-home-vpn"]
    :log info "  SSTP client removed"
}

# Check if it's an OpenVPN client
:if ([:len [/interface ovpn-client find where name="back-to-home-vpn"]] > 0) do={
    :log info "  Found OpenVPN client interface"
    /interface ovpn-client remove [find where name="back-to-home-vpn"]
    :log info "  OpenVPN client removed"
}

# Check if it's a WireGuard interface
:if ([:len [/interface wireguard find where name="back-to-home-vpn"]] > 0) do={
    :log info "  Found WireGuard interface"
    /interface wireguard remove [find where name="back-to-home-vpn"]
    :log info "  WireGuard interface removed"
}

# Check if it's an IPsec policy
:foreach policy in=[/ip ipsec policy find where comment~"back-to-home-vpn"] do={
    :log info "  Removing IPsec policy"
    /ip ipsec policy remove $policy
}

:foreach peer in=[/ip ipsec peer find where comment~"back-to-home-vpn"] do={
    :log info "  Removing IPsec peer"
    /ip ipsec peer remove $peer
}

:log info "VPN interface removal checked"


################################################################################
# STEP 7: Remove from Bridge (if applicable)
################################################################################
:log info "Checking bridge ports..."

:foreach port in=[/interface bridge port find where interface="back-to-home-vpn"] do={
    :log info "  Removing from bridge"
    /interface bridge port remove $port
}

:log info "Bridge ports checked"


################################################################################
# STEP 8: Remove PPP Secrets (if PPTP/L2TP)
################################################################################
:log info "Checking PPP secrets..."

:foreach secret in=[/ppp secret find where comment~"back-to-home-vpn"] do={
    :local secretName [/ppp secret get $secret name]
    :log info "  Removing PPP secret: $secretName"
    /ppp secret remove $secret
}

:log info "PPP secrets checked"


################################################################################
# STEP 9: Verification
################################################################################
:log info ""
:log info "=========================================="
:log info "VERIFICATION"
:log info "=========================================="

# Check if interface still exists
:local ifaceExists [:len [/interface find where name="back-to-home-vpn"]]
:if ($ifaceExists > 0) do={
    :log warning "  WARNING: Interface still exists!"
    :log warning "  You may need to remove it manually:"
    :log warning "  /interface print detail where name=\"back-to-home-vpn\""
} else={
    :log info "  Interface removed: YES"
}

# Check for remaining firewall rules
:local filterRules [:len [/ip firewall filter find where comment~"back-to-home-vpn"]]
:local natRules [:len [/ip firewall nat find where comment~"back-to-home-vpn"]]
:log info "  Remaining filter rules: $filterRules"
:log info "  Remaining NAT rules: $natRules"

# Check for remaining IP addresses
:local ipAddresses [:len [/ip address find where address~"192.168.216"]]
:log info "  Remaining IP addresses (192.168.216.x): $ipAddresses"


################################################################################
# COMPLETION
################################################################################
:log info ""
:log info "=========================================="
:log info "REMOVAL COMPLETE"
:log info "=========================================="
:log info "All back-to-home-vpn configuration removed"
:log info ""
:log info "Manual verification commands:"
:log info "  /interface print where name~\"back-to-home\""
:log info "  /ip address print where address~\"192.168.216\""
:log info "  /ip firewall filter print where comment~\"back-to-home\""
:log info "  /ip firewall nat print where comment~\"back-to-home\""
:log info "=========================================="

# End of script
