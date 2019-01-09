#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2018
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/craved.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='Crave-Project/Crave-NG'
# Display Name.
DAEMON_NAME='Crave'
# Coin Ticker.
TICKER='CRAV'
# Binary base name.
BIN_BASE='crave'
# Directory.
DIRECTORY='.craveng'
# Conf File.
CONF='crave.conf'
# Port.
DEFAULT_PORT=48882
# Explorer URL
EXPLORER_URL='http://explorer.craveproject.net/'
# Amount of Collateral needed.
COLLATERAL=5000
# Cycle Daemon on first start.
DAEMON_CYCLE=1

# Tip Address
TIPS='VQpV3agw3LwhNJeZpuQFidWGwao2PKLPLz'
# Dropbox Addnodes
DROPBOX_ADDNODES='4dcu0mwtl4c10vq'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap
DROPBOX_BOOTSTRAP='two26u19dz1wm8i'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='ix72th3bwmrsotk'

# Multiple on single IP.
MULTI_IP_MODE=1
# Mini Monitor check masternode list.
MINI_MONITOR_MN_LIST=1
# Mini Monitor Status to check for.
MINI_MONITOR_MN_STATUS='4'
# Mini Monitor masternode count is a json string.
MINI_MONITOR_MN_COUNT_JSON=1

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "CRAVE"

   ___
 .'   \ .___    ___  _   __   ___
 |      /   \  /   ` |   /  .'   `
 |      |   ' |    | `  /   |----'
  `.__, /     `.__/|  \/    `.___,

CRAVE
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
  COUNTER=1
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

(
# shellcheck disable=SC1091
# shellcheck source=/root/___mn.sh
. ~/___mn.sh
DAEMON_SETUP_THREAD
)
# shellcheck source=/root/.bashrc
. ~/.bashrc
stty sane
