#!/bin/bash

GLOBAL_FOLDER_SCRIPT=$(/usr/bin/dirname "$0")

if [ ${GLOBAL_FOLDER_SCRIPT:0:1} == "." ]
then
 GLOBAL_FOLDER_SCRIPT="$(/bin/pwd)${GLOBAL_FOLDER_SCRIPT:1}"
elif [ ${GLOBAL_FOLDER_SCRIPT:0:1} != "/" ]
then
 GLOBAL_FOLDER_SCRIPT="$(/bin/pwd)/$GLOBAL_FOLDER_SCRIPT"
fi

read -e -p "Enter cron E-Mail to: " -i "zfs@mail.$(/bin/domainname)" GLOBAL_MAILTO
read -e -p "Enter cron E-Mail from: " -i "cron@$(/bin/hostname -f)" GLOBAL_MAILFROM


echo "#!/bin/bash

CONFIG_FOLDER_MAIN=\"$GLOBAL_FOLDER_SCRIPT\"

source \"\$CONFIG_FOLDER_MAIN/etc/kbcom.net-zfs-report.conf\"

\"\$CONFIG_FOLDER_MAIN/usr/share/kbcom.net-zfs-report.bash\"
" 1>"$GLOBAL_FOLDER_SCRIPT/run.bash"

/bin/chmod a+x "$GLOBAL_FOLDER_SCRIPT/run.bash"


echo "MAILTO=\"$GLOBAL_MAILTO\"
MAILFROM=\"$GLOBAL_MAILFROM\"

0 23 * * *  root  $GLOBAL_FOLDER_SCRIPT/run.bash
" 1>"$GLOBAL_FOLDER_SCRIPT/local/etc/cron.d/kbcom.net-zfs-report"

/bin/ln -i -s "$GLOBAL_FOLDER_SCRIPT/local/etc/cron.d/kbcom.net-zfs-report" "/etc/cron.d/zfs-report"
