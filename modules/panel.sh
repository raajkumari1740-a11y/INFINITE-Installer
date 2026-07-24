#!/usr/bin/env bash
#
# modules/panel.sh
# "Panel Setup" menu for the Pterodactyl Panel / Wings / Blueprint stack.
# Installation is delegated to installers/, while lifecycle operations
# (backup, restore, update, remove) live here since they are specific
# to how this project lays out the panel.

# ---------------------------------------------------------------------------
# Lifecycle operations
# ---------------------------------------------------------------------------

panel_backup() {
    if [[ ! -d "$PANEL_DIR" ]]; then
        msg_error "Panel is not installed at $PANEL_DIR."
        return
    fi

    mkdir -p "$BACKUP_DIR/panel"
    local stamp
    stamp=$(date '+%Y%m%d-%H%M%S')
    local archive="$BACKUP_DIR/panel/panel-backup-$stamp.tar.gz"

    msg_info "Backing up panel files to $archive..."
    tar -czf "$archive" -C "$(dirname "$PANEL_DIR")" "$(basename "$PANEL_DIR")"

    if command_exists mysqldump && [[ -f "$PANEL_ENV_FILE" ]]; then
        local db_name db_user db_pass
        db_name=$(grep -E '^DB_DATABASE=' "$PANEL_ENV_FILE" | cut -d '=' -f2)
        db_user=$(grep -E '^DB_USERNAME=' "$PANEL_ENV_FILE" | cut -d '=' -f2)
        db_pass=$(grep -E '^DB_PASSWORD=' "$PANEL_ENV_FILE" | cut -d '=' -f2)

        if [[ -n "$db_name" ]]; then
            msg_info "Backing up panel database..."
            MYSQL_PWD="$db_pass" mysqldump -u "$db_user" "$db_name" \
                > "$BACKUP_DIR/panel/panel-db-$stamp.sql" 2>/dev/null \
                && msg_success "Database backup saved." \
                || msg_warn "Database backup failed; check credentials in $PANEL_ENV_FILE."
        fi
    fi

    msg_success "Panel backup complete: $archive"
}

panel_restore() {
    mkdir -p "$BACKUP_DIR/panel"
    local backups=("$BACKUP_DIR"/panel/panel-backup-*.tar.gz)

    if [[ ! -e "${backups[0]}" ]]; then
        msg_error "No panel backups found in $BACKUP_DIR/panel."
        return
    fi

    echo -e "${C_WHITE}Available backups:${C_RESET}"
    local i=1
    local file
    for file in "${backups[@]}"; do
        echo "  [$i] $(basename "$file")"
        ((i++))
    done

    read -r -p "Select backup number to restore: " index
    local selected="${backups[$((index - 1))]}"

    if [[ -z "$selected" || ! -f "$selected" ]]; then
        msg_error "Invalid selection."
        return
    fi

    if ! confirm_action "This will overwrite $PANEL_DIR. Continue?"; then
        msg_warn "Restore cancelled."
        return
    fi

    systemctl stop nginx 2>/dev/null
    rm -rf "$PANEL_DIR"
    mkdir -p "$PANEL_DIR"
    tar -xzf "$selected" -C "$(dirname "$PANEL_DIR")"
    systemctl start nginx 2>/dev/null

    msg_success "Panel restored from $(basename "$selected")."
}

panel_update() {
    if [[ ! -d "$PANEL_DIR" ]]; then
        msg_error "Panel is not installed."
        return
    fi

    msg_info "Updating Pterodactyl Panel..."
    cd "$PANEL_DIR" || return 1

    php artisan down 2>/dev/null

    curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
    tar -xzf panel.tar.gz
    rm -f panel.tar.gz

    chmod -R 755 storage/* bootstrap/cache

    composer install --no-dev --optimize-autoloader --no-interaction

    php artisan migrate --seed --force
    php artisan view:clear
    php artisan config:clear

    chown -R www-data:www-data "$PANEL_DIR"

    php artisan up 2>/dev/null

    msg_success "Panel updated successfully."
}

panel_remove() {
    if ! confirm_action "This will PERMANENTLY remove the panel, its database and nginx config. Continue?"; then
        msg_warn "Removal cancelled."
        return
    fi

    systemctl stop nginx 2>/dev/null
    systemctl disable --now pteroq.service 2>/dev/null

    rm -rf "$PANEL_DIR"
    rm -f /etc/nginx/sites-enabled/pterodactyl.conf
    rm -f /etc/nginx/sites-available/pterodactyl.conf
    rm -f /etc/systemd/system/pteroq.service

    systemctl daemon-reload
    systemctl restart nginx 2>/dev/null

    msg_success "Panel removed. The MySQL database was left intact; drop it manually if desired."
}

# ---------------------------------------------------------------------------
# Menu
# ---------------------------------------------------------------------------

panel_setup_menu() {
    while true; do
        clear
        print_header "PANEL SETUP"
        print_menu_item "1" "Install Pterodactyl Panel"
        print_menu_item "2" "Install Wings"
        print_menu_item "3" "Reinstall Panel"
        print_menu_item "4" "Install Blueprint"
        print_menu_item "5" "Backup"
        print_menu_item "6" "Restore"
        print_menu_item "7" "Update"
        print_menu_item "8" "Remove"
        print_menu_item "0" "Back to Main Menu"
        print_line "-"

        read -r -p "$(echo -e "${C_GREEN}Select an option: ${C_RESET}")" choice
        echo

        case "$choice" in
            1) bash "$INSTALLERS_DIR/panel-install.sh" ;;
            2) bash "$INSTALLERS_DIR/wings-install.sh" ;;
            3)
                if confirm_action "This will remove and reinstall the panel. Continue?"; then
                    panel_remove
                    bash "$INSTALLERS_DIR/panel-install.sh"
                fi
                ;;
            4) bash "$INSTALLERS_DIR/blueprint-install.sh" ;;
            5) panel_backup ;;
            6) panel_restore ;;
            7) panel_update ;;
            8) panel_remove ;;
            0) return ;;
            *) msg_error "Invalid option." ;;
        esac

        press_enter_to_continue
    done
}

panel_setup_menu
