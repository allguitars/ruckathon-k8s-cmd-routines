#!/bin/bash

# 腳本目的：
# 1. 列出所有 context
# 2. 告知目前位於哪個 context
# 3. 提供所有 context names 問是否要 switch，最後一個選項是不 switch。

# ANSI Color
STD='\033[0m'
ERR='\033[0;41;30m'
CURR='\033[36m'
INFO='\033[1;34m'
PMPT='\033[1;32m'
WARN='\033[33m'

CMD_GET_CONTEXTS="kubectl config get-contexts"
CMD_GET_NAMESPACES="kubectl get namespace"

LOG_FOLDER="$HOME/logs"
CONTEXTS_PATH="$LOG_FOLDER/contexts.txt"
NAMESPACES_PATH="$LOG_FOLDER/namespaces.txt"

# If the log folder does not exist, create one.
[ ! -d "$LOG_FOLDER" ] && mkdir $LOG_FOLDER

test_number() {
    low=$1
    high=$2
    # Keep looping until it's a number and in range
    while : ; do
        # a number?
        if [[ $CHOICE =~ ^[0-9]+$ ]]; then
            # number in range?
            if [ $CHOICE -lt $1 ] || [ $CHOICE -gt $2 ]; then
                read -p "Out of range. Input again> " CHOICE
            else break
            fi
        else read -p "Please input a number> " CHOICE
        fi
    done
}

show_contexts() {
    # 列出所有 context 並存到檔案
    eval $CMD_GET_CONTEXTS > "$CONTEXTS_PATH"

    {
        read LINE
        echo "$LINE"
        while read LINE; do
            if [ -z "${LINE##*\**}" ]; then                 # If this line contains "\*" (escaped)
                echo -e "${CURR}$LINE${STD}"
            else
                echo -e "          $LINE"
            fi
        done
    } < "$CONTEXTS_PATH"
}

switch_contexts() {
    clear
    show_contexts
    # 取得 current context name 並且把所有 context names 存到一個陣列中
    INDEX=0
    {
        read                                               # skip the first line using a separate process
        while read LINE; do
            if [ -z "${LINE##*\**}" ]; then                    # If this line contains "\*" (escaped)
                CURRENT=$(echo "$LINE" | awk '{print $2}') 
                NAMES[INDEX]=$CURRENT
                CURRENT_INDEX=$(($INDEX+1))
            else
                NAMES[INDEX]=$(echo "$LINE" | awk '{print $1}')
            fi

        ((INDEX++))
        done 
    } < "$CONTEXTS_PATH"

    echo -e
    # 列出context name列表，問要 switch 到哪一個，若不要則按 q
    for ((i=0; i < ${#NAMES[@]}; ++i)); do
        position=$(($i+1))
        if [ ${NAMES[$i]} == $CURRENT ]; then
        echo -e "😽\t${CURR}$position. ${NAMES[$i]}${STD}"
        else
        echo -e "\t$position. ${NAMES[$i]}"
        fi
    done

    # Display other options
    echo -e "\te. Use Current Context"
    echo -e "\t${WARN}q. Quit Program${STD}\n"

    # Read the input
    local CHOICE
    read -p "Which context do you want to use? " CHOICE

    # Current context was chosen
    if [ $CHOICE == $CURRENT_INDEX ]; then
        echo -e "${INFO}Context was not switched. ${STD}🙌\n"
        return
    fi

    # Validate the answer
    while (( $CHOICE < 1 || $CHOICE > ${#NAMES[@]} )); do   # not in range
        if [ $CHOICE == "e" ]; then
            echo -e "${INFO}Context was not switched. ${STD}🙌\n"
            return
        elif [ $CHOICE == "q" ]; then exit 0
        else read -p "Please input a valid option: " CHOICE
        fi
    done

    # Switch to another context
    printf "🎉 🎉 🎉 ${INFO}" && kubectl config use-context ${NAMES[$CHOICE-1]}
    printf "${STD}\n"
}

change_namespace() {
    echo -e "${INFO}Getting namespaces in current cluster...${STD} 🚀"
    eval $CMD_GET_NAMESPACES > "$NAMESPACES_PATH"

    # Read the namespaces from the file into an array
    INDEX=0
    {
        read
        while read LINE; do
            NAMESPACES[INDEX]=$(echo "$LINE" | awk '{print $1}') 
        ((INDEX++))
        done 
    } < "$NAMESPACES_PATH"

    printf "Select one of the following namespaces:\n"
    
    # List the namespaces as a menu
    for ((i=0; i < ${#NAMESPACES[@]}; ++i)); do
        position=$(($i+1))
        printf "$position:\t${NAMESPACES[$i]}\n"
    done
    # Quit option
    printf "${PMPT}e:\tDo Not Change\n${STD}"

    read -p "> " CHOICE
    if [ $CHOICE == "e" ]; then
        echo -e "${INFO}Namespace was not changed.${STD} 🙌\n"
        return
    fi
    # Validates the answer
    test_number 1 ${#NAMESPACES[@]}

    # Set namespace
    kubectl config set-context --current --namespace=${NAMESPACES[$CHOICE-1]}
    printf "\n"
}

show_menu() {
	echo "---------------------"	
	echo "* * * MAIN MENU * * *"
	echo "---------------------"
	echo -e "1. 🚌 Switch Context"
	echo -e "2. 🏠 Set Namespace"
	echo -e "${WARN}3. 🖐  Exit${STD} \n"
}

read_option(){
	local CHOICE
    read -p "[1 - 3]: " CHOICE
	case $CHOICE in
		1) switch_contexts ;;
		2) change_namespace ;;
		3) rm -rf "$LOG_FOLDER" && exit 0 ;;
		*) echo -e "${ERR}Wrong input...${STD}" && sleep 2
	esac
}

# trap '' SIGINT SIGQUIT SIGTSTP

# MAIN PROCESS
clear
while : ; do
    show_contexts
    echo -e
    show_menu
    read_option
done
