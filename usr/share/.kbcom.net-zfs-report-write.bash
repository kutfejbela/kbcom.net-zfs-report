#!/bin/bash

write_spaceseparatednamevalue()
{
 local LOCAL_FILE_DESTINATION="$1"
 local LOCAL_STRING_DATETIME="$2"
 local -n LOCAL_ARRAY_NAMEVALUE="$3"

 local LOCAL_ITEMKEYSTRING_NAMEVALUE

 echo "$LOCAL_STRING_DATETIME" 1>"$LOCAL_FILE_DESTINATION"
 echo "name value" 1>>"$LOCAL_FILE_DESTINATION"

 for LOCAL_ITEMKEYSTRING_NAMEVALUE in "${!LOCAL_ARRAY_NAMEVALUE[@]}"
 do
  echo "$LOCAL_ITEMKEYSTRING_NAMEVALUE ${GLOBAL_ARRAY_ARCSTATS[$LOCAL_ITEMKEYSTRING_NAMEVALUE]}" 1>>"$LOCAL_FILE_DESTINATION"
 done
}
