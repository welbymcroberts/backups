# Mikrotik RouterOS Devices

RouterOS devices provide an number of different ways to extract configuration. There is the 'export' which provides the equivelent of a 'show running-config' on a Cisco device, and a file based backup, which can be used to restore a device directly

# Processes
## Backup
### Local
Backups are run from [NAS](/servers/nas/README.md) as part of a cronjob. This is run at 03:00 daily.

The script which is run is [backup.sh](/networking/mikrotik/backup.sh)

This script contains a array of devices with IP addresses

```
# List of devices "name:ip_or_dns"
devices=(
        "rb5009-1:100.65.0.1"
        "rb5009-2:100.65.0.2"
)
```

A new device would require a new line in the format of freindlyname:ipaddress.

The script then uses the SSH key which is stored in /backup/networking/ssh.ros, and connects as ${backupuser}.

The script will connect and then run multiple commands
* `/export compact` which is stored in `${date}.rosexport`
* `/system health print`, `/system routerboard print`, `/system history print`, `/system package print`, `/sys backup save dont-exncrypt=yes name=backup.backup`, the output from these commands are storeed in `${date}.system`
* SCP of `backup.backup` from router to ${date}.backup

### Cloud
Mikrotik offer a cloud backup of a RouterOS devices configuration. This is still a TODO to investigate.

## Restore
### Software requirements
No aditional software is required, as this is provides the native backup file, and a text based `/export` of the configuration

### Steps
#### Backup file

1. Upload the backup to the RouterOS device
2. `/system/backup/load name=${date}.backup`
3. Reboot the RouterOS device with `/system/reboot` if not already rebooting

#### Configuration export
1. Open a terminal to the RouterOS device
2. Paste the contents of the configuration file.
3. Reboot the RouterOS device with `/system/reboot`

# 3-2-1

**3-2-1**  Pass :white_check_mark:

## Locations
| Copy | Location  | Media | Immutable | Parent | By | Encrypted |
|------|-----------|-------|-----------|--------|----|-----------|
| 1 | On Device | Flash | :x: | Original | | :x: |
| 2 | [NAS](/servers/nas/README.md) | HDD [ZPool 'Backup'](/servers/nas/README.md#ZPool_backup) | :x: | 1 | [backup.sh](/networking/mikrotik/backup.sh) | :x: |
| 3 | [Synology](/servers/synology/README.md) | HDD [Volume 1'](/servers/synology/README.md#volume_1) | :x: | 2 | [to_syno.sh](/servers/nas/to_syno.sh) | :x: |
| 4 | [DW Synology](/servers/dw-synology/README.md) | HDD [Volume 1'](/servers/dw-synology/README.md#volume_1) | :x: | 3 | [Synology Hyper Backup](/servers/synology/README.md#Hyper_Backup) | :white_check_mark: By Hyper Backup |
| 5 | [Hetzner Storage Box](/cloud-services/hetzner-storage-box/README.md) | HDD | :x: | 3 | [Synology Hyper Backup](/servers/synology/README.md#Hyper_Backup) | :white_check_mark: By Hyper Backup |

# Restore test
## 2022-02-13
A test restore using configuration was performed for one device. 

Other devices were confirmed to be backing up with valid files.

Restore was from NAS, however file was also downloaded from Hyper Backup archive on [DW Synology](/servers/dw-synology/README.md) and [Hetzner Storage Box](/cloud-services/hetzner-storage-box/README.md) which confirms that [Synology](/servers/synology/README.md) also has a valid copy of the file due to the Chain being 1->2->3->4+5

# Backup job verification
TODO: Currently there is no verification that a job has been completed.


---
[Home](/README.md) | [Networking](/networking/README.md)
