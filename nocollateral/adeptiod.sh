#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/adeptiod.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='adeptio-project/adeptio'
# Display Name.
DAEMON_NAME='Adeptio Core'
# Coin Ticker.
TICKER='ADE'
# Binary base name.
BIN_BASE='adeptio'
# Directory.
DIRECTORY='.adeptio'
# Conf File.
CONF='adeptio.conf'
# Port.
DEFAULT_PORT=9077
# Explorer URL.
EXPLORER_URL='https://explorer.adeptio.cc/'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Amount of Collateral needed.
COLLATERAL=10000
# Direct Daemon Download if github has no releases.
DAEMON_DOWNLOAD=''
# Blocktime in seconds.
BLOCKTIME=60
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Multiple on single IP.
MULTI_IP_MODE=1


# Tip Address.
TIPS='AGH2mrGfZGHNfNCpGrW6F8uG4GqJz3diXg'
# Dropbox Addnodes.
DROPBOX_ADDNODES='6d0kfrssmk27cop'
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='31k3yemns3hp34u'
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='vzv96xie7l1lj4m'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "ADEPTIO"
    _       _            _   _          ____               
   / \   __| | ___ _ __ | |_(_) ___    / ___|___  _ __ ___ 
  / _ \ / _` |/ _ \ '_ \| __| |/ _ \  | |   / _ \| '__/ _ \
 / ___ \ (_| |  __/ |_) | |_| | (_) | | |__| (_) | | |  __/
/_/   \_\__,_|\___| .__/ \__|_|\___/   \____\___/|_|  \___|
                  |_|                                      

ADEPTIO
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

