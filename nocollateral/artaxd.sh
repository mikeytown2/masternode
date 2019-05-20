#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/artaxd.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='artaxcommittee/Artax'
# Display Name.
DAEMON_NAME='Artax Core'
# Coin Ticker.
TICKER='XAX'
# Binary base name.
BIN_BASE='artax'
# Directory.
DIRECTORY='.artax'
# Conf File.
CONF='artax.conf'
# Port.
DEFAULT_PORT=21527
# Explorer URL.
EXPLORER_URL='https://artax.blockxplorer.info/'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Bad Explorer SSL.
BAD_SSL_HACK='--no-check-certificate'
# Amount of Collateral needed.
COLLATERAL=2500
# Direct Daemon Download if github has no releases.
DAEMON_DOWNLOAD=''
# Blocktime in seconds.
BLOCKTIME=60
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Multiple on single IP.
MULTI_IP_MODE=1
MASTERNODE_CALLER='merchantnode '
MASTERNODE_PREFIX='mn'


# Tip Address.
TIPS='ARNcnjeMEYu34arij13JW4qaF5V4BeNEvc'
# Dropbox Addnodes.
DROPBOX_ADDNODES='pek24peo79c7ky8'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='wiy1bnrobpo2148'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='c0tevuebxr9whk1'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "ARTAX"
    _____ __________________________  ____  ___
   /  _  \\______   \__    ___/  _  \ \   \/  /
  /  /_\  \|       _/ |    | /  /_\  \ \     /  2019 Artax/XAX
 /    |    \    |   \ |    |/    |    \/     \
 \____|____/____|___/ |____|\____|____/___/\__\

ARTAX
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

