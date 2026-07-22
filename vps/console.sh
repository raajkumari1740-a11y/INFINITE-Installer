#!/usr/bin/env bash

# ==========================================================
# VPS CONSOLE
# ==========================================================

GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
RESET='\033[0m'

clear

echo -e "${GREEN}"
echo "=========================================================="
echo "                     VPS CONSOLE"
echo "=========================================================="
echo -e "${RESET}"

if [[ $EUID -ne 0 ]]; then

    echo -e "${RED}Please run as root!${RESET}"

    exit 1

fi

echo

read -rp "VPS Name : " VPS_NAME

echo

echo -e "${YELLOW}Detecting VPS Platform...${RESET}"

echo

if command -v pct >/dev/null 2>&1; then

    echo "LXC Environment Detected."

    echo

    pct enter "$VPS_NAME"

elif command -v docker >/dev/null 2>&1; then

    echo "Docker Environment Detected."

    echo

    docker exec -it "$VPS_NAME" /bin/bash

else

    echo -e "${RED}No Supported VPS Platform Found.${RESET}"

    exit 1

fi

echo

read -rp "Press Enter to continue..."
