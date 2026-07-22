#!/usr/bin/env bash

# ==========================================================
# INFINITE VPS MANAGER
# Version : 1.0
# ==========================================================

clear

# ==========================================================
# COLORS
# ==========================================================

GREEN='\033[1;32m'
WHITE='\033[1;37m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
RESET='\033[0m'

# ==========================================================
# PATHS
# ==========================================================

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

MODULES="$BASE_DIR/modules"

# ==========================================================
# ROOT CHECK
# ==========================================================

if [[ $EUID -ne 0 ]]; then

    echo -e "${RED}[ERROR] Please run this script as root.${RESET}"

    exit 1

fi

# ==========================================================
# MODULES CHECK
# ==========================================================

if [ ! -d "$MODULES" ]; then

    mkdir -p "$MODULES"

fi

# ==========================================================
# SYSTEM INFO
# ==========================================================

OS_NAME=$(grep '^PRETTY_NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')

KERNEL=$(uname -r)

HOSTNAME=$(hostname)

MAIN_USER=$(whoami)

RAM=$(free -h | awk '/Mem:/ {print $3 " / " $2}')

DISK=$(df -h / | awk 'NR==2 {print $3 " / " $2}')

CPU=$(top -bn1 | awk -F',' '/Cpu/ {print int($1)}')

LOAD=$(uptime | awk -F'load average:' '{print $2}')

UPTIME=$(uptime -p)

PUBLIC_IP=$(curl -4 -s ifconfig.me 2>/dev/null || echo "Unavailable")

# ==========================================================
# HEADER
# ==========================================================

header() {

    clear

    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                 INFINITE VPS MANAGER v1.0                   ║"
    echo "║              Advanced VPS Deployment Suite                  ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"

    echo -e "${WHITE} OS            : ${GREEN}$OS_NAME${RESET}"
    echo -e "${WHITE} KERNEL        : ${GREEN}$KERNEL${RESET}"
    echo -e "${WHITE} RAM USAGE     : ${GREEN}$RAM${RESET}"
    echo -e "${WHITE} DISK USAGE    : ${GREEN}$DISK${RESET}"
    echo -e "${WHITE} CPU USAGE     : ${GREEN}$CPU%${RESET}"
    echo -e "${WHITE} VPS MAIN USER : ${GREEN}$MAIN_USER${RESET}"
    echo -e "${WHITE} HOSTNAME      : ${GREEN}$HOSTNAME${RESET}"
    echo -e "${WHITE} IP ADDRESS    : ${GREEN}$PUBLIC_IP${RESET}"
    echo -e "${WHITE} VPS LOAD      : ${GREEN}$LOAD${RESET}"
    echo -e "${WHITE} UPTIME        : ${GREEN}$UPTIME${RESET}"

    echo
    echo "──────────────────────────────────────────────────────────────"
    echo

}

# ==========================================================
# MAIN MENU
# ==========================================================

main_menu() {

    header

    echo -e "${GREEN}[1]${RESET} Panel Setup"
    echo -e "${GREEN}[2]${RESET} VPS Manager"
    echo -e "${GREEN}[3]${RESET} System Tools"
    echo -e "${GREEN}[4]${RESET} Network Tools"
    echo -e "${GREEN}[5]${RESET} Monitoring"

    echo

    echo -e "${RED}[0]${RESET} Exit"

    echo

    read -rp "Select Option : " OPTION

    case $OPTION in

            1)

            if [ -f "$MODULES/panel.sh" ]; then

                bash "$MODULES/panel.sh"

            else

                echo
                echo -e "${RED}Error:${RESET} panel.sh not found!"
                echo
                read -rp "Press Enter to continue..."

            fi

        ;;


        2)

            if [ -f "$MODULES/vps.sh" ]; then

                bash "$MODULES/vps.sh"

            else

                echo
                echo -e "${RED}Error:${RESET} vps.sh not found!"
                echo
                read -rp "Press Enter to continue..."

            fi

        ;;


        3)

            if [ -f "$MODULES/system.sh" ]; then

                bash "$MODULES/system.sh"

            else

                echo
                echo -e "${RED}Error:${RESET} system.sh not found!"
                echo
                read -rp "Press Enter to continue..."

            fi

        ;;


        4)

            if [ -f "$MODULES/network.sh" ]; then

                bash "$MODULES/network.sh"

            else

                echo
                echo -e "${RED}Error:${RESET} network.sh not found!"
                echo
                read -rp "Press Enter to continue..."

            fi

        ;;


        5)

            if [ -f "$MODULES/monitor.sh" ]; then

                bash "$MODULES/monitor.sh"

            else

                echo
                echo -e "${RED}Error:${RESET} monitor.sh not found!"
                echo
                read -rp "Press Enter to continue..."

            fi

        ;;


        0)

            clear

            echo
            echo -e "${GREEN}Thank you for using INFINITE VPS MANAGER!${RESET}"
            echo

            exit 0

        ;;


        *)

            echo
            echo -e "${RED}Invalid option!${RESET}"
            sleep 1

        ;;

    esac

}

# ==========================================================
# AUTO REFRESH LOOP
# ==========================================================

while true
do

    OS_NAME=$(grep '^PRETTY_NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')

    KERNEL=$(uname -r)

    HOSTNAME=$(hostname)

    MAIN_USER=$(whoami)

    RAM=$(free -h | awk '/Mem:/ {print $3 " / " $2}')

    DISK=$(df -h / | awk 'NR==2 {print $3 " / " $2}')

    CPU=$(top -bn1 | awk -F',' '/Cpu/ {print int($1)}')

    LOAD=$(uptime | awk -F'load average:' '{print $2}')

    UPTIME=$(uptime -p)

    PUBLIC_IP=$(curl -4 -s ifconfig.me 2>/dev/null || echo "Unavailable")

    main_menu

done
