#!/usr/bin/env bash

# ==========================================================
# INFINITE VPS MANAGER - VPS MANAGER MODULE
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

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VPS_DIR="$BASE_DIR/vps"
LOG_DIR="$BASE_DIR/logs"
LOG_FILE="$LOG_DIR/infinite.log"

# ==========================================================
# LOGGING
# ==========================================================

vps_log() {
    local level="${1:-INFO}"
    local message="${2:-}"
    local timestamp

    mkdir -p "$LOG_DIR" 2>/dev/null

    timestamp="$(date '+%Y-%m-%d %H:%M:%S' 2>/dev/null)"
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE" 2>/dev/null
}

# ==========================================================
# HELPERS
# ==========================================================

have_cmd() {
    command -v "$1" >/dev/null 2>&1
}

pause() {
    echo
    read -rp "Press Enter to continue..." _
}

# ==========================================================
# SECURE SCRIPT RUNNER
# ==========================================================

run_vps_script() {
    # $1 = script filename inside vps/, $2 = human readable action name
    local script_file="$VPS_DIR/$1"
    local action_name="$2"

    if [ ! -f "$script_file" ]; then
        echo
        echo -e "${RED}Required script not found.${RESET}"
        vps_log "ERROR" "$action_name failed: $1 not found in $VPS_DIR."
        pause
        return 1
    fi

    if [ ! -r "$script_file" ]; then
        echo
        echo -e "${RED}Required script not found.${RESET}"
        vps_log "ERROR" "$action_name failed: $1 is not readable."
        pause
        return 1
    fi

    if have_cmd stat; then
        local perms other_digit
        perms=$(stat -c '%a' "$script_file" 2>/dev/null)
        if [ -n "$perms" ]; then
            other_digit="${perms: -1}"
            case "$other_digit" in
                2|3|6|7)
                    echo
                    echo -e "${RED}Error:${RESET} $1 has insecure permissions (world-writable). Refusing to execute."
                    vps_log "ERROR" "$action_name refused: $1 is world-writable."
                    pause
                    return 1
                ;;
            esac
        fi
    fi

    echo
    echo -e "${CYAN}Running: $action_name${RESET}"
    echo

    bash "$script_file"
    local exit_code=$?

    if [ "$exit_code" -eq 0 ]; then
        vps_log "INFO" "$action_name completed successfully."
    else
        echo
        echo -e "${YELLOW}[!] $action_name exited with status $exit_code${RESET}"
        vps_log "WARN" "$action_name exited with status $exit_code."
    fi

    pause
    return 0
}

# ==========================================================
# ACTION FUNCTIONS
# ==========================================================

vps_create() {
    run_vps_script "create.sh" "Create VPS"
}

vps_list() {
    run_vps_script "list.sh" "List VPS"
}

vps_start() {
    run_vps_script "start.sh" "Start VPS"
}

vps_stop() {
    run_vps_script "stop.sh" "Stop VPS"
}

vps_restart() {
    run_vps_script "restart.sh" "Restart VPS"
}

vps_console() {
    run_vps_script "console.sh" "Console"
}

vps_delete() {
    run_vps_script "delete.sh" "Delete VPS"
}

# ==========================================================
# MENU HEADER
# ==========================================================

vps_manager_header() {
    clear
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                        VPS MANAGER                           ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
}

# ==========================================================
# MAIN MENU FUNCTION
# ==========================================================

vps_manager_menu() {

    if [ ! -d "$VPS_DIR" ]; then
        mkdir -p "$VPS_DIR" 2>/dev/null
    fi

    while true; do

        vps_manager_header

        echo -e "${GREEN}[1]${RESET} Create VPS"
        echo -e "${GREEN}[2]${RESET} List VPS"
        echo -e "${GREEN}[3]${RESET} Start VPS"
        echo -e "${GREEN}[4]${RESET} Stop VPS"
        echo -e "${GREEN}[5]${RESET} Restart VPS"
        echo -e "${GREEN}[6]${RESET} Console"
        echo -e "${GREEN}[7]${RESET} Delete VPS"

        echo
        echo -e "${RED}[0]${RESET} Back to Main Menu"
        echo

        read -rp "Select Option : " VPS_OPTION

        case "$VPS_OPTION" in

            1)
                vps_create
            ;;

            2)
                vps_list
            ;;

            3)
                vps_start
            ;;

            4)
                vps_stop
            ;;

            5)
                vps_restart
            ;;

            6)
                vps_console
            ;;

            7)
                vps_delete
            ;;

            0)
                vps_log "INFO" "Returning to main menu from VPS Manager."
                return 0
            ;;

            *)
                echo
                echo -e "${RED}Invalid option!${RESET}"
                vps_log "WARN" "Invalid VPS Manager option selected: $VPS_OPTION"
                sleep 1
            ;;

        esac

    done

}

vps_manager_menu
