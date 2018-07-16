#!/bin/bash

/bin/sed "s#/opt/kbnet.com-zfs-report#$(/bin/pwd)#g" local/etc/cron.d/kbnet.com-zfs-report.orig > local/etc/cron.d/kbnet.com-zfs-report
/bin/ln -i -s "$(/bin/pwd)/local/etc/cron.d/kbnet.com-zfs-report" /etc/cron.d/zfs-report

echo '!!! Modify "MAILTO" and "MAILFROM" variable in "/etc/cron.d/zfs-report" file !!!"
