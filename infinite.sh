#!/usr/bin/env bash

# ==========================================================
# INFINITE VPS MANAGER
# Version : 1.0
# ==========================================================

set -o pipefail
set -u

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

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

MODULES="$BASE_DIR/modules"
LOG_DIR="$BASE_DIR/logs"
LOG_FILE="$LOG_DIR/infinite.log"

# ==========================================================
# LOGGING
# ==========================================================

init_logging() {
    if ! mkdir -p "$LOG_DIR" 2>/dev/null; then
        LOG_FILE=""
        return
    fi
    touch "$LOG_FILE" 2>/dev/null
    chmod 640 "$LOG_FILE" 2>/dev/null
}

log() {
    # $1 = level (INFO|WARN|ERROR), $2 = message
    [ -z "$LOG_FILE" ] && return
    local level="${1:-INFO}"
    local message="${2:-}"
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S' 2>/dev/null)"
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE" 2>/dev/null
}

# ==========================================================
# ROOT CHECK
# ==========================================================

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}[ERROR] Please run this script as root.${RESET}"
        log "ERROR" "Script executed without root privileges."
        exit 1
    fi
}

# ==========================================================
# MODULES CHECK
# ==========================================================

check_modules_dir() {
    if [ ! -d "$MODULES" ]; then
        if ! mkdir -p "$MODULES" 2>/dev/null; then
            echo -e "${RED}[ERROR] Failed to create modules directory: $MODULES${RESET}"
            log "ERROR" "Failed to create modules directory: $MODULES"
            exit 1
        fi
    fi
}

# ==========================================================
# DEPENDENCY CHECK HELPER
# ==========================================================

have_cmd() {
    command -v "$1" >/dev/null 2>&1
}

# ==========================================================
# CPU USAGE
# ==========================================================

