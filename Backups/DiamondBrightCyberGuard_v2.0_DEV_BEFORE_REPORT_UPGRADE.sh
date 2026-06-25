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

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                 DIAMOND BRIGHT CYBERGUARD™                  ║"
echo "║          Business Cyber Risk Management Platform             ║"
echo "║                    Version 1.0 STABLE                       ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo
echo "Know Your Risks. Protect Your Business."
echo
echo "Assessment ID: $ASSESSMENT_ID"
echo "Started:       $START_READABLE"
echo

read -p "Press ENTER to begin CyberGuard Assessment..."

echo
echo "Starting assessment..."
echo

CYBERGUARD_NETWORK_RANGE="$NETWORK_RANGE" bash ./diamondbrighttest.sh

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
MINUTES=$((DURATION / 60))
SECONDS=$((DURATION % 60))

echo
echo "==========================================="
echo "        CYBERGUARD EXECUTIVE SUMMARY"
echo "==========================================="
echo
echo "Assessment ID:"
echo "$ASSESSMENT_ID"
echo
echo "Assessment Started:"
echo "$START_READABLE"
echo
echo "Assessment Duration:"
echo "${MINUTES} minutes ${SECONDS} seconds"
echo
echo "Status:"
echo "Assessment completed."
echo
echo "Next Step:"
echo "Review the generated report and recommendations."
echo
echo "Thank you for choosing Diamond Bright CyberGuard™"
echo "==========================================="
echo
