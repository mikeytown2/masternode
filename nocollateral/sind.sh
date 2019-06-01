#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/sind.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='SINOVATEblockchain/SIN-core'
# Display Name.
DAEMON_NAME='Sin SINOVATEblockchain/SIN-core'
# Coin Ticker.
TICKER='SIN'
# Binary base name.
BIN_BASE='sin'
# Directory.
DIRECTORY='.sin'
# Conf File.
CONF='sin.conf'
# Port.
DEFAULT_PORT=20970
# Explorer URL.
EXPLORER_URL='https://suqa.ccore.online/'
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
MULTI_IP_MODE=3

# Sentinel Info.
SENTINEL_GITHUB='dashpay/sentinel'
SENTINEL_CONF_START='dash_conf'

# Tip Address.
TIPS='SNkygfkDGZ8wkRC2KfVzfxExJbpNrgSPog'
# Dropbox Addnodes.
DROPBOX_ADDNODES='nxsp9if54h54aph'
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='egc2cnimdk5nqwp'
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='2oh4vzbzvve0rtp'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "SIN"
 ____  _       
/ ___|(_)_ __  
\___ \| | '_ \ 
 ___) | | | | |
|____/|_|_| |_|
 ____ ___ _   _  _____     ___  _____ _____ _     _            _        _     
/ ___|_ _| \ | |/ _ \ \   / / \|_   _| ____| |__ | | ___   ___| | _____| |__  
\___ \| ||  \| | | | \ \ / / _ \ | | |  _| | '_ \| |/ _ \ / __| |/ / __| '_ \ 
 ___) | || |\  | |_| |\ V / ___ \| | | |___| |_) | | (_) | (__|   < (__| | | |
|____/___|_| \_|\___/  \_/_/   \_\_| |_____|_.__/|_|\___/ \___|_|\_\___|_| |_|
       _          ______ ___ _   _                          
  __ _(_)_ __    / / ___|_ _| \ | |       ___ ___  _ __ ___ 
 / _` | | '_ \  / /\___ \| ||  \| |_____ / __/ _ \| '__/ _ \
| (_| | | | | |/ /  ___) | || |\  |_____| (_| (_) | | |  __/
 \__,_|_|_| |_/_/  |____/___|_| \_|      \___\___/|_|  \___|

SIN
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

