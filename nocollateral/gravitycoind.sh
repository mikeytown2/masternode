#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/gravitycoind.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='GravityCoinOfficial/GravityCoin'
# Display Name.
DAEMON_NAME='Gxx GravityCoin'
# Coin Ticker.
TICKER='GXX'
# Binary base name.
BIN_BASE='GravityCoin'
# Directory.
DIRECTORY='.GravityCoin'
# Conf File.
CONF='GravityCoin.conf'
# Port.
DEFAULT_PORT=29100
# Explorer URL.
EXPLORER_URL='https://chainz.cryptoid.info/gxx/'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Set the endpoint for getting info from the explorer.
EXPLORER_BLOCKCOUNT_PATH='api.dws?q=getblockcount'
EXPLORER_BLOCKCOUNT_OFFSET='+2'
EXPLORER_RAWTRANSACTION_PATH='api.dws?q=txinfo&t='
EXPLORER_RAWTRANSACTION_PATH_SUFFIX=' '
EXPLORER_GETADDRESS_PATH='api.dws?key=62f6b161a9a5&q=getbalance&a='
# Amount of Collateral needed.
COLLATERAL=2000
# Direct Daemon Download if github has no releases.
DAEMON_DOWNLOAD=''
# Blocktime in seconds.
BLOCKTIME=60
# Multiple on single IP.
MULTI_IP_MODE=1
MASTERNODE_CALLER='xnode '
MASTERNODE_PREFIX='xn'


# Tip Address.
TIPS='H9rDo3nGDf4m18nj9WdM2wQbfjvt2CMMm2'
# Dropbox Addnodes.
DROPBOX_ADDNODES='jtpvnbm9n4nxe98'
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='no4mtbhjlh3u7wm'
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='8iqmm1m57l435xg'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "GRAVITYCOIN"
  ____
 / ___|_  ____  __
| |  _\ \/ /\ \/ /
| |_| |>  <  >  <
 \____/_/\_\/_/\_\

GRAVITYCOIN
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

