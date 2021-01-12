#!/usr/bin/bash
#
# setHostUser.sh
#
# This script sets the hostname and adds a sudo user
# on this computer.
#
# Use:
#  setHostUser.sh newHostname username password
#
# should use scp to copy this file to the remote host
# prior to running it so it is in a known state
# or better yet, clone it from github...
#
# Seth McNeill
# 2021 January 10

# Good reference on bash arguments:
# https://www.baeldung.com/linux/use-command-line-arguments-in-bash-script

echo "Starting $0"
# change /etc/hostname
oldHost=`hostname`
echo "changing hostname from $oldHost to $1"
sed -i "s/$oldHost/$1/g" /etc/hostname

# change /etc/hosts
sed -i "s/$oldHost/$1/g" /etc/hosts

# add user
useradd $2 -m -s /bin/bash
adduser $2 sudo

# change user's password
echo "Going to change password"
echo "$2:$3"  # to make sure that the password transferred correctly
echo "$2:$3" | sudo chpasswd

# reboot
# https://stackoverflow.com/questions/6482377/check-existence-of-input-argument-in-a-bash-shell-script
if [ ! -z $4 ] && [ $4 = "reboot" ]
  then
    echo "You want to reboot"
    reboot
fi
