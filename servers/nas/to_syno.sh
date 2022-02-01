#!/bin/sh
# TODO: Healthchecks start
for PATHA in `cat paths.syno`; do
	PATHB=${PATHA%*:*}
	echo "Backing up ${PATHB%*:*} to ${PATHA#*:*}"
	rsync --delete -av --progress ${PATHB%*:*} ${PATHA#*:*} -e ./syno_rsh.sh
done
# TODO: Healthchecks end
