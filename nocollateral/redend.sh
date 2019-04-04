#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/redend.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='RedenCore/Reden'
# Display Name.
DAEMON_NAME='Reden Core'
# Coin Ticker.
TICKER='REDN'
# Binary base name.
BIN_BASE='reden'
# Directory.
DIRECTORY='.redencore'
# Conf File.
CONF='reden.conf'
# Port.
DEFAULT_PORT=13058
# Explorer URL.
EXPLORER_URL='http://explorer.reden.io/'
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
MULTI_IP_MODE=3


# Tip Address.
TIPS='RA8T2MFuachi5F1rdEoAntwpQKJADuSkVm'
# Dropbox Addnodes.
DROPBOX_ADDNODES='wdxipu1j1yzfdso'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='hteraelnxqgfugp'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='dl1zzxb5uu17572'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "REDEN"
 ____          _               ____
|  _ \ ___  __| | ___ _ __    / ___|___  _ __ ___
| |_) / _ \/ _` |/ _ \ '_ \  | |   / _ \| '__/ _ \
|  _ <  __/ (_| |  __/ | | | | |__| (_) | | |  __/
|_| \_\___|\__,_|\___|_| |_|  \____\___/|_|  \___|

REDEN
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
stty sane 2>/dev/null

