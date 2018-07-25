#!/bin/bash

read -e -p "Enter cron E-Mail to: " -i "zfs@mail.$(/bin/domainname)" MAILTO
read -e -p "Enter cron E-Mail from: " -i "cron@$(/bin/hostname -f)" MAILFROM

echo "#!/bin/bash

CONFIG_FOLDER_MAIN=\"$(/bin/pwd)\"

source \"\$CONFIG_FOLDER_MAIN/etc/kbcom.net-zfs-report.conf\"

\"\$CONFIG_FOLDER_MAIN/usr/share/kbcom.net-zfs-report.bash\"
" > "run.bash"

/bin/chmod a+x "run.bash"

echo "MAILTO=\"$MAILTO\"
MAILFROM=\"$MAILFROM\"

0 23 * * *  root  $(/bin/pwd)/run.bash"
> "local/etc/cron.d/kbcom.net-zfs-report"

/bin/ln -i -s "$(/bin/pwd)/local/etc/cron.d/kbcom.net-zfs-report" "/etc/cron.d/zfs-report"
