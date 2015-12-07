#!/bin/bash

CURRENT_DIR=$(pwd)"/"
BACKUP_DIR=""
REF_BACKUP=""
IGNORED_FILE=""
PROGRAM_NAME="backup_inc.sh"
BACKUP_DIRNAME=".backup"
TAR_INIT_NAME="backup_init.tar.gz"
CURRENT_TAR_NAME=""


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
    echo "	REF_BACKUP            Name of the reference backup"
    echo "	IGNORED_FILE            name of the file which contains patterns to ignore"
    exit 1
}

# Check if all args are set
# Modify BACKUP_DIR variable to absolute path if needed
function check_args(){
  #TODO check pattern $REF_BACKUP backup_*.tar.gz

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

  if [ ! "${IGNORED_FILE:0:1}" = "/" ]; then
    IGNORED_FILE=$CURRENT_DIR$IGNORED_FILE   # to obtain absolute path
  fi

  if [ ! "${BACKUP_DIR:0:1}" = "/" ]; then
    cd $BACKUP_DIR > /dev/null 2>&1
    BACKUP_DIR=$(pwd)
    cd - > /dev/null 2>&1
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

  local FIRST_REF_BACKUP=$BACKUP_DIR"/"$BACKUP_DIRNAME"/"$REF_BACKUP
  if [ ! -f "$FIRST_REF_BACKUP" ]; then
    error "The reference backup should exist in the archive to backup"
    exit 0
  fi

}

function create_backup_dir(){


  if [[ $CURRENT_TAR_NAME = ""  ]] ; then #create name of tar if not set yet
    local epoch_second=`date +%s`
    local old_epoch_second=`basename $REF_BACKUP | cut -d'_' -f2` #split old tar to get old_epoch
    CURRENT_TAR_NAME="inc_backup_"$epoch_second"_"$old_epoch_second".tar.gz"
  fi

  add_diff_files_to_tar $1
}

function add_diff_files_to_tar(){
  local list_of_files=`find "$1" -type f -maxdepth 1 | sed 's!.*/!!'`


  while read pattern_to_exclude; do
    list_of_files=$(echo "$list_of_files" | grep -Ev '.'$pattern_to_exclude'$')
  done < $IGNORED_FILE

  while read -r filename; do
    if [[ $(file -0 $1"/"$filename | grep 'empty\|text$') ]] ; then  # text file
      #text file

      # if file not in old archive add this to the new one
      # else add diff to the new one
      if ! tar -tf $1"/"$BACKUP_DIRNAME"/"$REF_BACKUP $filename >/dev/null 2>&1; then
        # $filename not inside OLD_TAR, so we add it inside new one
        tar --append -C $1 --file=$1"/"$BACKUP_DIRNAME"/"$CURRENT_TAR_NAME $filename > /dev/null 2>&1 #add the file into new tar
      else
        # file is already inside tar
        # untar file (from back_init to given one) and check if diff with this one
        # if yes, add the diff
        # if not different add an empty file to the archive
        # TODO

        restore_given_file $filename $REF_BACKUP $1

        #TODO
        #local changes=`diff -u $2"/"$BACKUP_DIRNAME"/"$filename $2"/"$filename`

        echo "$filename"
      fi
    else # binary file
      tar --append -C $1 --file=$1"/"$BACKUP_DIRNAME"/"$CURRENT_TAR_NAME $filename > /dev/null 2>&1  # added directly to new backup tar
    fi

  done <<< "$list_of_files"

}

function restore_given_file(){
  # $1 filename
  # $2 tar_name to restore
  # $3 current position
  local filename=$1

  local list_of_files=`find $3"/.backup" -type f -maxdepth 1 -name 'backup_*.tar.gz' | sed 's!.*/!!' | sort -n -t_ -k2` #list all files in .restore respecting *.tar.gz and sort it with given sort
  mkdir -p $3"/.backup/.restore"

  while read -r tar_name; do
    #TODO add enormous IF to leave function when reach END tar
    tar -C $3"/.backup/.restore" -zxvf $3"/.backup/"$tar_name $filename

    #TODO
    if [ ! -f $3"/.backup/"$filename ]; then
      #file not present so we can safely move it
      mv $3"/.backup/.restore/"$filename $3"/.backup"
    else
      # file already exist so we apply the patch
      mv $3"/.backup/.restore/"$filename $3"/.backup/"$filename".patch"
      patch -d $3"/.backup/" -f < $3"/.backup/"$filename".patch" > /dev/null 2>&1

      find $3"/.backup" \( -name \*.orig -o -name \*.rej \) -delete #delete useless files from patch

      rm $3"/.backup/"$filename".patch"
    fi
  done <<< "$list_of_files"

  rm -rf $3"/.backup/.restore"

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

create_backup_dir $BACKUP_DIR
