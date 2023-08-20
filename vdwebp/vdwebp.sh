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

# --------------- Functions --------------- #
# script Informations
scriptInformations() {

    printf "\nScript directory: $c4%s$c0 \n" "$DIR_SCRIPT"
    printf "SQL conf: $c4%s$c0 \n" "$SQL_CONF"
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

            printf "\n[$c3 stepCounter: Argument 1 is not sting 'reset' and/or argument 2 is not a number $c0] \n" >&2
            exit 1
        fi
    else

        ((cur_step++))
    fi
}

# Step Counter
#
#   @param string -e
#   @param string
mysqlConnection() {

    local command="$1"
    local query="$2"

    # Check if $query is not empty
    if [ -n "$query" ] && [ "$command" = "-e" ]; then

        printf "%s/%s. Run the sql command $progress" "$cur_step" "$tot_step"
        mysql --host=$DB_HOST --user=$DB_USER --password=$DB_PASS $DB_NAME -e $query
        if [ $? -eq 0 ]; then
            printf "\r%s/%s. Run the sql command $success" "$cur_step" "$tot_step"
        else
            printf "\r%s/%s. Run the sql command $error" "$cur_step" "$tot_step"
        fi
    else

        mysql --host=$DB_HOST --user=$DB_USER --password=$DB_PASS $DB_NAME # For check connection
    fi
}

