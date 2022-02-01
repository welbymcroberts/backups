#!/bin/bash

# User we connect as to the router
backupuser="backup"
# List of devices "name:ip_or_dns"
devices=(
        "rb5009-1:100.65.0.1"
        "rb5009-2:100.65.0.2"
)
# Path to backup directory
dest="/backup/networking"
# Current date, in sensible format TODO: This won't work on some date implementations, such as MacOS
date=`date --rfc-3339=date`

# Iterate over each device in array
for I in "${devices[@]}"; do
	# TODO: Healthchecks started
        # Get name from array
        device="${I%%:*}"
        # Get IP from array
        ip="${I##*:}"
        # Create directory for device backups
        mkdir -p $dest/$device
        # Log, and echo, that we're connecting
        logger "Connecting to $I"
        echo "Connecting to $I"

	# Via SSH do a export of configuration (text)
        ssh $backupuser@$ip -i /backup/networking/ssh.ros '/export compact' > $dest/$device/$date.rosexport
	# Via SSH get some stats (health, routerboard, resources, config history, package versions) and save to .system.
	# Also perform an unencrypted backup to backup.backup on router	
        ssh $backupuser@$ip -i /backup/networking/ssh.ros  '/system health print; :put "###"; /system routerboard pri; :put "###"; /system resource pri; :put "###"; /system history print det; :put "###"; /system package pri; :put "###"; /sys backup save dont-encrypt=yes name=backup.backup' > $dest/$device/$date.system
        # SCP backup.backup to .backup
        scp -i /backup/networking/ssh.ros $backupuser@$ip:/backup.backup $dest/$device/$date.backup > /dev/null
        # Log and Echo finished message
        echo "Finished $I"
        logger "Finished $I"
	# TODO: Healthchecks completed
done
