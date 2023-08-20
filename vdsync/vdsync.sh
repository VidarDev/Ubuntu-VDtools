#!/bin/bash

#  __      ___     _            _____
#  \ \    / (_)   | |          |  __ \
#   \ \  / / _  __| | __ _ _ __| |  | | _____   __
#    \ \/ / | |/ _` |/ _` | '__| |  | |/ _ \ \ / /
#     \  /  | | (_| | (_| | |  | |__| |  __/\ V /
#      \/   |_|\__,_|\__,_|_|  |_____/ \___| \_/
#
#                V1.0 - GNU GENERAL PUBLIC LICENSE
#
# File name : vdwebp.sh
# Author : VidarDev
# Created Date : 16/08/2023
# Description :
#
# =======================================================================

# --------------- Not in Sudo --------------- #
# Check that the script is not started as root (Super Administrator)
if [ "$USER" = "root" ]; then
    printf "\n[\033[0;31m This script cannot be run as root. \033[0m] \n" >&2
    exit 1
fi

# Check that the script is not started as shell
if [ -z "$BASH" ]; then
    printf "\n[\033[0;31m This script is meant to be run with Bash, not sh. \033[0m] \n" >&2
    exit 1
fi

# --------------- Variables --------------- #
# colors
c1='\033[0;37m' # White
c2='\033[0;32m' # Green
c3='\033[0;31m' # Red
c4='\033[0;36m' # Cyan
c0='\033[0m'    # Color reset

# status
success='[\033[0;32mSuccess\033[0m] \n'
error='[\033[0;31mFailed\033[0m] \n'
progress='[\033[0;37m...\033[0m]'
optional='[\033[0;36mOptional\033[0m]'

# environment
DIR_SCRIPT=$(dirname $(readlink -f $0 2>/dev/null || perl -MCwd=realpath -e "print realpath '$0'"))
DIR_HOME=$HOME
SQL_CONF=$(dirname $DIR_SCRIPT)/sql.conf
DIR_CONF=$(dirname $DIR_SCRIPT)

source "$SQL_CONF"

# MYSQL variables
SQL_CONNECTION="mysql --host=$LOCAL_BD_HOST --user=$LOCAL_BD_USER --password=$LOCAL_BD_PASS $LOCAL_BD_NAME"

# SERVER variables
SSH_CONNECTION="ssh \"$SSH_USER\"@\"$SSH_HOST\" -p \"$SSH_PORT\""
SSH_SQL_CONNECTION="mysql --host=$BD_HOST --user=$BD_USER --password=$BD_PASS $BD_NAME"

# --------------- Functions --------------- #
# script Informations
scriptInformations() {

    printf "\nScript directory: $c4%s$c0 \n" "$DIR_SCRIPT"
    printf "SQL conf: $c4%s$c0 \n" "$SQL_CONF"
    printf "User HOME: $c4%s$c0 \n" "$DIR_HOME"
}

# Check projet conf
#
#   @param string -e
#   @param string
checkProjetConfiguration() {

    local projet_conf="$1"

    # Check if $projet_conf is not empty
    if [ -n "$projet_conf" ]; then
        # Check if the project configuration exists
        printf "%s/%s. Check if the %s project configuration exists $progress" "$cur_step" "$tot_step" "$projet_conf"
        source "$DIR_CONF/conf/$projet_conf.conf" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            printf "\r%s/%s. Check if the %s project configuration exists $success" "$cur_step" "$tot_step" "$projet_conf"
        else

            printf "\r%s/%s. Check if the %s project configuration exists $error" "$cur_step" "$tot_step" "$projet_conf" >&2
            printf "\n[$c3 Please, create the %s.conf project configuration in :$c1 $DIR_SCRIPT/conf/ $c0] \n" "$projet_conf"
            exit
        fi
    else
        printf "\n[$c3 checkProjetConfiguration: Argument 1 is empty $c0] \n" >&2
        exit 1
    fi
}

# Step Counter
#
#   @param string
#   @param number
cur_step=0 # global variable
tot_step=0 # global variable

