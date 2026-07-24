#!/usr/bin/env bash

# ==========================================================
# INFINITE VPS MANAGER - PANEL SETUP MODULE
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
INSTALLERS_DIR="$BASE_DIR/installers"
LOG_DIR="$BASE_DIR/logs"
LOG_FILE="$LOG_DIR/infinite.log"

# ==========================================================
# LOGGING
# ==========================================================

panel_log() {
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
# SECURE INSTALLER RUNNER
# ==========================================================

run_installer() {
    # $1 = script filename inside installers/, $2 = human readable action name
    local script_file="$INSTALLERS_DIR/$1"
    local action_name="$2"

    if [ ! -f "$script_file" ]; then
        echo
        echo -e "${RED}Installer not found.${RESET}"
        panel_log "ERROR" "$action_name failed: $1 not found in $INSTALLERS_DIR."
        pause
        return 1
    fi

    if [ ! -r "$script_file" ]; then
        echo
        echo -e "${RED}Installer not found.${RESET}"
        panel_log "ERROR" "$action_name failed: $1 is not readable."
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
                    panel_log "ERROR" "$action_name refused: $1 is world-writable."
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
        panel_log "INFO" "$action_name completed successfully."
    else
        echo
        echo -e "${YELLOW}[!] $action_name exited with status $exit_code${RESET}"
        panel_log "WARN" "$action_name exited with status $exit_code."
    fi

    pause
    return 0
}

# ==========================================================
# ACTION FUNCTIONS
# ==========================================================

panel_install_dependencies() {
    run_installer "install_dependencies.sh" "Install Dependencies"
}

panel_install_panel() {
    run_installer "install_panel.sh" "Install Pterodactyl Panel"
}

panel_install_wings() {
    run_installer "install_wings.sh" "Install Wings"
}

panel_install_blueprint() {
    run_installer "install_blueprint.sh" "Install Blueprint"
}

panel_update() {
    run_installer "update_panel.sh" "Update Panel"
}

panel_backup() {
    run_installer "backup_panel.sh" "Backup Panel"
}

panel_remove() {
    run_installer "remove_panel.sh" "Remove Panel"
}

# ==========================================================
# MENU HEADER
# ==========================================================

panel_setup_header() {
    clear
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                       PANEL SETUP                             ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
}

# ==========================================================
# MAIN MENU FUNCTION
# ==========================================================

panel_setup_menu() {

    if [ ! -d "$INSTALLERS_DIR" ]; then
        mkdir -p "$INSTALLERS_DIR" 2>/dev/null
    fi

    while true; do

        panel_setup_header

        echo -e "${GREEN}[1]${RESET} Install Dependencies"
        echo -e "${GREEN}[2]${RESET} Install Pterodactyl Panel"
        echo -e "${GREEN}[3]${RESET} Install Wings"
        echo -e "${GREEN}[4]${RESET} Install Blueprint"
        echo -e "${GREEN}[5]${RESET} Update Panel"
        echo -e "${GREEN}[6]${RESET} Backup Panel"
        echo -e "${GREEN}[7]${RESET} Remove Panel"

        echo
        echo -e "${RED}[0]${RESET} Back to Main Menu"
        echo

        read -rp "Select Option : " PANEL_OPTION

        case "$PANEL_OPTION" in

            1)
                panel_install_dependencies
            ;;

            2)
                panel_install_panel
            ;;

            3)
                panel_install_wings
            ;;

            4)
                panel_install_blueprint
            ;;

            5)
                panel_update
            ;;

            6)
                panel_backup
            ;;

            7)
                panel_remove
            ;;

            0)
                panel_log "INFO" "Returning to main menu from Panel Setup."
                return 0
            ;;

            *)
                echo
                echo -e "${RED}Invalid option!${RESET}"
                panel_log "WARN" "Invalid Panel Setup option selected: $PANEL_OPTION"
                sleep 1
            ;;

        esac

    done

}

panel_setup_menu
