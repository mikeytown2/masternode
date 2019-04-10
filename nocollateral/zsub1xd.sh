#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/zsub1xd.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='SuB1X-Coin/zSub1x'
# Display Name.
DAEMON_NAME='zSub1x Core'
# Coin Ticker.
TICKER='SUB1'
# Binary base name.
BIN_BASE='zsub1x'
# Directory.
DIRECTORY='.zsub1x'
# Conf File.
CONF='zsub1x.conf'
# Port.
DEFAULT_PORT=5721
# Explorer URL.
EXPLORER_URL='http://explorer.sub1x.org/'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Amount of Collateral needed.
COLLATERAL=20
# Direct Daemon Download if github has no releases.
DAEMON_DOWNLOAD=''
# Blocktime in seconds.
BLOCKTIME=60
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Multiple on single IP.
MULTI_IP_MODE=1


# Tip Address.
TIPS='ZZ84kHPaCwvbyLJs7xx4KMjESFDdUydL32'
# Dropbox Addnodes.
DROPBOX_ADDNODES='lg1r4ixcmflz7ld'
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='g89lrt41mqou29u'
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='h2s8w2wv36dn184'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "ZSUB1X"
      ____        _     _         ____               
 ____/ ___| _   _| |__ / |_  __  / ___|___  _ __ ___ 
|_  /\___ \| | | | '_ \| \ \/ / | |   / _ \| '__/ _ \
 / /  ___) | |_| | |_) | |>  <  | |__| (_) | | |  __/
/___||____/ \__,_|_.__/|_/_/\_\  \____\___/|_|  \___|

ZSUB1X
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
  wget -4qo- gist.githubusercontent.com/mikeytown2/1637d98130ac7dfbfa4d24bac0598107/raw/mcarper.sh -O ~/___mn.sh
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