stepCounter() {

    local stepString="$1"
    local stepNumber="$2"

    # Check if $stepString and $stepNumber are not empty
    if [ -n "$stepString" ] && [ -n "$stepNumber" ]; then

        # Check if $stepString is a string and $stepNumber is a number
        if [ "$stepString" = "reset" ] && [[ "$stepNumber" =~ ^[0-9]+$ ]]; then

            cur_step=1
            tot_step=$stepNumber
        else

            printf "\n[$c3 stepCounter: Argument 1 is not string 'reset' and/or argument 2 is not a number $c0] \n" >&2
            exit 1
        fi
    else

        ((cur_step++))
    fi
}

# Check mysql Connection
#
#   @param string -e
#   @param string
localMySqlCommand() {

    local query="$1"

    # Check if $query is not empty
    if [ -n "$query" ]; then

        printf "%s/%s. Run the SQL command $progress" "$cur_step" "$tot_step"
        mysql --host=$LOCAL_BD_HOST --user=$LOCAL_BD_USER --password=$LOCAL_BD_PASS $LOCAL_BD_NAME -e $query
        if [ $? -eq 0 ]; then
            printf "\r%s/%s. Run the SQL command $success" "$cur_step" "$tot_step"
        else
            printf "\r%s/%s. Run the SQL command $error" "$cur_step" "$tot_step"
        fi
    else
        printf "\n[$c3 localMySqlCommand: Argument 1 is empty $c0] \n" >&2
        exit 1
    fi
}

endSuccessfully() {

    printf "\n[$c2 End of script successfully $c0] \n"
}

# --------------- Sources --------------- #
source "$DIR_SCRIPT/check.sh"
source "$DIR_SCRIPT/dump.sh"
source "$DIR_SCRIPT/img.sh"

# --------------- Main --------------- #
# Check if "--help" is not in arguments
if [[ "$@" =~ "--help" ]] || [[ "$@" =~ "-h" ]]; then

    printf "\nMandatory arguments to long options are mandatory for short options too. \n"

    printf "\nStartup: \n"
    printf "  -h,  --help                      print this help \n"
    printf "       --check                     Specify [PROJET NAME], check all script variables \n"
    printf "       --sql                       Specify [PROJET NAME], get a dump from the PROD server \n"
    printf "       --img                       Specify [PROJET NAME], Sync images from PROD server to LOCAL \n"
    printf "       --all                       Specify [PROJET NAME], --img and --sql \n"

    exit 1
