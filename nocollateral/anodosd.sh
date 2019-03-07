#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/anodosd.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='AnodosCore/AnodosCore'
# Display Name.
DAEMON_NAME='Anodos Core'
# Coin Ticker.
TICKER='ANDS'
# Binary base name.
BIN_BASE='anodos'
# Directory.
DIRECTORY='.anodoscore'
# Conf File.
CONF='anodos.conf'
# Port.
DEFAULT_PORT=1929
# Explorer URL.
EXPLORER_URL='http://explorer.anodoscrypto.com:3001/'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Amount of Collateral needed.
COLLATERAL=10000
# Direct Daemon Download if github has no releases.
DAEMON_DOWNLOAD=''
# Blocktime in seconds.
BLOCKTIME=60
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Multiple on single IP.
MULTI_IP_MODE=1


# Tip Address.
TIPS='AH24NUPE3UYFf93qETseTaRa38YCGY1Ju9'
# Dropbox Addnodes.
DROPBOX_ADDNODES='0685pg2fmb68ua9'
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='0jbpmhuc5p5wsdd'
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='82yjj89r666cg7x'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "ANODOS"
    _                    _              ____
   / \   _ __   ___   __| | ___  ___   / ___|___  _ __ ___
  / _ \ | '_ \ / _ \ / _` |/ _ \/ __| | |   / _ \| '__/ _ \
 / ___ \| | | | (_) | (_| | (_) \__ \ | |__| (_) | | |  __/
/_/   \_\_| |_|\___/ \__,_|\___/|___/  \____\___/|_|  \___|

ANODOS
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

