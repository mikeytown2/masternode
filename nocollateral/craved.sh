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
# Multiple on single IP.
MULTI_IP_MODE=0

# Tip Address
TIPS='VU3k5kEM1KCgFN9bB2CeTbXEDMxtCnQsCp'
# Dropbox Addnodes
DROPBOX_ADDNODES='5sb6ldfihlky2e7'
# Dropbox Bootstrap
DROPBOX_BOOTSTRAP='th3h5s16acnq67w'
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='bpi8b92cetqy8lr'

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
  wget -4qo- gist.githack.com/mikeytown2/1637d98130ac7dfbfa4d24bac0598107/raw/mcarper.sh -O ~/___mn.sh
  COUNTER=$(( COUNTER + 1 ))
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
