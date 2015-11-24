#!/bin/bash

# Global variables
ignored_file=""
backup_dir=""

#Check the shell
if [ -z "$BASH_VERSION" ]; then
    echo -e "Error: this script requires the BASH shell!"
    exit 1
fi

function error(){
  printf "\nERROR :\n"
  echo " " $1
  printf "\n"
}

# TODO Write HELP Method
function usage(){
  echo "HELP"
}



###################
#####  START  #####
###################
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
    d)  backup_dir=$OPTARG
        ;;
    *)
      usage
      exit 0
      ;;
    esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

if [ -z "$ignored_file" -a -z "$backup_dir" ]; then
   usage
   exit 0
elif [ -z "$ignored_file" ]; then
      error "-i is mandatory"
      exit 0
elif [ -z "$backup_dir" ]; then
          error "-d is mandatory"
          exit 0
fi


# Here, we have $ignored_file and $backup_dir set
