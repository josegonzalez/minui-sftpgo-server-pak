#!/bin/sh
echo "$0" "$@"
progdir="$(dirname "$0")"
cd "$progdir" || exit 1
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$progdir"
echo 1 >/tmp/stay_awake
trap "rm -f /tmp/stay_awake" EXIT INT TERM HUP QUIT
RES_PATH="$progdir/res"

sftpgo_on() {
    cd /mnt/SDCARD/ || exit
    rm -f "$progdir/sftpgo.logs" 2>/dev/null || true
    chmod +x "$progdir/bin/sftpgo"
    (nice -2 "$progdir/bin/sftpgo" serve -c "$progdir/bin" > "$progdir/sftpgo.logs" &) &
    wait_for_sftpgo 10
}

sftpgo_off() {
    killall sftpgo
}

wait_for_sftpgo() {
    max_counter=$1
    counter=0

    while ! pgrep sftpgo >/dev/null 2>&1; do
        counter=$((counter + 1))
        if [ "$counter" -gt "$max_counter" ]; then
            return 1
        fi
        sleep 1
    done
}

{
    echo "Toggling sftpgo..."
    if pgrep sftpgo; then
        show.elf "$RES_PATH/disable.png" 2
        echo "Stopping sftpgo..."
        sftpgo_off
    else
        show.elf "$RES_PATH/enable.png" 2
        echo "Starting sftpgo..."
        sftpgo_on

        if ! wait_for_sftpgo 1; then
            show.elf "$RES_PATH/failed.png" 2
            echo "Failed to start sftpgo!"
            return 1
        fi
    fi

    echo "Done toggling sftpgo!"
    show.elf "$RES_PATH/done.png" 2
} &> ./log.txt
