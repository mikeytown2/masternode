#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2018
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/stakeshared.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='stakeshare-core/stakeshare'
# Display Name.
DAEMON_NAME='StakeShare Core'
# Coin Ticker.
TICKER='SSX'
# Binary base name.
BIN_BASE='stakeshare'
# Directory.
DIRECTORY='.stakeshare'
# Conf File.
CONF='stakeshare.conf'
# Port.
DEFAULT_PORT=5515
# Amount of Collateral needed.
COLLATERAL=2000
# Explorer URL
EXPLORER_URL='http://explorer.stakeshare.io/'
# Cycle Daemon
DAEMON_CYCLE=1
# Fallback Blockcount
BLOCKCOUNT_FALLBACK_VALUE=60000

# Tip Address
TIPS='SUJMipVM4P3osy1k1ptfJRDwX7RZZzrt76'
# Dropbox Addnodes
DROPBOX_ADDNODES='nzga4ytczi2bnc8'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap
DROPBOX_BOOTSTRAP='95twbhmv3k5gb4t'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='tcm9jn259h83ihg'

# Multiple on single IP.
MULTI_IP_MODE=1
IPV6=1
# Mini Monitor check masternode list.
MINI_MONITOR_MN_LIST=1
# Mini Monitor Status to check for.
MINI_MONITOR_MN_STATUS='4'
# Mini Monitor masternode count is a json string.
MINI_MONITOR_MN_COUNT_JSON=1

ASCII_ART () {
echo -e "\\e[0m"
clear 2> /dev/null
cat << "STAKESHARE"
 _______________________ _       _______ _______         _______ _______ ______
(  ____ \__   __(  ___  | |   /(  ____ (  ____ |\     /(  ___  (  ____ (  ____ \
| (    \/  ) (  | (   ) | |  / | (    \| (    \| )   ( | (   ) | (    )| (    \/
| (_____   | |  | (___) | (_/ /| (__   | (_____| (___) | (___) | (____)| (__
(_____  )  | |  |  ___  |  _ ( |  __)  (_____  |  ___  |  ___  |     __|  __)
      ) |  | |  | (   ) | ( \ \| (           ) | (   ) | (   ) | (\ (  | (
/\____) |  | |  | )   ( | |  \ | (____//\____) | )   ( | )   ( | ) \ \_| (____/\
\_______)  )_(  |/     \|_|   \(_______\_______|/     \|/     \|/   \__(_______/

STAKESHARE
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
