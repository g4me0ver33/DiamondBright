  GNU nano 9.0                     diamondbrighttest/sh *                             
#!/bin/bash

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
read -p "Network range to scan? Example 192.168.1.0/24: " NETRANGE
read -p "Number of Employees (optional): " EMPLOYEES

DATE=$(date +"%Y-%m-%d_%H-%M")
ASSESSMENT_ID="DB-$(date +%Y%m%d)-$(shuf -i 1000-9999 -n 1)"
REPORT="DiamondBright_Assessment_${CLIENT// /_}_$DATE.txt"
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
    DEVICE_SCAN=$(nmap -sn "$NETRANGE")
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
?????????????????decho

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
echo "Backup Status:         UNKNOWN"
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
echo

echo "========================================="
echo " DIAMOND BRIGHT RECOMMENDATIONS"
echo "========================================="
echo
echo "Recommended Services:"
echo
echo "[ ] Network Security Review"
echo "[ ] Firewall Optimization"
echo "[ ] Router Configuration Audit"
echo "[ ] WiFi Optimization"
echo "[ ] Backup Verification"
echo "[ ] Device Inventory"
echo "[ ] Smart Device Security Review"
echo "[ ] Password & MFA Review"
echo "[ ] Monthly Technology Checkup"
echo
echo "Estimated Project Hours:"
echo "2 - 4 Hours"
echo
echo "Estimated Project Value:"
echo "\$250 - \$750"
echo
echo
echo
echo "========================================="
echo " RECOMMENDED MONTHLY SERVICE PLAN"
echo "========================================="
echo

if [ "$SCORE" -ge 90 ]; then

echo "Diamond Bright Essential Plan"
echo
echo "\$99/month"
echo
echo "Includes:"
echo "- Monthly system health review"
echo "- Security update review"
echo "- Device inventory review"
echo "- Email support"
echo "- Remote assistance"

elif [ "$SCORE" -ge 80 ]; then

echo "Diamond Bright Professional Plan"
echo
echo "\$149/month"
echo
echo "Includes:"
echo "- Monthly network assessment"
echo "- Firewall review"
echo "- Security update management"
echo "- Device inventory review"
echo "- Remote support"

else

echo "Diamond Bright Secure Business Plan"
echo
echo "\$249/month"
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
echo " NEW CLIENT SAVINGS"
echo "========================================="
echo
echo "Thank you for choosing Diamond Bright LLC."
echo
echo "SPECIAL OFFER:"
echo "Purchase a monthly service package within"
echo "7 days of this assessment and receive"
echo "20% OFF your first month of service."
echo
echo "Offer applies to new monthly service agreements."
echo
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
    echo "Diamond Bright Essential ............ \$99/mo"
elif [ "$SCORE" -ge 80 ]; then
    MONTHLY=149
    echo "Diamond Bright Professional ......... \$149/mo"
else
    MONTHLY=249
    echo "Diamond Bright Secure Business ...... \$249/mo"
fi

echo "-----------------------------------------"
echo
echo "One-Time Project Estimate: \$${QUOTE_TOTAL}"
echo "Monthly Service Estimate: \$${MONTHLY}/month"
echo
echo "Bundle Discount Available"
echo "20% OFF first month when purchased"
echo "within 7 days of assessment."
echo
echo "========================================="
echo " BUSINESS IMPACT ESTIMATE"
echo "========================================="
echo


if [[ "$EMPLOYEES" =~ ^[0-9]+$ ]]; then
    LOWLOSS=$((EMPLOYEES*100))
    HIGHLOSS=$((EMPLOYEES*500))

    echo "Estimated Downtime Exposure:"
    echo "\$${LOWLOSS} - \$${HIGHLOSS} per day"
    echo
fi
echo
echo "========================================="
echo " CLIENT ACKNOWLEDGEMENT"
echo "========================================="
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
echo "=============================================="
echo " Assessment Complete"
echo "=============================================="

} | tee "$REPORT"

echo
echo "Report saved as: $REPORT"
