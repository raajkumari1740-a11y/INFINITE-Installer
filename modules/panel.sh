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

        5)

            clear

            echo -e "${GREEN}Creating Panel Backup...${RESET}"

            mkdir -p /var/backups/infinite

            tar -czf /var/backups/infinite/panel-$(date +%F-%H%M).tar.gz \
            /var/www/pterodactyl 2>/dev/null

            echo
            echo -e "${GREEN}Backup Completed Successfully.${RESET}"
            echo

            read -rp "Press Enter to continue..."

        ;;


        6)

            clear

            echo -e "${GREEN}Restore Panel Backup${RESET}"
            echo

            ls -lh /var/backups/infinite

            echo

            read -rp "Backup File Name : " BACKUP

            tar -xzf /var/backups/infinite/$BACKUP -C /

            echo
            echo -e "${GREEN}Backup Restored Successfully.${RESET}"
            echo

            read -rp "Press Enter to continue..."

        ;;


        7)

            clear

            echo -e "${GREEN}Updating Panel...${RESET}"

            bash <(curl -s https://pterodactyl-installer.se)

            read -rp "Press Enter to continue..."

        ;;


        8)

            clear

            echo -e "${RED}WARNING!${RESET}"
            echo "This will remove the Pterodactyl Panel."
            echo

            read -rp "Continue? (y/N): " CONFIRM

            if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then

                rm -rf /var/www/pterodactyl

                echo
                echo -e "${GREEN}Panel Removed Successfully.${RESET}"

            else

                echo
                echo "Cancelled."

            fi

            echo

            read -rp "Press Enter to continue..."

        ;;


        0)

            exit 0

        ;;


        *)

            echo
            echo -e "${RED}Invalid Option!${RESET}"

            sleep 1

        ;;

    esac

}

while true
do

    panel_menu

done
