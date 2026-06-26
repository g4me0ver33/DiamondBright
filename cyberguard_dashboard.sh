#!/bin/bash
clear

BLUE='\033[1;34m'
CYAN='\033[1;36m'
GREEN='\033[1;32m'
WHITE='\033[1;37m'
RESET='\033[0m'

echo -e "${BLUE}"
echo "═══════════════════════════════════════════════════════════════════════════════"
echo "                     DIAMOND BRIGHT CYBERGUARD™"
echo "                  PROFESSIONAL EDITION v3.0"
echo "═══════════════════════════════════════════════════════════════════════════════"
echo -e "${RESET}"

echo

echo -e "${CYAN}Business Cyber Risk Assessment Platform${RESET}"
echo
echo "Consultant : Joshua Bottoms"
echo "Company    : Diamond Bright LLC"
echo "Engine     : CyberGuard Professional"
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo
echo "Loading CyberGuard Modules..."
sleep .3
echo -e "${GREEN}✓${RESET} Assessment Engine"
sleep .2
echo -e "${GREEN}✓${RESET} Network Discovery"
sleep .2
echo -e "${GREEN}✓${RESET} Device Inventory"
sleep .2
echo -e "${GREEN}✓${RESET} Firewall Analysis"
sleep .2
echo -e "${GREEN}✓${RESET} Business Risk Engine"
sleep .2
echo -e "${GREEN}✓${RESET} Executive Report Builder"
sleep .2
echo -e "${GREEN}✓${RESET} PDF Generator"
sleep .2
echo -e "${GREEN}✓${RESET} Client Database"
sleep .2

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo
echo -e "${GREEN}CyberGuard Ready.${RESET}"
echo

read -p "Press ENTER to begin CyberGuard Assessment..."

clear
sudo ./DiamondBrightCyberGuard_v2.1.sh
