#!/bin/bash

GLOBAL_FOLDER_SCRIPT=$(/usr/bin/dirname "$0")
source "$GLOBAL_FOLDER_SCRIPT/.kbcom.net-zfs-report.bash"

zpool_print_status
echo
zpool_print_verbosediostat


IFS=$'\n'
GLOBAL_DATETIME="$(/bin/date)"
zfs_getarray_arcstats


if [ -f "$CONFIG_FILE_ARCSTATSLOG" ]
then
 echo "Last log date: $(zfs_getdate_arcstatslog "$CONFIG_FILE_ARCSTATSLOG")"
 zfs_getarray_arcstatslog "$CONFIG_FILE_ARCSTATSLOG"

 zfs_write_arcstatslog "$GLOBAL_DATETIME" "$CONFIG_FILE_ARCSTATSLOG"

 zfs_print_arcstatslog
else
 zfs_write_arcstatslog "$GLOBAL_DATETIME" "$CONFIG_FILE_ARCSTATSLOG"

 zfs_print_arcstats
fi
