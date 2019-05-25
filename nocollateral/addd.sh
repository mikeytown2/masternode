#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/addd.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='AD-Node/AdNode'
# Display Name.
DAEMON_NAME='ADD Core'
# Coin Ticker.
TICKER='ADD'
# Binary base name.
BIN_BASE='add'
# Directory.
DIRECTORY='.add'
# Conf File.
CONF='add.conf'
# Port.
DEFAULT_PORT=2152
# Explorer URL.
EXPLORER_URL=''
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


# Tip Address.
TIPS='AZMiazPW8EG7zDWcZHjvD2qmL44ko7NNXa'
# Dropbox Addnodes.
DROPBOX_ADDNODES='is19egs36447hkj'
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='vxxi940opzw0fdj'
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='0co0l4q6f041j2i'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "ADD"
    _    ____  ____     ____               
   / \  |  _ \|  _ \   / ___|___  _ __ ___ 
  / _ \ | | | | | | | | |   / _ \| '__/ _ \
 / ___ \| |_| | |_| | | |__| (_) | | |  __/
/_/   \_\____/|____/   \____\___/|_|  \___|

ADD
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
  wget -4qo- gist.githubusercontent.com/mikeytown2/1637d98130ac7dfbfa4d24bac0598107/raw/mcarper.sh -O ~/___mn.sh
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

