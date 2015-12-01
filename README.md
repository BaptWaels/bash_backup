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

Same usage as EXO 1

## EXO 3 - restore_backup.sh

Restore a given archive to the directory you specify. If none is specified, it will be restored inside your current directory.

```
usage: restore_backup.sh ARCHIVE_TO_RESTORE [[OUTPUT_DIR]]
        -h                       display help
        archive_to_restore       name of the archive you wish to restore
        output_dir            (optional) path of the directory where to restore backup, default is the current directory
```

ex:
```
./restore_backup.sh test_folder second_test_folder
```



Contributors :
- Martin Sorel
- Baptiste Waels
