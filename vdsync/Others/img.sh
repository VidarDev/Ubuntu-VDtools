img() {

    # Sync images from server to local
    printf "%s/%s. Sync images from server to local $progress" "$cur_step" "$tot_step"
    rsync -chavzP -e 'ssh -p $SSH_PORT' $SSH_USER@$SSH_HOST:$SSH_DIR_IMG $DIR_IMG >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        printf "\r%s/%s. Sync images from server to local $success" "$cur_step" "$tot_step"
    else
        printf "\r%s/%s. Sync images from server to local $error" "$cur_step" "$tot_step" >&2
        exit 1
    fi
}
