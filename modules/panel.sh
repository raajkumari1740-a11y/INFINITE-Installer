#!/usr/bin/env bash

# ==========================================================
# PANEL SETUP
# ==========================================================

GREEN='\033[1;32m'
WHITE='\033[1;37m'
RED='\033[1;31m'
RESET='\033[0m'

panel_menu() {

    clear

    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                        PANEL SETUP                          ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"

    echo -e "${GREEN}[1]${RESET} Install Pterodactyl Panel"
    echo -e "${GREEN}[2]${RESET} Install Wings"
    echo -e "${GREEN}[3]${RESET} Reinstall Panel"
    echo -e "${GREEN}[4]${RESET} Install Blueprint"
    echo -e "${GREEN}[5]${RESET} Panel Backup"
    echo -e "${GREEN}[6]${RESET} Restore Backup"
    echo -e "${GREEN}[7]${RESET} Update Panel"
    echo -e "${GREEN}[8]${RESET} Remove Panel"

    echo

    echo -e "${RED}[0]${RESET} Back"

    echo

    read -rp "Select Option : " OPTION

    case $OPTION in

        1)

            clear

            echo -e "${GREEN}Starting Pterodactyl Panel Installer...${RESET}"

            bash <(curl -s https://pterodactyl-installer.se)

        ;;


        2)

            clear

            echo -e "${GREEN}Starting Wings Installer...${RESET}"

            bash <(curl -s https://pterodactyl-installer.se)

        ;;


        3)

            clear

            echo -e "${GREEN}Reinstalling Panel...${RESET}"

            bash <(curl -s https://pterodactyl-installer.se)

        ;;


        4)

            clear

            echo -e "${GREEN}Installing Blueprint...${RESET}"

            echo "Coming Soon..."

            read -rp "Press Enter to continue..."

        ;;
