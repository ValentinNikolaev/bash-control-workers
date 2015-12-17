#!/usr/bin/env bash

#######################################
# Echo txt with date time
#######################################
msg() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@" >&2
}

#######################################
# Check if script run by owner
# Globals:
#   SUDO_COMMAND
# Arguments:
#   None
# Returns:
#   None
#######################################

check_sudo() {
  if [[ $(id -u) == 0 ]]; then
    if [[ -z "$SUDO_COMMAND" ]]; then
      msg 'Please, use sudo'
      exit 1
    fi
  else
    msg 'Please, use sudo or login as root'
    exit 1
  fi
}

#######################################
# Check needed script default params
# Globals:
#   WORKERS_DIR_LIST
#   LOGFILE
#   LOGFILEERROR
#   LIST_WORKERS
# Arguments:
#   None
# Returns:
#   None
#######################################

check_script_params() {
  if [ -z "$WORKERS_DIR_LIST" ]; then
    msg "Empty WORKERS_DIR_LIST";
    exit 1
  fi

  if [ -z "$LOGFILE" ]; then
    msg "Empty LOGFILE";
    exit 1
  fi

  if [ -z "$LOGFILEERROR" ]; then
    msg "Empty LOGFILEERROR";
    exit 1
  fi

  if [ -z "$LIST_WORKERS" ]; then
    msg "Empty LIST_WORKERS";
    exit 1
  fi
}

#######################################
# Start worker by it's filename
# Globals:
#   WORKERS_DIR_LIST
#   LOGFILE
#   LOGFILEERROR
# Locals:
#   PROCESS_NAME
#   PROCESS_RUN
# Arguments:
#   worker name (process name need to start)
# Returns:
#   None
#######################################

start_bash_command() {
  if [ -z "$1" ]; then
    msg "Missing worker name"  # Or no parameter passed.
    exit 1
  fi
  local PROCESS_NAME=$1
  local PROCESS_RUN=0
  for WORKERS_DIR in $WORKERS_DIR_LIST; do
    if [[ -d "$WORKERS_DIR" ]]; then
      if [[ -f "$WORKERS_DIR/${PROCESS_NAME}" ]]; then
        PROCESS_RUN=1;
        msg "Running $WORKERS_DIR/${PROCESS_NAME} >> $WORKERS_DIR$LOGFILE$PROCESS_NAME 2>> $WORKERS_DIR$LOGFILEERROR$PROCESS_NAME"
        bash "$WORKERS_DIR/${PROCESS_NAME}" >> $WORKERS_DIR$LOGFILE$PROCESS_NAME 2>> $WORKERS_DIR$LOGFILEERROR$PROCESS_NAME &
        break;
      fi
    fi
  done
  if [ ${PROCESS_RUN} -eq 0 ]; then
    msg "$PROCESS_NAME failed to start";
  fi
}

#######################################
# Return process counter
# Arguments:
#   process name
# Returns:
#   process count
#######################################
get_process_counter() {
  if [ -z "$1" ];  then
    msg "Missing process name"  # Or no parameter passed.
    exit 1
  fi
  ps xao command | grep $1  | grep -v 'grep' | wc -l
  return 1
}

#######################################
# Kill process by name
# Locals:
#   PROCESS_COUNTER
# Arguments:
#   process name to kill
# Returns:
#   None
#######################################
kill_process() {
  if [ -z "$1" ]; then
    msg "Missing process name"  # Or no parameter passed.
    exit 1
  fi
  local PROCESS_COUNTER=$(get_process_counter $1)
  if [ -z "$PROCESS_COUNTER"  -o $PROCESS_COUNTER -eq 0 ]; then
    msg "'$1' already Already killed"
  else
    PROCESSES=$(ps -ef | grep "$1"  | grep -v 'grep' | awk '{print $2}')
    for processSID in "$PROCESSES"; do
      msg "$1[pid $processSID] killing..."
      msg "Killing pid $processSID..."
      kill -9 $processSID
    done
  fi
}

#######################################

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


