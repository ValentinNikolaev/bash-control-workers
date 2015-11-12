#!/usr/bin/env bash

LOGFILE="/logs/lime-log-command-";
LOGFILEERROR="/logs/lime-log-error-command-";
WORKERS_DIR_LIST="/var/www/html/bash
/var/www/public_html/bash";

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
}

startBashCommand() {
    if [ -z "$1" ]
    then
        echo "Missing worker name"  # Or no parameter passed.
        exit 1
    else
        echo "Running worker $1"
    fi
    local processName=$1
    echo "$processName is not running. Starting..";
    for WORKERS_DIR in $WORKERS_DIR_LIST
    do
        if [[ -d "$WORKERS_DIR" ]]; then
            if [[ -f "$WORKERS_DIR/${processName}" ]]; then
                PROCESS_RUN=1;
                bash "$WORKERS_DIR/${processName}" >> $WORKERS_DIR$LOGFILE$1 2>> $WORKERS_DIR$LOGFILEERROR$1 &
                break;
            fi
        fi

        if [ $PROCESS_RUN -eq 0 ]; then
            echo "$processName failed to start";
        fi
    done
}

