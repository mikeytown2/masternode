#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/slated.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='slatecurrency/slate'
# Display Name.
DAEMON_NAME='SLATE Core'
# Coin Ticker.
TICKER='SLX'
# Binary base name.
BIN_BASE='slate'
# Directory.
DIRECTORY='.slate'
# Conf File.
CONF='slate.conf'
# Port.
DEFAULT_PORT=37415
# Explorer URL.
EXPLORER_URL='https://explorer.slate.io/'
# Rate limit explorer.
EXPLORER_SLEEP=1
EXPLORER_BLOCKCOUNT_OFFSET='+4'
# Amount of Collateral needed.
COLLATERAL=350000
# Direct Daemon Download if github has no releases.
DAEMON_DOWNLOAD=''
# Blocktime in seconds.
BLOCKTIME=60
# Cycle Daemon on first start.
DAEMON_CYCLE=0
# Multiple on single IP.
MULTI_IP_MODE=1
# Extra configuation for the conf file.
EXTRA_CONFIG='rpcbind=127.0.0.1'


# Tip Address.
TIPS='sWCWF1cZs3VByPKQeLjLiDtu8Zeo1vsPJU'
# Dropbox Addnodes.
DROPBOX_ADDNODES='zxorc3s0wisuy25'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='v7e1e8bofoj2r24'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='a80gy85gcznw22r'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "SLATE"
 ____  _        _  _____ _____    ____
/ ___|| |      / \|_   _| ____|  / ___|___  _ __ ___
\___ \| |     / _ \ | | |  _|   | |   / _ \| '__/ _ \
 ___) | |___ / ___ \| | | |___  | |__| (_) | | |  __/
|____/|_____/_/   \_\_| |_____|  \____\___/|_|  \___|

SLATE
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

