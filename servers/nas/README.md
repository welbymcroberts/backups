# run.sh
This takes path lists from paths, and excludes those in paths.exclude and will rsync to the directory defined in paths

# to_syno.sh
Performs a similar role to run.sh, but copies the paths.syno paths to the synology nas as per paths.syno's desitination via SSH.
As the synoloyg doesn't seem to reliably allow ssh key based login, a custom 'rsh' is being used in rsync, syno_rsh.sh


# syno_rsh.sh
This simply uses sshpass, catting a password from a file, and ssh's to the device specified.


