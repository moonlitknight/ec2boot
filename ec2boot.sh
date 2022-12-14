#!/usr/bin/bash
#
# ec2 boot script
# see https://linuxconfig.org/how-to-run-script-on-startup-on-ubuntu-20-04-focal-fossa-server-desktop
# installed with ...
#
#



set -x
cd /ec2boot
if [ -z "$1" ]
then
        git pull
        /ec2boot/ec2boot.sh -2 
        exit
fi

# 2nd pass after git pull
hostname=`hostname`
if [ "${hostname:-:3}" == "ec2" ]
then
        echo "hostname $hostname"
else
        hostname ec2d
fi
killall dockerd           # we don't want docker running until shared is mounted
if [ ! -d /shared/jails ]       # if shared not mounted, wait to give me time to attach the volume, then rerun
then
        sleep 2
        mount /shared
        /ec2boot/ec2boot.sh -3
        exit
fi
# do the startup stuff
echo running the rest of the startup stuff in 1 minute
at now + 2 minutes << EOF
 PATH=$PATH:/bin:/usr/bin:/sbin:/usr/sbin:/shared/scripts
 /shared/scripts/jailboot.sh all
EOF
atq


