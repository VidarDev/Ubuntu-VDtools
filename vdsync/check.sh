check() {
    scriptInformations

    #
    printf "\n$c4# ============================== #$c0 \n\n"

    read -s -p "SSH server password : " SSH_PASS
    printf "\n"
    read -s -p "SQL password from server : " SSH_BD_PASS

    printf "\n\n$c4# ============================== #$c0 \n"

    stepCounter reset 4
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

    stepCounter

    # Has the gzip package been installed
    printf "%s/%s. Has the gzip package been installed ? $progress" "$cur_step" "$tot_step"
    if command -v gzip >/dev/null 2>&1; then
        printf "\r%s/%s. Has the gzip package been installed ? $success" "$cur_step" "$tot_step"
    else
        printf "\r%s/%s. Has the gzip package been installed ? $error" "$cur_step" "$tot_step" >&2
        printf "\n[$c3 Please install the$c4 gzip${c3} package :$c1 sudo apt install gzip $c0] \n"
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
        printf "%s.5/%s. Create dumps/$projet_name directory $progress" "$cur_step" "$tot_step"
        mkdir $DIR_HOME/dumps/$projet_name >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            printf "\r%s.5/%s. Create dumps/$projet_name directory $success" "$cur_step" "$tot_step"
        else
            printf "\r%s.5/%s. Create dumps/$projet_name directory $error" "$cur_step" "$tot_step" >&2
            exit 1
        fi
    fi

    stepCounter

    # Check that the projet directory exists and not empty
    printf "%s/%s. Check that the projet directory exists and not empty $progress" "$cur_step" "$tot_step"
    if [ -d "$DIR_PROJET" ] && [ -z "$(find $DIR_PROJET -maxdepth 0 -empty)" ]; then
        printf "\r%s/%s. Check that the projet directory exists and not empty $success" "$cur_step" "$tot_step"
    else
        printf "\r%s/%s. Check that the projet directory exists and not empty $error" "$cur_step" "$tot_step" >&2
    fi

    stepCounter

    # Check that the project's images directory exists and is not empty
    printf "%s/%s. Check that the project's images directory exists and is not empty $progress" "$cur_step" "$tot_step"
    if [ -d "$DIR_IMG" ] && [ -z "$(find $DIR_IMG -maxdepth 0 -empty)" ]; then
        printf "\r%s/%s. Check that the project's images directory exists and is not empty $success" "$cur_step" "$tot_step"
    else
        printf "\r%s/%s. Check that the project's images directory exists and is not empty $error" "$cur_step" "$tot_step" >&2
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

    printf "%s/%s. Check remote server SSH connection $progress" "$cur_step" "$tot_step"
    if $SSH_CONNECTION >/dev/null 2>&1; then
        printf "\r%s/%s. Check remote server SSH connection $success" "$cur_step" "$tot_step"
    else
        printf "\r%s/%s. Check remote server SSH connection $error" "$cur_step" "$tot_step" >&2
        #exit 1
    fi

    stepCounter

    # Check that the projet directory exists and not empty
    printf "%s/%s. Check that the projet directory exists and not empty $progress" "$cur_step" "$tot_step"
    if $SSH_CONNECTION >/dev/null 2>&1 "[ -d \"$SSH_DIR_PROJET\" ]"; then
        if $SSH_CONNECTION >/dev/null 2>&1 "[ -z \"$(ls -A $SSH_DIR_PROJET)\" ]"; then
            printf "\r%s/%s. Check that the projet directory exists and not empty $success" "$cur_step" "$tot_step"
        else
            printf "\r%s/%s. Check that the projet directory exists and not empty $error" "$cur_step" "$tot_step"
        fi
    else
        printf "\r%s/%s. Check that the projet directory exists and not empty $error" "$cur_step" "$tot_step"
    fi

    stepCounter

    # Check that the project's images directory exists and is not empty
    printf "%s/%s. Check that the project's images directory exists and is not empty $progress" "$cur_step" "$tot_step"
    if $SSH_CONNECTION >/dev/null 2>&1 "[ -d \"$SSH_DIR_IMG\" ]"; then
        if $SSH_CONNECTION >/dev/null 2>&1 "[ -z \"$(ls -A $SSH_DIR_IMG)\" ]"; then
            printf "\r%s/%s. Check that the project's images directory exists and is not empty $success" "$cur_step" "$tot_step"
        else
            printf "\r%s/%s. Check that the project's images directory exists and is not empty $error" "$cur_step" "$tot_step"
        fi
    else
        printf "\r%s/%s. Check that the project's images directory exists and is not empty $error" "$cur_step" "$tot_step"
    fi

    stepCounter

    printf "%s/%s. Check remote server SQL connection $progress" "$cur_step" "$tot_step"
    if $SSH_SQL_CONNECTION >/dev/null 2>&1; then
        printf "\r%s/%s. Check remote server SQL connection $success" "$cur_step" "$tot_step"
    else
        printf "\r%s/%s. Check remote server SQL connection $error" "$cur_step" "$tot_step" >&2
        #exit 1
    fi
}
