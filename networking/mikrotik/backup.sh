#!/bin/bash

# User we connect as to the router
backupuser="backup"
# List of devices "name:ip_or_dns^healthcheck"
devices=(
        "rb5009-1:100.65.0.1^healthcheck.io/whatever"
        "rb5009-2:100.65.0.2^healthceck.io/whatever"
)
# Path to backup directory
dest="/backup/networking"
# Current date, in sensible format TODO: This won't work on some date implementations, such as MacOS
date=$(date --rfc-3339=date)

# Iterate over each device in array
for I in "${devices[@]}"; do

        # Get name from array
        device="${I%%:*}"
        # Get IP & Health from array
        ip_health="${I##*:}"
        # Get IP from array
        ip="${ip_health%%^*}"
        # Health
        health=https://"${ip_health##*^}"

        # Start healthcheck
        curl --retry 3 -s "${health}/start" -o /dev/null

        # Create directory for device backups
        mkdir -p "${dest}/${device}/${date}"

        # Log, and echo, that we're connecting
        logger "Connecting to ${device} on ${ip} with HC of ${health}"
	echo "Connecting to ${device} on ${ip} with HC of ${health}"

	# Via SSH do a export of configuration (text)
        if ! ssh ${backupuser}@"${ip}" -i /backup/networking/ssh.ros '/export compact' > "$dest/$device/$date/rosexport"; then curl --retry 3 -s "${health}"/${?} -o /dev/null; continue; fi

	# Via SSH get some stats (health, routerboard, resources, config history, package versions) and save to .system.
	# Also perform an unencrypted backup to backup.backup on router
        if ! ssh $backupuser@"$ip" -i /backup/networking/ssh.ros  '/system health print; :put "###"; /system routerboard pri; :put "###"; /system resource pri; :put "###"; /system history print det; :put "###"; /system package pri; :put "###"; /sys backup save dont-encrypt=yes name=backup.backup' > $dest/"$device"/"$date"/system; then curl --retry 3 -s "${health}"/${?} -o /dev/null; continue; fi
        
        # SCP backup.backup to .backup
        if ! scp -i /backup/networking/ssh.ros $backupuser@"$ip":/backup.backup $dest/"$device"/"$date"/backup > /dev/null; then curl --retry 3 -s "${health}"/${?} -o /dev/null; continue; fi

        # Log and Echo finished message
        echo "Finsihed ${device} on ${ip} with HC of ${health}"
	logger "Finished ${device} on ${ip} with HC of ${health}"

        if [ -s $dest/"$device"/"$date"/rosexport ] && [ -s $dest/"$device"/"$date"/system ] && [ -s $dest/"$device"/"$date"/backup ]; then
            curl --retry 3 -s "${health}" -o /dev/null
        else
            curl --retry 3 -s "${health}"/255 -o /dev/null
        fi


done
