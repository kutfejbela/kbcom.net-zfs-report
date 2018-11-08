#!/bin/bash

convert_byte_megabyte()
{
 local PARAMETER_INTEGER_BYTE="$1"

 local LOCAL_INTEGER_HUNDREDMEGABYTE

 LOCAL_INTEGER_HUNDREDMEGABYTE="$(( PARAMETER_INTEGER_BYTE * 100 / 1048576 ))"

 echo "${LOCAL_INTEGER_HUNDREDMEGABYTE:0:-2}.${LOCAL_INTEGER_HUNDREDMEGABYTE: -2}"
}

convert_file_namevalue()
{
 local PARAMETER_FILE_SOURCE="$1"
 local -n PARAMETER_STRING_FIRSTLINE="$2"
 local -n PARAMETER_ARRAY_RESULT="$3"

 local LOCAL_BOOLEAN_FIRSTLINE
 local LOCAL_STRING_SOURCE
 local LOCAL_LINESTRING_SOURCE
 local LOCAL_STRING_NAME
 local LOCAL_STRING_VALUE

 PARAMETER_ARRAY_RESULT=()
 LOCAL_BOOLEAN_FIRSTLINE=true

 LOCAL_STRING_SOURCE=$(<"$PARAMETER_FILE_SOURCE")

 IFS=$'\n'
 for LOCAL_LINESTRING_SOURCE in $LOCAL_STRING_SOURCE
 do
  if $LOCAL_BOOLEAN_FIRSTLINE
  then
   PARAMETER_STRING_FIRSTLINE="$LOCAL_LINESTRING_SOURCE"
   LOCAL_BOOLEAN_FIRSTLINE=false
   continue
  fi

  LOCAL_STRING_NAME="${LOCAL_LINESTRING_SOURCE%% *}"
  LOCAL_STRING_VARIABLE="${LOCAL_LINESTRING_SOURCE##* }"

  PARAMETER_ARRAY_RESULT["$LOCAL_STRING_NAME"]="$LOCAL_STRING_VARIABLE"
 done
}

calculate_percentage()
{
 local PARAMETER_INTEGER_VALUE="$1"
 local PARAMETER_INTEGER_100PERCENTAGE="$2"

 local LOCAL_INTEGER_HUNDREDPERCENTAGE

 if [ $PARAMETER_INTEGER_VALUE -eq 0 ]
 then
  echo "0.00"
  return
 fi

 if [ $PARAMETER_INTEGER_100PERCENTAGE -eq 0 ]
 then
  echo "0.00"
  return
 fi

 LOCAL_INTEGER_HUNDREDPERCENTAGE="$(( PARAMETER_INTEGER_VALUE * 10000 / $PARAMETER_INTEGER_100PERCENTAGE ))"

 if [ $LOCAL_INTEGER_HUNDREDPERCENTAGE -eq 0 ]
 then
  echo "0.00"
  return
 fi

 LOCAL_INTEGER_HUNDREDPERCENTAGE=$(printf "%03d" $LOCAL_INTEGER_HUNDREDPERCENTAGE)

 echo "${LOCAL_INTEGER_HUNDREDPERCENTAGE:0:-2}.${LOCAL_INTEGER_HUNDREDPERCENTAGE: -2}"
}

print_zpool_status()
{
 /sbin/zpool status
}

print_zpool_verbosediostat()
{
 /sbin/zpool iostat -v
}

print_arc_size()
{
 local -n PARAMETER_ARRAY_ARCSTATS="$1"

 echo -e "
Arc Size:
 \u2022 Current Size (size):
      ${PARAMETER_ARRAY_ARCSTATS[size]} ($(convert_byte_megabyte ${PARAMETER_ARRAY_ARCSTATS[size]}) MB)
 \u2022 Target Size (c):
      ${PARAMETER_ARRAY_ARCSTATS[c]} ($(convert_byte_megabyte ${PARAMETER_ARRAY_ARCSTATS[c]}) MB)
 \u2022 Minimum Size (c_min):
      ${PARAMETER_ARRAY_ARCSTATS[c_min]} ($(convert_byte_megabyte ${PARAMETER_ARRAY_ARCSTATS[c_min]}) MB)
 \u2022 Maximum Size (c_max):
      ${PARAMETER_ARRAY_ARCSTATS[c_max]} ($(convert_byte_megabyte ${PARAMETER_ARRAY_ARCSTATS[c_max]}) MB)"
}

