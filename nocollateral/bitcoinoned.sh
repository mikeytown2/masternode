#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/bitcoinoned.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='BitCoinONE1/BTCONE-Blockchain'
# Display Name.
DAEMON_NAME='BitCoin One'
# Coin Ticker.
TICKER='BTCO'
# Binary base name.
BIN_BASE='bitcoinone'
# Directory.
DIRECTORY='.bitcoinone'
# Conf File.
CONF='bitcoinone.conf'
# Port.
DEFAULT_PORT=41472
# Explorer URL.
EXPLORER_URL='https://explorer.bitcoinone.io/'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Bad Explorer SSL.
BAD_SSL_HACK='--no-check-certificate'
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
TIPS='bRbUp4igo577AKx9JQwkDawsTH4np9i2Tk'
# Dropbox Addnodes.
DROPBOX_ADDNODES='llc0oga3g75k02a'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='dnnl0xzkhqh10qa'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='5ql0ujzrauvmhkn'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "BITCOINONE"
 ____  _ _    ____      _          ___
| __ )(_) |_ / ___|___ (_)_ __    / _ \ _ __   ___
|  _ \| | __| |   / _ \| | '_ \  | | | | '_ \ / _ \
| |_) | | |_| |__| (_) | | | | | | |_| | | | |  __/
|____/|_|\__|\____\___/|_|_| |_|  \___/|_| |_|\___|

BITCOINONE
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

