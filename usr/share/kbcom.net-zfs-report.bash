#!/bin/bash

GLOBAL_FOLDER_SCRIPT=$(/usr/bin/dirname "$0")
source "$GLOBAL_FOLDER_SCRIPT/.kbcom.net-zfs-report.bash"

print_zpool_status
echo
print_zpool_verbosediostat

declare -A GLOBAL_ARRAY_ARCSTATS
declare -A GLOBAL_ARRAY_ARCSTATSLOG

convert_file_namevalue "$CONFIG_FILE_ARCSTATS" "GLOBAL_STRING_FIRSTLINE" "GLOBAL_ARRAY_ARCSTATS"
convert_file_namevalue "$CONFIG_FILE_ARCSTATSLOG" "GLOBAL_STRING_FIRSTLINE" "GLOBAL_ARRAY_ARCSTATSLOG"

GLOBAL_DATETIME_NOW=`printf "%(%c)T"`


print_arc_size "GLOBAL_ARRAY_ARCSTATS"
print_arc_sizebreakdown "GLOBAL_ARRAY_ARCSTATS"
print_arc_efficiencytotal "GLOBAL_ARRAY_ARCSTATS" "GLOBAL_ARRAY_ARCSTATSLOG"
print_arc_efficiencybreakdown "GLOBAL_ARRAY_ARCSTATS" "GLOBAL_ARRAY_ARCSTATSLOG"
#print_arc_efficiencycache "GLOBAL_ARRAY_ARCSTATS" "GLOBAL_ARRAY_ARCSTATSLOG"
print_arc_efficiencyhits "GLOBAL_ARRAY_ARCSTATS" "GLOBAL_ARRAY_ARCSTATSLOG"
print_arc_efficiencymisses "GLOBAL_ARRAY_ARCSTATS" "GLOBAL_ARRAY_ARCSTATSLOG"
print_arc_efficiencyl2 "GLOBAL_ARRAY_ARCSTATS" "GLOBAL_ARRAY_ARCSTATSLOG"
exit




echo "$GLOBAL_DATETIME_NOW"



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
