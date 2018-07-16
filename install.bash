#!/bin/bash

read -e -p "Enter cron E-Mail to: " -i "zfs@mail.$(/bin/domainname)" MAILTO
read -e -p "Enter cron E-Mail from: " -i "cron@$(/bin/hostname -f)" MAILFROM

echo "MAILTO=\"$MAILTO\"
MAILFROM=\"$MAILFROM\"

0 23 * * *  root  $(/bin/pwd)/usr/share/kbnet.com-zfs-report.bash" > local/etc/cron.d/kbnet.com-zfs-report

/bin/ln -i -s "$(/bin/pwd)/local/etc/cron.d/kbnet.com-zfs-report" /etc/cron.d/zfs-report
