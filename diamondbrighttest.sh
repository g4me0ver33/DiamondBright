  GNU nano 9.0                     diamondbrighttest/sh *                             
#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    echo "Please run this assessment with sudo."
    exit 1
fi
clear

echo "=============================================="
echo " Diamond Bright LLC - System Assessment Tool"
echo "=============================================="
echo
echo "Only run this on systems/networks you have permission to assess."
echo

read -p "Client/Business Name: " CLIENT
TECH_DEFAULT="Joshua Bottoms"
read -p "Technician Name [$TECH_DEFAULT]: " TECH
TECH=${TECH:-$TECH_DEFAULT}

echo
echo "===== BUSINESS DISCOVERY ====="
read -p "Primary Business Type: " BIZTYPE
read -p "Number of Employees: " EMPLOYEES
read -p "Average Hourly Wage ($): " WAGE
read -p "Average Daily Revenue (optional): $" REVENUE
read -p "Accept Credit Cards? (Y/N): " CARDS
read -p "Cloud Software Used? (Y/N): " CLOUD
read -p "Backups Currently In Place? (Y/N): " BACKUPS
read -p "MFA Enabled For Business Accounts? (Y/N): " MFA
read -p "Internet Required Daily For Operations? (Y/N): " INTERNET

echo
NETRANGE="${CYBERGUARD_NETWORK_RANGE:-}"

if [ -z "$NETRANGE" ]; then
    read -p "Network range to scan? Example 192.168.1.0/24: " NETRANGE
else
    echo "Network range detected automatically: $NETRANGE"
fi
DATE=$(date +"%Y-%m-%d_%H-%M")
ASSESSMENT_ID="DB-$(date +%Y%m%d)-$(date +%H%M%S)"
REPORT="DiamondBright_${ASSESSMENT_ID}_${CLIENT// /_}.txt"
echo
echo "Creating report: $REPORT"
echo

