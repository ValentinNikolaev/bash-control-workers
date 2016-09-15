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
#   No
# Returns:
#   Nothing
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
#   No
# Returns:
#   Nothing
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
#   process_name
#   process_run
# Arguments:
#   worker name (process name need to start)
# Returns:
#   Nothing
#######################################

start_bash_command() {
  if [ -z "$1" ]; then
    msg "Missing worker name"  # Or no parameter passed.
    exit 1
  fi
  local process_name=$1
  local process_run=0
  for workers_dir in $WORKERS_DIR_LIST; do
    if [[ -d "$workers_dir" ]]; then
      if [[ -f "$workers_dir/${process_name}" ]]; then
        process_run=1;
        msg "Running $workers_dir/${process_name} >> $workers_dir$LOGFILE$process_name 2>> $workers_dir$LOGFILEERROR$process_name"
        bash "$workers_dir/${process_name}" >> $workers_dir$LOGFILE$process_name 2>> $workers_dir$LOGFILEERROR$process_name &
        break;
      fi
    fi
  done
  if [ ${process_run} -eq 0 ]; then
    msg "$process_name failed to start";
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
#   process_counter
# Arguments:
#   process name to kill
# Returns:
#   Nothing
#######################################
kill_process() {
  if [ -z "$1" ]; then
    msg "Missing process name"  # Or no parameter passed.
    exit 1
  fi
  local process_counter=$(get_process_counter $1)
  if [ -z "$process_counter"  -o $process_counter -eq 0 ]; then
    msg "'$1' already Already killed"
  else
    local processes=$(ps -ef | grep "$1"  | grep -v 'grep' | awk '{print $2}')
    for process_sid in "$processes"; do
      msg "$1[pid $process_sid] killing..."
      msg "Killing pid $process_sid..."
      kill -9 $process_sid
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


