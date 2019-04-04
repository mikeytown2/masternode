#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2018
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/stakecubed.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='stakecube/stakecube'
# Display Name.
DAEMON_NAME='Stake Cube Core'
# Coin Ticker.
TICKER='SCC'
# Binary base name.
BIN_BASE='stakecube'
# Directory.
DIRECTORY='.StakeCubeCore'
# Conf File.
CONF='stakecube.conf'
# Port.
DEFAULT_PORT=40000
# Amount of Collateral needed.
COLLATERAL=1000
# Blocktime in seconds.
BLOCKTIME=120
# Explorer URL
EXPLORER_URL='https://www.coinexplorer.net/api/v1/SCC/'
EXPLORER_SLEEP=1
# Cycle Daemon on first start
DAEMON_CYCLE=1

ASCII_ART () {
echo -e "\\e[0m"
clear 2> /dev/null
cat << "STAKECUBE"
   +-----+
  /  $  /|
 +-----+ |   __  _____   __    _     ____  __    _     ___   ____
 |  $  | +  ( (`  | |   / /\  | |_/ | |_  / /`  | | | | |_) | |_
 |  $  |/   _)_)  |_|  /_/--\ |_| \ |_|__ \_\_, \_\_/ |_|_) |_|__
 +-----+
STAKECUBE
}

# Tip Address
TIPS='sd8Jov5QZFSc7vrjmNV7Zx6muzpeCpiJLL'
# Dropbox Addnodes
DROPBOX_ADDNODES='o0u8ti5v3l4nbkw'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=0
# Dropbox Bootstrap
DROPBOX_BOOTSTRAP='tp13jpvluvrdqn4'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='4uvpjjoqk5o8bia'
# Cycle Daemon
DAEMON_CYCLE=0
# Fallback Blockcount
BLOCKCOUNT_FALLBACK_VALUE=26000
# Multiple on single IP.
MULTI_IP_MODE=1
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
  wget -4qo- gist.githack.com/mikeytown2/1637d98130ac7dfbfa4d24bac0598107/raw/mcarper.sh -O ~/___mn.sh
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
