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
  fi

  if [ ! -f "$IGNORED_FILE" ]; then
    error "The file which contains patterns to ignore doesn't exist"
  fi
}

function create_backup_dir(){

  #$1=echo $1 | sed 's/[^\/]$/\//'  # add / at the end of param if absent
  local path_to_backup_dir=$1$BACKUP_DIRNAME"/"
  mkdir -p $path_to_backup_dir  # create backup dir if doesn't exist

  # if TAR_INIT exists, do question2 else do question1 (if dir doesn't exist or symbolic link)
  if [[ ! -d "$path_to_backup_dir$TAR_INIT_NAME"  || -L "$path_to_backup_dir"  ]] ; then
    echo $path_to_backup_dir
    add_files_to_tar $path_to_backup_dir
  fi
}

function add_files_to_tar(){

  local list_of_files=`find "test_folder" -type f -maxdepth 1`

  while read pattern_to_exclude; do
    list_of_files=$(echo "$list_of_files" | grep -Ev '.'$pattern_to_exclude'$')
  done < $IGNORED_FILE

  echo $list_of_files # contains list of files to KEEP

  # myvar="*.pdf"
  # find "test_folder" -type f -maxdepth 1 | grep -Ev '.'$myvar'$'  #iterate threw all line of backignore file
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


#find test_folder -type d #list all subfolder

#test
#create_backup_dir "/Users/baptou/Documents/dev/repository/own/bash_backup/"

add_files_to_tar

#echo $BACKUP_DIR
#echo $IGNORED_FILE
