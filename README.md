# bash_backup

This repository is our bash project

## EXO 1 - backup.sh

Create a .backup directory in each directories. Store inside backup_init.tar.gz
 every files inside this given directory. Ignore patterns specified by ignored_patterns
 file

```
usage: backup.sh [-i ignored_patterns] [-d BACKUP_DIR]
        -h                       display help
        -i ignored_patterns      name of the file which contains patterns to ignore
        -d BACKUP_DIR            Path of the directory to backup```
```

ex:
```
./backup.sh -i backignore -d test_folder
```

## EXO 2 - backup_improved.sh


Contributors :
- Martin Sorel
- Baptiste Waels
