#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2018
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# Run this file
# bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/qmcd-update.sh)" ; source ~/.bashrc

# Github user and project.
GITHUB_REPO='project-qmc/QMC'
# Explorer URL
EXPLORER_URL='http://explorer.qmc.network/'
# Rate limit explorer
EXPLORER_SLEEP=1
# Directory
DIRECTORY='.qmc2'
# Binary base name.
BIN_BASE='qmc'
# Port
DEFAULT_PORT=28443
# Conf File
CONF='qmc2.conf'
# Display Name
DAEMON_NAME='QMCoin'
# Coin Ticker
TICKER='QMC'
# Amount of Collateral needed
COLLATERAL=$(wget -4qO- -o- "${EXPLORER_URL}api/getinfo" | grep 'MN collateral' | cut -d ':' -f2 | sed 's/ //g' |  sed 's/,//g')
# Fallback Blockcount
BLOCKCOUNT_FALLBACK_VALUE=59000
# Multiple on single IP.
MULTI_IP_MODE=3

ASCII_ART () {
echo -e "\\e[0m"
clear 2> /dev/null
cat << "QMCoin"
 _      _
/ \|\/|/  _ o._
\_X|  |\_(_)|| |

QMCoin
}

# Tip Address
TIPS='Qji2oZBD2QzZ3Nk5q4ickFpDYfSLSAtG5q'
# Dropbox Addnodes
DROPBOX_ADDNODES='xbgib98dzd005df'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap
DROPBOX_BOOTSTRAP='0yz7z1zt6752rr2'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='gckue7v4ytq791c'

# Mini Monitor check masternode list.
MINI_MONITOR_MN_LIST=1
# Mini Monitor Status to check for.
MINI_MONITOR_MN_STATUS='4'
# Mini Monitor Queue Payouts.
MINI_MONITOR_MN_QUEUE=1
# Mini Monitor masternode count is a json string.
MINI_MONITOR_MN_COUNT_JSON=1

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
. ~/.bashrc
UPDATE_DAEMON_ADD_CRON "${BIN_BASE}" "${GITHUB_REPO}" "${CONF_FILE}" "${DAEMON_DOWNLOAD}"
# shellcheck source=/root/.bashrc
. ~/.bashrc
stty sane
