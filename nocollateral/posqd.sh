#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/posqd.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='Poseidon-POSQ/posq'
# Display Name.
DAEMON_NAME='POSQ Core'
# Coin Ticker.
TICKER='POSQ'
# Binary base name.
BIN_BASE='posq'
# Directory.
DIRECTORY='.posq'
# Conf File.
CONF='posq.conf'
# Port.
DEFAULT_PORT=5510
# Explorer URL.
EXPLORER_URL='https://poseidonchain.info/'
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
TIPS='QPjFriJ8x6LuxNrMspzeZzbdzCgCXzVcvU'
# Dropbox Addnodes.
DROPBOX_ADDNODES='mvjv7mubg5wricn'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='7fifbsdk648as72'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='e9w1uv9y6b042qg'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "POSQ"
 ____   ___  ____   ___     ____               
|  _ \ / _ \/ ___| / _ \   / ___|___  _ __ ___ 
| |_) | | | \___ \| | | | | |   / _ \| '__/ _ \
|  __/| |_| |___) | |_| | | |__| (_) | | |  __/
|_|    \___/|____/ \__\_\  \____\___/|_|  \___|

POSQ
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

