#!/bin/bash

# curl command to use
curl="curl --retry 5 -fsS -m 10 -o /dev/null "

# User we connect as to the router
backupuser="backup"

# List of devices "name:ip_or_dns^healthcheck"
devices=(
        "fb-1:100.64.0.1^something"
)

# Path to backup directory
dest="/backup/networking/firebrick/"

# Current date, in sensible format TODO: This won't work on some date implementations, such as MacOS
date=$(date --rfc-3339=date)

HCURL="something"




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

    # Perform a curl
    curl --retry 5 -fsS -m 10 -o "${dest}/${device}/${date}"/config.xml --user "$(cat /backup/scripts/networking/firebrick/.firebrickcreds)"  http://${ip}/config/config


    # Check output is >0 bytes
    if [ -s ${dest}/"${device}"/"${date}"/config.xml ]; then
	# Copy export, ignoring the first line, to current
    if ! cat ${dest}/"${device}"/"${date}"/config.xml  > "${dest}/current/${device}/config.xml"; then ${curl} "${health}"/${?} --data-raw "Failed copying to current"; continue; fi
    else
        ${curl} "${health}"/255 --data-raw "File sizes are zero bytest";
        continue;
    fi




    # Get graphs
    if ! wget --quiet --auth-no-challenge --no-if-modified-since -P ${dest}/"${device}"/ --no-parent -nH --cut-dirs=1 --mirror "http://$(cat /backup/scripts/networking/firebrick/.firebrickcreds)@${ip}/cqm/$(date +%F -dyesterday)/z/"; then
        ${curl} "${health}"/${?} --data-raw "Failed retreiving CQM graphs";
    else
        # Success
	${curl} "${health}"
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