#!/bin/bash

GLOBAL_FOLDER_SCRIPT=$(/usr/bin/dirname "$0")

if [ ${GLOBAL_FOLDER_SCRIPT:0:1} == "." ]
then
 GLOBAL_FOLDER_SCRIPT="$PWD${GLOBAL_FOLDER_SCRIPT:1}"
elif [ ${GLOBAL_FOLDER_SCRIPT:0:1} != "/" ]
then
 GLOBAL_FOLDER_SCRIPT="$PWD/$GLOBAL_FOLDER_SCRIPT"
fi

source "$GLOBAL_FOLDER_SCRIPT/.kbcom.net-zfs-report-calculate.bash"
source "$GLOBAL_FOLDER_SCRIPT/.kbcom.net-zfs-report-convert.bash"
source "$GLOBAL_FOLDER_SCRIPT/.kbcom.net-zfs-report-print.bash"
source "$GLOBAL_FOLDER_SCRIPT/.kbcom.net-zfs-report-write.bash"



print_zpool_status
echo
print_zpool_verbosediostat
echo
print_zfs_list
echo

declare -A GLOBAL_ARRAY_ARCSTATS
declare -A GLOBAL_ARRAY_ARCSTATSLOG
declare -A GLOBAL_ARRAY_MEMINFO

GLOBAL_DATETIME_NOW=`printf "%(%c)T"`

convert_filewithheader_namevalue "$CONFIG_FILE_ARCSTATS" "GLOBAL_STRING_FIRSTLINE" "GLOBAL_ARRAY_ARCSTATS"
convert_filewithheader_namevalue "$CONFIG_FILE_ARCSTATSLOG" "GLOBAL_STRING_FIRSTLINE" "GLOBAL_ARRAY_ARCSTATSLOG"
write_spaceseparatednamevalue "$CONFIG_FILE_ARCSTATSLOG" "$GLOBAL_DATETIME_NOW" "GLOBAL_ARRAY_ARCSTATS"

convert_filewithkb_namevalue "/proc/meminfo" "6" "GLOBAL_ARRAY_MEMINFO"

print_system_memory "GLOBAL_ARRAY_MEMINFO"

echo "
ARC log date:
 $GLOBAL_STRING_FIRSTLINE"

print_arcsize_total "$((${GLOBAL_ARRAY_MEMINFO[MemTotal]} * 1024))" "GLOBAL_ARRAY_ARCSTATS" "GLOBAL_ARRAY_ARCSTATSLOG"
print_arcsize_breakdown "GLOBAL_ARRAY_ARCSTATS" "GLOBAL_ARRAY_ARCSTATSLOG"
print_arcefficiency_total "GLOBAL_ARRAY_ARCSTATS" "GLOBAL_ARRAY_ARCSTATSLOG"
print_arcefficiency_breakdown "GLOBAL_ARRAY_ARCSTATS" "GLOBAL_ARRAY_ARCSTATSLOG"
print_arcefficiency_realcachehitsbycachelist "GLOBAL_ARRAY_ARCSTATS" "GLOBAL_ARRAY_ARCSTATSLOG"
print_arcefficiency_cachehitsbydatatype "GLOBAL_ARRAY_ARCSTATS" "GLOBAL_ARRAY_ARCSTATSLOG"
print_arcefficiency_cachemissesbydatatype "GLOBAL_ARRAY_ARCSTATS" "GLOBAL_ARRAY_ARCSTATSLOG"
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
