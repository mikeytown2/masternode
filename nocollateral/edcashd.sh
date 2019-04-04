#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/edcashd.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='edcash-project/edcash'
# Display Name.
DAEMON_NAME='EdCash Core'
# Coin Ticker.
TICKER='EDC'
# Binary base name.
BIN_BASE='edcash'
# Directory.
DIRECTORY='.edcash'
# Conf File.
CONF='edcash.conf'
# Port.
DEFAULT_PORT=5003
# Explorer URL.
EXPLORER_URL='http://explorer.edcash.com.br/'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Amount of Collateral needed.
COLLATERAL=25000
# Direct Daemon Download if github has no releases.
DAEMON_DOWNLOAD=''
# Blocktime in seconds.
BLOCKTIME=60
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Multiple on single IP.
MULTI_IP_MODE=1


# Tip Address.
TIPS='EHRtRgBekMnGU8hn34smn7qs2Dehhip7hr'
# Dropbox Addnodes.
DROPBOX_ADDNODES='ns0gibt4q88nzi3'
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='b37x630iur9543e'
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='z4i5p4sap0zzto7'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "EDCASH"
 _____    _  ____          _        ____               
| ____|__| |/ ___|__ _ ___| |__    / ___|___  _ __ ___ 
|  _| / _` | |   / _` / __| '_ \  | |   / _ \| '__/ _ \
| |__| (_| | |__| (_| \__ \ | | | | |__| (_) | | |  __/
|_____\__,_|\____\__,_|___/_| |_|  \____\___/|_|  \___|

EDCASH
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
stty sane 2>/dev/null

