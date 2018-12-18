#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2018
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/lindad.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='TheLindaProjectInc/Linda'
# Display Name.
DAEMON_NAME='Linda Wallet'
# Coin Ticker.
TICKER='LIND'
# Binary base name.
BIN_BASE='Linda'
# Directory.
DIRECTORY='.Linda'
# Conf File.
CONF='Linda.conf'
# Port.
DEFAULT_PORT=33820
# Explorer URL
EXPLORER_URL='https://lindaexplorer.kdhsolutions.co.uk/'
# Amount of Collateral needed.
COLLATERAL=2000000
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Single IP.
MULTI_IP_MODE=3
# Can use IPv6.
IPV6=1
# Control Binary.
CONTROLLER_BIN='Lindad'

# Tip Address
TIPS='LQU9b7ebXEQqXyfJ4hQasEoGFXcMt8By94'
# Dropbox Addnodes
DROPBOX_ADDNODES='qxzy1glglcdm2mq'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap
DROPBOX_BOOTSTRAP='a6748cxsms0vaak'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='2m2maymhkxb3l8x'


ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "LINDA"
    _
 \_|_)  o             |
   |        _  _    __|   __,
  _|    |  / |/ |  /  |  /  |
 (/\___/|_/  |  |_/\_/|_/\_/|_/

LINDA
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
