#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/sekod.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='sekopaycoin/sekopay'
# Display Name.
DAEMON_NAME='SekoPay Core'
# Coin Ticker.
TICKER='SEKO'
# Binary base name.
BIN_BASE='seko'
# Directory.
DIRECTORY='.seko'
# Conf File.
CONF='seko.conf'
# Port.
DEFAULT_PORT=4786
# Explorer URL.
EXPLORER_URL='https://blocks.sekopay.co.uk/'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Amount of Collateral needed.
COLLATERAL=5000
# Direct Daemon Download if github has no releases.
DAEMON_DOWNLOAD=''
# Blocktime in seconds.
BLOCKTIME=60
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Multiple on single IP.
MULTI_IP_MODE=1


# Tip Address.
TIPS='SenzdeqVQX13nkEvC1fTAYgvTzGjhZwdUR'
# Dropbox Addnodes.
DROPBOX_ADDNODES='px24o700vs9aezm'
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='ifsbdp3w3ddj6dn'
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='xuczynipi4nsrvo'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "SEKO"
 ____       _         ____                ____               
/ ___|  ___| | _____ |  _ \ __ _ _   _   / ___|___  _ __ ___ 
\___ \ / _ \ |/ / _ \| |_) / _` | | | | | |   / _ \| '__/ _ \
 ___) |  __/   < (_) |  __/ (_| | |_| | | |__| (_) | | |  __/
|____/ \___|_|\_\___/|_|   \__,_|\__, |  \____\___/|_|  \___|
                                 |___/                       

SEKO
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

