# backups
## Servers
#### Containers
#### Services
##### Service 1
##### Service 2
## Synology
## NAS
## Infrastructure
### Networking
#### Mikrotik Devices
Backup'ed up nightly on NAS to /backup/networking/<name> via networking/mikrotik/backup.sh, run on NAS with a systemd timer

| Copy | Location | Media |
| ---- | -------- | ----- |
| 1    | Device   | Flash |
| 2    | NAS      | HDD   |
| 3    | Synology | HDD   |
| 4    | Don-Syno | HDD   |


#### Firebrick CQM Graphs
Backup'ed up nightly on NAS to /backup/networking/firebrick/graphs/<ip>/ via networking/firebrick/graphs.sh, run on NAS with a systemd timer

| Copy | Location | Media |
| ---- | -------- | ----- |
| 1    | Device   | Flash |
| 2    | NAS      | HDD   |
| 3    | Synology | HDD   |
| 4    | Don-Syno | HDD   |