print_arc_sizebreakdown()
{
 local -n PARAMETER_ARRAY_ARCSTATS="$1"

 local LOCAL_INTEGER_MFU

 LOCAL_INTEGER_MFU=$(( ${PARAMETER_ARRAY_ARCSTATS[c]} - ${PARAMETER_ARRAY_ARCSTATS[p]} ))

 echo -e "
ARC Size Breakdown:
 \u2022 Most Recently Used Cache Size (p):
      ${PARAMETER_ARRAY_ARCSTATS[p]} ($(convert_byte_megabyte ${PARAMETER_ARRAY_ARCSTATS[p]}) MB - $(calculate_percentage ${PARAMETER_ARRAY_ARCSTATS[p]} ${PARAMETER_ARRAY_ARCSTATS[c]})%)
 \u2022 Most Frequently Used Cache Size (c-p):
      $LOCAL_INTEGER_MFU ($(convert_byte_megabyte $LOCAL_INTEGER_MFU) MB - $(calculate_percentage $LOCAL_INTEGER_MFU ${PARAMETER_ARRAY_ARCSTATS[c]})%)"
}

print_arc_efficiencytotal()
{
 local -n PARAMETER_ARRAY_ARCSTATS="$1"
 local -n PARAMETER_ARRAY_ARCSTATSLOG="$2"

 local LOCAL_INTEGER_TOTAL
 local LOCAL_INTEGER_TOTALLOG
 local LOCAL_INTEGER_TOTALDELTA
 local LOCAL_INTEGER_HITSDELTA
 local LOCAL_INTEGER_MISSESDELTA
 local LOCAL_INTEGER_REALHITS
 local LOCAL_INTEGER_REALHITSLOG
 local LOCAL_INTEGER_REALHITSDELTA

 LOCAL_INTEGER_TOTAL=$(( ${PARAMETER_ARRAY_ARCSTATS[hits]} + ${PARAMETER_ARRAY_ARCSTATS[misses]} ))
 LOCAL_INTEGER_TOTALLOG=$(( ${PARAMETER_ARRAY_ARCSTATSLOG[hits]} + ${PARAMETER_ARRAY_ARCSTATSLOG[misses]} ))
 LOCAL_INTEGER_TOTALDELTA=$(( $LOCAL_INTEGER_TOTAL - $LOCAL_INTEGER_TOTALLOG))

 LOCAL_INTEGER_HITSDELTA=$(( ${PARAMETER_ARRAY_ARCSTATS[hits]} - ${PARAMETER_ARRAY_ARCSTATSLOG[hits]} ))
 LOCAL_INTEGER_MISSESDELTA=$(( ${PARAMETER_ARRAY_ARCSTATS[misses]} - ${PARAMETER_ARRAY_ARCSTATSLOG[misses]} ))

 LOCAL_INTEGER_REALHITS=$(( ${PARAMETER_ARRAY_ARCSTATS[mru_hits]} + ${PARAMETER_ARRAY_ARCSTATS[mfu_hits]} ))
 LOCAL_INTEGER_REALHITSLOG=$(( ${PARAMETER_ARRAY_ARCSTATSLOG[mru_hits]} + ${PARAMETER_ARRAY_ARCSTATSLOG[mfu_hits]} ))
 LOCAL_INTEGER_REALHITSDELTA=$(( $LOCAL_INTEGER_REALHITS - $LOCAL_INTEGER_REALHITSLOG))

 echo -e "
ARC Efficiency Total:
 \u2022 Cache Access Total:
      $LOCAL_INTEGER_TOTAL \u279f $LOCAL_INTEGER_TOTALLOG - \u0394$LOCAL_INTEGER_TOTALDELTA
 \u2022 Cache Hits (hits):
      ${PARAMETER_ARRAY_ARCSTATS[hits]} ($(calculate_percentage ${PARAMETER_ARRAY_ARCSTATS[hits]} $LOCAL_INTEGER_TOTAL)%) \u279f ${PARAMETER_ARRAY_ARCSTATSLOG[hits]} - \u0394$LOCAL_INTEGER_HITSDELTA (\u0394$(calculate_percentage $LOCAL_INTEGER_HITSDELTA $LOCAL_INTEGER_TOTALDELTA)%)
 \u2022 Cache Misses (misses):
      ${PARAMETER_ARRAY_ARCSTATS[misses]} ($(calculate_percentage ${PARAMETER_ARRAY_ARCSTATS[misses]} $LOCAL_INTEGER_TOTAL)%) \u279f ${PARAMETER_ARRAY_ARCSTATSLOG[misses]} - \u0394$LOCAL_INTEGER_MISSESDELTA (\u0394$(calculate_percentage $LOCAL_INTEGER_MISSESDELTA $LOCAL_INTEGER_TOTALDELTA)%)
 \u2022 Real Hits (mru_hits + mfu_hits):
      $LOCAL_INTEGER_REALHITS ($(calculate_percentage $LOCAL_INTEGER_REALHITS $LOCAL_INTEGER_TOTAL)%) \u279f $LOCAL_INTEGER_REALHITSLOG - \u0394$LOCAL_INTEGER_REALHITSDELTA (\u0394$(calculate_percentage $LOCAL_INTEGER_REALHITSDELTA $LOCAL_INTEGER_TOTALDELTA)%)"
}

