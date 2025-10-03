#!/bin/bash

# curl command to use
curl="curl --retry 5 -fsS -m 10 -o /dev/null "
# User we connect as to the router
backupuser="backup"
# List of devices "name:ip_or_dns^healthcheck"
devices=(
        "rb5009-1:100.65.0.1^healthcheck.io/whatever"
        "rb5009-2:100.65.0.2^healthceck.io/whatever"
)
# Path to backup directory
dest="/backup/networking/mikrotik/"
# Current date, in sensible format TODO: This won't work on some date implementations, such as MacOS
date=$(date --rfc-3339=date)
# Healthcheck for git
HCURL="https://whatever/"

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
        ${curl} "${health}/start"

        # Create directory for device backups
        mkdir -p "${dest}/${device}/${date}"
        mkdir -p "${dest}/current/${device}"

        # Log, and echo, that we're connecting
        logger "Connecting to ${device} on ${ip} with HC of ${health}"
	echo "Connecting to ${device} on ${ip} with HC of ${health}"

	# Via SSH do a export of configuration (text)
        if ! ssh ${backupuser}@"${ip}" -i /backup/networking/ssh.ros '/export compact' > "$dest/$device/$date/rosexport"; then ${curl} "${health}"/${?} --data-raw "Failed getting /export"; continue; fi

	# Via SSH get some stats (health, routerboard, resources, config history, package versions) and save to .system.
 	# Some devices don't have /system health, check first
	# Also perform an unencrypted backup to backup.backup on router
 	if ssh $backupuser@"$ip" -i /backup/networking/ssh.ros  '/system health print' > /dev/null 2>&1; then
		if ! ssh $backupuser@"$ip" -i /backup/networking/ssh.ros  '/system health print; :put "###"; /system routerboard pri; :put "###"; /system resource pri; :put "###"; /system history print det; :put "###"; /system package pri; :put "###"; /sys backup save dont-encrypt=yes name=backup.backup' > ${dest}/"${device}"/"${date}"/system; then ${curl} "${health}"/${?} --data-raw "Failed creating backup"; continue; fi
	else
 		if ! ssh $backupuser@"$ip" -i /backup/networking/ssh.ros  '/system routerboard pri; :put "###"; /system resource pri; :put "###"; /system history print det; :put "###"; /system package pri; :put "###"; /sys backup save dont-encrypt=yes name=backup.backup' > ${dest}/"${device}"/"${date}"/system; then ${curl} "${health}"/${?} --data-raw "Failed creating backup"; continue; fi
   	fi
        
        # SCP backup.backup to .backup
        if ! scp -i /backup/networking/ssh.ros $backupuser@"$ip":/backup.backup ${dest}/"${device}"/"${date}"/backup > /dev/null; then ${curl} "${health}"/${?} --data-raw "Failed retreiving backup"; continue; fi

        if [ -s ${dest}/"${device}"/"${date}"/rosexport ] && [ -s ${dest}/"${device}"/"${date}"/system ] && [ -s ${dest}/"${device}"/"${date}"/backup ]; then
	    # Copy export, ignoring the first line, to current
            if ! tail -n +2 ${dest}/${device}/${date}/rosexport > "${dest}/current/${device}/rosexport"; then ${curl} "${health}"/${?} --data-raw "Failed copying to current"; continue; fi
            # Success
            ${curl} "${health}"
        else
            ${curl} "${health}"/255 --data-raw "File sizes are zero bytes";
            continue;
        fi

        # Log and Echo finished message
        echo "Finsihed ${device} on ${ip} with HC of ${health}"
	logger "Finished ${device} on ${ip} with HC of ${health}"

done


# Check if git has a name / email
if $(git config user.email > /dev/null) && $(git config user.name > /dev/null); then
    cd $dest/current
    # Create git repo if it doesnt exsit
    if [ ! -d ${dest}/current/.git ]; then git init && git config --local core.whitespace cr-at-eol; fi
    # Add everything in the directory
    git add .
    # Commit
    git commit -m "Updated config from cron"
    cd -
    ${curl} "${HCURL}"
else
    ${curl} "${HCURL}"/254 --data-raw "Git is not configured"
fi

