#!/bin/bash


PROGRAM_NAME="backup.sh"
IGNORED_FILE="" # will be defined by script args (-i)
BACKUP_DIR="" # will be defined by script args (-d) which is the dir to backup
CURRENT_DIR=$(pwd)"/" # Current path
BACKUP_DIRNAME=".backup"  # name of the directory to store backups
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

# Print usage of the script
function usage() {
    echo "usage: $PROGRAM_NAME [-i ignored_patterns] [-d BACKUP_DIR]"
    echo "	-h	                 display help"
    echo "	-i ignored_patterns	 name of the file which contains patterns to ignore"
    echo "	-d BACKUP_DIR            Path of the directory to backup"
    exit 1
}

# Check if all args are set
# Modify BACKUP_DIR variable to absolute path if needed
function check_args(){
  if [ -z "$IGNORED_FILE" -a -z "$BACKUP_DIR" ]; then
     usage
     exit 0
  elif [ -z "$IGNORED_FILE" ]; then
        error "-i is mandatory"
        usage
        exit 0
  elif [ -z "$BACKUP_DIR" ]; then
            error "-d is mandatory"
            usage
            exit 0
  fi

  IGNORED_FILE=$(echo $IGNORED_FILE | sed "s/^.\///g")   # to replace ./mypath by mypath
  BACKUP_DIR=$(echo $BACKUP_DIR | sed "s/^.\///g")   # to replace ./mypath by mypath

  if [ ! "${BACKUP_DIR:0:1}" = "/" ]; then
    BACKUP_DIR=$CURRENT_DIR$BACKUP_DIR    # to obtain absolute path
  fi

  if [ ! "${IGNORED_FILE:0:1}" = "/" ]; then
    IGNORED_FILE=$CURRENT_DIR$IGNORED_FILE   # to obtain absolute path
  fi

  if [ ! -d "$BACKUP_DIR" ]; then
    error "The directory you would like to backup doesn't exist"
    exit 0
  fi

  if [ ! -f "$IGNORED_FILE" ]; then
    error "The file which contains patterns to ignore doesn't exist"
    exit 0
  fi
}

function create_backup_dir(){

  #$1=echo $1 | sed 's/[^\/]$/\//'  # add / at the end of param if absent
  local path_to_backup_dir=$1$BACKUP_DIRNAME"/"
  mkdir -p $path_to_backup_dir  # create backup dir if doesn't exist

  # if TAR_INIT exists, do question2 else do question1 (if dir doesn't exist or symbolic link)
  echo "$path_to_backup_dir$TAR_INIT_NAME"
  if [[ ! -f "$path_to_backup_dir$TAR_INIT_NAME" ]] ; then
    add_files_to_tar $path_to_backup_dir #question 1
  fi
}

function add_files_to_tar(){
  local current_backup_path=`dirname "$1"`
  local list_of_files=`find "$current_backup_path" -type f -maxdepth 1 | sed 's!.*/!!'`

  echo "$list_of_files"

  while read pattern_to_exclude; do
    list_of_files=$(echo "$list_of_files" | grep -Ev '.'$pattern_to_exclude'$')
  done < $IGNORED_FILE

  while read -r filename; do
    tar --append -C $current_backup_path --file=$1$TAR_INIT_NAME $filename
  done <<< "$list_of_files"
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
    i)  IGNORED_FILE=$OPTARG
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


subdirs_to_backup=`find "$BACKUP_DIR" -type d -not -path '*'$BACKUP_DIRNAME` #list all subfolder but exclude the BACKUP_DIRNAME

while read -r dir_to_backup; do
  create_backup_dir $dir_to_backup"/"
done <<< "$subdirs_to_backup"

#create_backup_dir "/Users/baptou/Documents/dev/repository/own/bash_backup/test_folder/"
