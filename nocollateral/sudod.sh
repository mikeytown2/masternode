#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/sudod.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='cryptosudo/sudo'
# Display Name.
DAEMON_NAME='Sudo cryptosudo/sudo'
# Coin Ticker.
TICKER='SUDO'
# Binary base name.
BIN_BASE='sudo'
# Directory.
DIRECTORY='.sudocore'
# Conf File.
CONF='sudo.conf'
# Port.
DEFAULT_PORT=11919
# Explorer URL.
EXPLORER_URL='https://cryptosudo.online/'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Amount of Collateral needed.
COLLATERAL=50000
# Direct Daemon Download if github has no releases.
DAEMON_DOWNLOAD=''
# Blocktime in seconds.
BLOCKTIME=60
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Multiple on single IP.
MULTI_IP_MODE=3

# Sentinel Info.
SENTINEL_GITHUB='https://github.com/cryptosudo/sudo-sentinel'
SENTINEL_CONF_START='sudo_conf'

# Tip Address.
TIPS='ScCvxfUp1dSVf5toGUqLckcNx2xqqbYVU5'
# Dropbox Addnodes.
DROPBOX_ADDNODES='6280a1j2th5ugau'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='1y7vqz6iy6dmdzl'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='u83seuyc29j5jjj'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "SUDO"
 ____            _       
/ ___| _   _  __| | ___  
\___ \| | | |/ _` |/ _ \ 
 ___) | |_| | (_| | (_) |
|____/ \__,_|\__,_|\___/ 
                       _                      _
  ___ _ __ _   _ _ __ | |_ ___  ___ _   _  __| | ___
 / __| '__| | | | '_ \| __/ _ \/ __| | | |/ _` |/ _ \
| (__| |  | |_| | |_) | || (_) \__ \ |_| | (_| | (_) |
 \___|_|   \__, | .__/ \__\___/|___/\__,_|\__,_|\___/
           |___/|_|                                                            
SUDO
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

