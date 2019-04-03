#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/resqd.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='RESQ-Chain/RESQ'
# Display Name.
DAEMON_NAME='RESQ Core'
# Coin Ticker.
TICKER='RESQ'
# Binary base name.
BIN_BASE='resq'
# Directory.
DIRECTORY='.resq'
# Conf File.
CONF='resq.conf'
# Port.
DEFAULT_PORT=13200
# Explorer URL.
EXPLORER_URL='http://explorer.resqchain.org/'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Amount of Collateral needed.
COLLATERAL=300000
# Direct Daemon Download if github has no releases.
DAEMON_DOWNLOAD=''
# Blocktime in seconds.
BLOCKTIME=60
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Multiple on single IP.
MULTI_IP_MODE=1


# Tip Address.
TIPS='qcfN3SbX8kBu2hPQEWi2gKp5wwVyACqNhC'
# Dropbox Addnodes.
DROPBOX_ADDNODES='01vm5odeqyyswx2'
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='ehka65zuged0pzs'
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='pyla6w27ix18xv0'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "RESQ"
    ____                  ________          _
   / __ \___  _________ _/ ____/ /_  ____ _(_)___
  / /_/ / _ \/ ___/ __ `/ /   / __ \/ __ `/ / __ \
 / _, _/  __(__  ) /_/ / /___/ / / / /_/ / / / / /
/_/ |_|\___/____/\__, /\____/_/ /_/\__,_/_/_/ /_/
                   /_/

RESQ
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
stty sane 2>/dev/null

