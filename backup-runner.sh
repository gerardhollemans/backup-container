#!/bin/sh

# Power up external drive
echo "`date` - Power up" >> /tmp/test.log
/usr/local/bin/uhubctl-rpi --vendor 0424:9514 -p2 -a1

# Wait for device to become ready
echo "`date` - Waiting for device" >> /tmp/test.log
while [ ! -e /dev/sd? ]
do
  sleep 1
done
echo "`date` - Device ready" >> /tmp/test.log

# Get device path of disk
DEV=`ls /dev/sd?`

# Mount external drive
while [ ! -e /mnt/target/.markerfile ]
do
  echo "`date` - Mount device" >> /tmp/test.log
  /bin/mount ${DEV}1 /mnt/target
  sleep 1
done

# Run backup script
/usr/local/bin/backup.sh

# Unmount external drive
echo "`date` - Unmount device" >> /tmp/test.log
/bin/umount /mnt/target

# Power down external drive
echo "`date` - Power down" >> /tmp/test.log
/usr/local/bin/uhubctl-rpi --vendor 0424:9514 -p2 -a0
