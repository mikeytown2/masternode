#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2018
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/huzud.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='HUZU-Project/HUZU'
# Display Name.
DAEMON_NAME='HUZU Core'
# Coin Ticker.
TICKER='HUZU'
# Binary base name.
BIN_BASE='huzu'
# Directory.
DIRECTORY='.huzu'
# Conf File.
CONF='huzu.conf'
# Port.
DEFAULT_PORT=51992
# Explorer URL.
EXPLORER_URL='http://explorer.huzu.io/'
# Amount of Collateral needed.
COLLATERAL=3000
# Fallback Blockcount.
BLOCKCOUNT_FALLBACK_VALUE=9000
# Multiple on single IP.
MULTI_IP_MODE=0
# Daemon can use IPv6.
IPV6=0

# Tip Address.
TIPS='HKSgkhmsbcHLSXHPtLXCFcHuxtCCJjhLFM'
# Dropbox Addnodes.
DROPBOX_ADDNODES='nqre9g68gcuhax5'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='fv32gy4hei50q1u'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='vew2ymhmhj5mqh7'
# Dropbox has more than blocks and chainstake.
DROPBOX_BLOCKS_N_CHAINS_ALL=1

# Mini Monitor check masternode list.
MINI_MONITOR_MN_LIST=1
# Mini Monitor Status to check for.
MINI_MONITOR_MN_STATUS='4'
# Mini Monitor masternode count is a json string.
MINI_MONITOR_MN_COUNT_JSON=1

ASCII_ART () {
echo -e "\\e[0m"
clear 2>/dev/null
cat << "HUZU"

|\    /|   _   _ _   _ ______   _
| \  / |  | | | | | | |__  / | | |
|  \/  |  | |_| | | | | / /| | | |
|  /\  |  |  _  | |_| |/ /_| |_| |
| /  \ |  |_| |_|\___//____|\___/
|/    \|

HUZU
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

(
# shellcheck disable=SC1091
# shellcheck source=/root/___mn.sh
. ~/___mn.sh
DAEMON_SETUP_THREAD
)
# shellcheck source=/root/.bashrc
. ~/.bashrc
stty sane