elif [[ "$@" =~ "--check" ]] || [[ "$@" =~ "--all" ]] || [[ "$@" =~ "--sql" ]] || [[ "$@" =~ "--img" ]]; then

    scriptInformations

    #
    printf "\n$c4# ============================== #$c0 \n\n"

    read -s -p "SSH server password : " SSH_PASS
    printf "\n"
    read -s -p "SQL password from server : " SSH_BD_PASS

    printf "\n\n$c4# ============================== #$c0 \n"

    stepCounter reset 3
    printf "\nCheck that the required package been installed \n"

    # Has the ssh package been installed
    printf "%s/%s. Has the ssh package been installed ? $progress" "$cur_step" "$tot_step"
    if command -v ssh >/dev/null 2>&1; then
        printf "\r%s/%s. Has the ssh package been installed ? $success" "$cur_step" "$tot_step"
    else
        printf "\r%s/%s. Has the ssh package been installed ? $error" "$cur_step" "$tot_step" >&2
        printf "\n[$c3 Please install the$c4 ssh${c3} package $c3:$c1 sudo apt install ssh $c0] \n"
        exit 1
    fi

    stepCounter
    # Has the rsync package been installed
    printf "%s/%s. Has the rsync package been installed ? $progress" "$cur_step" "$tot_step"
    if command -v rsync >/dev/null 2>&1; then
        printf "\r%s/%s. Has the rsync package been installed ? $success" "$cur_step" "$tot_step"
    else
        printf "\r%s/%s. Has the rsync package been installed ? $error" "$cur_step" "$tot_step" >&2
        printf "\n[$c3 Please install the$c4 rsync${c3} package $c3:$c1 sudo apt install rsync $c0] \n"
        exit 1
    fi

    stepCounter

    # Has the grep package been installed
    printf "%s/%s. Has the grep package been installed ? $progress" "$cur_step" "$tot_step"
    if command -v grep >/dev/null 2>&1; then
        printf "\r%s/%s. Has the grep package been installed ? $success" "$cur_step" "$tot_step"
    else
        printf "\r%s/%s. Has the grep package been installed ? $error" "$cur_step" "$tot_step" >&2
        printf "\n[$c3 Please install the$c4 grep${c3} package :$c1 sudo apt install grep $c0] \n"
        exit 1
    fi

    stepCounter reset 6
    printf "\nCheck all ${c4}local${c0} elements of the script \n"

    # Check the script arguments
    for ((i = 1; i <= $#; i++)); do

        # ${i} = 2 and ${!i} = --sql

        # Check if script argument is "--sql"
        if [ "${!i}" == "--check" ] || [ "${!i}" == "--all" ] || [ "${!i}" == "--sql" ] || [ "${!i}" == "--img" ]; then

            # Increment variable i to get the next argument
            ((i++))
            # Check the script argument after "--sql"
            if [ "$i" -le "$#" ]; then
                projet_name=$(echo "${!i}" | tr '[:upper:]' '[:lower:]')

                checkProjetConfiguration $projet_name
            else
                ((i--))
                printf "\n[$c3 Error  : ${!i} requires a next value. $c0] \n"
                exit 1
            fi
        fi
    done

    stepCounter

    # Check that the $DIR_HOME/dumps directory exists
    printf "%s/%s. Check that the $DIR_HOME/dumps directory exists $optional $progress" "$cur_step" "$tot_step"
    if [ -d "$DIR_HOME/dumps" ]; then
        printf "\r%s/%s. Check that the $DIR_HOME/dumps directory exists $optional $success" "$cur_step" "$tot_step"
    else
        printf "\r%s/%s. Check that the $DIR_HOME/dumps directory exists $optional $error" "$cur_step" "$tot_step"

        # Create dumps directory
        printf "%s.5/%s. Create dumps directory $progress" "$cur_step" "$tot_step"
        mkdir $DIR_HOME/dumps >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            printf "\r%s.5/%s. Create dumps directory $success" "$cur_step" "$tot_step"
        else
            printf "\r%s.5/%s. Create dumps directory $error" "$cur_step" "$tot_step" >&2
            exit 1
        fi
    fi

    stepCounter

    # Check that the $DIR_HOME/dumps/$projet_name directory exists
    printf "%s/%s. Check that the $DIR_HOME/dumps/$projet_name directory exists $optional $progress" "$cur_step" "$tot_step"
    if [ -d "$DIR_HOME/dumps/$projet_name" ]; then
        printf "\r%s/%s. Check that the $DIR_HOME/dumps/$projet_name directory exists $optional $success" "$cur_step" "$tot_step"
    else
        printf "\r%s/%s. Check that the $DIR_HOME/dumps/$projet_name directory exists $optional $error" "$cur_step" "$tot_step"

        # Create dumps directory
        printf "%s.5/%s. Create dumps directory $progress" "$cur_step" "$tot_step"
        mkdir $DIR_HOME/dumps/$projet_name >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            printf "\r%s.5/%s. Create dumps/$projet_name directory $success" "$cur_step" "$tot_step"
        else
            printf "\r%s.5/%s. Create dumps/$projet_name directory $error" "$cur_step" "$tot_step" >&2
            exit 1
        fi
    fi

    stepCounter

    echo "$DIR_PROJET"
    # Check that the projet directory exists and not empty
    printf "%s/%s. Check that the projet directory exists and not empty $progress" "$cur_step" "$tot_step"
    if [ -d "$DIR_PROJET" ] && [ -n "$(find $DIR_PROJET -maxdepth 0 -empty)" ]; then
        printf "\r%s/%s. Check that the projet directory exists and not empty $success" "$cur_step" "$tot_step"
    else
        printf "\r%s/%s. Check that the projet directory exists and not empty $error" "$cur_step" "$tot_step"
    fi

    stepCounter

    echo "$DIR_IMG"
    # Check that the project's images directory exists and is not empty
    printf "%s/%s. Check that the project's images directory exists and is not empty $progress" "$cur_step" "$tot_step"
    if [ -d "$DIR_IMG" ] && [ -n "$(find $DIR_IMG -maxdepth 0 -empty)" ]; then
        printf "\r%s/%s. Check that the project's images directory exists and is not empty $success" "$cur_step" "$tot_step"
    else
        printf "\r%s/%s. Check that the project's images directory exists and is not empty $error" "$cur_step" "$tot_step"
    fi

    stepCounter

    printf "%s/%s. Check local SQL connection $progress" "$cur_step" "$tot_step"
    if $SQL_CONNECTION; then
        printf "\r%s/%s. Check local SQL connection $success" "$cur_step" "$tot_step"
    else
        printf "\r%s/%s. Check local SQL connection $error" "$cur_step" "$tot_step" >&2
        #exit 1
    fi

    stepCounter reset 4
    printf "\nCheck all ${c4}server${c0} elements of the script \n"

    # printf "%s/%s. Check remote server SSH connection $progress" "$cur_step" "$tot_step"
    # if $SSH_CONNECTION; then
    #     printf "\r%s/%s. Check remote server SSH connection $success" "$cur_step" "$tot_step"
    # else
    #     printf "\r%s/%s. Check remote server SSH connection $error" "$cur_step" "$tot_step" >&2
    #     #exit 1
    # fi

    # stepCounter

    # # Check that the projet directory exists and not empty
    # printf "%s/%s. Check that the projet directory exists and not empty $progress" "$cur_step" "$tot_step"
    # if $SSH_SQL_CONNECTION "[ -d \"$SSH_DIR_PROJET\" ]"; then
    #     if $SSH_SQL_CONNECTION "[ -n \"$(ls -A $SSH_DIR_PROJET)\" ]"; then
    #         printf "\r%s/%s. Check that the projet directory exists and not empty $success" "$cur_step" "$tot_step"
    #     else
    #         printf "\r%s/%s. Check that the projet directory exists and not empty $error" "$cur_step" "$tot_step"
    #     fi
    # else
    #     printf "\r%s/%s. Check that the projet directory exists and not empty $error" "$cur_step" "$tot_step"
    # fi

    # stepCounter

    # # Check that the project's images directory exists and is not empty
    # printf "%s/%s. Check that the project's images directory exists and is not empty $progress" "$cur_step" "$tot_step"
    # if $SSH_SQL_CONNECTION "[ -d \"$SSH_DIR_IMG\" ]"; then
    #     if $SSH_SQL_CONNECTION "[ -n \"$(ls -A $SSH_DIR_IMG)\" ]"; then
    #         printf "\r%s/%s. Check that the project's images directory exists and is not empty $success" "$cur_step" "$tot_step"
    #     else
    #         printf "\r%s/%s. Check that the project's images directory exists and is not empty $error" "$cur_step" "$tot_step"
    #     fi
    # else
    #     printf "\r%s/%s. Check that the project's images directory exists and is not empty $error" "$cur_step" "$tot_step"
    # fi

    # stepCounter

    # printf "%s/%s. Check remote server SQL connection $progress" "$cur_step" "$tot_step"
    # if $SSH_SQL_CONNECTION; then
    #     printf "\r%s/%s. Check remote server SQL connection $success" "$cur_step" "$tot_step"
    # else
    #     printf "\r%s/%s. Check remote server SQL connection $error" "$cur_step" "$tot_step" >&2
    #     #exit 1
    # fi

    endSuccessfully

else

    printf "\n[$c3 Argument provided is invalid, check options with :$c4 --help $c0] \n"
    exit 1
fi
