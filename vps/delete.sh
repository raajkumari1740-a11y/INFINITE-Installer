#!/usr/bin/env bash

# ==========================================================
# DELETE VPS
# ==========================================================

GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
RESET='\033[0m'

clear

echo -e "${GREEN}"
echo "=========================================================="
echo "                     DELETE VPS"
echo "=========================================================="
echo -e "${RESET}"

if [[ $EUID -ne 0 ]]; then

    echo -e "${RED}Please run as root!${RESET}"

    exit 1

fi

echo

read -rp "VPS Name : " VPS_NAME

echo

read -rp "Are you sure you want to delete '$VPS_NAME'? (YES/NO): " CONFIRM

if [[ "$CONFIRM" != "YES" ]]; then

    echo

    echo -e "${YELLOW}Deletion Cancelled.${RESET}"

    exit 0

fi

echo

echo -e "${YELLOW}Detecting VPS Type...${RESET}"

echo

if command -v pct >/dev/null 2>&1; then

    echo "LXC Environment Detected."

    pct stop "$VPS_NAME" >/dev/null 2>&1

    pct destroy "$VPS_NAME"

elif command -v docker >/dev/null 2>&1; then

    echo "Docker Environment Detected."

    docker rm -f "$VPS_NAME"

else

    echo -e "${RED}No Supported VPS Platform Found.${RESET}"

    exit 1

fi

echo

echo -e "${GREEN}==============================================${RESET}"
echo -e "${GREEN} VPS Deleted Successfully! ${RESET}"
echo -e "${GREEN}==============================================${RESET}"

echo

read -rp "Press Enter to continue..."
