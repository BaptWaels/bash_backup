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

function restore_given_tar(){
  if [ ! -f "$1" ]; then
    #error "You tried to restore an unknow .tar.gz : "$1
    return #no tar to restore in this archive
  fi

  local backupdir_container=`dirname $1 | xargs dirname` # get dir containing .backup dir

  if [ ! "$backupdir_container" = "$ARCHIVE_TO_RESTORE" ] ; then
    # non root of restore folder
    local path_to_create=$OUTPUT_DIR"/""${backupdir_container#"$ARCHIVE_TO_RESTORE"/""}"
    mkdir -p $path_to_create"/.restore"  # create missing dirs into OUTPUT_DIR
  else
    # deal with root of restore folder

    local path_to_create=$OUTPUT_DIR
    mkdir $OUTPUT_DIR"/.restore"
  fi

  tar -C $path_to_create"/.restore" -xvf $1 > /dev/null 2>&1  # fully restore backup into .restore dir

  # comparison between restored files and current files
  compare_dir_and_restore $path_to_create $path_to_create"/.restore"

  rm -rf $path_to_create"/.restore"
}

function restore_given_archive(){
  local tar_location=$1

  local list_of_files=`find "$tar_location" -type f -maxdepth 1 -name 'backup_*.tar.gz' | sed 's!.*/!!' | sort -n -t_ -k2` #list all files in .restore respecting *.tar.gz and sort it with given sort

  while read -r filename; do
    restore_given_tar $tar_location"/"$filename
  done <<< "$list_of_files"

  #restore_given_tar "/Users/baptou/Documents/dev/repository/own/bash_backup/test_folder/.backup/backup_1448799223_BaptWaels.tar.gz"
}

function compare_dir_and_restore(){
  local list_of_files=`find "$2" -type f -maxdepth 1 | sed 's!.*/!!'` #list all files in .restore

  while read -r filename; do
    if [[ $(file -0 $2"/"$filename | grep 'empty\|text$') ]] ; then
      # text file, restore diff

      if [ ! -f $1"/"$filename ]; then
        #file not present so we can safely move it
        mv $2"/"$filename $1
      else
        # file already exist so we apply the patch

        mv $2"/"$filename $1"/"$filename".patch"
        patch -d $1 -f < $1"/"$filename".patch" > /dev/null 2>&1

        find $1 \( -name \*.orig -o -name \*.rej \) -delete #delete useless files from patch

        rm $1"/"$filename".patch"
      fi

    else
      # $filename is a binary, should erase previous one
      mv $2"/"$filename $1
    fi
  done <<< "$list_of_files"
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


ARCHIVE_TO_RESTORE=$1

if [ $2 ] ; then
  OUTPUT_DIR=$2
fi

check_args

# list recursively all .backup dir inside archive to restore
backup_to_restore_list=`find "$ARCHIVE_TO_RESTORE" -type d -path '*'$BACKUP_DIRNAME`


while read -r dir_to_restore; do
  restore_given_archive $dir_to_restore
done <<< "$backup_to_restore_list"
