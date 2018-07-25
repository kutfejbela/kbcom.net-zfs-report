#!/bin/bash

read -e -p "Enter cron E-Mail to: " -i "zfs@mail.$(/bin/domainname)" MAILTO
read -e -p "Enter cron E-Mail from: " -i "cron@$(/bin/hostname -f)" MAILFROM

echo "#!/bin/bash

CONFIG_FOLDER_MAIN=\"$(/bin/pwd)\"

source \"$CONFIG_FOLDER_MAIN/etc/kbcom.net-zfs-report.conf\"

\"$(/bin/pwd)/usr/share/kbnet.com-zfs-report.bash\"
" > "$(/bin/pwd)/run.bash"

/bin/chmod a+x "$(/bin/pwd)/run.bash"

echo "MAILTO=\"$MAILTO\"
MAILFROM=\"$MAILFROM\"

0 23 * * *  root  $(/bin/pwd)/run.bash"
> "local/etc/cron.d/kbnet.com-zfs-report"

/bin/ln -i -s "$(/bin/pwd)/local/etc/cron.d/kbnet.com-zfs-report" "/etc/cron.d/zfs-report"
