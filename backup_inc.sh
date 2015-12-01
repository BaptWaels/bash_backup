#!/bin/bash

CURRENT_DIR=$(pwd)"/"
BACKUP_DIR=""
REF_BACKUP=""
IGNORED_FILE=""
PROGRAM_NAME="backup_inc.sh"
BACKUP_DIRNAME=".backup"
TAR_INIT_NAME="backup_init.tar.gz"


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

# Format logs
function log(){
  printf "\nINFO :\n"
  echo " " $1
  printf "\n"
}

# Print usage of the script
function usage() {
    echo "usage: $PROGRAM_NAME BACKUP_DIR REF_BACKUP IGNORED_FILE"
    echo "	-h	                 display help"
    echo "	BACKUP_DIR	 Path of the directory to backup"
    echo "	REF_BACKUP            todo"
    echo "	IGNORED_FILE            name of the file which contains patterns to ignore"
    exit 1
}

# Check if all args are set
# Modify BACKUP_DIR variable to absolute path if needed
function check_args(){

  # check obliged parameters
  if [ -z "$BACKUP_DIR" ]; then
    error "You must specify an archive to backup"
    usage
    exit 0
  fi
  if [ -z "$REF_BACKUP" ]; then
    error "You must specify a reference tar"
    usage
    exit 0
  fi
  if [ -z "$IGNORED_FILE" ]; then
    error "You must specify a file which contains patterns to ignore"
    usage
    exit 0
  fi

  IGNORED_FILE=$(echo $IGNORED_FILE | sed "s/^.\///g")   # to replace ./mypath by mypath
  BACKUP_DIR=$(echo $BACKUP_DIR | sed "s/^.\///g")
  REF_BACKUP=$(echo $REF_BACKUP | sed "s/^.\///g")

  if [ ! "${REF_BACKUP:0:1}" = "/" ]; then
    REF_BACKUP=$CURRENT_DIR$REF_BACKUP   # to obtain absolute path
  fi

  if [ ! "${IGNORED_FILE:0:1}" = "/" ]; then
    IGNORED_FILE=$CURRENT_DIR$IGNORED_FILE   # to obtain absolute path
  fi

  if [ ! "${BACKUP_DIR:0:1}" = "/" ]; then
    cd $BACKUP_DIR > /dev/null 2>&1
    BACKUP_DIR=$(pwd)
    cd - > /dev/null 2>&1
  fi

  #check if ARCHIVE_TO_RESTORE contains backup_init
  if [[ ! -f $ARCHIVE_TO_RESTORE"/"$BACKUP_DIRNAME"/""$TAR_INIT_NAME" ]] ; then
    error "You archive must contains at least one "$TAR_INIT_NAME
    usage
    exit 0
  fi

  if [ ! -d "$BACKUP_DIR" ]; then
    error $BACKUP_DIR" must be a directory"
    usage
    exit 0
  fi

  if [ ! -f "$IGNORED_FILE" ]; then
    error "The file which contains patterns to ignore doesn't exist"
    exit 0
  fi

  if [ ! -f "$REF_BACKUP" ]; then
    error "The reference backup doesn't exist"
    exit 0
  fi

}

while getopts "h" opt; do
    case "$opt" in
    h)
        usage
        exit 0
        ;;
    esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

BACKUP_DIR=$1
REF_BACKUP=$2
IGNORED_FILE=$3

check_args
