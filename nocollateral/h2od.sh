#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/h2od.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='h2ocore/h2o'
# Display Name.
DAEMON_NAME='H2O Core'
# Coin Ticker.
TICKER='H2O'
# Binary base name.
BIN_BASE='h2o'
# Directory.
DIRECTORY='.h2ocore'
# Conf File.
CONF='h2o.conf'
# Port.
DEFAULT_PORT=13355
# Explorer URL.
EXPLORER_URL='https://h2o.coinexplorer.xyz/'
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
MULTI_IP_MODE=1


# Tip Address.
TIPS='HjCvrW7ucD4gdytS1JVKLNrzemGRtYNrmW'
# Dropbox Addnodes.
DROPBOX_ADDNODES='hcj2qjo5zii8k7h'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='uxax7y1w2j02l7c'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='4xhje3ippv1mdy3'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "H2O"
 _   _ ____   ___     ____               
| | | |___ \ / _ \   / ___|___  _ __ ___ 
| |_| | __) | | | | | |   / _ \| '__/ _ \
|  _  |/ __/| |_| | | |__| (_) | | |  __/
|_| |_|_____|\___/   \____\___/|_|  \___|

H2O
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