# Convert your images in webp images
#
#   @param string
webpConverter() {

    local image="$1"
    local image_dir=$(dirname "$image")
    local image_name=$(basename "$image")
    local image_name_without_extension=${image_name%.*}

    # Check if $image exist and is not empty
    if [ -n "$image" ] && [ -e "$image" ]; then

        cwebp -lossless -exact $image -o $image_dir/$image_name_without_extension.webp
        if [ ! $? -eq 0 ]; then
            printf "\n[$c3 webpConverter: Error fi$c1 %s $c0] \n" "$image" >&2
            exit 1
        fi
    else

        printf "\n[$c3 webpConverter: Argument does not exist or is not empty :$c1 %s $c0] \n" "$image" >&2
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

    printf "\nOptions: \n"
    printf "       --sql                       Specify projet name \n"

    exit 1
elif [ -d "$(realpath "$1")" ] || [ -e "$(realpath "$1")" ]; then

    argument=$(realpath "$1")

    scriptInformations

    stepCounter reset 2
    printf "\nCheck that the required package been installed \n"

    # Has the cwebp package been installed
    printf "%s/%s. Has the sed cwebp package been installed ? $progress" "$cur_step" "$tot_step"
    if command -v cwebp >/dev/null 2>&1; then
        printf "\r%s/%s. Has the sed cwebp package been installed ? $success" "$cur_step" "$tot_step"
    else
        printf "\r%s/%s. Has the sed cwebp package been installed ? $error" "$cur_step" "$tot_step" >&2
        printf "\n[$c3 Please install the$c4 cwebp${c3} package $c3:$c1 sudo apt install webp $c0] \n"
        exit 1
    fi

    stepCounter

    # Has the sed package been installed
    printf "%s/%s. Has the sed package been installed ? $progress" "$cur_step" "$tot_step"
    if command -v sed >/dev/null 2>&1; then
        printf "\r%s/%s. Has the sed package been installed ? $success" "$cur_step" "$tot_step"
    else
        printf "\r%s/%s. Has the sed package been installed ? $error" "$cur_step" "$tot_step" >&2
        printf "\n[$c3 Please install the$c4 sed${c3} package :$c1 sudo apt install sed $c0] \n"
        exit
    fi

    # Check the script arguments
    for ((i = 1; i <= $#; i++)); do

        # ${i} = 2 and ${!i} = --sql

        # Check if script argument is "--sql"
        if [ "${!i}" == "--sql" ]; then

            # Increment variable i to get the next argument
            ((i++))
            # Check the script argument after "--sql"
            if [ "$i" -le "$#" ]; then
                sql_value=$(echo "${!i}" | tr '[:upper:]' '[:lower:]')

                stepCounter reset 1
                printf "\nCheck if the required %s project configuration exists \n" "$sql_value"

                # Check if the project configuration exists
                printf "%s/%s. Check if the %s project configuration exists $progress" "$cur_step" "$tot_step" "$sql_value"
                source "$DIR_CONF/conf/$sql_value.conf" >/dev/null 2>&1
                if [ $? -eq 0 ]; then
                    printf "\r%s/%s. Check if the %s project configuration exists $success" "$cur_step" "$tot_step" "$sql_value"

                    printf "\nCheck projet name and sql local informations \n"

                    printf "PROJET_NAME : $c4%s$c0\n" "$PROJET_NAME"
                    printf "DB_HOST : $c4%s$c0\n" "$DB_HOST"
                    printf "DB_NAME : $c4%s$c0\n" "$DB_NAME"
                    printf "DB_USER : $c4%s$c0\n" "$DB_USER"
                    printf "DB_PASS : $c4%s$c0\n" "$DB_PASS"
                    printf "DB_PREFIX : $c4%s$c0\n" "$DB_PREFIX"

                    stepCounter reset 1
                    printf "\nCheck sql connection\n"

                    printf "%s/%s. Check sql connection $progress" "$cur_step" "$tot_step"
                    mysqlConnection >/dev/null 2>&1
                    if [ $? -eq 0 ]; then
                        printf "\r%s/%s. Check sql connection $success" "$cur_step" "$tot_step"
                    else
                        printf "\r%s/%s. Check sql connection $error" "$cur_step" "$tot_step" >&2
                        #exit 1
                    fi
                else

                    printf "\r%s/%s. Check if the %s project configuration exists $error" "$cur_step" "$tot_step" "$sql_value" >&2
                    printf "\n[$c3 Please, create the %s.conf project configuration in :$c1 $DIR_SCRIPT/conf/ $c0] \n" "$sql_value"
                    exit
                fi
            else
                printf "\n[$c3 Error  : --sql requires a next value. $c0] \n"
                exit 1
            fi
        fi
    done

    if [ -d "$argument" ]; then
        printf "\nDirectory : $c4%s$c0 \n\n" "$argument"

        # List all .svg files
        find "$argument" -type f \( -iname \*.jpeg -o -iname \*.jpg -o -iname \*.png -o -iname \*.tiff -o -iname \*.webp \) | while read -r file; do
            printf "SVG file : $c4%s$c0 \n" "$file"
        done

        if [[ "$@" =~ "--sql" ]]; then
            # Convert your images in webp images
            find "$argument" -type f \( -iname \*.jpeg -o -iname \*.jpg -o -iname \*.png -o -iname \*.tiff -o -iname \*.webp \) | while read -r file; do
                local file_name=$(basename "$file")
                local file_name_without_extension=${file_name%.*}

                webpConverter $file
                rm $file

                local TABLES=$(mysql --host=$DB_HOST --user=$DB_USER --password=$DB_PASS $DB_NAME -e "SHOW TABLES;" | awk 'NR > 1')
                for TABLE in $TABLES; do
                    local QUERY="SELECT $(VALUE), REGEXP_REPLACE($(VALUE),'$file_name','$file_name_without_extension.webp') AS 'REPLACE' FROM $TABLE WHERE $(VALUE) REGEXP '$file_name';"

                    # Exécuter la requête
                    mysqlConnection -e "$QUERY"
                done

            done
        else
            # Convert your images in webp images
            find "$argument" -type f \( -iname \*.jpeg -o -iname \*.jpg -o -iname \*.png -o -iname \*.tiff -o -iname \*.webp \) | while read -r file; do
                webpConverter $file
                rm $file
            done
        fi

        endSuccessfully

    elif [ -e "$argument" ]; then
        printf "\nSVG file : $c4%s$c0 \n" "$argument"

        if [[ "$@" =~ "--sql" ]]; then
            local file_name=$(basename "$file")
            local file_name_without_extension=${file_name%.*}

            webpConverter $argument
            rm $argument

            local TABLES=$(mysql --host=$DB_HOST --user=$DB_USER --password=$DB_PASS $DB_NAME -e "SHOW TABLES;" | awk 'NR > 1')
            for TABLE in $TABLES; do
                local QUERY="SELECT $(VALUE), REGEXP_REPLACE($(VALUE),'$file_name','$file_name_without_extension.webp') AS 'REPLACE' FROM $TABLE WHERE $(VALUE) REGEXP '$file_name';"

                # Exécuter la requête
                mysqlConnection -e "$QUERY"
            done
        else
            webpConverter $argument
            rm $argument
        fi

        endSuccessfully
    fi

else

    printf "\n[$c3 Argument provided is invalid, check options with :$c4 --help $c0] \n"
    exit 1
fi
