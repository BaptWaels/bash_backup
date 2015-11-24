#!/bin/bash

program_name="backup.sh"
ignored_file=""
BACKUP_DIR=""
CURRENT_DIR=$(pwd)"/"

#Check the shell
if [ -z "$BASH_VERSION" ]; then
    echo -e "Error: this script requires the BASH shell!"
    exit 1
fi

# Format errors
function error(){
  printf "\nERROR :\n"
  echo " " $1
  printf "\n"
}

# Print usage of the script
function usage() {
    echo "usage: $program_name [-i ignored_patterns] [-d BACKUP_DIR]"
    echo "	-h	                 display help"
    echo "	-i ignored_patterns	 name of the file which contains patterns to ignore"
    echo "	-d BACKUP_DIR            Path of the directory to backup"
    exit 1
}

# Check if all args are set
# Modify BACKUP_DIR variable to absolute path if needed
function check_args(){
  if [ -z "$ignored_file" -a -z "$BACKUP_DIR" ]; then
     usage
     exit 0
  elif [ -z "$ignored_file" ]; then
        error "-i is mandatory"
        usage
        exit 0
  elif [ -z "$BACKUP_DIR" ]; then
            error "-d is mandatory"
            usage
            exit 0
  fi

  ignored_file=$(echo $ignored_file | sed "s/^.\///g")   # to replace ./mypath by mypath
  BACKUP_DIR=$(echo $BACKUP_DIR | sed "s/^.\///g")   # to replace ./mypath by mypath

  if [ ! "${BACKUP_DIR:0:1}" = "/" ]; then
    BACKUP_DIR=$CURRENT_DIR$BACKUP_DIR    # to obtain absolute path
  fi

  if [ ! "${ignored_file:0:1}" = "/" ]; then
    ignored_file=$CURRENT_DIR$ignored_file   # to obtain absolute path
  fi

  if [ ! -d "$BACKUP_DIR" ]; then
    error "The directory you would like to backup doesn't exist"
  fi

  if [ ! -f "$ignored_file" ]; then
    error "The file which contains patterns to ignore doesn't exist"
  fi
}

#################
### DEAL ARGS ###
#################
OPTIND=1 # Reset in case getopts has been used previously in the shell.

# Initialize our own variables:
while getopts "hi:d:" opt; do
    case "$opt" in
    h)
        usage
        exit 0
        ;;
    i)  ignored_file=$OPTARG
        ;;
    d)  BACKUP_DIR=$OPTARG
        ;;
    *)
      usage
      exit 0
      ;;
    esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift
check_args

echo $BACKUP_DIR
echo $ignored_file
