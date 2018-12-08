#!/bin/bash

GLOBAL_FOLDER_SCRIPT="${0%/*}"

if [ ${GLOBAL_FOLDER_SCRIPT:0:1} == "." ]
then
 GLOBAL_FOLDER_SCRIPT="$PWD${GLOBAL_FOLDER_SCRIPT:1}"
elif [ ${GLOBAL_FOLDER_SCRIPT:0:1} != "/" ]
then
 GLOBAL_FOLDER_SCRIPT="$PWD/$GLOBAL_FOLDER_SCRIPT"
fi


echo "Create another instance of this program with suffix (symlink) to prevent git pull errors"
read -e -p "Enter instance suffix: " -i "daily" GLOBAL_STRING_SUFFIX

read -e -p "Enter cron E-Mail to: " -i "zfs@mail.$(/bin/domainname)" GLOBAL_MAILTO
read -e -p "Enter cron E-Mail from: " -i "cron@$(/bin/hostname -f)" GLOBAL_MAILFROM

echo

GLOBAL_FOLDER_INSTANCE="${GLOBAL_FOLDER_SCRIPT%/*}/${GLOBAL_FOLDER_SCRIPT##*/}-$GLOBAL_STRING_SUFFIX"


### Create instance folder ###

if [ -x "$GLOBAL_FOLDER_INSTANCE" ]
then
 echo "Error: \"$GLOBAL_FOLDER_INSTANCE\" exist"
 exit 1
fi

echo "Create $GLOBAL_FOLDER_INSTANCE folder..."
/bin/mkdir "$GLOBAL_FOLDER_INSTANCE"

if [ $? -ne 0 ]
then
 echo "Error: Cannot create \"$GLOBAL_FOLDER_INSTANCE\" folder"
 exit 2
fi


### Symlink usr folder to instance ###

echo "Symlink $GLOBAL_FOLDER_SCRIPT/usr to $GLOBAL_FOLDER_INSTANCE/usr..."
/bin/ln -i -s "$GLOBAL_FOLDER_SCRIPT/usr" "$GLOBAL_FOLDER_INSTANCE/usr"

if [ $? -ne 0 ]
then
 echo "Error: Cannot symlink \"usr\" folder"
 exit 3
fi


### Create instance configuration file ###

echo "Create $GLOBAL_FOLDER_INSTANCE/etc folder..."
/bin/mkdir "$GLOBAL_FOLDER_INSTANCE/etc"

if [ $? -ne 0 ]
then
 echo "Error: Cannot create \"$GLOBAL_FOLDER_INSTANCE\"/etc folder"
 exit 4
fi

echo "Create $GLOBAL_FOLDER_INSTANCE/etc/kbcom.net-zfs-report.conf file..."
echo "export CONFIG_FILE_ARCSTATSLOG=\"\$CONFIG_FOLDER_MAIN/var/kbcom.net-zfs-report.log\"
export CONFIG_FILE_ARCSTATS=\"/proc/spl/kstat/zfs/arcstats\"

export CONFIG_EXTERNALCOMMAND_ZPOOL=\"/sbin/zpool\"
" 1>"$GLOBAL_FOLDER_INSTANCE/etc/kbcom.net-zfs-report.conf"

if [ $? -ne 0 ]
then
 echo "Error: Cannot create $GLOBAL_FOLDER_INSTANCE/etc/kbcom.net-zfs-report.conf file"
 exit 5
fi


### Create instance arcstats log file ###

echo "Create $GLOBAL_FOLDER_INSTANCE/var folder..."
/bin/mkdir "$GLOBAL_FOLDER_INSTANCE/var"

if [ $? -ne 0 ]
then
 echo "Error: Cannot create \"$GLOBAL_FOLDER_INSTANCE\"/var folder"
 exit 6
fi

echo "Create $GLOBAL_FOLDER_INSTANCE/var/kbcom.net-zfs-report.log file..."
printf "%(%c)T\n" 1>"$GLOBAL_FOLDER_INSTANCE/var/kbcom.net-zfs-report.log"

if [ $? -ne 0 ]
then
 echo "Error: Cannot create \"$GLOBAL_FOLDER_INSTANCE\"/var/kbcom.net-zfs-report.log file"
 exit 7
fi

/usr/bin/tail -n +2 "/proc/spl/kstat/zfs/arcstats" 1>>"$GLOBAL_FOLDER_INSTANCE/var/kbcom.net-zfs-report.log"

if [ $? -ne 0 ]
then
 echo "Error: Cannot append \"$GLOBAL_FOLDER_INSTANCE\"/var/kbcom.net-zfs-report.log file"
 exit 8
fi


### Create instance run.bash ###

echo "Create $GLOBAL_FOLDER_INSTANCE/run.bash file..."
echo "#!/bin/bash

CONFIG_FOLDER_MAIN=\"$GLOBAL_FOLDER_INSTANCE\"

source \"\$CONFIG_FOLDER_MAIN/etc/kbcom.net-zfs-report.conf\"

\"\$CONFIG_FOLDER_MAIN/usr/share/kbcom.net-zfs-report.bash\" \"$1\"
" 1>"$GLOBAL_FOLDER_INSTANCE/run.bash"

if [ $? -ne 0 ]
then
 echo "Error: Cannot create \"$GLOBAL_FOLDER_INSTANCE\"/run.bash file"
 exit 9
fi

echo "Make $GLOBAL_FOLDER_INSTANCE/run.bash file executable..."
/bin/chmod a+x "$GLOBAL_FOLDER_INSTANCE/run.bash"

if [ $? -ne 0 ]
then
 echo "Error: Cannot make \"$GLOBAL_FOLDER_INSTANCE\"/run.bash file executable"
 exit 10
fi


### !!! Replace with systemctl timer and service !!! ###

mkdir "$GLOBAL_FOLDER_INSTANCE/local"
mkdir "$GLOBAL_FOLDER_INSTANCE/local/etc"
mkdir "$GLOBAL_FOLDER_INSTANCE/local/etc/cron.d"

echo "MAILTO=\"$GLOBAL_MAILTO\"
MAILFROM=\"$GLOBAL_MAILFROM\"

0 23 * * *  root  $GLOBAL_FOLDER_INSTANCE/run.bash
" 1>"$GLOBAL_FOLDER_INSTANCE/local/etc/cron.d/kbcom.net-zfs-report"

ln -i -s "$GLOBAL_FOLDER_INSTANCE/local/etc/cron.d/kbcom.net-zfs-report" "/etc/cron.d/zfs-report"

systemctl restart cron
