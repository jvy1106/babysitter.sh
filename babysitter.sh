#!/usr/bin/env bash
#babysitter script to manage watching multiple instance of script
#created by: Jesse Yen jesse@jads.com

SLEEP_TIME=10
SPAWN_AMOUNT=3
COMMAND=$@
kill_sig=0

if [ ! $@ ]
then
    echo "Enter path of script to run"
    exit 1
fi

trap "kill_sig=1" SIGINT SIGTERM

#spawn the processes
for (( i=0; i<$SPAWN_AMOUNT; i++ ))
do
    echo "spawing $COMMAND number $i"
    $COMMAND &
    PIDS[$i]=$!
done

while :
do
    #detected signal shutdown all processes
    if [ $kill_sig -ne 0 ]
    then
        for (( i=0; i<$SPAWN_AMOUNT; i++ ))
        do
            kill ${PIDS[$i]}
        done
        exit 1
    fi

    #check status on running processes
    for (( i=0; i<$SPAWN_AMOUNT; i++ ))
    do
        if ! kill -0 ${PIDS[$i]} > /dev/null 2>&1
        then
            #sleep a few second and spawn a new instance
            echo "looks like process died unexpectedly"
            sleep $SLEEP_TIME
            echo "rerunning: $COMMAND"
            $COMMAND &
            PIDS[$i]=$!
        fi
    done
    sleep 1
done
