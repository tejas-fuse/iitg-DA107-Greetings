#!/bin/bash

# --- Settings ---
LOCATION="Shegaon"
USER_NAME="Sir" 

# Colors
CYAN="\e[0;36m"
WHITE="\e[1;37m"
GREEN="\e[0;32m"
YELLOW="\e[1;33m"
RED="\e[0;31m"
MAGENTA="\e[1;35m"
RESET="\e[0m"

# Get terminal width for centering
WIDTH=$(tput cols)

# --- Logic for Greeting & Theme ---
HOUR=$(date +%H)
if [ $HOUR -lt 12 ]; then
    GREETING="Good Morning, $USER_NAME"
    THEME_COLOR=$YELLOW
elif [ $HOUR -lt 17 ]; then
    GREETING="Good Afternoon, $USER_NAME"
    THEME_COLOR=$GREEN
elif [ $HOUR -lt 21 ]; then
    GREETING="Good Evening, $USER_NAME"
    THEME_COLOR=$CYAN
else
    GREETING="Good Night, $USER_NAME"
    THEME_COLOR=$MAGENTA
fi

# --- 1. Perfectly Centered Banner ---
echo -e "${THEME_COLOR}"
# Generate ASCII, then pad each line with spaces to center it
figlet -f standard "$GREETING" | while IFS= read -r line; do
    printf "%*s\n" $(( (${#line} + WIDTH) / 2 )) "$line"
done
echo -e "${RESET}"

# --- 2. System Info Section ---
draw_line() { printf "${CYAN}%.s─${RESET}" $(seq 1 $WIDTH); echo; }

draw_line
echo -e "${WHITE}  DATE:${RESET} $(date +'%A, %d %B %Y')  |  ${WHITE}TIME:${RESET} $(date +'%T')  |  ${WHITE}UPTIME:${RESET} $(uptime -p | sed 's/up //')"
draw_line

# --- 3. Hardware & Stats ---
# Battery Info (Checks if it exists for laptops)
if [ -d /sys/class/power_supply/BAT0 ]; then
    BATT=$(cat /sys/class/power_supply/BAT0/capacity)
    BATT_STAT=$(cat /sys/class/power_supply/BAT0/status)
    echo -ne "${WHITE}  BATTERY:${RESET} ${BATT}% (${BATT_STAT})  |  "
fi

# Disk Usage Bar
DISK_PERC=$(df / --output=pcent | tail -1 | tr -dc '0-9')
echo -e "${WHITE}DISK USAGE:${RESET} [${GREEN}$(printf '%*s' $((DISK_PERC/5)) | tr ' ' '#')${RESET}$(printf '%*s' $((20-DISK_PERC/5)) | tr ' ' '-')]"

# Memory & CPU Load
MEM=$(free -h | awk '/^Mem:/ {print $3 "/" $2}')
LOAD=$(cut -d' ' -f1-3 /proc/loadavg)
echo -e "${WHITE}  MEMORY:${RESET} $MEM         |  ${WHITE}CPU LOAD:${RESET} $LOAD"

# --- 4. Network & Weather ---
WEATHER=$(curl -s "wttr.in/$LOCATION?format=1" | xargs)
IP_ADDR=$(hostname -I | awk '{print $1}')
echo -e "${WHITE}  WEATHER:${RESET} ${WEATHER:-'Offline'}  |  ${WHITE}LOCAL IP:${RESET} $IP_ADDR"

# --- 5. Logs ---
echo -e "\n${THEME_COLOR}  [ RECENT ACCESS LOGS ]${RESET}"
last -n 3 | grep -v "wtmp" | grep -v "^$" | sed 's/^/  /'

draw_line