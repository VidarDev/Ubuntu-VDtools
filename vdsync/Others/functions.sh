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