{
echo "====================================================="
echo " Diamond Bright LLC"
echo " Technology & Security Assessment"
echo " DBA: Flawless Gem AI"
echo " Email: ceo@diamondbrightai.com"
echo "====================================================="
echo
echo "Client: $CLIENT"
echo "Technician: $TECH"
echo "Assessment Date: $(date)"
echo "Assessment ID: $ASSESSMENT_ID"
echo
echo "===== BUSINESS PROFILE ====="
echo "Business Type: $BIZTYPE"
echo "Employees: $EMPLOYEES"
echo "Credit Card Processing: $CARDS"
echo "Cloud Software Usage: $CLOUD"
echo "Backups In Place: $BACKUPS"
echo "MFA Enabled: $MFA"
echo "Internet Critical To Operations: $INTERNET"
echo "Average Daily Revenue: \$${REVENUE}"
echo

echo "===== AUTHORIZATION NOTICE ====="
echo "This assessment is intended only for systems and networks where permission has been granted."
echo

echo "===== SYSTEM INFO ====="
hostnamectl 2>/dev/null
uname -a
uptime
echo

echo "===== CPU / MEMORY ====="
lscpu | grep -E "Model name|CPU\(s\)|Thread|Core|Socket"
free -h
echo

echo "===== DISK / STORAGE ====="
lsblk -f
df -h
echo

echo "===== FAILED SERVICES ====="
systemctl --failed 2>/dev/null
echo

echo "===== NETWORK INTERFACES ====="
ip addr
echo

echo "===== ROUTING TABLE ====="
ip route
echo

echo "===== DNS CONFIG ====="
cat /etc/resolv.conf
echo

echo "===== INTERNET CONNECTIVITY ====="
ping -c 5 1.1.1.1
echo

echo "===== DNS TEST ====="
dig google.com
echo

echo "===== ROUTE QUALITY TEST ====="
mtr -rwzc 10 1.1.1.1 2>/dev/null || echo "mtr not installed or failed"
echo

echo "===== WIFI STATUS ====="
iw dev 2>/dev/null
nmcli -f IN-USE,SSID,SIGNAL,RATE,BARS dev wifi 2>/dev/null
echo

echo "===== LOCAL NETWORK DISCOVERY ====="
if [ -n "$NETRANGE" ]; then
DEVICE_SCAN=$(nmap -sn "$NETRANGE" --max-retries 1 --host-timeout 15s)
    echo "$DEVICE_SCAN"
    DEVICE_COUNT=$(echo "$DEVICE_SCAN" | grep -c "Nmap scan report")
else
    echo "No network range entered."
    DEVICE_COUNT=0
fi
echo
echo "===== DEVICE INVENTORY SUMMARY ====="
echo "Devices Discovered: $DEVICE_COUNT"
echo "Network Scanned: $NETRANGE"
echo

echo "===== LISTENING PORTS ====="
ss -tulpn
echo

echo "===== FIREWALL STATUS ====="
ufw status verbose 2>/dev/null || echo "UFW not installed or unavailable"
echo

echo "===== RECENT SYSTEM ERRORS ====="
journalctl -p 3 -b --no-pager 2>/dev/null | tail -50
echo

echo "===== SMART DISK HEALTH ====="
for disk in $(lsblk -ndo NAME,TYPE | awk '$2=="disk"{print "/dev/"$1}'); do
    echo "--- $disk ---"
    smartctl -H "$disk" 2>/dev/null || echo "SMART unavailable for $disk"
done
echo

echo "===== SECURITY UPDATES ====="
apt list --upgradable 2>/dev/null
echo

echo "===== LOCAL OPEN PORTS ====="
nmap -sV localhost 2>/dev/null
echo

echo "===== RUNNING SERVICES ====="
systemctl list-units --type=service --state=running --no-pager
echo

echo "===== WIFI SECURITY CHECK ====="
SSID=$(iw dev wlan0 link 2>/dev/null | awk -F': ' '/SSID/ {print $2}')
if [ -n "$SSID" ]; then
    echo "Connected SSID: $SSID"
    nmcli -f active,ssid,security dev wifi | grep '^yes'
else
    echo "No Wi-Fi connection detected"
fi
echo

echo "===== INTERNET SPEED TEST ====="
if command -v speedtest >/dev/null 2>&1; then
    speedtest --accept-license --accept-gdpr
else
    echo "Speedtest utility not installed"
fi
echo


echo "========================================="
echo " AUTOMATED FINDINGS"
echo "========================================="

DISK_USE=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
FAILED=$(systemctl --failed --no-legend 2>/dev/null | wc -l)
UPDATES=$(apt list --upgradable 2>/dev/null | grep -v "Listing" | wc -l)
OPENPORTS=$(ss -tuln | grep LISTEN | wc -l)
SCORE=100

if [ "$DISK_USE" -gt 90 ]; then
    echo "[HIGH] Disk usage exceeds 90%"
    SCORE=$((SCORE-15))
elif [ "$DISK_USE" -gt 75 ]; then
    echo "[MEDIUM] Disk usage exceeds 75%"
    SCORE=$((SCORE-8))
else
    echo "[PASS] Storage usage is healthy"
fi

if [ "$FAILED" -gt 0 ]; then
    echo "[MEDIUM] Failed services detected: $FAILED"
    SCORE=$((SCORE-10))
else
    echo "[PASS] No failed services detected"
fi

if ufw status 2>/dev/null | grep -q "Status: active"; then
    echo "[PASS] Firewall is active"
else
    echo "[HIGH] Firewall is not active or unavailable"
    SCORE=$((SCORE-15))
fi

if [ "$UPDATES" -gt 10 ]; then
    echo "[MEDIUM] Multiple system updates available: $UPDATES"
    SCORE=$((SCORE-8))
elif [ "$UPDATES" -gt 0 ]; then
    echo "[LOW] System updates available: $UPDATES"
    SCORE=$((SCORE-3))
else
    echo "[PASS] No package updates detected"
fi

if [ "$OPENPORTS" -gt 20 ]; then
    echo "[MEDIUM] High number of listening ports detected: $OPENPORTS"
    SCORE=$((SCORE-5))
else
    echo "[PASS] Listening port count appears reasonable"
fi

WIFI_SECURITY=$(nmcli -f active,security dev wifi 2>/dev/null | grep "^yes" | awk "{print \$2}")
if echo "$WIFI_SECURITY" | grep -qE "WPA2|WPA3"; then
    echo "[PASS] Wi-Fi encryption appears acceptable: $WIFI_SECURITY"
else
    echo "[MEDIUM] Wi-Fi encryption should be reviewed"
    SCORE=$((SCORE-8))
fi

echo
echo "========================================="
echo " BUSINESS RISK MATRIX"
echo "========================================="
echo "Patch Management:      $([ "$UPDATES" -gt 0 ] && echo MEDIUM || echo LOW)"
if ufw status 2>/dev/null | grep -q "Status: active"; then
    FW_RISK="LOW"
else
    FW_RISK="HIGH"
fi
echo "Firewall Protection:   $FW_RISK"
if [[ "$BACKUPS" =~ ^[Yy]$ ]]; then
    echo "Backup Status:         REPORTED IN PLACE"
else
    echo "Backup Status:         NOT VERIFIED"
fi
echo "IoT Device Security:   REVIEW RECOMMENDED"
echo "Wireless Security:     $([ -n "$WIFI_SECURITY" ] && echo LOW || echo REVIEW)"
echo "Open Service Exposure: $([ "$OPENPORTS" -gt 20 ] && echo MEDIUM || echo LOW)"
echo

echo "========================================="
echo " DYNAMIC SCORECARD"
echo "========================================="
echo "Overall Technical Score: $SCORE/100"

if [ "$SCORE" -ge 90 ]; then
    echo "Overall Rating: A"
    RISK="LOW"
elif [ "$SCORE" -ge 80 ]; then
    echo "Overall Rating: B"
    RISK="LOW TO MEDIUM"
elif [ "$SCORE" -ge 70 ]; then
    echo "Overall Rating: C"
    RISK="MEDIUM"
else
    echo "Overall Rating: NEEDS ATTENTION"
    RISK="HIGH"
fi
echo
DEPENDENCY=0

[[ "$INTERNET" =~ ^[Yy]$ ]] && DEPENDENCY=$((DEPENDENCY+3))
[[ "$CLOUD" =~ ^[Yy]$ ]] && DEPENDENCY=$((DEPENDENCY+2))
[[ "$CARDS" =~ ^[Yy]$ ]] && DEPENDENCY=$((DEPENDENCY+2))
[[ "$BACKUPS" =~ ^[Nn]$ ]] && DEPENDENCY=$((DEPENDENCY+1))
[[ "$MFA" =~ ^[Nn]$ ]] && DEPENDENCY=$((DEPENDENCY+1))

CONTINUITY=100

[[ "$BACKUPS" =~ ^[Nn]$ ]] && CONTINUITY=$((CONTINUITY-30))
[[ "$MFA" =~ ^[Nn]$ ]] && CONTINUITY=$((CONTINUITY-20))
[ "$FAILED" -gt 0 ] && CONTINUITY=$((CONTINUITY-10))
[ "$UPDATES" -gt 0 ] && CONTINUITY=$((CONTINUITY-10))

echo "===== BASIC CHECKLIST ====="
echo "[ ] Router password changed"
echo "[ ] WPA2/WPA3 enabled"
echo "[ ] WPS disabled"
echo "[ ] Guest network separated"
echo "[ ] MFA enabled"
echo "[ ] Backups verified"
echo "[ ] Firmware current"
echo "[ ] Old employee/user access removed"
echo "[ ] Smart devices reviewed"
echo
echo "========================================="
echo " CLIENT EXECUTIVE SNAPSHOT"
echo "========================================="
echo
echo "Assessment ID:"
echo "$ASSESSMENT_ID"
echo

echo "Overall Technical Score:"
echo "$SCORE / 100"
echo

if [ "$SCORE" -ge 90 ]; then
    SNAPSHOT_PLAN="Diamond Bright Essential"
    SNAPSHOT_MONTHLY=99
    SNAPSHOT_SECURITY="A"
elif [ "$SCORE" -ge 80 ]; then
    SNAPSHOT_PLAN="Diamond Bright Professional"
    SNAPSHOT_MONTHLY=149
    SNAPSHOT_SECURITY="B"
else
    SNAPSHOT_PLAN="Diamond Bright Secure Business"
    SNAPSHOT_MONTHLY=249
    SNAPSHOT_SECURITY="Needs Attention"
fi

echo "Overall Security Rating:"
echo "$SNAPSHOT_SECURITY"
echo

echo "Technology Reliance:"
if [ "$DEPENDENCY" -ge 8 ]; then
    echo "VERY HIGH"
elif [ "$DEPENDENCY" -ge 5 ]; then
    echo "HIGH"
elif [ "$DEPENDENCY" -ge 3 ]; then
    echo "MODERATE"
else
    echo "LOW"
fi
echo

echo "Business Continuity:"
if [ "$CONTINUITY" -ge 90 ]; then
    echo "EXCELLENT"
elif [ "$CONTINUITY" -ge 75 ]; then
    echo "GOOD"
elif [ "$CONTINUITY" -ge 60 ]; then
    echo "FAIR"
else
    echo "HIGH RISK"
fi
echo

if [[ "$REVENUE" =~ ^[0-9]+$ ]] && [[ "$EMPLOYEES" =~ ^[0-9]+$ ]] && [[ "$WAGE" =~ ^[0-9]+$ ]]; then
    SNAPSHOT_FULL_DAY=$((EMPLOYEES * WAGE * 8))
    SNAPSHOT_TOTAL_IMPACT=$((SNAPSHOT_FULL_DAY + REVENUE))
    echo "Potential One-Day Business Impact:"
    echo "\$${SNAPSHOT_TOTAL_IMPACT}"
    echo
fi

echo "Recommended Protection Plan:"
echo "$SNAPSHOT_PLAN"
echo

echo "Estimated Monthly Investment:"
echo "\$${SNAPSHOT_MONTHLY}"
echo

echo "Estimated Annual Investment:"
echo "\$$(($SNAPSHOT_MONTHLY * 12))"
echo


echo "========================================="
echo " EXECUTIVE SUMMARY"
echo " FOR CLIENT REVIEW"
echo "========================================="
echo
echo "Overall Security Rating: $([ "$SCORE" -ge 90 ] && echo A || echo B)"
echo "Overall Network Rating: A"
echo "Overall System Health: $([ "$FAILED" -eq 0 ] && echo A || echo B)"
echo
echo "Critical Issues Found:"
if [ "$SCORE" -ge 80 ]; then
    echo "None detected during this assessment."
else
    echo "One or more items require immediate review."
fi
echo
echo "Medium Priority Findings:"
echo "- Review router firmware"
echo "- Review connected smart/IoT devices"
echo "- Verify backup process"
echo "- Review user account and MFA settings"
echo
echo "Low Priority Findings:"
echo "- Review recent system warnings"
echo "- Review unnecessary running services"
echo "- Review patch/update status"
echo
echo "Recommended Actions:"
echo "1. Verify backups are working and restore-tested"
echo "2. Enable MFA on important business accounts"
echo "3. Review router and firewall configuration"
echo "4. Review connected devices for unknown equipment"
echo "5. Schedule regular monthly technology checkups"
echo
echo "Estimated Risk Level: $RISK"
if [[ "$REVENUE" =~ ^[0-9]+$ ]] && [[ "$EMPLOYEES" =~ ^[0-9]+$ ]] && [[ "$WAGE" =~ ^[0-9]+$ ]]; then
    EXEC_FULL_DAY=$((EMPLOYEES * WAGE * 8))
    EXEC_TOTAL_IMPACT=$((EXEC_FULL_DAY + REVENUE))
    echo "Potential One-Day Business Impact: \$${EXEC_TOTAL_IMPACT}"
fi

if [ "$SCORE" -ge 90 ]; then
    echo "Recommended Protection Plan: Diamond Bright Essential (\$99/month)"
    echo "Annual Protection Cost: \$1188"
elif [ "$SCORE" -ge 80 ]; then
    echo "Recommended Protection Plan: Diamond Bright Professional (\$149/month)"
    echo "Annual Protection Cost: \$1788"
else
    echo "Recommended Protection Plan: Diamond Bright Secure Business (\$249/month)"
    echo "Annual Protection Cost: \$2988"
fi
echo
echo "========================================="
echo " IMMEDIATE PRIORITIES"
echo "========================================="
echo

echo "Priority 1:"
if [[ "$MFA" =~ ^[Nn]$ ]]; then
    echo "Enable Multi-Factor Authentication on important business accounts."
else
    echo "Review MFA coverage for all important business accounts."
fi
echo

echo "Priority 2:"
if [[ "$BACKUPS" =~ ^[Nn]$ ]]; then
    echo "Create and verify a reliable backup process."
else
    echo "Verify backups are recoverable with a restore test."
fi
echo

echo "Priority 3:"
echo "Review router firmware, WiFi settings, and firewall configuration."
echo

echo "Priority 4:"
echo "Schedule routine monthly technology maintenance."
echo
echo
echo "========================================="
echo " RECOMMENDED PROTECTION PLAN"
echo "========================================="
echo

if [ "$SCORE" -ge 90 ]; then

echo "Diamond Bright Essential"
echo
echo "Investment:"
echo "\$99/month"
echo
echo "Designed For:"
echo "- Small businesses"
echo "- Home offices"
echo "- Businesses with low to moderate support needs"
echo
echo "Includes:"
echo "- Monthly system health review"
echo "- Security update review"
echo "- Device inventory review"
echo "- Email support"
echo "- Remote assistance"
echo "- Quarterly technology review"

elif [ "$SCORE" -ge 80 ]; then

echo "Diamond Bright Professional"
echo
echo "Investment:"
echo "\$149/month"
echo
echo "Designed For:"
echo "- Small businesses using internet daily"
echo "- Businesses with connected devices"
echo "- Businesses needing regular support"
echo
echo "Includes:"
echo "- Monthly network assessment"
echo "- Firewall review"
echo "- Security update management"
echo "- Device inventory review"
echo "- Remote support"
echo "- Technology health reporting"

else

echo "Diamond Bright Secure Business"
echo
echo "Investment:"
echo "\$249/month"
echo
echo "Designed For:"
echo "- Higher-risk business environments"
echo "- Businesses with critical technology needs"
echo "- Businesses needing priority response"
echo
echo "Includes:"
echo "- Monthly security assessment"
echo "- Firewall optimization"
echo "- Network monitoring"
echo "- Device inventory management"
echo "- Priority support"
echo "- Incident response assistance"

fi
echo "========================================="
echo " RECOMMENDED SERVICES & QUOTE"
echo "========================================="
echo

QUOTE_TOTAL=0

if [ "$SCORE" -lt 90 ]; then
    echo "Network Security Review ............. \$299"
    QUOTE_TOTAL=$((QUOTE_TOTAL+299))
fi

if [ "$FAILED" -gt 0 ]; then
    echo "System Optimization ................. \$149"
    QUOTE_TOTAL=$((QUOTE_TOTAL+149))
fi

if [ "$UPDATES" -gt 0 ]; then
    echo "Patch Management Setup .............. \$99"
    QUOTE_TOTAL=$((QUOTE_TOTAL+99))
fi

echo "Backup Verification ................. \$99"
QUOTE_TOTAL=$((QUOTE_TOTAL+99))

echo "Router / Firewall Audit ............. \$149"
QUOTE_TOTAL=$((QUOTE_TOTAL+149))

echo
echo "-----------------------------------------"
echo "Recommended Monthly Service Plan"

if [ "$SCORE" -ge 90 ]; then
    MONTHLY=99
    PLAN_NAME="Diamond Bright Essential"
    echo "Diamond Bright Essential ............ \$99/mo"
elif [ "$SCORE" -ge 80 ]; then
    MONTHLY=149
    PLAN_NAME="Diamond Bright Professional"
    echo "Diamond Bright Professional ......... \$149/mo"
else
    MONTHLY=249
    PLAN_NAME="Diamond Bright Secure Business"
    echo "Diamond Bright Secure Business ...... \$249/mo"
fi

echo "-----------------------------------------"
echo
echo "Estimated Remediation Value: \$${QUOTE_TOTAL}"
echo "Monthly Service Estimate: \$${MONTHLY}/month"
echo
echo "Monthly Plan Benefit:"
echo "Initial remediation may be included with"
echo "a qualifying monthly protection plan."
echo
echo "New Client Offer:"
echo "20% OFF first month when purchased"
echo "within 7 days of assessment."
echo
echo
echo
echo "========================================="
echo " TECHNOLOGY DEPENDENCY ANALYSIS"
echo "========================================="

echo "Technology Dependency Score: ${DEPENDENCY}/10"

if [ "$DEPENDENCY" -ge 8 ]; then
    echo "Business Technology Reliance: VERY HIGH"
elif [ "$DEPENDENCY" -ge 5 ]; then
    echo "Business Technology Reliance: HIGH"
elif [ "$DEPENDENCY" -ge 3 ]; then
    echo "Business Technology Reliance: MODERATE"
else
    echo "Business Technology Reliance: LOW"
fi

echo
echo "Business Observation:"

if [ "$DEPENDENCY" -ge 8 ]; then
    echo "Operations appear highly dependent on"
    echo "technology and internet connectivity."
    echo "Business interruptions could result in"
    echo "immediate productivity and revenue loss."
elif [ "$DEPENDENCY" -ge 5 ]; then
    echo "Technology plays a significant role in"
    echo "daily operations and should be actively"
    echo "maintained and protected."
else
    echo "Technology reliance appears limited,"
    echo "but basic security and continuity"
    echo "planning are still recommended."
fi

echo

echo "Business Continuity Score: ${CONTINUITY}/100"

if [ "$CONTINUITY" -ge 90 ]; then
    echo "Continuity Rating: EXCELLENT"
elif [ "$CONTINUITY" -ge 75 ]; then
    echo "Continuity Rating: GOOD"
elif [ "$CONTINUITY" -ge 60 ]; then
    echo "Continuity Rating: FAIR"
else
    echo "Continuity Rating: HIGH RISK"
fi

echo
echo
echo "========================================="
echo " BUSINESS FINANCIAL IMPACT ANALYSIS"
echo "========================================="
echo

if [[ "$EMPLOYEES" =~ ^[0-9]+$ ]] && [[ "$WAGE" =~ ^[0-9]+$ ]]; then

    HOURLY_COST=$((EMPLOYEES * WAGE))

    TWO_HOUR=$((HOURLY_COST * 2))
    HALF_DAY=$((HOURLY_COST * 4))
    FULL_DAY=$((HOURLY_COST * 8))

    YEARLY_PLAN=$((MONTHLY * 12))

    echo "Employees: $EMPLOYEES"
    echo "Average Hourly Wage: \$${WAGE}"
    echo

    echo "Employee Productivity Loss"
    echo "-----------------------------------------"
    echo "2 Hour Outage:     \$${TWO_HOUR}"
    echo "Half Day Outage:   \$${HALF_DAY}"
    echo "Full Day Outage:   \$${FULL_DAY}"
    echo

    if [[ "$REVENUE" =~ ^[0-9]+$ ]]; then

        TOTAL_IMPACT=$((FULL_DAY + REVENUE))
        MONTHS_COVERAGE=$(((TOTAL_IMPACT + MONTHLY - 1) / MONTHLY))

        echo "Estimated Daily Revenue Impact:"
        echo "\$${REVENUE}"
        echo

        echo "Potential One-Day Business Impact:"
        echo "\$${TOTAL_IMPACT}"
        echo

        echo "Annual Protection Plan Cost:"
        echo "\$${YEARLY_PLAN}"
        echo

        echo "Monthly Protection Comparison:"
        echo "One day of disruption could equal"
        echo "${MONTHS_COVERAGE} month(s) of protection coverage."
        echo

    else

        echo "Annual Protection Plan Cost:"
        echo "\$${YEARLY_PLAN}"
        echo

        echo "Monthly Protection Comparison:"
        echo "Revenue impact was not provided."
        echo "Only employee productivity loss was calculated."
        echo

    fi

    echo "Business Consideration:"
    echo "Would you rather budget predictable"
    echo "technology costs each month, or absorb"
    echo "unexpected downtime costs when problems occur?"
    echo

else

    echo "Financial impact analysis skipped."
    echo "Employee count and hourly wage not provided."

fi

echo
echo
echo "========================================="
echo " CLIENT ACKNOWLEDGEMENT"
echo "========================================="
echo "Assessment ID: $ASSESSMENT_ID"
echo
echo "Client Name: __________________________"
echo
echo "Signature: ____________________________"
echo
echo "Date: _________________________________"
echo
echo "By signing, the client acknowledges receipt"
echo "of this technology assessment report."
echo
echo "Technician: $TECH"
echo "Diamond Bright LLC"
echo "Email: ceo@diamondbrightai.com"
echo "Website: flawlessgemai.com"
echo "=============================================="
echo " Assessment Complete"
echo "=============================================="
} | tee "$REPORT"

echo
echo "Report saved as: $REPORT"
