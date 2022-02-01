#!/bin/bash
mkdir -p /backup/networking/firebrick/graphs/fb2900-1 /backup/networking/firebrick/graphs/fb2900-1

cd /backup/networking/firebrick/graphs/fb2900-1
wget --quiet --no-parent --mirror http://192.168.3.10/cqm/`date +%F -dyesterday`/z/

cd /backup/networking/firebrick/graphs/fb2900-1
wget --quiet --no-parent --mirror http://192.168.3.11/cqm/`date +%F -dyesterday`/z/