print_arc_efficiencybreakdown()
{
 local -n PARAMETER_ARRAY_ARCSTATS="$1"
 local -n PARAMETER_ARRAY_ARCSTATSLOG="$2"

 local LOCAL_INTEGER_DEMANDDATATOTAL
 local LOCAL_INTEGER_DEMANDDATATOTALLOG
 local LOCAL_INTEGER_DEMANDMETADATATOTAL
 local LOCAL_INTEGER_DEMANDMETADATATOTALLOG
 local LOCAL_INTEGER_PREFETCHDATATOTAL
 local LOCAL_INTEGER_PREFETCHDATATOTALLOG
 local LOCAL_INTEGER_PREFETCHMETADATATOTAL
 local LOCAL_INTEGER_PREFETCHMETADATATOTALLOG

 LOCAL_INTEGER_DEMANDDATATOTAL=$(( ${PARAMETER_ARRAY_ARCSTATS[demand_data_hits]} + ${PARAMETER_ARRAY_ARCSTATS[demand_data_misses]} ))
 LOCAL_INTEGER_DEMANDDATATOTALLOG=$(( ${PARAMETER_ARRAY_ARCSTATSLOG[demand_data_hits]} + ${PARAMETER_ARRAY_ARCSTATSLOG[demand_data_misses]} ))
 LOCAL_INTEGER_DEMANDMETADATATOTAL=$(( ${PARAMETER_ARRAY_ARCSTATS[demand_metadata_hits]} + ${PARAMETER_ARRAY_ARCSTATS[demand_metadata_misses]} ))
 LOCAL_INTEGER_DEMANDMETADATATOTALLOG=$(( ${PARAMETER_ARRAY_ARCSTATSLOG[demand_metadata_hits]} + ${PARAMETER_ARRAY_ARCSTATSLOG[demand_metadata_misses]} ))
 LOCAL_INTEGER_PREFETCHDATATOTAL=$(( ${PARAMETER_ARRAY_ARCSTATS[prefetch_data_hits]} + ${PARAMETER_ARRAY_ARCSTATS[prefetch_data_misses]} ))
 LOCAL_INTEGER_PREFETCHDATATOTALLOG=$(( ${PARAMETER_ARRAY_ARCSTATSLOG[prefetch_data_hits]} + ${PARAMETER_ARRAY_ARCSTATSLOG[prefetch_data_misses]} ))
 LOCAL_INTEGER_PREFETCHMETADATATOTAL=$(( ${PARAMETER_ARRAY_ARCSTATS[prefetch_metadata_hits]} + ${PARAMETER_ARRAY_ARCSTATS[prefetch_metadata_misses]} ))
 LOCAL_INTEGER_PREFETCHMETADATATOTALLOG=$(( ${PARAMETER_ARRAY_ARCSTATSLOG[prefetch_metadata_hits]} + ${PARAMETER_ARRAY_ARCSTATSLOG[prefetch_metadata_misses]} ))

 echo -e "
ARC Efficiency Breakdown:
 \u2022 Demand Data Hits (demand_data_hits):
      ${PARAMETER_ARRAY_ARCSTATS[demand_data_hits]} ($(calculate_percentage ${PARAMETER_ARRAY_ARCSTATS[demand_data_hits]} $LOCAL_INTEGER_DEMANDDATATOTAL)%) \u279f ${PARAMETER_ARRAY_ARCSTATSLOG[demand_data_hits]} - \u0394$(( ${PARAMETER_ARRAY_ARCSTATS[demand_data_hits]} - ${PARAMETER_ARRAY_ARCSTATSLOG[demand_data_hits]} )) (\u0394$(calculate_percentage ${PARAMETER_ARRAY_ARCSTATSLOG[demand_data_hits]} $LOCAL_INTEGER_DEMANDDATATOTALLOG)%)
 \u2022 Demand Data Misses (demand_data_misses):
      ${PARAMETER_ARRAY_ARCSTATS[demand_data_misses]} ($(calculate_percentage ${PARAMETER_ARRAY_ARCSTATS[demand_data_misses]} $LOCAL_INTEGER_DEMANDDATATOTAL)%) \u279f ${PARAMETER_ARRAY_ARCSTATSLOG[demand_data_misses]} - \u0394$(( ${PARAMETER_ARRAY_ARCSTATS[demand_data_misses]} - ${PARAMETER_ARRAY_ARCSTATSLOG[demand_data_misses]} )) (\u0394$(calculate_percentage ${PARAMETER_ARRAY_ARCSTATSLOG[demand_data_misses]} $LOCAL_INTEGER_DEMANDDATATOTALLOG)%)
 \u2022 Demand Metadata Hits (demand_metadata_hits):
      ${PARAMETER_ARRAY_ARCSTATS[demand_metadata_hits]} ($(calculate_percentage ${PARAMETER_ARRAY_ARCSTATS[demand_metadata_hits]} $LOCAL_INTEGER_DEMANDMETADATATOTAL)%) \u279f ${PARAMETER_ARRAY_ARCSTATSLOG[demand_metadata_hits]} - \u0394$(( ${PARAMETER_ARRAY_ARCSTATS[demand_metadata_hits]} - ${PARAMETER_ARRAY_ARCSTATSLOG[demand_metadata_hits]} )) (\u0394$(calculate_percentage ${PARAMETER_ARRAY_ARCSTATSLOG[demand_metadata_hits]} $LOCAL_INTEGER_DEMANDMETADATATOTALLOG)%)
 \u2022 Demand Metadata Misses (demand_metadata_misses):
      ${PARAMETER_ARRAY_ARCSTATS[demand_metadata_misses]} ($(calculate_percentage ${PARAMETER_ARRAY_ARCSTATS[demand_metadata_misses]} $LOCAL_INTEGER_DEMANDMETADATATOTAL)%) \u279f ${PARAMETER_ARRAY_ARCSTATSLOG[demand_metadata_misses]} - \u0394$(( ${PARAMETER_ARRAY_ARCSTATS[demand_metadata_misses]} - ${PARAMETER_ARRAY_ARCSTATSLOG[demand_metadata_misses]} )) (\u0394$(calculate_percentage ${PARAMETER_ARRAY_ARCSTATSLOG[demand_metadata_misses]} $LOCAL_INTEGER_DEMANDMETADATATOTALLOG)%)
 \u2022 Prefetch Data Hits (prefetch_data_hits):
      ${PARAMETER_ARRAY_ARCSTATS[prefetch_data_hits]} ($(calculate_percentage ${PARAMETER_ARRAY_ARCSTATS[prefetch_data_hits]} $LOCAL_INTEGER_PREFETCHDATATOTAL)%) \u279f ${PARAMETER_ARRAY_ARCSTATSLOG[prefetch_data_hits]} - \u0394$(( ${PARAMETER_ARRAY_ARCSTATS[prefetch_data_hits]} - ${PARAMETER_ARRAY_ARCSTATSLOG[prefetch_data_hits]} )) (\u0394$(calculate_percentage ${PARAMETER_ARRAY_ARCSTATSLOG[prefetch_data_hits]} $LOCAL_INTEGER_PREFETCHDATATOTALLOG)%)
 \u2022 Prefetch Data Misses (prefetch_data_misses):
      ${PARAMETER_ARRAY_ARCSTATS[prefetch_data_misses]} ($(calculate_percentage ${PARAMETER_ARRAY_ARCSTATS[prefetch_data_misses]} $LOCAL_INTEGER_PREFETCHDATATOTAL)%) \u279f ${PARAMETER_ARRAY_ARCSTATSLOG[prefetch_data_misses]} - \u0394$(( ${PARAMETER_ARRAY_ARCSTATS[prefetch_data_misses]} - ${PARAMETER_ARRAY_ARCSTATSLOG[prefetch_data_misses]} )) (\u0394$(calculate_percentage ${PARAMETER_ARRAY_ARCSTATSLOG[prefetch_data_misses]} $LOCAL_INTEGER_PREFETCHDATATOTALLOG)%)
 \u2022 Prefetch Metadata Hits (prefetch_metadata_hits):
      ${PARAMETER_ARRAY_ARCSTATS[prefetch_metadata_hits]} ($(calculate_percentage ${PARAMETER_ARRAY_ARCSTATS[prefetch_metadata_hits]} $LOCAL_INTEGER_PREFETCHMETADATATOTAL)%) \u279f ${PARAMETER_ARRAY_ARCSTATSLOG[prefetch_metadata_hits]} - \u0394$(( ${PARAMETER_ARRAY_ARCSTATS[prefetch_metadata_hits]} - ${PARAMETER_ARRAY_ARCSTATSLOG[prefetch_metadata_hits]} )) (\u0394$(calculate_percentage ${PARAMETER_ARRAY_ARCSTATSLOG[prefetch_metadata_hits]} $LOCAL_INTEGER_PREFETCHMETADATATOTALLOG)%)
 \u2022 Prefetch Metadata Misses (prefetch_metadata_misses):
      ${PARAMETER_ARRAY_ARCSTATS[prefetch_metadata_misses]} ($(calculate_percentage ${PARAMETER_ARRAY_ARCSTATS[prefetch_metadata_misses]} $LOCAL_INTEGER_PREFETCHMETADATATOTAL)%) \u279f ${PARAMETER_ARRAY_ARCSTATSLOG[prefetch_metadata_misses]} - \u0394$(( ${PARAMETER_ARRAY_ARCSTATS[prefetch_metadata_misses]} - ${PARAMETER_ARRAY_ARCSTATSLOG[prefetch_metadata_misses]} )) (\u0394$(calculate_percentage ${PARAMETER_ARRAY_ARCSTATSLOG[prefetch_metadata_misses]} $LOCAL_INTEGER_PREFETCHMETADATATOTALLOG)%)"
}

