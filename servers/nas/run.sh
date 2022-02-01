#!/bin/sh
# TODO: Healthchecks start

# Paths to exclude
EXCLUDE=$(cat paths.exclude)

# For paths in paths file
for PATHA in $(cat paths); do
        # Echo backup info, and rsync command that is to be run
	echo "Backing up ${PATHA%*:*} to ${PATHB#*:*}"
	echo rsync -av ${PATHA%*:*} ${PATHB#*:*} --exclude $EXCLUDE
        # perform rsync
	rsync -av ${PATHA%*:*} ${PATHA#*:*} --exclude ${EXCLUDE}
done

# TODO: Healthchecks end
