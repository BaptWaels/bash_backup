#!/bin/bash

#Check the shell
if [ -z "$BASH_VERSION" ]; then
    echo -e "Error: this script requires the BASH shell!"
    exit 1
fi

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

if [ -z "$ignored_file" -a -z "$backup_dir" ]
then
   echo "ERROR : -i and -d options are mandatory"
   usage
   exit 0
elif [ -z "$ignored_file" ]
then
      echo "ERROR : -i option is mandatory"
      usage
      exit 0
elif [ -z "$backup_dir" ]
then
          echo "ERROR : -d option is mandatory"
          usage
          exit 0
fi


# If here, it works