print_arc_efficiencyhits()
{
 local -n PARAMETER_ARRAY_ARCSTATS="$1"
 local -n PARAMETER_ARRAY_ARCSTATSLOG="$2"

 echo -e "
ARC Efficiency Hits:
 \u2022 Cache Hits (hits):
      ${PARAMETER_ARRAY_ARCSTATS[hits]} \u279f ${PARAMETER_ARRAY_ARCSTATSLOG[hits]} - \u0394$(( ${PARAMETER_ARRAY_ARCSTATS[hits]} - ${PARAMETER_ARRAY_ARCSTATSLOG[hits]} ))
 \u2022 Demand Data Hits (demand_data_hits):
      ${PARAMETER_ARRAY_ARCSTATS[demand_data_hits]} ($(calculate_percentage ${PARAMETER_ARRAY_ARCSTATS[demand_data_hits]} ${PARAMETER_ARRAY_ARCSTATS[hits]})%) \u279f ${PARAMETER_ARRAY_ARCSTATSLOG[demand_data_hits]} - \u0394$(( ${PARAMETER_ARRAY_ARCSTATS[demand_data_hits]} - ${PARAMETER_ARRAY_ARCSTATSLOG[demand_data_hits]} )) (\u0394$(calculate_percentage ${PARAMETER_ARRAY_ARCSTATSLOG[demand_data_hits]} ${PARAMETER_ARRAY_ARCSTATS[hits]})%)
 \u2022 Demand Metadata Hits (demand_metadata_hits):
      ${PARAMETER_ARRAY_ARCSTATS[demand_metadata_hits]} ($(calculate_percentage ${PARAMETER_ARRAY_ARCSTATS[demand_metadata_hits]} ${PARAMETER_ARRAY_ARCSTATS[hits]})%) \u279f ${PARAMETER_ARRAY_ARCSTATSLOG[demand_metadata_hits]} - \u0394$(( ${PARAMETER_ARRAY_ARCSTATS[demand_metadata_hits]} - ${PARAMETER_ARRAY_ARCSTATSLOG[demand_metadata_hits]} )) (\u0394$(calculate_percentage ${PARAMETER_ARRAY_ARCSTATSLOG[demand_metadata_hits]} ${PARAMETER_ARRAY_ARCSTATS[hits]})%)
 \u2022 Prefetch Data Hits (prefetch_data_hits):
      ${PARAMETER_ARRAY_ARCSTATS[prefetch_data_hits]} ($(calculate_percentage ${PARAMETER_ARRAY_ARCSTATS[prefetch_data_hits]} ${PARAMETER_ARRAY_ARCSTATS[hits]})%) \u279f ${PARAMETER_ARRAY_ARCSTATSLOG[prefetch_data_hits]} - \u0394$(( ${PARAMETER_ARRAY_ARCSTATS[prefetch_data_hits]} - ${PARAMETER_ARRAY_ARCSTATSLOG[prefetch_data_hits]} )) (\u0394$(calculate_percentage ${PARAMETER_ARRAY_ARCSTATSLOG[prefetch_data_hits]} ${PARAMETER_ARRAY_ARCSTATS[hits]})%)
 \u2022 Prefetch Metadata Hits (prefetch_metadata_hits):
      ${PARAMETER_ARRAY_ARCSTATS[prefetch_metadata_hits]} ($(calculate_percentage ${PARAMETER_ARRAY_ARCSTATS[prefetch_metadata_hits]} ${PARAMETER_ARRAY_ARCSTATS[hits]})%) \u279f ${PARAMETER_ARRAY_ARCSTATSLOG[prefetch_metadata_hits]} - \u0394$(( ${PARAMETER_ARRAY_ARCSTATS[prefetch_metadata_hits]} - ${PARAMETER_ARRAY_ARCSTATSLOG[prefetch_metadata_hits]} )) (\u0394$(calculate_percentage ${PARAMETER_ARRAY_ARCSTATSLOG[prefetch_metadata_hits]} ${PARAMETER_ARRAY_ARCSTATS[hits]})%)"
}

