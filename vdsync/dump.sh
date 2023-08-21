dump() {
    dd=$(date +"%d")
    mm=$(date +"%m")
    yyyy=$(date +"%Y")
    FILE_DUMP="dump_database_${dd}_${mm}_${yyyy}.sql.gz"

    # SSH connection to dump the database
    printf "%s/%s. SSH connection to dump the database $progress" "$cur_step" "$tot_step"
    ssh -p $SSH_PORT $SSH_USER@$SSH_HOST "mysqldump -u $SSH_BD_USER -p$SSH_BD_PASS $SSH_BD_NAME | gzip -9 > $FILE_DUMP" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        printf "\r%s/%s. SSH connection to dump the database $success" "$cur_step" "$tot_step"
    else
        printf "\r%s/%s. SSH connection to dump the database $error" "$cur_step" "$tot_step" >&2
        exit 1
    fi

    # Download the dump locally
    printf "%s/%s. Download the dump locally $progress" "$cur_step" "$tot_step"
    scp -P $SSH_PORT $SSH_USER@$SSH_HOST:$FILE_DUMP $DIR_HOME/dumps/$projet_name/$FILE_DUMP >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        printf "\r%s/%s. Download the dump locally $success" "$cur_step" "$tot_step"
    else
        printf "\r%s/%s. Download the dump locally $error" "$cur_step" "$tot_step" >&2
        exit 1
    fi

    # Deleting the dump on the remote server
    printf "%s/%s. Deleting the dump on the remote server $progress" "$cur_step" "$tot_step"
    ssh -p $SSH_PORT $SSH_USER@$SSH_HOST "rm $FILE_DUMP" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        printf "\r%s/%s. Deleting the dump on the remote server $success" "$cur_step" "$tot_step"
    else
        printf "\r%s/%s. Deleting the dump on the remote server $error" "$cur_step" "$tot_step" >&2
        exit 1
    fi

    # Check that compressed SQL files do not exist
    printf "%s/%s. Check that compressed SQL files do not exist $progress" "$cur_step" "$tot_step"
    if ! ls "$DIR_DUMP"/*.sql >/dev/null 2>&1; then
        printf "\r%s/%s. Check that compressed SQL files do not exist $success" "$cur_step" "$tot_step"
    else
        printf "\r%s/%s. Check that compressed SQL files do not exist $error" "$cur_step" "$tot_step"

        # Deleting existing unpacked SQL files
        printf "%s.5/%s. Deleting existing unpacked SQL files $progress" "$cur_step" "$tot_step"
        find $DIR_HOME/dumps/$projet_name -type f -name "*.sql" -exec rm {} + >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            printf "\r%s%s.5/%s. Deleting existing unpacked SQL files $success" "$cur_step" "$tot_step"
        else
            printf "\r%s%s.5/%s. Deleting existing unpacked SQL files $error" "$cur_step" "$tot_step" >&2
            exit 1
        fi
    fi

    # Check that compressed SQL files do not exist
    printf "%s/%s. Check that compressed SQL files do not exist $progress" "$cur_step" "$tot_step"
    if [ ! "$(ls -1 "$DIR_DUMP"/*.sql.gz 2>/dev/null | wc -l)" -gt 3 ]; then
        printf "\r%s/%s. Check that compressed SQL files do not exist $success" "$cur_step" "$tot_step"
    else
        printf "\r%s/%s. Check that compressed SQL files do not exist $error" "$cur_step" "$tot_step"

        # Keep only the 3 most recent compressed dumps
        printf "%s/%s. Keep only the 3 most recent compressed dumps $progress" "$cur_step" "$tot_step"
        (cd $DIR_HOME/dumps/$projet_name && ls -t | grep ".sql.gz" | tail -n +4 | xargs rm -f) >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            printf "\r%s/%s. Keep only the 3 most recent compressed dumps $success" "$cur_step" "$tot_step"
        else
            printf "\r%s/%s. Keep only the 3 most recent compressed dumps $error" "$cur_step" "$tot_step" >&2
            exit 1
        fi
    fi

    # Decompressing the downloaded compressed dump
    printf "%s/%s. Decompressing the downloaded compressed dump $progress" "$cur_step" "$tot_step"
    gunzip $DIR_HOME/dumps/$projet_name/$FILE_DUMP >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        printf "\r%s/%s. Decompressing the downloaded compressed dump $success" "$cur_step" "$tot_step"
    else
        printf "\r%s/%s. Decompressing the downloaded compressed dump $error" "$cur_step" "$tot_step" >&2
        exit 1
    fi
}
