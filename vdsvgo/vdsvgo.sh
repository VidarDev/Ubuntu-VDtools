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
# File name : vdsvgo.sh
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
    printf "User HOME: $c4%s$c0 \n" "$DIR_HOME"
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

# Optimize svg files
#
#   @param string
svgOptimizer() {

    local svg="$1"

    # Check if $svg exist and is not empty
    if [ -n "$svg" ] && [ -e "$svg" ]; then

        svgo $svg -o $svg
        if [ ! $? -eq 0 ]; then
            printf "\n[$c3 svgOptimizer: Error fi$c1 %s $c0] \n" "$svg" >&2
            exit 1
        fi
    else

        printf "\n[$c3 svgOptimizer: Argument does not exist or is not empty :$c1 %s $c0] \n" "$svg" >&2
        exit 1
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
    printf "       path/                       Optimize files recursively against path \n"
    printf "       path/*.svg                  Optimize file \n"

    exit 1
elif [ -d "$(realpath "$1")" ] || [ -e "$(realpath "$1")" ]; then

    argument=$(realpath "$1")

    stepCounter reset 4

    printf "\nCheck that the required package been installed \n"

    # Check that the npm been installed
    printf "%s/%s. Has the NVM been installed ? $progress" "$cur_step" "$tot_step"
    if [ -d "$DIR_HOME/.nvm/.git" ]; then
        printf "\r%s/%s. Has the NVM been installed ? $success" "$cur_step" "$tot_step"
    else
        printf "\r%s/%s. Has the NVM been installed ? $error" "$cur_step" "$tot_step" >&2
        printf "\n[$c3 Please install the ${c4}NVM${c3} package $c0] \n"
        exit 1
    fi

    stepCounter

    # Check that the npm been installed
    printf "%s/%s. Has the npm been installed ? $progress" "$cur_step" "$tot_step"
    if command -v npm >/dev/null 2>&1; then
        printf "\r%s/%s. Has the npm been installed ? $success" "$cur_step" "$tot_step"
    else
        printf "\r%s/%s. Has the npm been installed ? $error" "$cur_step" "$tot_step" >&2
        printf "\n[$c3 Please install the$c4 npm${c3} package $c3:$c1 npm i $c0] \n"
        exit 1
    fi

    stepCounter

    # Check that the SVGO package been installed
    printf "%s/%s. Has the SVGO package been installed ? $progress" "$cur_step" "$tot_step"
    if command -v svgo >/dev/null 2>&1; then
        printf "\r%s/%s. Has the SVGO package been installed ? $success" "$cur_step" "$tot_step"
    else
        printf "\r%s/%s. Has the SVGO package been installed ? $error" "$cur_step" "$tot_step" >&2
        printf "\n[$c3 Please install the$c4 SVGO${c3} package :$c1 npm -g install svgo $c0] \n"
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

    if [ -d "$argument" ]; then
        printf "\nDirectory : $c4%s$c0 \n\n" "$argument"

        # List all .svg files
        find "$argument" -type f -name "*.svg" | while read -r file; do
            printf "SVG file : $c4%s$c0 \n" "$file"
        done

        # Optimize all svg files
        find "$argument" -type f -name "*.svg" | while read -r file; do
            svgOptimizer $file
        done

        endSuccessfully

    elif [ -e "$argument" ]; then
        printf "\nSVG file : $c4%s$c0 \n" "$argument"

        svgOptimizer $argument

        endSuccessfully
    fi

else

    printf "\n[$c3 Argument provided is invalid, check options with :$c4 --help $c0] \n"
    exit 1
fi
