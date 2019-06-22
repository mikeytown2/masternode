#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/zyrkd.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='zyrkproject/zyrk-core'
# Display Name.
DAEMON_NAME='Zyrk zyrkproject/zyrk-core'
# Coin Ticker.
TICKER='ZYRK'
# Binary base name.
BIN_BASE='zyrk'
# Directory.
DIRECTORY='.zyrk'
# Conf File.
CONF='zyrk.conf'
# Port.
DEFAULT_PORT=19655
# Explorer URL.
EXPLORER_URL='https://explorer.zyrk.io/'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Amount of Collateral needed.
COLLATERAL=
# Direct Daemon Download if github has no releases.
DAEMON_DOWNLOAD=''
# Blocktime in seconds.
BLOCKTIME=60
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Multiple on single IP.
MULTI_IP_MODE=1


# Tip Address.
TIPS='ZDaLMx2Lz48BYh5ZnyUPJArYmZd61ihkoc'
# Dropbox Addnodes.
DROPBOX_ADDNODES='9fl5tc93g4uoxos'
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='6yyqk2n9myxt931'
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='8ua422a95bxkwc1'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "ZYRK"
 _____          _    
|__  /   _ _ __| | __
  / / | | | '__| |/ /
 / /| |_| | |  |   < 
/____\__, |_|  |_|\_\
     |___/           
                _                    _           _      __              _    
 _____   _ _ __| | ___ __  _ __ ___ (_) ___  ___| |_   / /____   _ _ __| | __
|_  / | | | '__| |/ / '_ \| '__/ _ \| |/ _ \/ __| __| / /_  / | | | '__| |/ /
 / /| |_| | |  |   <| |_) | | | (_) | |  __/ (__| |_ / / / /| |_| | |  |   < 
/___|\__, |_|  |_|\_\ .__/|_|  \___// |\___|\___|\__/_/ /___|\__, |_|  |_|\_\
     |___/          |_|           |__/                       |___/           
        ___ ___  _ __ ___ 
 _____ / __/ _ \| '__/ _ \
|_____| (_| (_) | | |  __/
       \___\___/|_|  \___|

ZYRK
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

