#!/bin/bash

# --- Configuration ---
USER_NAME="Sir" 

# Colors
CYAN="\e[0;36m"
WHITE="\e[1;37m"
GREEN="\e[0;32m"
YELLOW="\e[1;33m"
MAGENTA="\e[1;35m"
RESET="\e[0m"

# Get terminal width
WIDTH=$(tput cols)
COL_WIDTH=$(( (WIDTH / 2) - 10 ))

# --- Logic for Greeting ---
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

# --- 1. Upper Banner (Centered) ---
echo -e "${THEME_COLOR}"
figlet -f standard "$GREETING" | while IFS= read -r line; do
    printf "%*s\n" $(( (${#line} + WIDTH) / 2 )) "$line"
done
echo -e "${RESET}"

# --- 2. Top Header Section (Matching Image) ---
draw_line() { printf "${CYAN}%.s─${RESET}" $(seq 1 $WIDTH); echo; }

draw_line
echo -e " ${WHITE}DATE:${RESET} $(date +'%A, %d %B %Y')  |  ${WHITE}TIME:${RESET} $(date +'%T')  |  ${WHITE}UPTIME:${RESET} $(uptime -p | sed 's/up //')"
draw_line

# --- 3. Middle Section: System Details (Two Columns) ---
# Column 1: Battery | Column 2: Uptime (detailed)
BATT="N/A"
[ -d /sys/class/power_supply/BAT0 ] && BATT=$(cat /sys/class/power_supply/BAT0/capacity)%
UP_LONG=$(uptime -p | sed 's/up //')
printf " ${WHITE}%-11s${RESET} %-${COL_WIDTH}s | ${WHITE}%-8s${RESET} %s\n" "BATTERY:" "$BATT" "UPTIME:" "$UP_LONG"

# Column 1: Memory | Column 2: CPU Load
MEM=$(free -h | awk '/^Mem:/ {print $3 "/" $2}')
LOAD=$(cut -d' ' -f1-3 /proc/loadavg)
printf " ${WHITE}%-11s${RESET} %-${COL_WIDTH}s | ${WHITE}%-8s${RESET} %s\n" "MEMORY:" "$MEM" "CPU LOAD:" "$LOAD"

# --- 4. Aligned Bars: Disk & Network ---
# Disk Usage
DISK_PERC=$(df / --output=pcent | tail -1 | tr -dc '0-9')
BAR_SIZE=$(( WIDTH - 30 ))
FILLED=$(( DISK_PERC * BAR_SIZE / 100 ))
EMPTY=$(( BAR_SIZE - FILLED ))
printf " ${WHITE}%-11s${RESET} [%s%s] %s%%\n" "DISK:" "$(printf '#%.0s' $(seq 1 $FILLED))" "$(printf -- '-%.0s' $(seq 1 $EMPTY))" "$DISK_PERC"

# Network Speed (Aligned to the Disk Bar)
INTERFACE=$(ip route get 8.8.8.8 2>/dev/null | awk '{print $5; exit}')
if [ -n "$INTERFACE" ]; then
    R1=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
    T1=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)
    sleep 0.4
    R2=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
    T2=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)
    RX=$(( (R2 - R1) / 410 )) 
    TX=$(( (T2 - T1) / 410 ))
    printf " ${WHITE}%-11s${RESET} ↓ %-10s | ↑ %-10s (via %s)\n" "NET SPEED:" "${RX} KB/s" "${TX} KB/s" "$INTERFACE"
fi

# --- 5. Logs Section (Matching Image) ---
echo -e "\n ${CYAN}RECENT ACCESS LOGS:${RESET}"
last -n 3 | grep -v "wtmp" | grep -v "^$" | sed 's/^/ /'

draw_line