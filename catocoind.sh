#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2018
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# Run this file
# if skip_last_confirm is set use bash -c instead of bash -ic
# bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/catocoind.sh)" -- starting_username_number txhash outputindex genkey skip_last_confirm ; source ~/.bashrc
# screen -d -m bash -c "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/catocoind.sh)" -- -1 0 -1 -1 Y ; source ~/.bashrc
# bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/catocoind.sh)" ; source ~/.bashrc

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/catocoind.sh)" ; source ~/.bashrc
```

'

# Directory
DIRECTORY='.catocoin2'
# Port
DEFAULT_PORT=34888
# Conf File
CONF='catocoin2.conf'
# Display Name
DAEMON_NAME='CatoCoin'
# Github user and project.
GITHUB_REPO='CatoCoin/CatoCoin'
# Direct Daemon Download if github has no releases.
DAEMON_DOWNLOAD='https://github.com/CatoCoin/releases/raw/master/cato-linux.tar.gz'
# Binary base name.
BIN_BASE='catocoin'
# Username Prefix
DAEMON_PREFIX='cato_mn'
# RPC username
RPC_USERNAME='catocoin'
# Explorer URL
EXPLORER_URL='http://explorer.catocoin.info/'
# Log filename
DAEMON_SETUP_LOG='/tmp/cato.log'
# Masternode output file.
DAEMON_SETUP_INFO="${HOME}/cato.mn.txt"
# Project Folder
PROJECT_DIR='CatoCoin'
# Amount of Collateral needed
COLLATERAL=$(wget -4qO- -o- "${EXPLORER_URL}/api/getinfo" | grep 'MN collateral' | cut -d ':' -f2 | sed 's/ //g' |  sed 's/,//g')
# Coin Ticker
TICKER='CATO'
# Tip Address
TIPS='CbExC5RLwSghSNEq8pwDtiTS32Ngr8qquw'
# Dropbox Addnodes
DROPBOX_ADDNODES='8ejwde780f45q6u'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap
DROPBOX_BOOTSTRAP='0qk6sxfx02eyi76'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='8gd968uig7skwb4'
# Cycle Daemon
DAEMON_CYCLE=0
# Fallback Blockcount
BLOCKCOUNT_FALLBACK_VALUE=130000
# Slow Daemon Start.
SLOW_DAEMON_START=0
# Bad Explorer SSL.
BAD_SSL_HACK=''
# Extra configuation for the conf file.
EXTRA_CONFIG=''
# Auto Recovery.
RESTART_IN_SYNC=1
# Multiple on single IP.
MULTI_IP_MODE=1
# Number of Connections to wait for.
DAEMON_CONNECTIONS=4
# Wait for MNSYNC
#MNSYNC_WAIT_FOR='"RequestedMasternodeAssets": 999,'
MNSYNC_WAIT_FOR=''
# Run Mini Monitor.
MINI_MONITOR_RUN=1
# Mini Monitor check masternode list.
MINI_MONITOR_MN_LIST=1
# Mini Monitor Status to check for.
MINI_MONITOR_MN_STATUS='4'
# Mini Monitor Queue Payouts.
MINI_MONITOR_MN_QUEUE=1
# Mini Monitor masternode count is a json string.
MINI_MONITOR_MN_COUNT_JSON=1

# Log to a file.
rm -f "${DAEMON_SETUP_LOG}"
touch "${DAEMON_SETUP_LOG}"
chmod 600 "${DAEMON_SETUP_LOG}"
exec >  >(tee -ia "${DAEMON_SETUP_LOG}")
exec 2> >(tee -ia "${DAEMON_SETUP_LOG}" >&2)

ASCII_ART () {
echo -e "\\e[0m"
clear 2> /dev/null
cat << "CATOCOIN"

 __         __
/   _ |_ _ /   _ . _
\__(_||_(_)\__(_)|| )


CATOCOIN
}

SENTINEL_SETUP () {
  echo
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
