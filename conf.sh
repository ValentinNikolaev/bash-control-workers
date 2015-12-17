#!/usr/bin/env bash

# path for log file
LOGFILE="/logs/lime-log-command-";
# path for log-error file
LOGFILEERROR="/logs/lime-log-error-command-";
# php workers directory
# i.e.
# "/var/www/html/bash
# /var/development/html/bash"
WORKERS_DIR_LIST="/var/www/html/bash";
# php worker names. The same formatting as WORKERS_DIR_LIST
LIST_WORKERS="queue_workers"

checkSudo() {
    if [[ $(id -u) == 0 ]]; then
        if [[ -z "$SUDO_COMMAND" ]]; then
            echo 'Please, use sudo'
            exit;
        fi
    else  echo 'Please, use sudo or login as root'
        exit 1
    fi
}

checkScriptParams() {
    if [ -z "$WORKERS_DIR_LIST" ]; then
       echo "Empty WORKERS_DIR_LIST";
       exit 1
    fi

    if [ -z "$LOGFILE" ]; then
       echo "Empty LOGFILE";
       exit 1
    fi

    if [ -z "$LOGFILEERROR" ]; then
       echo "Empty LOGFILEERROR";
       exit 1
    fi

    if [ -z "$LIST_WORKERS" ]; then
       echo "Empty LIST_WORKERS";
       exit 1
    fi
}

startBashCommand() {
    if [ -z "$1" ]
    then
        echo "Missing worker name"  # Or no parameter passed.
        exit 1
    fi
    local PROCESS_NAME=$1
    local PROCESS_RUN=0
    for WORKERS_DIR in $WORKERS_DIR_LIST
    do
        if [[ -d "$WORKERS_DIR" ]]; then
            if [[ -f "$WORKERS_DIR/${PROCESS_NAME}" ]]; then
                PROCESS_RUN=1;
                echo "Running $WORKERS_DIR/${PROCESS_NAME} >> $WORKERS_DIR$LOGFILE$PROCESS_NAME 2>> $WORKERS_DIR$LOGFILEERROR$PROCESS_NAME"
                bash "$WORKERS_DIR/${PROCESS_NAME}" >> $WORKERS_DIR$LOGFILE$PROCESS_NAME 2>> $WORKERS_DIR$LOGFILEERROR$PROCESS_NAME &
                break;
            fi
        fi
    done
    if [ ${PROCESS_RUN} -eq 0 ]; then
        echo "$PROCESS_NAME failed to start";
    fi
}

getProcessCounter() {
    if [ -z "$1" ]
    then
        echo "Missing process name"  # Or no parameter passed.
        exit 1
    fi
    ps xao command | grep $1  | grep -v 'grep' | wc -l
    return 1
}

killProcess() {
    if [ -z "$1" ]
    then
        echo "Missing process name"  # Or no parameter passed.
        exit 1
    fi

    PROCESS_COUNTER=$(getProcessCounter $1)
    if [ -z "$PROCESS_COUNTER"  -o $PROCESS_COUNTER -eq 0 ]
    then
        echo "Already killed '$1'"
    else
        PROCESSES=$(ps -ef | grep "$1"  | grep -v 'grep' | awk '{print $2}')

        for processSID in "$PROCESSES"
        do
            echo "$1[pid $processSID] killing..."
            echo "Killing pid $processSID..."
            kill -9 $processSID
        done
    fi
}

msg() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@" >&2
}
