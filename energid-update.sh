#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2018
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# Run this file
# bash -i <(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/energid-update.sh) ; source ~/.bashrc

# Github user and project.
GITHUB_REPO='energicryptocurrency/energi'
# Display Name.
DAEMON_NAME='Energi Core'
# Coin Ticker.
TICKER='NRG'
# Binary base name.
BIN_BASE='energi'
# Directory.
DIRECTORY='.energicore'
# Conf File.
CONF='energi.conf'
# Port.
DEFAULT_PORT=9797
# Amount of Collateral needed.
COLLATERAL=10000
# Explorer URL.
EXPLORER_URL='https://explore.energi.network/'
# Direct Daemon Download if github has no releases.
DAEMON_DOWNLOAD=''

ASCII_ART () {
stty sane
echo
cat << "ENERGI"
      ___
     /\  \
    /::\  \
   /:/\:\__\
  /:/ /:/ _/_
 /:/ /:/ /\__\
 \:\ \/ /:/  /
  \:\  /:/  /   ____ __  __  ____ ____    ___  __
   \:\/:/  /   ||    ||\ || ||    || \\  // \\ ||
    \::/  /    ||==  ||\\|| ||==  ||_// (( ___ ||
     \/__/     ||___ || \|| ||___ || \\  \\_|| ||

ENERGI
}

# Discord User Info
# @mcarper#0918
# 401161988744544258
cd ~/ || exit
ASCII_ART
COUNTER=0
rm -f ~/___mn.sh
while [[ ! -f ~/___mn.sh ]] || [[ $( grep -Fxc "# End of masternode setup script." ~/___mn.sh ) -eq 0 ]]
do
  rm -f ~/___mn.sh
  echo "Downloading Masternode Setup Script."
  wget -4qo- goo.gl/uQw9tz -O ~/___mn.sh
  COUNTER=$((COUNTER+1))
  if [[ "${COUNTER}" -gt 3 ]]
  then
    echo
    echo "Download of masternode setup script failed."
    echo
    exit 1
  fi
done

(
  sleep 2
  rm ~/___mn.sh
) & disown

# shellcheck disable=SC1091
# shellcheck source=/root/___mn.sh
. ~/___mn.sh
# shellcheck source=/root/.bashrc
source ~/.bashrc
source /var/multi-masternode-data/.bashrc
source /var/multi-masternode-data/___temp.sh

MN_USRNAME=''
find /home/* -maxdepth 0 -type d | tr '/' ' ' | awk '{print $2}' | while read -r MN_USRNAME
do
  IS_EMPTY=$( type "${MN_USRNAME}" 2>/dev/null )
  if [ -z "${IS_EMPTY}" ] || [[ $( "${MN_USRNAME}" daemon ) != 'energid' ]]
  then
    continue
  fi
  echo "Working on ${MN_USRNAME}"
  CONF_FILE=$( "${MN_USRNAME}" conf loc )
  if [[ $( "${MN_USRNAME}" conf | grep -c 'github_repo' ) -eq 0 ]]
  then
    echo "# github_repo=${GITHUB_REPO}" >> "${CONF_FILE}"
  fi
  if [[ $( "${MN_USRNAME}" conf | grep -c 'bin_base' ) -eq 0 ]]
  then
    echo "# bin_base=${BIN_BASE}"  >> "${CONF_FILE}"
  fi
  if [[ $( "${MN_USRNAME}" conf | grep -c 'daemon_download' ) -eq 0 ]]
  then
    echo "# daemon_download=${DAEMON_DOWNLOAD}"  >> "${CONF_FILE}"
  fi

  if [[ $( sudo su - "${MN_USRNAME}" -c 'crontab -l' 2>/dev/null | grep -cF "${MN_USRNAME} update_daemon 2>&1" ) -eq 0  ]]
  then
    echo 'Setting up crontab for auto updating in the future.'
    MINUTES=$((RANDOM % 60))
    sudo su - "${MN_USRNAME}" -c " ( crontab -l 2>/dev/null ; echo \"${MINUTES} */6 * * * bash -ic 'source /var/multi-masternode-data/.bashrc; ${MN_USRNAME} update_daemon 2>&1'\" ) | crontab - "
  fi

  "${MN_USRNAME}" update_daemon
done

# shellcheck source=/root/.bashrc
. ~/.bashrc
stty sane
