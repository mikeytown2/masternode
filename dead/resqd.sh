#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2018
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/resqd.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='RESQ-Chain/resq-chain'
# Display Name.
DAEMON_NAME='Resq Core'
# Coin Ticker.
TICKER='RESQ'
# Binary base name.
BIN_BASE='resq'
# Directory.
DIRECTORY='.resqcore'
# Conf File.
CONF='resq.conf'
# Port.
DEFAULT_PORT=19988
# Explorer URL
EXPLORER_URL='http://explorer.resqchain.org:3001/'
# Amount of Collateral needed.
COLLATERAL=300000
# Blocktime in seconds.
BLOCKTIME=150
# Cycle Daemon on first start.
DAEMON_CYCLE=1

# Tip Address
TIPS='QVLGsb3byATeLGxggGB9ajY5uFRLZUAxtH'
# Dropbox Addnodes
DROPBOX_ADDNODES='0i7bqbwnit5dh1u'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=0
# Dropbox Bootstrap
DROPBOX_BOOTSTRAP='sql7cq5tviesgq2'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=0
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='v41turql84hqx0s'

# Multiple on single IP.
MULTI_IP_MODE=3
# Mini Monitor check masternode list.
MINI_MONITOR_MN_LIST=1
# Mini Monitor Status to check for.
MINI_MONITOR_MN_STATUS='Masternode successfully started'
# Mini Monitor masternode count is a json string.
MINI_MONITOR_MN_COUNT_JSON=1

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
