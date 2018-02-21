FROM alpine

# Install tools and libs from repo
RUN apk add --no-cache rsync libusb

# Install USB power controller and backup script files
WORKDIR /usr/local/bin

COPY "uhubctl-rpi" "backup-runner.sh" "backup.sh" "rsync.exclude" "./"
RUN chmod +x *.sh uhubctl-rpi

# Prepare mounts for external volumes
RUN mkdir /mnt/target /mnt/source

# Install cronjob and make it active
COPY backup.cron /etc/crontabs/root

# Start crond in the foreground with maximum logging
ENTRYPOINT ["crond", "-f", "-l0"]
