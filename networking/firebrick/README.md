# Firebrick Devices

[Firebrick](https://www.firebrick.co.uk) devices use a XML based connfiguration which is easily backed up via HTTPS. They also store CQM graphs in memory, which it is benefitial to have backed up.

# Processes
## Backup
### Local
Backups are run from [NAS](/servers/nas/README.md) as part of a systemd timer. This is run daily.

The script which is run is [backup.sh](/networking/firebrick/backup.sh)

This script contains a array of devices with IP addresses and 'healthcheck' URLs

```
# List of devices "name:ip_or_dns^url_for_healthcheck"
devices=(
        "fb2900-1:100.65.0.1^healthcheck/ping"
)
```

A new device would require a new line in the format of freindlyname:ipaddress^healthcheck.

The script will use CURL to get the configuration from the device at URL `http://${IP}/config/config` using the username and password in `/backup/scripts/networking/firebrick/.firebrickcreds` This file should be secured with the appropriate permissions ( 0600 )

The script will connect and then run
* `show running-config` which is stored in `${date}/show_running`
* Using wget get a copy of all of yesterdays CQM graphs on the device
* A copy is also commited to the git repo in `current/`
  
## Restore
### Software requirements
To perform a backup CURL and wget is required. These are FOSS.
No aditional software is required to restore, as this is provides a XML file based copy of the configuration

### Steps
#### Configuration export
1. Open a webbrowser to the device on http://${IP}/config/xmledit
2. Paste the contents of the configuration file and click save.
3. Reboot the device

# 3-2-1

**3-2-1**  Pass :white_check_mark:

## Locations
| Copy | Location  | Media | Immutable | Parent | By | Encrypted |
|------|-----------|-------|-----------|--------|----|-----------|
| 1 | On Device | Flash | :x: | Original | | :x: |
| 2 | [NAS](/servers/nas/README.md) | HDD [ZPool 'Backup'](/servers/nas/README.md#ZPool_backup) | :x: | 1 | [backup.sh](/networking/aruba/backup.sh) | :x: |
| 3 | [Synology](/servers/synology/README.md) | HDD [Volume 1'](/servers/synology/README.md#volume_1) | :x: | 2 | [to_syno.sh](/servers/nas/to_syno.sh) | :x: |
| 4 | [DW Synology](/servers/dw-synology/README.md) | HDD [Volume 1'](/servers/dw-synology/README.md#volume_1) | :x: | 3 | [Synology Hyper Backup](/servers/synology/README.md#Hyper_Backup) | :white_check_mark: By Hyper Backup |
| 5 | [Hetzner Storage Box](/cloud-services/hetzner-storage-box/README.md) | HDD | :x: | 3 | [Synology Hyper Backup](/servers/synology/README.md#Hyper_Backup) | :white_check_mark: By Hyper Backup |

# Restore test
## 2022-02-25
A test restore using configuration was performed for one device. 

Other devices were confirmed to be backing up with valid files.

Restore was from NAS, however file was also downloaded from Hyper Backup archive on [DW Synology](/servers/dw-synology/README.md) and [Hetzner Storage Box](/cloud-services/hetzner-storage-box/README.md) which confirms that [Synology](/servers/synology/README.md) also has a valid copy of the file due to the Chain being 1->2->3->4+5

# Backup job verification
Whilst the backup is not checked that it is 'valid', a non zero size is checked for each file, and a health check is sent to healthchecks.io. If these are not run within a predefined time frame, or an error occurs an alert will be sent.

# Install
1. Place files in `/backup/scripts/networking/firebrick/` (or update scripts to reflect this)
2. Copy systemd unit file to your systemd unit path, for example `/lib/systemd/system`
3. Copy systemd timer file to your systemd unit path, for example `/lib/systemd/system`
4. Create the ``/backup/scripts/networking/firebrick/.firebrickcreds` file with the username:password to be used.
5. Create any healthchecks for each device.
6. Enable the timer `systemctl enable --now backup-firebrick.timer`

---
[Home](/README.md) | [Networking](/networking/README.md)
