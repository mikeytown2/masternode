#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2018
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/emralsd.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='Emrals/emrals'
# Display Name.
DAEMON_NAME='Emrals Core'
# Coin Ticker.
TICKER='EMRA'
# Binary base name.
BIN_BASE='emrals'
# Directory.
DIRECTORY='.emralscore'
# Conf File.
CONF='emrals.conf'
# Port.
DEFAULT_PORT=30001
# Explorer URL.
EXPLORER_URL='http://explorer.emrals.com/'
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
MULTI_IP_MODE=3


# Tip Address.
TIPS='EYvx183fh8AdAbs4F5Ets5d1QJXR19XRdq'
# Dropbox Addnodes.
DROPBOX_ADDNODES='1yd404x38yqoluk'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='lac0eildij36c9y'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='ervxtflm9s9t4go'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "EMRALS"
 _____                     _        ____
| ____|_ __ ___  _ __ __ _| |___   / ___|___  _ __ ___
|  _| | '_ ` _ \| '__/ _` | / __| | |   / _ \| '__/ _ \
| |___| | | | | | | | (_| | \__ \ | |__| (_) | | |  __/
|_____|_| |_| |_|_|  \__,_|_|___/  \____\___/|_|  \___|

EMRALS
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

