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

    check

    img

    endSuccessfully

else

    printf "\n[$c3 Argument provided is invalid, check options with :$c4 --help $c0] \n"
    exit 1
fi
