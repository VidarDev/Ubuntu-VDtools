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
# File name : install.sh
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

# --------------- Main --------------- #
#check if there are no parameters provided to a command ?
if [ ! $# -eq 0 ]; then
    printf "\n[\033[0;31m This script does not need any arguments. \033[0m] \n" >&2
    exit 1
fi

stepCounter reset 2
printf "\nInstalling linux commands \n"

# Installing vdsvgo command
printf "%s/%s. Installing vdsvgo command $progress" "$cur_step" "$tot_step"
sudo ln -s $DIR_SCRIPT/vdsvgo/vdsvgo.sh /usr/bin/vdsvgo >/dev/null 2>&1
if [ $? -eq 0 ]; then
    printf "\r%s/%s. Installing vdsvgo command $success" "$cur_step" "$tot_step"
else
    printf "\r%s/%s. Installing vdsvgo command $error" "$cur_step" "$tot_step" >&2
    exit 1
fi

# Installing vdwebp command
printf "%s/%s. Installing vdwebp command $progress" "$cur_step" "$tot_step"
sudo ln -s $DIR_SCRIPT/vdwebp/vdwebp.sh /usr/bin/vdwebp >/dev/null 2>&1
if [ $? -eq 0 ]; then
    printf "\r%s/%s. Installing vdwebp command $success" "$cur_step" "$tot_step"
else
    printf "\r%s/%s. Installing vdwebp command $error" "$cur_step" "$tot_step" >&2
    exit 1
fi

printf "\n[$c2 End of script successfully $c0] \n"
