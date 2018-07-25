#!/bin/bash

read -e -p "Enter cron E-Mail to: " -i "zfs@mail.$(/bin/domainname)" MAILTO
read -e -p "Enter cron E-Mail from: " -i "cron@$(/bin/hostname -f)" MAILFROM

echo "#!/bin/bash

CONFIG_FOLDER_MAIN=\"$(/bin/pwd)\"

source \"\$CONFIG_FOLDER_MAIN/etc/kbcom.net-zfs-report.conf\"

\"\$CONFIG_FOLDER_MAIN/usr/share/kbcom.net-zfs-report.bash\"
" 1>"run.bash"

/bin/chmod a+x "run.bash"

#echo "# ZFS ARCSTATS log file
#export CONFIG_FILE_ARCSTATSLOG=\"$CONFIG_FOLDER_MAIN/var/kbcom.net-zfs-report.log\"
#" 1> "etc/kbcom.net-zfs-report.conf"


echo "MAILTO=\"$MAILTO\"
MAILFROM=\"$MAILFROM\"

0 23 * * *  root  $(/bin/pwd)/run.bash
" 1>"local/etc/cron.d/kbcom.net-zfs-report"

/bin/ln -i -s "$(/bin/pwd)/local/etc/cron.d/kbcom.net-zfs-report" "/etc/cron.d/zfs-report"
