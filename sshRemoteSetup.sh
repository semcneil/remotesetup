#!/bin/bash
#
# sshRemoteSetup.sh
#
# Runs remote scripts via ssh using information from a file
#
# Usage:
#  ./sshRemoteSetup.sh xxx_Machine_Info.txt sudoUsername sudoPwd path-to-ssh-pvt-key path-to-remoteScript
#
# This assumes that the xxx_Machine_Info.txt has the following columns separated by spaces:
#  desired-host-name in the form basename-newUserName
#  ip-address
#  MAC-address (not used)
#  password for newUserName
#
# The first three columns of xxx_Machine_Info.txt are returned from our 
# typical Hyper-V VM duplication script.
#
# Seth McNeill
# 2021 January 10

# https://www.cyberciti.biz/faq/unix-howto-read-line-by-line-from-file/
while IFS=' ' read -ra line # reads line into an array using ' ' as separator
do
  echo "========================="
  # https://stackoverflow.com/questions/15148796/get-string-after-character
  user=`cut -d "-" -f2- <<< "${line[0]}"`
  ip=${line[1]}
  newPass=${line[3]}
  hostname=${line[0]}
  echo "hostname: $hostname"
  # https://stackoverflow.com/questions/43167317/how-to-get-the-first-element-of-a-string-split-with-space
#  echo "basename: ${line[0]%%-*}"
  echo "username: $user"
  echo "IP addr:  $ip"
  echo "Password: $newPass"

  # copy the script to the remote computer
  scp -i $4 $5 $2@$ip:~/

  # https://stackoverflow.com/questions/3162385/how-to-split-a-string-in-shell-and-get-the-last-field
  script_with_path=$5
  scriptname=${script_with_path##*/}
  
  # Run the remote script, the final ENDSSH has to be at the beginning of the line
  ssh -i $4 $2@$ip NEW_HOST=$hostname NEW_USER=$user NEW_PASS="'$newPass'" SCRIPT=$scriptname SUDO_PASS="$'$3'" 'bash -s ' << 'ENDSSH'
    echo $SUDO_PASS | sudo -S ~/$SCRIPT $NEW_HOST $NEW_USER $NEW_PASS reboot
ENDSSH

done < "$1"
