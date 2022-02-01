#!/bin/bash
sshpass -p `cat syno.password` ssh $@
