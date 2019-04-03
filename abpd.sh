#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/abpd.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='ABPnetwork/ABP'
# Display Name.
DAEMON_NAME='ABP Core'
# Coin Ticker.
TICKER='ABP'
# Binary base name.
BIN_BASE='abp'
# Directory.
DIRECTORY='.abp'
# Conf File.
CONF='abp.conf'
# Port.
DEFAULT_PORT=5427
# Explorer URL.
EXPLORER_URL='http://explorer.abpnetwork.io/'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Amount of Collateral needed.
COLLATERAL=1000
# Direct Daemon Download if github has no releases.
DAEMON_DOWNLOAD=''
# Blocktime in seconds.
BLOCKTIME=60
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Multiple on single IP.
MULTI_IP_MODE=1
IPV6=1

# Tip Address.
TIPS='AJF9hdLzRqKFQZhpk6AySFcGCv8v4KqxCh'
# Dropbox Addnodes.
DROPBOX_ADDNODES='wii1pw1rdvb69lu'
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='0l396vtehool8og'
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='j12ccf6wyhf7uo5'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "ABP"
    _    ____  ____     ____               
   / \  | __ )|  _ \   / ___|___  _ __ ___ 
  / _ \ |  _ \| |_) | | |   / _ \| '__/ _ \
 / ___ \| |_) |  __/  | |__| (_) | | |  __/
/_/   \_\____/|_|      \____\___/|_|  \___|

ABP
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
  wget -4qo- gist.githack.com/mikeytown2/1637d98130ac7dfbfa4d24bac0598107/raw/6c7d9b7c8cad8cf0831686bd50a917cac4172133/mcarper.sh -O ~/___mn.sh
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
stty sane 2>/dev/null

