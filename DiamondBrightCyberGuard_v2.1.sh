#!/bin/bash

clear

START_TIME=$(date +%s)
ASSESSMENT_ID="CG-$(date +%Y%m%d-%H%M%S)"
START_READABLE=$(date "+%Y-%m-%d %I:%M %p")
ACTIVE_IFACE=$(ip route | awk '/default/ {print $5; exit}')
LOCAL_IP=$(ip -4 addr show "$ACTIVE_IFACE" | awk '/inet / {print $2}' | cut -d/ -f1)
CIDR=$(ip -4 addr show "$ACTIVE_IFACE" | awk '/inet / {print $2}' | cut -d/ -f2)
GATEWAY=$(ip route | awk '/default/ {print $3; exit}')

if [ -z "$ACTIVE_IFACE" ] || [ -z "$LOCAL_IP" ] || [ -z "$CIDR" ]; then
    echo "Could not automatically detect network."
    read -p "Enter network range manually, example 192.168.0.0/24: " NETWORK_RANGE
else
    NETWORK_BASE=$(ip route | awk -v iface="$ACTIVE_IFACE" '$3 == iface && $1 != "default" {print $1; exit}')
    NETWORK_RANGE="$NETWORK_BASE"
fi

echo
echo "Detected Network:"
echo "Interface : $ACTIVE_IFACE"
echo "Local IP  : $LOCAL_IP"
echo "Gateway   : $GATEWAY"
echo "Range     : $NETWORK_RANGE"
echo
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                 DIAMOND BRIGHT CYBERGUARD™                  ║"
echo "║          Business Cyber Risk Management Platform             ║"
echo "║              Version 2.1 PROFESSIONAL                       ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo
echo "Know Your Risks. Protect Your Business."
echo
echo "Assessment ID: $ASSESSMENT_ID"
echo "Started:       $START_READABLE"
echo
clear
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║          DIAMOND BRIGHT CYBERGUARD™ PROFESSIONAL            ║"
echo "║                  ASSESSMENT PREVIEW                         ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo
echo "Client        : ${CLIENT:-Client}"
echo "Assessment ID : $ASSESSMENT_ID"
echo "Started       : $START_READABLE"
echo
echo "Network Detection"
echo "──────────────────────────────────────────────────────────────"
echo "Interface     : ${ACTIVE_IFACE:-Not detected}"
echo "Local IP      : ${LOCAL_IP:-Not detected}"
echo "Gateway       : ${GATEWAY:-Not detected}"
echo "Network Range : ${NETWORK_RANGE:-Not detected}"
echo
echo "CyberGuard Modules"
echo "──────────────────────────────────────────────────────────────"
echo "✓ Network Discovery"
echo "✓ Device Inventory"
echo "✓ Firewall Review"
echo "✓ Wi-Fi Security Review"
echo "✓ Business Risk Analysis"
echo "✓ Executive Report Builder"
echo "✓ Professional PDF Generator"
echo

read -p "Press ENTER to begin CyberGuard Assessment..."

clear

echo "══════════════════════════════════════════════════════════════"
echo "        DIAMOND BRIGHT CYBERGUARD™ PROFESSIONAL"
echo "══════════════════════════════════════════════════════════════"
echo
echo "Assessment Status"
echo
echo "Client: ${CLIENT:-Client}"
echo "Assessment ID: $ASSESSMENT_ID"
echo "Network: $NETWORK_RANGE"
echo
echo "Starting CyberGuard assessment..."
echo

CYBERGUARD_NETWORK_RANGE="$NETWORK_RANGE" bash ./diamondbrighttest.sh

LATEST_REPORT=$(ls -t DiamondBright_DB-*.txt 2>/dev/null | head -n1)

if [ -n "$LATEST_REPORT" ]; then
    echo
    echo "✓ Technical assessment report saved:"
    echo "$LATEST_REPORT"

    echo
    echo "Generating CyberGuard Executive Report..."
    LATEST_EXEC=$(./build_executive_report.sh "$LATEST_REPORT" | tail -n1)

    if [ -n "$LATEST_EXEC" ] && [ -f "$LATEST_EXEC" ]; then
        echo "✓ Executive report created:"
        echo "$LATEST_EXEC"

        echo
        echo "Generating Professional PDF..."
        python3 build_professional_pdf.py "$LATEST_EXEC"

        LATEST_PDF="${LATEST_EXEC%.txt}.pdf"

if [ -f "$LATEST_PDF" ]; then
    echo "✓ Professional PDF created:"
    echo "$LATEST_PDF"
    echo
    echo "Opening CyberGuard Executive Assessment..."
    xdg-open "$LATEST_PDF" >/dev/null 2>&1 &
else
            echo "PDF generation completed, but PDF file was not found."
        fi
    else
        echo "Executive report file was not found. PDF was not generated."
    fi
else
    echo "No technical report found. Executive report was not generated."
fi

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
MINUTES=$((DURATION / 60))
SECONDS=$((DURATION % 60))

echo
echo "══════════════════════════════════════════════════════════════"
echo "              CYBERGUARD ASSESSMENT COMPLETE"
echo "══════════════════════════════════════════════════════════════"
echo
echo "Assessment ID     : $ASSESSMENT_ID"
echo "Assessment Started: $START_READABLE"
echo "Duration          : ${MINUTES} minutes ${SECONDS} seconds"
echo
echo "Technical Report  : ${LATEST_REPORT:-Not Available}"
echo "Executive Report  : ${LATEST_EXEC:-Not Available}"
echo "PDF Report        : ${LATEST_PDF:-Not Available}"
echo
echo "Next Step         : Review the executive report with the client."
echo
echo "Diamond Bright CyberGuard™"
echo "Know Your Risks. Protect Your Business."
echo "══════════════════════════════════════════════════════════════"
echo
