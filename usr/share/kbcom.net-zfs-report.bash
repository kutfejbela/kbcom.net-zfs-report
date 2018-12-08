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
source "$GLOBAL_FOLDER_SCRIPT/.kbcom.net-zfs-report-main.bash"
source "$GLOBAL_FOLDER_SCRIPT/.kbcom.net-zfs-report-print.bash"
source "$GLOBAL_FOLDER_SCRIPT/.kbcom.net-zfs-report-write.bash"

declare -A GLOBAL_ARRAY_ARCSTATS
declare -A GLOBAL_ARRAY_ARCSTATSLOG
declare -A GLOBAL_ARRAY_MEMINFO

SHELL_STRING_COMMAND="$1"

case "$SHELL_STRING_COMMAND" in
 "writelog")
  GLOBAL_DATETIME_NOW=`printf "%(%c)T"`
  convert_filewithheader_namevalue "$CONFIG_FILE_ARCSTATSLOG" "GLOBAL_STRING_FIRSTLINE" "GLOBAL_ARRAY_ARCSTATSLOG"
  write_spaceseparatednamevalue "$CONFIG_FILE_ARCSTATSLOG" "$GLOBAL_DATETIME_NOW" "GLOBAL_ARRAY_ARCSTATS"
  ;;
 "report")
  convert_filewithheader_namevalue "$CONFIG_FILE_ARCSTATS" "GLOBAL_STRING_FIRSTLINE" "GLOBAL_ARRAY_ARCSTATS"
  ;;
 "reportwithdelta")
  convert_filewithheader_namevalue "$CONFIG_FILE_ARCSTATS" "GLOBAL_STRING_FIRSTLINE" "GLOBAL_ARRAY_ARCSTATS"

  convert_filewithheader_namevalue "$CONFIG_FILE_ARCSTATSLOG" "GLOBAL_STRING_FIRSTLINE" "GLOBAL_ARRAY_ARCSTATSLOG"
  ;;
 *)
  convert_filewithheader_namevalue "$CONFIG_FILE_ARCSTATS" "GLOBAL_STRING_FIRSTLINE" "GLOBAL_ARRAY_ARCSTATS"

  GLOBAL_DATETIME_NOW=`printf "%(%c)T"`
  convert_filewithheader_namevalue "$CONFIG_FILE_ARCSTATSLOG" "GLOBAL_STRING_FIRSTLINE" "GLOBAL_ARRAY_ARCSTATSLOG"
  write_spaceseparatednamevalue "$CONFIG_FILE_ARCSTATSLOG" "$GLOBAL_DATETIME_NOW" "GLOBAL_ARRAY_ARCSTATS"
  ;;
esac

case "$SHELL_STRING_COMMAND" in
 "writelog")
  ;;
 *)
  main_print_zpool
  main_print_memory

  main_print_arcstatslogdate "$GLOBAL_STRING_FIRSTLINE" "GLOBAL_ARRAY_ARCSTATSLOG"
  main_print_arcsize "$((${GLOBAL_ARRAY_MEMINFO[MemTotal]} * 1024))" "GLOBAL_ARRAY_ARCSTATS" "GLOBAL_ARRAY_ARCSTATSLOG"
  main_print_arcefficiency "GLOBAL_ARRAY_ARCSTATS" "GLOBAL_ARRAY_ARCSTATSLOG"
  ;;
esac
