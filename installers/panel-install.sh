#!/usr/bin/env bash

# ==========================================================
# PTERODACTYL PANEL INSTALLER
# ==========================================================

GREEN='\033[1;32m'
WHITE='\033[1;37m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
RESET='\033[0m'

clear

echo -e "${GREEN}"
echo "=========================================================="
echo "             PTERODACTYL PANEL INSTALLER"
echo "=========================================================="
echo -e "${RESET}"

if [[ $EUID -ne 0 ]]; then

    echo -e "${RED}Please run as root!${RESET}"

    exit 1

fi

echo

read -rp "Domain             : " DOMAIN

read -rp "Timezone           : " TIMEZONE

read -rp "Admin Username     : " USERNAME

read -rp "First Name         : " FIRSTNAME

read -rp "Last Name          : " LASTNAME

read -rp "Admin Email        : " EMAIL

read -rsp "Admin Password     : " PASSWORD

echo

echo
echo "=========================================================="
echo "Installation Summary"
echo "=========================================================="

echo "Domain      : $DOMAIN"
echo "Timezone    : $TIMEZONE"
echo "Username    : $USERNAME"
echo "First Name  : $FIRSTNAME"
echo "Last Name   : $LASTNAME"
echo "Email       : $EMAIL"

echo

read -rp "Continue Installation? (Y/N): " CONFIRM

if [[ "$CONFIRM" != "Y" && "$CONFIRM" != "y" ]]; then

    echo

    echo "Installation Cancelled."

    exit 0

fi

echo

echo -e "${YELLOW}Preparing Installation...${RESET}"

sleep 2

echo -e "${GREEN}Wizard Completed Successfully.${RESET}"

echo

# ==========================================================
# DOWNLOAD PTERODACTYL PANEL
# ==========================================================

echo
echo -e "${YELLOW}Downloading Pterodactyl Panel...${RESET}"
echo

mkdir -p /var/www/pterodactyl

cd /var/www/pterodactyl || exit

curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz

tar -xzf panel.tar.gz

rm -f panel.tar.gz

chmod -R 755 storage bootstrap/cache

echo
echo -e "${GREEN}Panel Download Completed.${RESET}"
echo


# ==========================================================
# INSTALL COMPOSER PACKAGES
# ==========================================================

echo
echo -e "${YELLOW}Installing Composer Packages...${RESET}"
echo

composer install \
    --no-dev \
    --optimize-autoloader

echo
echo -e "${GREEN}Composer Packages Installed.${RESET}"
echo


# ==========================================================
# CREATE ENVIRONMENT FILE
# ==========================================================

echo
echo -e "${YELLOW}Creating Environment File...${RESET}"
echo

cp .env.example .env

php artisan key:generate --force

echo
echo -e "${GREEN}Environment File Created.${RESET}"
echo


# ==========================================================
# SET FILE PERMISSIONS
# ==========================================================

echo
echo -e "${YELLOW}Setting Permissions...${RESET}"
echo

chown -R www-data:www-data /var/www/pterodactyl

chmod -R 755 /var/www/pterodactyl

echo
echo -e "${GREEN}Permissions Applied.${RESET}"
echo


# ==========================================================
# READY FOR DATABASE SETUP
# ==========================================================

echo
echo -e "${GREEN}Panel Files Installed Successfully.${RESET}"
echo

# ==========================================================
# CONFIGURE DATABASE
# ==========================================================

echo
echo -e "${YELLOW}Configuring Database...${RESET}"
echo

read -rp "Database Name      : " DB_NAME

read -rp "Database User      : " DB_USER

read -rsp "Database Password  : " DB_PASS

echo

mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
CREATE USER IF NOT EXISTS '${DB_USER}'@'127.0.0.1' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'127.0.0.1';
FLUSH PRIVILEGES;
EOF

echo
echo -e "${GREEN}Database Configured Successfully.${RESET}"
echo


# ==========================================================
# CONFIGURE PANEL
# ==========================================================

echo
echo -e "${YELLOW}Configuring Panel...${RESET}"
echo

php artisan p:environment:setup \
    --author="${EMAIL}" \
    --url="https://${DOMAIN}" \
    --timezone="${TIMEZONE}" \
    --cache=redis \
    --session=redis \
    --queue
