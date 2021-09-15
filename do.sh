#!/bin/bash

# ANSI Color
STD='\033[0m'
ERR='\033[0;41;30m'
CURR='\033[36m'
INFO='\033[1;34m'
PMPT='\033[32m'
WARN='\033[33m'

CUR_DIR=$(dirname "$0")

show_menu() {
	echo "---------------------"	
	echo "* * * * TASKS * * * *"
	echo "---------------------"
	echo "1. 🪐 kubectl config"
	echo "2. 🌡  TODO"
	echo -e "${WARN}3. 🌙 Exit${STD}\n"
}

read_option(){
	local CHOICE
    read -p "Enter choice [1 - 3]: " CHOICE
	case $CHOICE in
		1) . "$CUR_DIR/switch-context.sh" ;;
		2) echo "Under construction" ;;
		3) exit 0 ;;
		*) echo -e "${ERR}Wrong input...${STD}" && sleep 2
	esac
}

# MAIN PROCESS
clear
while : ; do
    show_menu
    read_option
done