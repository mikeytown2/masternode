#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2018
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/energid.sh)" ; source ~/.bashrc
```

'

# Directory.
DIRECTORY='.energicore'
# Port.
DEFAULT_PORT=9797
# Conf File.
CONF='energi.conf'
# Display Name.
DAEMON_NAME='Energi Core'
# Github user and project.
GITHUB_REPO='energicryptocurrency/energi'
# Binary base name.
BIN_BASE='energi'
# Direct Daemon Download if github has no releases.
DAEMON_DOWNLOAD=''
# Username Prefix.
DAEMON_PREFIX='enrg_mn'
# RPC username.
RPC_USERNAME='energi'
# Explorer URL.
EXPLORER_URL='https://explore.energi.network/'
# Log filename.
DAEMON_SETUP_LOG='/tmp/enrg.log'
# Masternode output file.
DAEMON_SETUP_INFO="${HOME}/enrg.mn.txt"
# Project Folder.
PROJECT_DIR='energi'
# Amount of Collateral needed.
COLLATERAL=10000
# Coin Ticker.
TICKER='NRG'
# Tip Address.
TIPS='EfQZJxx86Xa2DqzP9Hdgv7HQe1MtYzQpDC'
# Dropbox Addnodes.
DROPBOX_ADDNODES='ayu1r026swtmoat'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='j9wb0stn3c6nwyf'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='gsaqiry3h1ho3nh'
# Cycle Daemon.
DAEMON_CYCLE=0
# Slow Daemon Start.
SLOW_DAEMON_START=1
# Fallback Blockcount.
BLOCKCOUNT_FALLBACK_VALUE=200000
# Bad Explorer SSL.
BAD_SSL_HACK='--no-check-certificate'
# Extra configuation for the conf file.
EXTRA_CONFIG='maxconnections=24'
# Auto Recovery.
RESTART_IN_SYNC=0
# Multiple on single IP.
MULTI_IP_MODE=3
# Number of Connections to wait for.
DAEMON_CONNECTIONS=4
# Wait for MNSYNC
MNSYNC_WAIT_FOR='"AssetName": "MASTERNODE_SYNC_FINISHED"'
# Run Mini Monitor.
MINI_MONITOR_RUN=1
# Mini Monitor check masternode list.
MINI_MONITOR_MN_LIST=0
# Mini Monitor Status to check for.
MINI_MONITOR_MN_STATUS='Masternode successfully started'
# Mini Monitor Queue Payouts.
MINI_MONITOR_MN_QUEUE=1
# Mini Monitor masternode count is a json string.
MINI_MONITOR_MN_COUNT_JSON=0

# Log to a file.
rm -f "${DAEMON_SETUP_LOG}"
touch "${DAEMON_SETUP_LOG}"
chmod 600 "${DAEMON_SETUP_LOG}"
exec >  >(tee -ia "${DAEMON_SETUP_LOG}")
exec 2> >(tee -ia "${DAEMON_SETUP_LOG}" >&2)


ASCII_ART () {
echo -e "\\e[0m"
clear 2> /dev/null
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

SENTINEL_SETUP () {
  local USRNAME
  USRNAME=$1

  # Get Repo.
  echo
  echo "Getting energicryptocurrency sentinel github project."
  sudo mkdir -p "/home/${USRNAME}/sentinel/"
  git clone https://github.com/energicryptocurrency/sentinel.git "/home/${USRNAME}/sentinel/"
  git -C "/home/${USRNAME}/sentinel/" clean -x -f -d
  git -C "/home/${USRNAME}/sentinel/" reset --hard
  git -C "/home/${USRNAME}/sentinel/" pull
  git -C "/home/${USRNAME}/sentinel/" reset --hard
  sudo chown -R "${USRNAME}":"${USRNAME}" "/home/${USRNAME}/"

  # Install needed software.
  WAIT_FOR_APT_GET
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    virtualenv \
    python-virtualenv

  # Setup virtualenv venv and requirements.
  sudo su - "${USRNAME}" -c 'cd ~/sentinel ; virtualenv venv ; venv/bin/pip install -r requirements.txt'
  sudo su - "${USRNAME}" -c 'cd ~/sentinel ; venv/bin/python bin/sentinel.py'
  echo "energi_conf=/home/${USRNAME}/.energicore/energi.conf" | sudo tee -a /home/"${USRNAME}"/sentinel/sentinel.conf >/dev/null

  # Add Crontab if not set.
  if [[ $( sudo su - "${USRNAME}" -c 'crontab -l' | grep -cF "* * * * * cd /home/${USRNAME}/sentinel/ ; /home/${USRNAME}/sentinel/venv/bin/python /home/${USRNAME}/sentinel/bin/sentinel.py 2>&1 >> sentinel-cron.log" ) -eq 0  ]]
  then
    echo 'Setting up crontab for sentinel.'
    sudo su - "${USRNAME}" -c " ( crontab -l ; echo \"* * * * * cd /home/${USRNAME}/sentinel/ ; /home/${USRNAME}/sentinel/venv/bin/python /home/${USRNAME}/sentinel/bin/sentinel.py 2>&1 >> sentinel-cron.log\" ) | crontab - "
    # Show crontab contents.
    sudo su - "${USRNAME}" -c 'crontab -l'
  fi
}

# Discord User Info
# @mcarper#0918
# 401161988744544258
cd ~/ || exit
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
DAEMON_SETUP_THREAD
# shellcheck source=/root/.bashrc
. ~/.bashrc
stty sane
