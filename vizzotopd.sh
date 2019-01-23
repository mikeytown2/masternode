#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2018
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/vizzotopd.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='VizzoTopCore/vizzotop'
# Display Name.
DAEMON_NAME='VizzoTop Wallet'
# Coin Ticker.
TICKER='VIZZ'
# Binary base name.
BIN_BASE='vizzotop'
# Directory.
DIRECTORY='.vizzotop'
# Conf File.
CONF='vizzotop.conf'
# Port.
DEFAULT_PORT=14146
# Explorer URL.
EXPLORER_URL=''
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
# Number of Connections to wait for.
DAEMON_CONNECTIONS=2

# Control Binary.
CONTROLLER_BIN='vizzotopd'

# Tip Address.
TIPS='VUecRj1Tw3XZ14kunx9bpLhZYR6kJdrctU'
# Dropbox Addnodes.
DROPBOX_ADDNODES='i9jjkwfeqn13gn8'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='pslwkrye3kgboqa'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='hohmy3fuwurn8wp'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "VIZZOTOP"
__     ___            _____            __        __    _ _      _
\ \   / (_)__________|_   _|__  _ __   \ \      / /_ _| | | ___| |_
 \ \ / /| |_  /_  / _ \| |/ _ \| '_ \   \ \ /\ / / _` | | |/ _ \ __|
  \ V / | |/ / / / (_) | | (_) | |_) |   \ V  V / (_| | | |  __/ |_
   \_/  |_/___/___\___/|_|\___/| .__/     \_/\_/ \__,_|_|_|\___|\__|
                               |_|

VIZZOTOP
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

