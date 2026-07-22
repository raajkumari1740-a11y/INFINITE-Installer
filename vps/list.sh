#!/usr/bin/env bash

# ==========================================================
# LIST VPS
# ==========================================================

GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
RESET='\033[0m'

clear

echo -e "${GREEN}"
echo "=========================================================="
echo "                      VPS LIST"
echo "=========================================================="
echo -e "${RESET}"

if [[ $EUID -ne 0 ]]; then

    echo -e "${RED}Please run as root!${RESET}"

    exit 1

fi

echo

echo -e "${YELLOW}Detecting VPS Platform...${RESET}"

echo

if command -v pct >/dev/null 2>&1; then

    echo "LXC Environment Detected."

    echo

    pct list

elif command -v docker >/dev/null 2>&1; then

    echo "Docker Environment Detected."

    echo

    docker ps -a \
        --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"

else

    echo -e "${RED}No Supported VPS Platform Found.${RESET}"

    exit 1

fi

echo

echo -e "${GREEN}==============================================${RESET}"
echo -e "${GREEN} VPS List Loaded Successfully ${RESET}"
echo -e "${GREEN}==============================================${RESET}"

echo

read -rp "Press Enter to continue..."