get_cpu_usage() {

    if ! have_cmd top; then
        CPU="N/A"
        return
    fi

    local idle
    idle=$(LC_ALL=C top -bn1 2>/dev/null | awk -F',' '
        /Cpu\(s\)/ {
            for (i = 1; i <= NF; i++) {
                if ($i ~ /id/) {
                    gsub(/[^0-9.]/, "", $i)
                    print $i
                }
            }
        }
    ')

    if [[ "$idle" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        CPU=$(awk -v i="$idle" 'BEGIN { printf "%.0f", 100 - i }' 2>/dev/null)
        [[ "$CPU" =~ ^[0-9]+$ ]] || CPU="0"
    else
        CPU="0"
    fi

}

# ==========================================================
# PUBLIC IP (cached: only re-queried while unavailable,
# avoids a network call on every menu redraw)
# ==========================================================

PUBLIC_IP="Unavailable"

fetch_public_ip() {

    if [[ "$PUBLIC_IP" != "Unavailable" && -n "$PUBLIC_IP" ]]; then
        return
    fi

    if ! have_cmd curl; then
        PUBLIC_IP="Unavailable"
        return
    fi

    local ip=""
    ip=$(curl -4 -s --max-time 3 https://ifconfig.me 2>/dev/null)

    if [[ -z "$ip" ]]; then
        ip=$(curl -4 -s --max-time 3 https://api.ipify.org 2>/dev/null)
    fi

    if [[ -z "$ip" ]]; then
        ip=$(curl -4 -s --max-time 3 https://icanhazip.com 2>/dev/null | tr -d '[:space:]')
    fi

    PUBLIC_IP="${ip:-Unavailable}"

}

# ==========================================================
# SYSTEM INFO
# ==========================================================

refresh_system_info() {

    if have_cmd grep && [ -r /etc/os-release ]; then
        OS_NAME=$(grep -m1 '^PRETTY_NAME=' /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"')
    fi
    [ -z "${OS_NAME:-}" ] && OS_NAME="Unknown"

    if have_cmd uname; then
        KERNEL=$(uname -r 2>/dev/null)
    fi
    [ -z "${KERNEL:-}" ] && KERNEL="Unknown"

    HOSTNAME=$(hostname 2>/dev/null)
    if [ -z "$HOSTNAME" ] && [ -r /etc/hostname ]; then
        HOSTNAME=$(cat /etc/hostname 2>/dev/null)
    fi
    [ -z "$HOSTNAME" ] && HOSTNAME="Unknown"

    MAIN_USER=$(whoami 2>/dev/null)
    [ -z "$MAIN_USER" ] && MAIN_USER="Unknown"

    if have_cmd free; then
        RAM=$(free -h 2>/dev/null | awk '/Mem:/ {print $3 " / " $2}')
    fi
    [ -z "${RAM:-}" ] && RAM="Unavailable"

    if have_cmd df; then
        DISK=$(df -h / 2>/dev/null | awk 'NR==2 {print $3 " / " $2}')
    fi
    [ -z "${DISK:-}" ] && DISK="Unavailable"

    get_cpu_usage

    if have_cmd uptime; then
        LOAD=$(uptime 2>/dev/null | awk -F'load average:' '{print $2}')
        UPTIME=$(uptime -p 2>/dev/null)
    fi
    [ -z "${LOAD:-}" ] && LOAD="Unavailable"
    [ -z "${UPTIME:-}" ] && UPTIME="Unavailable"

    fetch_public_ip

}

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
# MODULE SECURITY CHECK
# (refuses to execute world-writable scripts as root)
# ==========================================================

is_world_writable() {
    local file="$1"
    local perms

    if ! have_cmd stat; then
        return 1
    fi

    perms=$(stat -c '%a' "$file" 2>/dev/null) || return 1
    local other_digit="${perms: -1}"

    case "$other_digit" in
        2|3|6|7) return 0 ;;
        *) return 1 ;;
    esac
}

# ==========================================================
# MODULE RUNNER
# ==========================================================

run_module() {
    # $1 = module filename, $2 = display name
    local module_file="$MODULES/$1"
    local module_name="$2"

    if [ -f "$module_file" ]; then

        if [ ! -r "$module_file" ]; then
            echo
            echo -e "${RED}Error:${RESET} $1 is not readable!"
            log "ERROR" "$1 is not readable."
            echo
            read -rp "Press Enter to continue..."
            return
        fi

        if is_world_writable "$module_file"; then
            echo
            echo -e "${RED}Error:${RESET} $1 has insecure permissions (world-writable). Refusing to execute."
            log "ERROR" "$1 refused to execute: world-writable permissions detected."
            echo
            read -rp "Press Enter to continue..."
            return
        fi

        bash "$module_file"
        local exit_code=$?
        if [ "$exit_code" -ne 0 ]; then
            log "WARN" "$1 exited with status $exit_code"
        fi

    else

        echo
        echo -e "${RED}Error:${RESET} $1 not found!"
        log "ERROR" "$module_name selected but $1 not found in $MODULES."
        echo
        read -rp "Press Enter to continue..."

    fi
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

    case "$OPTION" in

            1)

            run_module "panel.sh" "Panel Setup"

        ;;


        2)

            run_module "vps.sh" "VPS Manager"

        ;;


        3)

            run_module "system.sh" "System Tools"

        ;;


        4)

            run_module "network.sh" "Network Tools"

        ;;


        5)

            run_module "monitor.sh" "Monitoring"

        ;;


        0)

            clear

            echo
            echo -e "${GREEN}Thank you for using INFINITE VPS MANAGER!${RESET}"
            echo

            log "INFO" "User exited INFINITE VPS MANAGER."

            exit 0

        ;;


        *)

            echo
            echo -e "${RED}Invalid option!${RESET}"
            log "WARN" "Invalid menu option selected: $OPTION"
            sleep 1

        ;;

    esac

}

# ==========================================================
# SIGNAL HANDLING
# ==========================================================

handle_interrupt() {
    echo
    echo -e "${YELLOW}[!] Interrupted. Exiting...${RESET}"
    log "INFO" "Script interrupted by signal."
    exit 130
}

# ==========================================================
# MAIN
# ==========================================================

main() {

    trap handle_interrupt INT TERM

    check_root
    init_logging
    check_modules_dir

    log "INFO" "INFINITE VPS MANAGER started."

    while true
    do
        refresh_system_info
        main_menu
    done

}

main "$@"
