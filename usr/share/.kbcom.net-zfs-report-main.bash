#!/bin/bash

main_print_zpool()
{
 print_zpool_status
 echo
 print_zpool_verbosediostat
}

main_print_memory()
{
 convert_filewithkb_namevalue "/proc/meminfo" "6" "GLOBAL_ARRAY_MEMINFO"

 print_system_memory "GLOBAL_ARRAY_MEMINFO"
}

main_print_arcsize()
{
 local PARAMETER_INTEGER_MEMORYSIZE="$1"
 local PARAMETER_ARRAY_ARCSTATS="$2"
 local PARAMETER_ARRAY_ARCSTATSLOG="$3"

 print_arcsize_total "$PARAMETER_INTEGER_MEMORYSIZE" "$PARAMETER_ARRAY_ARCSTATS" "$PARAMETER_ARRAY_ARCSTATSLOG"
 print_arcsize_breakdown "$PARAMETER_ARRAY_ARCSTATS" "$PARAMETER_ARRAY_ARCSTATSLOG"
}

main_print_arcefficiency()
{
 local PARAMETER_ARRAY_ARCSTATS="$1"
 local PARAMETER_ARRAY_ARCSTATSLOG="$2"

 print_arcefficiency_total "$PARAMETER_ARRAY_ARCSTATS" "$PARAMETER_ARRAY_ARCSTATSLOG"
 print_arcefficiency_breakdown "$PARAMETER_ARRAY_ARCSTATS" "$PARAMETER_ARRAY_ARCSTATSLOG"
 print_arcefficiency_realcachehitsbycachelist "$PARAMETER_ARRAY_ARCSTATS" "$PARAMETER_ARRAY_ARCSTATSLOG"
 print_arcefficiency_cachehitsbydatatype "$PARAMETER_ARRAY_ARCSTATS" "$PARAMETER_ARRAY_ARCSTATSLOG"
 print_arcefficiency_cachemissesbydatatype "$PARAMETER_ARRAY_ARCSTATS" "$PARAMETER_ARRAY_ARCSTATSLOG"
 print_arcefficiency_l2 "$PARAMETER_ARRAY_ARCSTATS" "$PARAMETER_ARRAY_ARCSTATSLOG"
}
