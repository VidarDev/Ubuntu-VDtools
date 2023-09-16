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

endSuccessfully() {
    printf "\n[$c2 End of script successfully $c0] \n"
}

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
elif [[ -n "$1" ]] && [[ -n "$2" ]] && [[ -n "$3" ]] && [[ -z "$4" ]]; then
    SERVER_NAME=$1
    SSH_DIR_PATH=$2
    LOCAL_DIR_PATH=$3

    scriptInformations
    printf "\nServer SSH: $c4%s$c0 \n" "$SERVER_NAME"
    printf "Server path directory: $c4%s$c0 \n" "$SSH_DIR_PATH"
    printf "Local path directory: $c4%s$c0 \n" "$LOCAL_DIR_PATH"

    stepCounter reset 1
    printf "\nCheck the server SSH connection \n"

    printf "%s/%s. Check the server SSH connection ? $progress" "$cur_step" "$tot_step"
    if ssh $SERVER_NAME; then
        printf "\r%s/%s. Check the server SSH connection ? $success" "$cur_step" "$tot_step"
    else
        printf "\r%s/%s. Check the server SSH connection ? $error" "$cur_step" "$tot_step" >&2
        printf "\n[$c3 Argument provided is invalid, check options with :$c4 --help $c0] \n"
        exit 1
    fi

    stepCounter reset 2
    printf "\nCheck if the paths exist \n"

    printf "%s/%s. Check if the paths exist on the server ? $progress" "$cur_step" "$tot_step"
    if ssh $SERVER_NAME `[ -d $SSH_DIR_PATH ]`; then
        printf "\r%s/%s. Check if the paths exist on the server ? $success" "$cur_step" "$tot_step"
    else
        printf "\r%s/%s. Check if the paths exist on the server ? $error" "$cur_step" "$tot_step" >&2
        printf "\n[$c3 Argument provided is invalid, check options with :$c4 --help $c0] \n"
        exit 1
    fi

    stepCounter

    printf "%s/%s. Check if the paths exist on the local ? $progress" "$cur_step" "$tot_step"
    if [ -d $LOCAL_DIR_PATH ]; then
        printf "\r%s/%s. Check if the paths exist on the local ? $success" "$cur_step" "$tot_step"
    else
        printf "\r%s/%s. Check if the paths exist on the local ? $error" "$cur_step" "$tot_step" >&2
        printf "\n[$c3 Argument provided is invalid, check options with :$c4 --help $c0] \n"
        exit 1
    fi

    rsync -chavzP --exclude='p/*/' $SERVER_NAME:$SSH_DIR_PATH $LOCAL_DIR_PATH

    rsync -chavzP --include='*/' --include='*.'{png,jpg,webp,jpeg,tiff} --exclude='*' $SERVER_NAME:$SSH_DIR_PATH $LOCAL_DIR_PATH

    endSuccessfully
    exit 1
else
    printf "\n[$c3 Argument provided is invalid, check options with :$c4 --help $c0] \n"
    exit 1
fi