print_arc_efficiencymisses()
{
 local -n PARAMETER_ARRAY_ARCSTATS="$1"
 local -n PARAMETER_ARRAY_ARCSTATSLOG="$2"

 echo -e "
ARC Efficiency Misses:
 \u2022 Cache Misses (misses):
      ${PARAMETER_ARRAY_ARCSTATS[misses]} \u279f ${PARAMETER_ARRAY_ARCSTATSLOG[misses]} - \u0394$(( ${PARAMETER_ARRAY_ARCSTATS[misses]} - ${PARAMETER_ARRAY_ARCSTATSLOG[misses]} ))
 \u2022 Demand Data Misses (demand_data_misses):
      ${PARAMETER_ARRAY_ARCSTATS[demand_data_misses]} ($(calculate_percentage ${PARAMETER_ARRAY_ARCSTATS[demand_data_misses]} ${PARAMETER_ARRAY_ARCSTATS[misses]})%) \u279f ${PARAMETER_ARRAY_ARCSTATSLOG[demand_data_misses]} - \u0394$(( ${PARAMETER_ARRAY_ARCSTATS[demand_data_misses]} - ${PARAMETER_ARRAY_ARCSTATSLOG[demand_data_misses]} )) (\u0394$(calculate_percentage ${PARAMETER_ARRAY_ARCSTATSLOG[demand_data_misses]} ${PARAMETER_ARRAY_ARCSTATS[misses]})%)
 \u2022 Demand Metadata Misses (demand_metadata_misses):
      ${PARAMETER_ARRAY_ARCSTATS[demand_metadata_misses]} ($(calculate_percentage ${PARAMETER_ARRAY_ARCSTATS[demand_metadata_misses]} ${PARAMETER_ARRAY_ARCSTATS[misses]})%) \u279f ${PARAMETER_ARRAY_ARCSTATSLOG[demand_metadata_misses]} - \u0394$(( ${PARAMETER_ARRAY_ARCSTATS[demand_metadata_misses]} - ${PARAMETER_ARRAY_ARCSTATSLOG[demand_metadata_misses]} )) (\u0394$(calculate_percentage ${PARAMETER_ARRAY_ARCSTATSLOG[demand_metadata_misses]} ${PARAMETER_ARRAY_ARCSTATS[misses]})%)
 \u2022 Prefetch Data Misses (prefetch_data_misses):
      ${PARAMETER_ARRAY_ARCSTATS[prefetch_data_misses]} ($(calculate_percentage ${PARAMETER_ARRAY_ARCSTATS[prefetch_data_misses]} ${PARAMETER_ARRAY_ARCSTATS[misses]})%) \u279f ${PARAMETER_ARRAY_ARCSTATSLOG[prefetch_data_misses]} - \u0394$(( ${PARAMETER_ARRAY_ARCSTATS[prefetch_data_misses]} - ${PARAMETER_ARRAY_ARCSTATSLOG[prefetch_data_misses]} )) (\u0394$(calculate_percentage ${PARAMETER_ARRAY_ARCSTATSLOG[prefetch_data_misses]} ${PARAMETER_ARRAY_ARCSTATS[misses]})%)
 \u2022 Prefetch Metadata Misses (prefetch_metadata_misses):
      ${PARAMETER_ARRAY_ARCSTATS[prefetch_metadata_misses]} ($(calculate_percentage ${PARAMETER_ARRAY_ARCSTATS[prefetch_metadata_misses]} ${PARAMETER_ARRAY_ARCSTATS[misses]})%) \u279f ${PARAMETER_ARRAY_ARCSTATSLOG[prefetch_metadata_misses]} - \u0394$(( ${PARAMETER_ARRAY_ARCSTATS[prefetch_metadata_misses]} - ${PARAMETER_ARRAY_ARCSTATSLOG[prefetch_metadata_misses]} )) (\u0394$(calculate_percentage ${PARAMETER_ARRAY_ARCSTATSLOG[prefetch_metadata_misses]} ${PARAMETER_ARRAY_ARCSTATS[misses]})%)"
}

