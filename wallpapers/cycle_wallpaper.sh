#!/bin/sh
refresh=$1
swaybg -i $(find /home/nikita/dev/nixos-config/wallpapers/img/ -type f | shuf -n1) -m fill &
# OLD_PID=$!
while true; do
    kill `pidof swaybg`
    swaybg -i $(find /home/nikita/dev/nixos-config/wallpapers/img/ -type f | shuf -n1) -m fill &
    # NEXT_PID=$!
    sleep 1
    # kill $OLD_PID
    sleep $refresh
    # OLD_PID=$NEXT_PID
done
