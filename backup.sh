#!/bin/sh

# Setup logging
logfile=backup.log
loglocation=/var/log

# Setup source and target
source=/mnt/source/
target=/mnt/target

# Remove log from both locations
rm $loglocation/$logfile $source/$logfile

echo "`date` - Backup start" >> /tmp/test.log
rsync --archive --delete-before --compress --human-readable --stats --progress --log-file=$loglocation/$logfile --log-file-format=' %b bytes sent for %n' --exclude-from='/usr/local/bin/rsync.exclude' $source $target
echo "`date` - Backup complete" >> /tmp/test.log

# Copy log to source for easy inspection
cp $loglocation/$logfile $source