print_arc_efficiencyl2()
{
 local -n PARAMETER_ARRAY_ARCSTATS="$1"
 local -n PARAMETER_ARRAY_ARCSTATSLOG="$2"

 local LOCAL_INTEGER_L2TOTAL
 local LOCAL_INTEGER_L2TOTALLOG
 local LOCAL_INTEGER_L2TOTALDELTA
 local LOCAL_INTEGER_L2HITSDELTA
 local LOCAL_INTEGER_L2MISSESDELTA

 LOCAL_INTEGER_L2TOTAL=$(( ${PARAMETER_ARRAY_ARCSTATS[l2_hits]} + ${PARAMETER_ARRAY_ARCSTATS[l2_misses]} ))
 LOCAL_INTEGER_L2TOTALLOG=$(( ${PARAMETER_ARRAY_ARCSTATSLOG[l2_hits]} + ${PARAMETER_ARRAY_ARCSTATSLOG[l2_misses]} ))
 LOCAL_INTEGER_L2TOTALDELTA=$(( $LOCAL_INTEGER_L2TOTAL - $LOCAL_INTEGER_L2TOTALLOG))

 LOCAL_INTEGER_L2HITSDELTA=$(( ${PARAMETER_ARRAY_ARCSTATS[l2_hits]} - ${PARAMETER_ARRAY_ARCSTATSLOG[l2_hits]} ))
 LOCAL_INTEGER_L2MISSESDELTA=$(( ${PARAMETER_ARRAY_ARCSTATS[l2_misses]} - ${PARAMETER_ARRAY_ARCSTATSLOG[l2_misses]} ))

 echo -e "
L2ARC Efficiency:
 \u2022 L2 Cache Access Total:
      $LOCAL_INTEGER_L2TOTAL \u279f $LOCAL_INTEGER_L2TOTALLOG - \u0394$LOCAL_INTEGER_L2TOTALDELTA
 \u2022 L2 Cache Hits (l2_hits):
      ${PARAMETER_ARRAY_ARCSTATS[l2_hits]} ($(calculate_percentage ${PARAMETER_ARRAY_ARCSTATS[l2_hits]} $LOCAL_INTEGER_L2TOTAL)%) \u279f ${PARAMETER_ARRAY_ARCSTATSLOG[l2_hits]} - \u0394$LOCAL_INTEGER_L2HITSDELTA (\u0394$(calculate_percentage $LOCAL_INTEGER_L2HITSDELTA $LOCAL_INTEGER_L2TOTALDELTA)%)
 \u2022 L2 Cache Misses (misses):
      ${PARAMETER_ARRAY_ARCSTATS[l2_misses]} ($(calculate_percentage ${PARAMETER_ARRAY_ARCSTATS[l2_misses]} $LOCAL_INTEGER_L2TOTAL)%) \u279f ${PARAMETER_ARRAY_ARCSTATSLOG[l2_misses]} - \u0394$LOCAL_INTEGER_L2MISSESDELTA (\u0394$(calculate_percentage $LOCAL_INTEGER_L2MISSESDELTA $LOCAL_INTEGER_L2TOTALDELTA)%)"
}
