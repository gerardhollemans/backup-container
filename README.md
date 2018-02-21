# backup-container
Docker container running backup script using cron

## Approach

- Use backup script to
  - Power up USB-attached disk using TrickleStar PC TrickleSaver and [uhubctl](https://github.com/mvp/uhubctl)
  - Mount USB disk
  - Run backup using rsync
  - Unmount USB disk
  - Power off USB-attached disk
- Start container running cron triggering backup script with source volume and restart options

## Preparations

Place a file named *.markerfile* on the USB-attached disk in the directory that will end up under */mnt/target/*. After the disk has been mounted in the container, the file */mnt/target/.markerfile* has to exist.

This file is used by *backup-runner.sh* to determine that preparations have completed and the backup (using rsync) can start. If this file is not found, *backup-runner* will hang.

The file *.markerfile* is exluded in *rsync.exclude* to prevent it from being deleted by the backup process.

## Deployment

- Push container to ResinPi

``sudo resin local push resin.local --source . --app-name backup-service``

- SSH into the Pi to stop and remove the container...

``docker stop backup-service``

``docker rm backup-service``

- ...and restart it with the proper command line options

``docker run -d --privileged --restart always --name backup-service -v /dev:/dev -v /mnt/data/local-storage/:/mnt/source backup-service``

Notes:

- ``--privileged`` is required to grant the container access to the USB ports
- ``-v /dev:/dev`` makes the USB disk (dis)appear as device in the container

## Additional notes

It is always possible to start the backup script manually, by opening a shell in the Docker container and running the script:

``docker exec -it backup-service sh``

``/usr/local/bin/backup-runner``

The following one-liner should also work:

``docker exec backup-service /usr/local/bin/backup-runner``

## Troubleshooting

### First run of rsync copies very many files, that are already in the target directory

The first time rsync runs, many files may be synched, even though a copy of all files was already created at the target. This is because the option ``--archive`` makes rsync check the file modification times as well.

The timestamps for the source and the target files can be made identical by runnig the following script in the container when the USB-attached disk is mounted:

```sh
#!/bin/sh

find /mnt/source | while read file; do
  echo "Processing '${file/source/target}'"
  touch --reference "$file" "${file/source/target}"
done
```

Notes:

- ``find /mnt/source`` lists all files in /mnt/source
- `` | while read file`` reads the resulting lines one by done
- ``touch --reference <file>`` uses the timestamp of the referenced file, instead of the current time
- ``${file/source/target}`` modifies the variable ``$file``, replacing *source* with *target*

### Pushing the container to the Raspberry Pi fails

When pushing the container to the Raspberry Pi, resin may present the following question:

``Destination directory on device container [/usr/src/app]``

Rather than setting the destination directory, the file *.resin-sync.yml* should be removed and the push command repeated.
