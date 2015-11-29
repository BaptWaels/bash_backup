#!/bin/bash

#two args archive to restore and
CURRENT_DIR=$(pwd)"/"
ARCHIVE_TO_RESTORE=""
OUTPUT_DIR=$(pwd)"/"
PROGRAM_NAME="restore_backup.sh"
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
    echo "usage: $PROGRAM_NAME ARCHIVE_TO_RESTORE [[OUTPUT_DIR]]"
    echo "	-h	                 display help"
    echo "	archive_to_restore	 name of the archive you wish to restore"
    echo "	output_dir            (optional) path of the directory where to restore backup, default is the current directory"
    exit 1
}

# Check if all args are set
# Modify BACKUP_DIR variable to absolute path if needed
function check_args(){
  if [ -z "$ARCHIVE_TO_RESTORE" ]; then
    error "You must specify an archive to restore"
    usage
    exit 0
  fi

  if [ ! "${ARCHIVE_TO_RESTORE:0:1}" = "/" ]; then
    cd $ARCHIVE_TO_RESTORE > /dev/null 2>&1
    ARCHIVE_TO_RESTORE=$(pwd)
    cd - > /dev/null 2>&1
  fi

  #check if ARCHIVE_TO_RESTORE contains backup_init
  if [[ ! -f $ARCHIVE_TO_RESTORE"/"$BACKUP_DIRNAME"/""$TAR_INIT_NAME" ]] ; then
    #TODO check recursively in all subdirs if they all contains .backup DIR & an init tar
    error "You archive must contains at least one "$TAR_INIT_NAME
    usage
    exit 0
  fi

  if [ ! -d "$OUTPUT_DIR" ]; then
    error $OUTPUT_DIR" must be a directory"
    usage
    exit 0
  else
    cd $OUTPUT_DIR > /dev/null 2>&1
    OUTPUT_DIR=$(pwd)
    cd - > /dev/null 2>&1
  fi

}

ARCHIVE_TO_RESTORE=$1

if [ $2 ] ; then
  OUTPUT_DIR=$2
  ECHO $OUTPUT_DIR
fi

check_args
