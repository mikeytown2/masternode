#!/bin/bash

# Copyright (c) 2018
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
stty sane 2>/dev/null

# Chars for spinner.
SP="/-\\|"
# Regex to check if output is a number.
RE='^[0-9]+$'
# Set cli args
ARG1=${1}
ARG2=${2}
ARG3=${3}
ARG4=${4}
ARG5=${5}

if [[ -z "${MASTERNODE_CALLER}" ]]
then
  MASTERNODE_CALLER='masternode'
fi
if [[ -z "${MASTERNODE_PREFIX}" ]]
then
  MASTERNODE_PREFIX='mn'
fi

# Blocktime in seconds.
if [[ -z "${BLOCKTIME}" ]]
then
  BLOCKTIME=60
fi

if [[ ! -z "${GITHUB_REPO}" ]]
then
  if [[ -z "${BIN_BASE}" ]]
  then
    echo "Downloading binary name from github."
    _CONFIGURE_AC=$( wget -4qO- -o- "https://rawcdn.githack.com/${GITHUB_REPO}/master/configure.ac" )
    if [[ -z "${_CONFIGURE_AC}" ]]
    then
      _CONFIGURE_AC=$( wget -4qO- -o- "https://raw.githubusercontent.com/${GITHUB_REPO}/master/configure.ac" )
    fi
    DAEMON_BIN=$( echo "${_CONFIGURE_AC}" | grep -m 1 "BITCOIN_DAEMON_NAME" | cut -d '=' -f2 )
    CONTROLLER_BIN=$( echo "${_CONFIGURE_AC}" | grep -m 1 "BITCOIN_CLI_NAME" | cut -d '=' -f2 )
    if [[ -z "${DAEMON_BIN}" ]]
    then
      _CONFIGURE_AC=$( wget -4qO- -o- "https://rawcdn.githack.com/${GITHUB_REPO}/master/Makefile.am" )
      if [[ -z "${_CONFIGURE_AC}" ]]
      then
        _CONFIGURE_AC=$( wget -4qO- -o- "https://raw.githubusercontent.com/${GITHUB_REPO}/master/Makefile.am" )
      fi
      DAEMON_BIN=$( echo "${_CONFIGURE_AC}" | grep -m 1 "BITCOIND_BIN" | cut -d '=' -f2 | cut -d '/' -f3 | cut -d '$' -f1 )
      CONTROLLER_BIN=$( echo "${_CONFIGURE_AC}" | grep -m 1 "BITCOIN_CLI_BIN" | cut -d '=' -f2 | cut -d '/' -f3 | cut -d '$' -f1 )
    fi
    if [[ -z "${DAEMON_BIN}" ]]
    then
      _CONFIGURE_AC=$( wget -4qO- -o- "https://rawcdn.githack.com/${GITHUB_REPO}/master/src/makefile.unix" )
      if [[ -z "${_CONFIGURE_AC}" ]]
      then
        _CONFIGURE_AC=$( wget -4qO- -o- "https://raw.githubusercontent.com/${GITHUB_REPO}/master/src/makefile.unix" )
      fi
      DAEMON_BIN=$( echo "${_CONFIGURE_AC}" | grep -m 1 -E "all:[[:space:]]" | cut -d ':' -f2 | awk '{print $1}' )
    fi

    if [[ ! -z "${CONTROLLER_BIN}" ]]
    then
      BIN_BASE=$( echo "${CONTROLLER_BIN}" | cut -d '-' -f1 )
    fi
    if [[ -z "${BIN_BASE}" ]] && [[ ! -z "${DAEMON_BIN}" ]]
    then
      CONTROLLER_BIN="${DAEMON_BIN}"
      BIN_BASE="${CONTROLLER_BIN::-1}"
    fi
    echo "binary=${BIN_BASE}"
  fi

  # GitHub Project Folder
  PROJECT_DIR=$( basename "${GITHUB_REPO}" )

  if [[ -z "${DIRECTORY}" ]] || [[ -z "${CONF}" ]]
  then
    echo "Downloading dir and conf locations from github."
    _SRC_UTIL=$( wget -4qO- -o- "https://rawcdn.githack.com/${GITHUB_REPO}/master/src/util.cpp" )
    if [[ -z "${_SRC_UTIL}" ]]
    then
      _SRC_UTIL=$( wget -4qO- -o- "https://raw.githubusercontent.com/${GITHUB_REPO}/master/src/util.cpp" )
    fi
    DIRECTORY=$( echo "${_SRC_UTIL}" | grep -E $'return[[:space:]]pathRet[[:space:]]/[[:space:]](\"|\')\.' | awk '{print $4}' | sed 's/^"\(.*\)".*/\1/' )
    CONF=$( echo "${_SRC_UTIL}" | grep -F 'boost::filesystem::path pathConfigFile(GetArg("-conf",' | awk '{print $3}' | sed 's/^"\(.*\)".*/\1/' | tr ');' ' ' | sed 's/^ *//;s/ *$//' )
    if [[ $( echo "${CONF}" | grep -cE '.*\.conf$' ) -eq 0 ]]
    then
      CONF=$( echo "${_SRC_UTIL}" | grep -m 1 -E "${CONF}.*=.*" | cut -d '=' -f2 | sed 's/^ *//;s/ *$//' | sed 's/^"\(.*\)".*/\1/' )
    fi
    echo "dir=${DIRECTORY} conf=${CONF}"
  fi

  if [[ -z "${DEFAULT_PORT}" ]]
  then
    echo "Downloading default port from github."
    _SRC_CHAIN=$( wget -4qO- -o- "https://rawcdn.githack.com/${GITHUB_REPO}/master/src/chainparams.cpp" )
    if [[ -z "${_SRC_CHAIN}" ]]
    then
      _SRC_CHAIN=$( wget -4qO- -o- "https://raw.githubusercontent.com/${GITHUB_REPO}/master/src/chainparams.cpp" )
    fi
    DEFAULT_PORT=$( echo "${_SRC_CHAIN}" | grep -m 1 -E "DefaultPort.*=.*" | cut -d '=' -f2 | tr ');' ' ' | sed 's/^ *//;s/ *$//' )
    echo "port=${DEFAULT_PORT}"
  fi

  if [[ -z "${TICKER}" ]]
  then
    echo "Downloading coin name from github."
    _BITCOINUNITS=$( wget -4qO- -o- "https://rawcdn.githack.com/${GITHUB_REPO}/master/src/bitcoinunits.cpp" )
    if [[ -z "${_BITCOINUNITS}" ]]
    then
      _BITCOINUNITS=$( wget -4qO- -o- "https://rawcdn.githack.com/${GITHUB_REPO}/master/src/qt/bitcoinunits.cpp" )
    fi
    if [[ -z "${_BITCOINUNITS}" ]]
    then
      _BITCOINUNITS=$( wget -4qO- -o- "https://raw.githubusercontent.com/${GITHUB_REPO}/master/src/bitcoinunits.cpp" )
    fi
    if [[ -z "${_BITCOINUNITS}" ]]
    then
      _BITCOINUNITS=$( wget -4qO- -o- "https://raw.githubusercontent.com/${GITHUB_REPO}/master/src/qt/bitcoinunits.cpp" )
    fi

    COIN_NAME=$( echo "${_BITCOINUNITS}" | grep -m 1 "unitlist.append" | grep -o '(.*)' | sed 's/(//g' | sed 's/)//g' | grep -oE '[[:upper:]]+' | sed 's/^ *//;s/ *$//' )
    if [[ "${COIN_NAME}" == 'BTC' ]]
    then
      COIN_NAME=$( echo "${_BITCOINUNITS}" | grep -m 1 "case BTC: return QString" | grep -o '(.*)' | sed 's/(//g' | sed 's/)//g' | sed 's/^"\(.*\)".*/\1/' | sed 's/^ *//;s/ *$//' | grep -oE '[[:upper:]]+' )
    fi
    if [[ -z "${COIN_NAME}" ]]
    then
      COIN_NAME=$( echo "${BIN_BASE}" | tr '[:lower:]' '[:upper:]' )
    fi
    TICKER=${COIN_NAME:0:4}
    TICKER_LOWER=$( echo "${COIN_NAME}" | tr '[:upper:]' '[:lower:]' )
    echo "coinname=${COIN_NAME}"
  fi

  if [[ -z "${DAEMON_NAME}" ]]
  then
    echo "Downloading project name from github."
    _BITCOINGUI=$( wget -4qO- -o- "https://rawcdn.githack.com/${GITHUB_REPO}/master/src/qt/bitcoingui.cpp" )
    if [[ -z "${_BITCOINGUI}" ]]
    then
      _BITCOINGUI=$( wget -4qO- -o- "https://raw.githubusercontent.com/${GITHUB_REPO}/master/src/qt/bitcoingui.cpp" )
    fi
    DAEMON_NAME=$( echo "${_BITCOINGUI}" | grep -i -m 1 "windowTitle" | grep -o '(.*)' | sed 's/(//g' | sed 's/)//g' | sed 's/^"\(.*\)".*/\1/' | sed 's/^ *//;s/ *$//' | sed 's/tr"//g' | tr '"\-+' ' ' | awk '{print $1 " " $2}' | sed 's/^ *//;s/ *$//' )
    if [[ "${DAEMON_NAME}" == 'PACKAGE_NAME' ]]
    then
      DAEMON_NAME=$( tr '[:lower:]' '[:upper:]' <<< "${TICKER_LOWER:0:1}" )
      DAEMON_NAME="${DAEMON_NAME}${TICKER_LOWER:1} ${GITHUB_REPO}"
    fi
    if [[ -z "${DAEMON_NAME}" ]]
    then
      DAEMON_NAME=$( tr '[:lower:]' '[:upper:]' <<< "${TICKER_LOWER:0:1}" )
      DAEMON_NAME="${DAEMON_NAME}${BIN_BASE:1} ${GITHUB_REPO}"
    fi
    echo "daemon name=${DAEMON_NAME}"
  fi

  if [[ -z "${COLLATERAL}" ]]
  then
    echo "Downloading collateral requirements from github."
    COLLATERAL=$( echo "${CHAIN}" | grep -iE "Collateral.*=.*" | cut -d '=' -f2 | tr ');' ' ' | sed 's/^ *//;s/ *$//' | cut -d '*' -f1 | grep -o '[0-9]*' )
    if [[ -z "${COLLATERAL}" ]]
    then
      COLLATERAL=$( echo "${CHAIN}" | grep  -iE "Colleteral.*=.*" | cut -d '=' -f2 | tr ');' ' ' | sed 's/^ *//;s/ *$//' | cut -d '*' -f1 | grep -o '[0-9]*' )
    fi
    if [[ -z "${COLLATERAL}" ]]
    then
      _MNINFO=$( wget -4qO- -o- "https://rawcdn.githack.com/${GITHUB_REPO}/master/src/activemasternode.cpp" )
      if [[ -z "${_MNINFO}" ]]
      then
        _MNINFO=$( wget -4qO- -o- "https://raw.githubusercontent.com/${GITHUB_REPO}/master/src/activemasternode.cpp" )
      fi
      COLLATERAL=$( echo "${_MNINFO}" | grep -iF "out.tx->vout[out.i].nValue" | cut -d '=' -f3 | cut -d '*' -f1 | grep -o '[0-9]*' )
    fi
    if [[ -z "${COLLATERAL}" ]]
    then
      _MNINFO=$( wget -4qO- -o- "https://rawcdn.githack.com/${GITHUB_REPO}/master/src/masternode.h" )
      if [[ -z "${_MNINFO}" ]]
      then
        _MNINFO=$( wget -4qO- -o- "https://raw.githubusercontent.com/${GITHUB_REPO}/master/src/masternode.h" )
      fi
      COLLATERAL=$( echo "${_MNINFO}" | grep -m 1 -iE "Collateral.*=.*" | cut -d '=' -f2 | tr ');' ' ' | sed 's/^ *//;s/ *$//' | cut -d '*' -f1 | grep -o '[0-9]*' )
    fi
    if [[ -z "${COLLATERAL}" ]]
    then
      _MNINFO=$( wget -4qO- -o- "https://rawcdn.githack.com/${GITHUB_REPO}/master/src/smartnode/smartnode.h" )
      if [[ -z "${_MNINFO}" ]]
      then
        _MNINFO=$( wget -4qO- -o- "https://raw.githubusercontent.com/${GITHUB_REPO}/master/src/smartnode/smartnode.h" )
      fi
      COLLATERAL=$( echo "${_MNINFO}" | grep -iE "COIN_REQUIRED.*=.*" | cut -d '=' -f2 | tr ');' ' ' | sed 's/^ *//;s/ *$//' | cut -d '*' -f1 | grep -o '[0-9]*' )
    fi
    if [[ -z "${COLLATERAL}" ]]
    then
      _MNINFO=$( wget -4qO- -o- "https://rawcdn.githack.com/${GITHUB_REPO}/master/src/main.h" )
      if [[ -z "${_MNINFO}" ]]
      then
        _MNINFO=$( wget -4qO- -o- "https://raw.githubusercontent.com/${GITHUB_REPO}/master/src/main.h" )
      fi
      COLLATERAL=$( echo "${_MNINFO}" | grep -iE "MNCollateral" | grep -o '{.*}' | grep -Eo '[0-9]+' | tail -n 1 )
      if [[ -z "${COLLATERAL}" ]]
      then
        COLLATERAL=$( echo "${_MNINFO}" | grep -iE "MASTERNODE_COLLATERAL" | grep -Eo '[0-9]+' | tail -n 1 )
      fi
    fi
    if [[ -z "${COLLATERAL}" ]]
    then
      _MNINFO=$( wget -4qO- -o- "https://rawcdn.githack.com/${GITHUB_REPO}/master/src/chainparamschainparams" )
      if [[ -z "${_MNINFO}" ]]
      then
        _MNINFO=$( wget -4qO- -o- "https://raw.githubusercontent.com/${GITHUB_REPO}/master/src/chainparams.cpp" )
      fi
      COLLATERAL=$( echo "${_MNINFO}" | grep -iE "Collateral" | cut -d '=' -f2 | tr ');' ' ' | sed 's/^ *//;s/ *$//' | cut -d '*' -f1 | grep -o '[0-9]*' )
    fi
    COLLATERAL=$( echo "${COLLATERAL}" | head -n 1 )
    echo "collateral=${COLLATERAL}"
  fi

  if [[ -z "${BLOCKTIME}" ]]
  then
    _SRC_CHAIN=$( wget -4qO- -o- "https://rawcdn.githack.com/${GITHUB_REPO}/master/src/chainparams.cpp" )
    if [[ -z "${_SRC_CHAIN}" ]]
    then
      _SRC_CHAIN=$( wget -4qO- -o- "https://raw.githubusercontent.com/${GITHUB_REPO}/master/src/chainparams.cpp" )
    fi
    BLOCKTIME=$( echo "${_SRC_CHAIN}" | grep -m 1 -E "TargetSpacing\s=.*" )
    if [[ -z "${BLOCKTIME}" ]]
    then
      _SRC_MAIN=$( wget -4qO- -o- "https://rawcdn.githack.com/${GITHUB_REPO}/master/src/main.cpp" )
      if [[ -z "${_SRC_MAIN}" ]]
      then
        _SRC_MAIN=$( wget -4qO- -o- "https://raw.githubusercontent.com/${GITHUB_REPO}/master/src/main.cpp" )
      fi
      BLOCKTIME=$( echo "${_SRC_MAIN}" | grep -m 1 -E "TargetSpacing\s=.*" )
    fi
    if [[ -z "${BLOCKTIME}" ]]
    then
      _SRC_MAIN=$( wget -4qO- -o- "https://rawcdn.githack.com/${GITHUB_REPO}/master/src/main.h" )
      if [[ -z "${_SRC_MAIN}" ]]
      then
        _SRC_MAIN=$( wget -4qO- -o- "https://raw.githubusercontent.com/${GITHUB_REPO}/master/src/main.h" )
      fi
      BLOCKTIME=$( echo "${_SRC_MAIN}" | grep -m 1 -E "TARGET_SPACING\s=.*" )
    fi
    BLOCKTIME=$( echo "${BLOCKTIME}" | cut -d ';' -f1 | cut -d '=' -f2 | bc )
  fi

fi

# Daemon Binary.
if [[ -z "${DAEMON_BIN}" ]]
then
  DAEMON_BIN="${BIN_BASE}d"
fi
# Control Binary.
if [[ -z "${CONTROLLER_BIN}" ]]
then
  CONTROLLER_BIN="${BIN_BASE}-cli"
fi
# Daemon Binary Grep.
DAEMON_GREP="[${DAEMON_BIN:0:1}]${DAEMON_BIN:1}"

# Coin Ticker lowercase.
if [[ -z "${TICKER_LOWER}" ]]
then
  TICKER_LOWER=$( echo "${TICKER}" | tr '[:upper:]' '[:lower:]' )
fi

if [[ -z "${DAEMON_PREFIX}" ]]
then
  # Username Prefix.
  DAEMON_PREFIX="${TICKER_LOWER:0:4}_${MASTERNODE_PREFIX}"
fi
if [[ -z "${RPC_USERNAME}" ]]
then
  # RPC username.
  RPC_USERNAME=${TICKER_LOWER}
fi
if [[ -z "${DAEMON_SETUP_LOG}" ]]
then
  # Log filename.
  DAEMON_SETUP_LOG="/tmp/${TICKER_LOWER}.log"
  # Log to a file.
  rm -f "${DAEMON_SETUP_LOG}" 2>/dev/null
  touch "${DAEMON_SETUP_LOG}" 2>/dev/null
  chmod 600 "${DAEMON_SETUP_LOG}" 2>/dev/null
  exec >  >(tee -ia "${DAEMON_SETUP_LOG}") 2>/dev/null
  exec 2> >(tee -ia "${DAEMON_SETUP_LOG}" >&2) 2>/dev/null
fi
if [[ -z "${DAEMON_SETUP_INFO}" ]]
then
  # Masternode output file.
  DAEMON_SETUP_INFO="${HOME}/${TICKER_LOWER}.${MASTERNODE_PREFIX}.txt"
fi

# Cycle Daemon on first start.
if [[ -z "${DAEMON_CYCLE}" ]]
then
  DAEMON_CYCLE=0
fi

# Slow Daemon Start.
if [[ -z "${SLOW_DAEMON_START}" ]]
then
  SLOW_DAEMON_START=0
fi

# Bad Explorer SSL.
if [[ -z "${BAD_SSL_HACK}" ]]
then
  BAD_SSL_HACK=''
fi

# Extra configuation for the conf file.
if [[ -z "${EXTRA_CONFIG}" ]]
then
  EXTRA_CONFIG=''
fi

# Auto Recovery.
if [[ -z "${RESTART_IN_SYNC}" ]]
then
  RESTART_IN_SYNC=1
fi

# Number of Connections to wait for.
if [[ -z "${DAEMON_CONNECTIONS}" ]]
then
  DAEMON_CONNECTIONS=6
fi

# Wait for MNSYNC.
if [[ -z "${MNSYNC_WAIT_FOR}" ]]
then
  #MNSYNC_WAIT_FOR='"RequestedMasternodeAssets": 999,'
  MNSYNC_WAIT_FOR=''
fi

# Run Mini Monitor.
if [[ -z "${MINI_MONITOR_RUN}" ]]
then
  MINI_MONITOR_RUN=1
fi

# Mini Monitor Queue Payouts.
if [[ -z "${MINI_MONITOR_MN_QUEUE}" ]]
then
  MINI_MONITOR_MN_QUEUE=1
fi

# Rate limit explorer.
if [[ -z "${EXPLORER_SLEEP}" ]]
then
  EXPLORER_SLEEP=0
fi

WAIT_FOR_APT_GET () {
  ONCE=0
  while [[ $( sudo lslocks | grep -c 'apt-get\|dpkg\|unattended-upgrades' ) -ne 0 ]]
  do
    if [[ "${ONCE}" -eq 0 ]]
    then
      while read -r LOCKINFO
      do
        PID=$( echo "${LOCKINFO}" | awk '{print $2}' )
        ps -up "${PID}"
        echo "${LOCKINFO}"
      done <<< "$( sudo lslocks | grep 'apt-get\|dpkg\|unattended-upgrades' )"
      ONCE=1
    fi
    echo -e "\r${SP:i++%${#SP}:1} Waiting for apt-get to finish... \c"
    sleep 0.3
  done
  echo
  echo -e "\r\c"
  stty sane 2>/dev/null
}

DAEMON_DOWNLOAD_SUPER () {
  REPO=${1}
  BIN_BASE=${2}
  DAEMON_DOWNLOAD_URL=${3}
  FILENAME=$( echo "${REPO}" | tr '/' '_' )
  RELEASE_TAG='latest'
  if [[ ! -z "${4}" ]]
  then
    rm /var/multi-masternode-data/latest-github-releasese/"${FILENAME}".json
    RELEASE_TAG=${4}
  fi

  if [[ -z "${REPO}" ]] || [[ -z "${BIN_BASE}" ]]
  then
    return 1 2>/dev/null
  fi
  echo "Checking ${REPO} for the latest version"
  if [[ ! -d /var/multi-masternode-data/latest-github-releasese ]]
  then
    sudo -n mkdir -p /var/multi-masternode-data/latest-github-releasese
    sudo -n chmod -R a+rw /var/multi-masternode-data/
  fi
  mkdir -p /var/multi-masternode-data/latest-github-releasese 2>/dev/null
  chmod -R a+rw /var/multi-masternode-data/ 2>/dev/null
  PROJECT_DIR=$( basename "${REPO}" )

  DAEMON_BIN="${BIN_BASE}d"
  DAEMON_GREP="[${DAEMON_BIN:0:1}]${DAEMON_BIN:1}"
  CONTROLLER_BIN="${BIN_BASE}-cli"

  if [[ ! "${DAEMON_DOWNLOAD_URL}" == http* ]]
  then
    DAEMON_DOWNLOAD_URL=''
  fi

  # curl & curl cache.
  if [[ -z "${DAEMON_DOWNLOAD_URL}" ]]
  then
    TIMESTAMP=9999
    if [[ -f /var/multi-masternode-data/latest-github-releasese/"${FILENAME}".json ]]
    then
      # Get timestamp.
      TIMESTAMP=$( stat -c %Y /var/multi-masternode-data/latest-github-releasese/"${FILENAME}".json )
    fi
    echo "Downloading ${RELEASE_TAG} release info from github."
    curl -sL --max-time 10 "https://api.github.com/repos/${REPO}/releases/${RELEASE_TAG}" -z "$( date --rfc-2822 -d "@${TIMESTAMP}" )" -o /var/multi-masternode-data/latest-github-releasese/"${FILENAME}".json

    LATEST=$( cat /var/multi-masternode-data/latest-github-releasese/"${FILENAME}".json )
    if [[ $( echo "${LATEST}" | grep -c 'browser_download_url' ) -eq 0 ]]
    then
      echo "Downloading ${RELEASE_TAG} release info from github."
      curl -sL --max-time 10 "https://api.github.com/repos/${REPO}/releases/${RELEASE_TAG}" -o /var/multi-masternode-data/latest-github-releasese/"${FILENAME}".json
      LATEST=$( cat /var/multi-masternode-data/latest-github-releasese/"${FILENAME}".json )
    fi
    if [[ $( echo "${LATEST}" | grep -c 'browser_download_url' ) -eq 0 ]]
    then
      echo "Downloading latest release info from github."
      RELEASE_ID=$( wget -4qO- -o- "https://api.github.com/repos/${REPO}/releases" | jq '.[].id' )
      curl -sL --max-time 10 "https://api.github.com/repos/${REPO}/releases/${RELEASE_ID}" -o /var/multi-masternode-data/latest-github-releasese/"${FILENAME}".json
      LATEST=$( cat /var/multi-masternode-data/latest-github-releasese/"${FILENAME}".json )
    fi

    VERSION_REMOTE=$( echo "${LATEST}" | jq -r '.tag_name' | sed 's/[^0-9.]*\([0-9.]*\).*/\1/' )
    echo "Remote version: ${VERSION_REMOTE}"
    if [[ -f /var/multi-masternode-data/"${PROJECT_DIR}"/src/"${CONTROLLER_BIN}" ]]
    then
      VERSION_LOCAL=$( /var/multi-masternode-data/"${PROJECT_DIR}"/src/"${CONTROLLER_BIN}" -version 2>/dev/null | sed 's/[^0-9.]*\([0-9.]*\).*/\1/' )
      echo "Local version: ${VERSION_LOCAL}"
      if [[ $( echo "${VERSION_LOCAL}" | grep -c "${VERSION_REMOTE}" ) -eq 1 ]]
      then
        return 1 2>/dev/null
      fi
    fi
    ALL_DOWNLOADS=$( echo "${LATEST}" | jq -r '.assets[].browser_download_url' )
    # Remove useless files.
    DOWNLOADS=$( echo "${ALL_DOWNLOADS}" | grep -iv 'win' | grep -iv 'arm-RPi' | grep -iv '\-qt' | grep -iv 'raspbian' | grep -v '.dmg$' | grep -v '.exe$' | grep -v '.sh$' | grep -v '.pdf$' | grep -v '.sig$' | grep -v '.asc$' | grep -iv 'MacOS' | grep -iv 'HighSierra' | grep -iv 'arm' )

    # Try to pick the correct file.
    LINES=$( echo "${DOWNLOADS}" | wc -l )
    if [[ "${LINES}" -eq 0 ]]
    then
      echo "ERROR!"
    elif [[ "${LINES}" -eq 1 ]]
    then
      DAEMON_DOWNLOAD_URL="${DOWNLOADS}"
    else
      # Pick ones that are 64 bit linux.
      DAEMON_DOWNLOAD_URL=$( echo "${DOWNLOADS}" | grep 'x86_64\|linux64\|ubuntu\|daemon\|lin64' )
    fi

    if [[ -z "${DAEMON_DOWNLOAD_URL}" ]]
    then
      # Pick ones that are linux command line.
      DAEMON_DOWNLOAD_URL=$( echo "${DOWNLOADS}" | grep -i 'linux_cli' )
    fi

    if [[ -z "${DAEMON_DOWNLOAD_URL}" ]]
    then
      # Pick ones that are linux.
      DAEMON_DOWNLOAD_URL=$( echo "${DOWNLOADS}" | grep -i 'linux' )
    fi

    # If more than 1 pick the one with 64 in it.
    if [[ $( echo "${DAEMON_DOWNLOAD_URL}" | wc -l ) -gt 1 ]]
    then
      DAEMON_DOWNLOAD_URL=$( echo "${DAEMON_DOWNLOAD_URL}" | grep -i '64' )
    fi
  fi
  if [[ -z "${DAEMON_DOWNLOAD_URL}" ]]
  then
    echo
    echo "Could not find linux wallet from https://api.github.com/repos/${REPO}/releases/latest"
    echo "${DOWNLOADS}"
    echo
  else
    BIN_FILENAME=$( basename "${DAEMON_DOWNLOAD_URL}" )
    echo "Downloading latest release from github."
    echo "${DAEMON_DOWNLOAD_URL}"
    wget -4qo- "${DAEMON_DOWNLOAD_URL}" -O /var/multi-masternode-data/latest-github-releasese/"${BIN_FILENAME}"
    mkdir -p /var/multi-masternode-data/"${PROJECT_DIR}"/src
    if [[ $( echo "${BIN_FILENAME}" | grep -c '.tar.gz$' ) -eq 1 ]]
    then
      tar -xzf /var/multi-masternode-data/latest-github-releasese/"${BIN_FILENAME}" -C /var/multi-masternode-data/"${PROJECT_DIR}"/src

    elif [[ $( echo "${BIN_FILENAME}" | grep -c '.tar.xz$' ) -eq 1 ]]
    then
      tar -xf /var/multi-masternode-data/latest-github-releasese/"${BIN_FILENAME}" -C /var/multi-masternode-data/"${PROJECT_DIR}"/src

    elif [[ $( echo "${BIN_FILENAME}" | grep -c '.zip$' ) -eq 1 ]]
    then
      unzip -o /var/multi-masternode-data/latest-github-releasese/"${BIN_FILENAME}" -d /var/multi-masternode-data/"${PROJECT_DIR}"/src/

    elif [[ $( echo "${BIN_FILENAME}" | grep -c '.deb$' ) -eq 1 ]]
    then
      sudo -n dpkg --install /var/multi-masternode-data/latest-github-releasese/"${BIN_FILENAME}"
      dpkg -x /var/multi-masternode-data/latest-github-releasese/"${BIN_FILENAME}" /var/multi-masternode-data/"${PROJECT_DIR}"/src/

    else
      cp /var/multi-masternode-data/latest-github-releasese/"${BIN_FILENAME}" /var/multi-masternode-data/"${PROJECT_DIR}"/src/
    fi

    cd ~/ || return 1 2>/dev/null
    find /var/multi-masternode-data/"${PROJECT_DIR}"/src/ -name "$DAEMON_BIN" -exec cp {} /var/multi-masternode-data/"${PROJECT_DIR}"/src/  \; 2>/dev/null
    find /var/multi-masternode-data/"${PROJECT_DIR}"/src/ -name "$CONTROLLER_BIN" -exec cp {} /var/multi-masternode-data/"${PROJECT_DIR}"/src/  \; 2>/dev/null
    if [[ -f /var/multi-masternode-data/"${PROJECT_DIR}"/src/"${DAEMON_BIN}" ]]
    then
      sudo -n chmod +x /var/multi-masternode-data/"${PROJECT_DIR}"/src/"${DAEMON_BIN}" 2>/dev/null
      chmod +x /var/multi-masternode-data/"${PROJECT_DIR}"/src/"${DAEMON_BIN}" 2>/dev/null
    fi
    if [[ -f /var/multi-masternode-data/"${PROJECT_DIR}"/src/"${CONTROLLER_BIN}" ]]
    then
      sudo -n chmod +x /var/multi-masternode-data/"${PROJECT_DIR}"/src/"${CONTROLLER_BIN}" 2>/dev/null
      chmod +x /var/multi-masternode-data/"${PROJECT_DIR}"/src/"${CONTROLLER_BIN}" 2>/dev/null
    fi
  fi
}

UPDATE_USER_FILE () {
  STRING=${1}
  FUNCTION_NAME=${2/#\~/$HOME}
  FILENAME=${3}
  ALT_FILENAME=${4}
  DIR=$( dirname "${ALT_FILENAME}" )
  sudo mkdir -p "${DIR}"
  sudo chmod -R a+rw "${DIR}"
  touch "${ALT_FILENAME}"

  # Replace ${FUNCTION_NAME} function if it exists.
  FUNC_START=$( grep -Fxn "# Start of function for ${FUNCTION_NAME}." "$FILENAME" | sed 's/:/ /g' | awk '{print $1 }' | sort -r )
  FUNC_END=$( grep -Fxn "# End of function for ${FUNCTION_NAME}." "$FILENAME" | sed 's/:/ /g' | awk '{print $1 }' | sort -r )
  if [ ! -z "${FUNC_START}" ] && [ ! -z "${FUNC_END}" ]
  then
    paste <( echo "${FUNC_START}" ) <( echo "${FUNC_END}" ) -d ' ' | while read -r START END
    do
      sed -i "${START},${END}d" "$FILENAME"
    done
  fi
  # Remove empty lines at end of file.
  sed -i -r '${/^[[:space:]]*$/d;}' "$FILENAME"
  echo "" >> "$FILENAME"
  # Add in ${FUNCTION_NAME} function.
  {
    echo "${STRING}"; echo ""
  } >> "$FILENAME"
  {
    echo "${STRING}"; echo ""
  } >> "${ALT_FILENAME}"
  # Remove double empty lines in the file.
  sed -i '/^$/N;/^\n$/D' ~/.bashrc
}

STRING_TO_INT () {
  local -i num="10#${1}"
  echo "${num}"
}

PORT_IS_OK () {
  local port="$1"
  local -i port_num
  port_num=$( STRING_TO_INT "${port}" 2>/dev/null )

  if (( port_num < 1 || port_num > 65535 || port_num == 22 ))
  then
    echo "${port} is not a valid port number (1 to 65535 and not 22)" 1>&2
    return 255
  fi
}

VALID_IP () {
  local IPA1=$1
  local stat=1
  local OIFS
  local ip

  if [[ $IPA1 =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]];
  then
    OIFS=$IFS

  local IFS='.'             #read man, you will understand, this is internal field separator; which is set as '.'
    ip=( $ip )       # IP value is saved as array
    IFS=$OIFS      #setting IFS back to its original value;

    [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
      && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]  # It's testing if any part of IP is more than 255
    stat=$? #If any part of IP as tested above is more than 255 stat will have a non zero value
  fi
  return $stat # as expected returning
}

if [[ "${DAEMON_BIN}" != "catocoind" ]] && \
  [[ "${DAEMON_BIN}" != "decentroniumd" ]] && \
  [[ "${DAEMON_BIN}" != "energid" ]] && \
  [[ "${DAEMON_BIN}" != "galileld" ]] && \
  [[ "${DAEMON_BIN}" != "GLPMd" ]] && \
  [[ "${DAEMON_BIN}" != "gossipcoind" ]] && \
  [[ "${DAEMON_BIN}" != "huzud" ]] && \
  [[ "${DAEMON_BIN}" != "printexd" ]] && \
  [[ "${DAEMON_BIN}" != "pured" ]] && \
  [[ "${DAEMON_BIN}" != "qmcd" ]] && \
  [[ "${DAEMON_BIN}" != "stakecubed" ]] && \
  [[ "${DAEMON_BIN}" != "stakeshared" ]] && \
  [[ "${DAEMON_BIN}" != "smartcashd" ]] && \
  [[ "${DAEMON_BIN}" != "smkd" ]] && \
  [[ "${DAEMON_BIN}" != "specialcoind" ]] && \
  [[ "${DAEMON_BIN}" != "venoxd" ]]
then
  echo
  echo "Contact @mcarper on twitter or discord for help."
  echo
  return 1 2>/dev/null || exit 1
fi

CHECK_SYSTEM () {
  local OS
  local VER
  local TARGET
  local FREEPSPACE_ALL
  local FREEPSPACE_BOOT
  local ARCH

  # Only run if user has sudo.
  sudo true
  CAN_SUDO=$( timeout 1s bash -c 'sudo -l 2>/dev/null | wc -l ' )
  if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
  then
    :
  else
    echo "Script must be run as a user with no password sudo privileges"
    echo "To switch to the root user type"
    echo
    echo "sudo su"
    echo
    echo "And then re-run this command."
    return 1 2>/dev/null || exit 1
  fi

  # Make sure sudo will work
  if [[ $( sudo false 2>&1 ) ]]
  then
    echo "$( hostname -I | awk '{print $1}' ) $( hostname )" >> /etc/hosts
  fi

  # Make sure home is set.
  if [[ -z "${HOME}" ]]
  then
    echo
    echo "Please set the HOME variable."
    echo
    return 1 2>/dev/null || exit 1
  fi

  # Check for systemd
  systemctl --version >/dev/null 2>&1 || { cat /etc/*-release; echo; echo "systemd is required. Are you using Ubuntu 16.04?" >&2; return 1 2>/dev/null || exit 1; }

  # Check for Ubuntu
  if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
  elif type lsb_release >/dev/null 2>&1; then
    # linuxbase.org
    OS=$( lsb_release -si )
    VER=$( lsb_release -sr )
  elif [ -f /etc/lsb-release ]; then
    # For some versions of Debian/Ubuntu without lsb_release command
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
  elif [ -f /etc/debian_version ]; then
    # Older Debian/Ubuntu/etc.
    OS=Debian
    VER=$( cat /etc/debian_version )
  elif [ -f /etc/SuSe-release ]; then
    # Older SuSE/etc.
    ...
  elif [ -f /etc/redhat-release ]; then
    # Older Red Hat, CentOS, etc.
    ...
  else
    # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
    OS=$( uname -s )
    VER=$( uname -r )
  fi

  if [ "${OS}" != "Ubuntu" ]
  then
    cat /etc/*-release
    echo
    echo "Are you using Ubuntu 16.04 or higher?"
    echo
    return 1 2>/dev/null || exit 1
  fi

  TARGET='16.04'
  if [[ "${VER%.*}" -eq "${TARGET%.*}" ]] && [[ "${VER#*.}" -ge "${TARGET#*.}" ]] || [[ "${VER%.*}" -gt "${TARGET%.*}" ]]
  then
    :
  else
    cat /etc/*-release
    echo
    echo "Are you using Ubuntu 16.04 or higher?"
    echo
    return 1 2>/dev/null || exit 1
  fi

  # Make sure it's 64bit.
  ARCH=$( uname -m )
  if [[ "${ARCH}" != "x86_64" ]]
  then
    echo
    echo "${ARCH} is not x86_64. A 64bit OS is required."
    echo
    return 1 2>/dev/null || exit 1
  fi

  # Check hd space.
  FREEPSPACE_ALL=$( df -P . | tail -1 | awk '{print $4}' )
  FREEPSPACE_BOOT=$( df -P /boot | tail -1 | awk '{print $4}' )
  if [ "${FREEPSPACE_ALL}" -lt 1572864  ] || [ "${FREEPSPACE_BOOT}" -lt 131072 ]
  then
    WAIT_FOR_APT_GET
    sudo DEBIAN_FRONTEND=noninteractive apt-get clean

    FREEPSPACE_ALL=$( df -P . | tail -1 | awk '{print $4}' )
    FREEPSPACE_BOOT=$( df -P /boot | tail -1 | awk '{print $4}' )
    if [ "${FREEPSPACE_ALL}" -lt 1572864  ] || [ "${FREEPSPACE_BOOT}" -lt 131072 ]
    then
      echo
      echo "${FREEPSPACE_ALL} Kbytes of free disk space found."
      echo "1572864 Kbytes (1.5 GB) of free space is needed to proceed"
      echo "${FREEPSPACE_BOOT} Kbytes of free disk space found on /boot."
      echo "131072 Kbytes (128 MB) of free space is needed on the boot folder to proceed"
      echo
      return 1 2>/dev/null || exit 1
    fi
  fi

  # Check ram.
  MEM_AVAILABLE=$( sudo cat /proc/meminfo | grep -i 'MemAvailable:\|MemFree:' | awk '{print $2}' | tail -n 1 )
  if [[ "${MEM_AVAILABLE}" -lt 65536 ]]
  then
    SWAP_FREE=$( free | grep -i 'Swap:' | awk '{print $4}' )
    echo
    echo "Free Memory: ${MEM_AVAILABLE} kb"
    if [[ "${SWAP_FREE}" -lt 524288 ]]
    then
      echo "Free Swap Space: ${SWAP_FREE} kb"
      echo
      echo "This linux box may not have enough resources to run a ${MASTERNODE_CALLER} daemon."
      echo "If I were you I'd get a better linux box."
      echo "ctrl-c to exit this script."
      echo
      read -r -t 10 -p "Hit ENTER to continue or wait 10 seconds" 2>&1
    else
      echo "Note: This linux box may not have enough free memory to run a ${MASTERNODE_CALLER} daemon."
      read -r -t 5 -p "Hit ENTER to continue or wait 5 seconds" 2>&1
    fi
    echo
  fi
}

INITIAL_PROGRAMS () {
  local LAST_LOGIN_IP
  local LAST_UPDATED
  local UNIX_TIME
  local TIME_DIFF
  local LOGGED_IN_USR
  local COUNTER

  # Fix broken apt-get
  WAIT_FOR_APT_GET
  sudo dpkg --configure -a
  WAIT_FOR_APT_GET
  sudo DEBIAN_FRONTEND=noninteractive apt-get -f install -yq

  # Only run apt-get update if not ran in the last 12 hours.
  LAST_UPDATED=$( stat --format="%X" /var/cache/apt/pkgcache.bin )
  UNIX_TIME=$( date +%s )
  TIME_DIFF=$(( UNIX_TIME - LAST_UPDATED ))
  if [[ "${TIME_DIFF}" -gt 43200 ]]
  then
    WAIT_FOR_APT_GET
    sudo DEBIAN_FRONTEND=noninteractive apt-get update -yq
  fi

  # Make sure add-apt-repository is available.
  if [ ! -x "$( command -v add-apt-repository )" ]
  then
    WAIT_FOR_APT_GET
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq software-properties-common
  fi

  if [[ $( grep /etc/apt/sources.list -ce '^deb.*universe' ) -eq 0 ]]
  then
    WAIT_FOR_APT_GET
    sudo add-apt-repository universe
    WAIT_FOR_APT_GET
    sudo DEBIAN_FRONTEND=noninteractive apt-get update -yq
  fi

  # Clear /var/log/auth.log of this IP before installing denyhosts.
  if ! [ -x "$( command -v denyhosts )" ]
  then
    LOGGED_IN_USR=$( whoami )
    LAST_LOGIN_IP=$( sudo last -i | grep -v '0.0.0.0' | grep "${LOGGED_IN_USR}" | head -1 | awk '{print $3}' )
    if [ ! -x "${LAST_LOGIN_IP}" ]
    then
      echo "sshd: ${LAST_LOGIN_IP}" | sudo tee -a /etc/hosts.allow >/dev/null
    fi
    sudo touch /var/log/auth.log
    sudo chmod 640 /var/log/auth.log
    # Remove failed login attempts for this user so denyhosts doesn't block us right here.
    while read -r IP_UNBLOCK
    do
      denyhosts_unblock "$IP_UNBLOCK" 2>/dev/null
      sudo sed -i -e "/$IP_UNBLOCK/d" /etc/hosts.deny
      sudo sed -i -e "/refused connect from $IP_UNBLOCK/d" /var/log/auth.log
      sudo sed -i -e "/from $IP_UNBLOCK port/d" /var/log/auth.log
      sudo iptables -D INPUT -s "${IP_UNBLOCK}" -j DROP 2>/dev/null
    done <<< "$( sudo last -ix | head -n -2 | awk '{print $3 }' | sort | uniq )"

    WAIT_FOR_APT_GET
    sudo dpkg --configure -a
    WAIT_FOR_APT_GET
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq denyhosts

    # Allow for 5 bad root login attempts before killing the ip.
    sudo sed -ie 's/DENY_THRESHOLD_ROOT \= 1/DENY_THRESHOLD_ROOT = 5/g' /etc/denyhosts.conf
    sudo sed -ie 's/DENY_THRESHOLD_RESTRICTED \= 1/DENY_THRESHOLD_RESTRICTED = 5/g' /etc/denyhosts.conf
    sudo systemctl restart denyhosts

    WAIT_FOR_APT_GET
    sudo dpkg --configure -a
    WAIT_FOR_APT_GET
    sudo DEBIAN_FRONTEND=noninteractive apt-get -f install -yq
  fi

  # Make sure firewall and some utilities is installed.
  WAIT_FOR_APT_GET
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq \
    curl \
    pwgen \
    ufw \
    lsof \
    util-linux \
    gzip \
    unzip \
    xz-utils \
    procps \
    jq \
    htop \
    git \
    gpw \
    bc \
    sysstat \
    glances

  # Turn on firewall, only allow port 22.
  sudo ufw allow 22 >/dev/null 2>&1
  echo "y" | sudo ufw enable >/dev/null 2>&1
  sudo ufw reload

  COUNTER=0
  DAEMON_DOWNLOAD_SUPER "${GITHUB_REPO}" "${BIN_BASE}" "${DAEMON_DOWNLOAD}"
  while [[ ! -f /var/multi-masternode-data/"${PROJECT_DIR}"/src/"${DAEMON_BIN}" ]]
  do
    DAEMON_DOWNLOAD_SUPER "${GITHUB_REPO}" "${BIN_BASE}" "${DAEMON_DOWNLOAD}"
    echo -e "\r\c"
    COUNTER=$(( COUNTER+1 ))
    if [[ "${COUNTER}" -gt 3 ]]
    then
      break;
    fi
  done

  WAIT_FOR_APT_GET
  sudo dpkg --configure -a
  if [[ $( ldd /var/multi-masternode-data/"${PROJECT_DIR}"/src/"${DAEMON_BIN}" | grep -cF 'not found' ) -ne 0 ]] || [[ $( ldd /var/multi-masternode-data/"${PROJECT_DIR}"/src/"${CONTROLLER_BIN}" | grep -cF 'not found' ) -ne 0 ]]
  then
    # Add in 16.04 repo.
    COUNTER=0
    if ! grep -Fxq "deb http://archive.ubuntu.com/ubuntu/ xenial-updates main restricted" /etc/apt/sources.list
    then
      echo "deb http://archive.ubuntu.com/ubuntu/ xenial-updates main restricted" | sudo tee -a /etc/apt/sources.list >/dev/null
      COUNTER=1
    fi
    if ! grep -Fxq "deb http://archive.ubuntu.com/ubuntu/ xenial universe" /etc/apt/sources.list
    then
      echo "deb http://archive.ubuntu.com/ubuntu/ xenial universe" | sudo tee -a /etc/apt/sources.list >/dev/null
      COUNTER=1
    fi

    if [[ $( grep -r '/etc/apt' -e 'bitcoin' | wc -l ) -eq 0 ]]
    then
      WAIT_FOR_APT_GET
      echo | sudo add-apt-repository ppa:bitcoin/bitcoin
      COUNTER=1
    fi

    # Update apt-get info with the new repo.
    if [[ "${COUNTER}" -gt 0 ]]
    then
      WAIT_FOR_APT_GET
      sudo dpkg --configure -a
      WAIT_FOR_APT_GET
      sudo DEBIAN_FRONTEND=noninteractive apt-get update -yq
      WAIT_FOR_APT_GET
      sudo DEBIAN_FRONTEND=noninteractive apt-get -f install -yq
    fi

    # Make sure shared libs are installed.
    WAIT_FOR_APT_GET
    sudo dpkg --configure -a
    WAIT_FOR_APT_GET
    sudo DEBIAN_FRONTEND=noninteractive apt-get -f install -yq
    # Install libboost.
    # Install libevent.
    # Install libminiupnpc.
    # Install older db code from bitcoin repo.
    WAIT_FOR_APT_GET
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq \
      libboost-system1.58.0 \
      libboost-filesystem1.58.0 \
      libboost-program-options1.58.0 \
      libboost-thread1.58.0 \
      libboost-chrono1.58.0 \
      libevent-2.0-5 \
      libevent-core-2.0-5 \
      libevent-extra-2.0-5 \
      libevent-openssl-2.0-5 \
      libevent-pthreads-2.0-5 \
      libminiupnpc-dev \
      libzmq5 \
      libdb4.8-dev \
      libdb4.8++-dev
  fi

  WAIT_FOR_APT_GET
  sudo DEBIAN_FRONTEND=noninteractive apt-get -f install -yq
  # sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq html-xml-utils

  # Make sure jq is installed.
  if ! [ -x "$( command -v jq )" ]
  then
    echo
    echo "jq not installed; exiting. This command failed"
    echo "sudo apt-get install -yq jq"
    echo
    return 1 2>/dev/null || exit 1
  fi
}

SYSTEM_UPDATE_UPGRADE () {
  local TOTAL_RAM
  local TARGET_SWAP
  local SWAP_SIZE
  local FREE_HD
  local MIN_SWAP

  # Log to a file.
  exec >  >( tee -ia "${DAEMON_SETUP_LOG}" )
  exec 2> >( tee -ia "${DAEMON_SETUP_LOG}" >&2 )

  echo "Make swap file if one does not exist."
  if ! [ -x "$( command -v bc )" ]
  then
    WAIT_FOR_APT_GET
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq bc
  fi
  SWAP_SIZE=$( echo "scale=2; $( sudo sed -n 2p /proc/swaps | awk '{print $3 }' ) / 1024" | bc | awk '{printf("%d\n",$1 + 0.5)}' )
  if [ -z "${SWAP_SIZE}" ]
  then
    TOTAL_RAM=$( echo "scale=2; $( awk '/MemTotal/ {print $2}' /proc/meminfo ) / 1024" | bc | awk '{printf("%d\n",$1 + 0.5)}' )
    FREE_HD=$( echo "scale=2; $( df -P . | tail -1 | awk '{print $4}' ) / 1024" | bc | awk '{printf("%d\n",$1 + 0.5)}' )
    MIN_SWAP=4096
    TARGET_SWAP=$(( TOTAL_RAM * 3 ))
    TARGET_SWAP=$(( TARGET_SWAP > MIN_SWAP ? TARGET_SWAP : MIN_SWAP ))
    TARGET_SWAP=$(( FREE_HD / 2 < TARGET_SWAP ? FREE_HD / 2 : TARGET_SWAP ))

    sudo dd if=/dev/zero of=/var/swap.img bs=1024k count="${TARGET_SWAP}"
    sudo chmod 600 /var/swap.img
    sudo mkswap /var/swap.img
    sudo swapon /var/swap.img
    OUT=$?
    if [ $OUT -eq 255 ]
    then
      echo "System does not support swap files."
      sudo rm /var/swap.img
    else
      echo "/var/swap.img none swap sw 0 0" >> /etc/fstab
    fi
  fi

  # Update the system.
  echo "# Updating software"
  WAIT_FOR_APT_GET
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq libc6
  WAIT_FOR_APT_GET
  sudo DEBIAN_FRONTEND=noninteractive apt-get -yq -o DPkg::options::="--force-confdef" \
  -o DPkg::options::="--force-confold"  install grub-pc
  WAIT_FOR_APT_GET
  sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -yq
  WAIT_FOR_APT_GET
  sudo DEBIAN_FRONTEND=noninteractive apt-get -f install -yq
  echo "# Updating system"
  WAIT_FOR_APT_GET
  sudo DEBIAN_FRONTEND=noninteractive apt-get -yq -o Dpkg::Options::="--force-confdef" \
  -o Dpkg::Options::="--force-confold" dist-upgrade
  WAIT_FOR_APT_GET
  sudo DEBIAN_FRONTEND=noninteractive apt-get -f install -yq

  WAIT_FOR_APT_GET
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq unattended-upgrades

  if [ ! -f /etc/apt/apt.conf.d/20auto-upgrades ]
  then
    # Enable auto updating of Ubuntu security packages.
    cat << UBUNTU_SECURITY_PACKAGES | sudo tee /etc/apt/apt.conf.d/20auto-upgrades >/dev/null
APT::Periodic::Enable "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
UBUNTU_SECURITY_PACKAGES
  fi

  # Force run unattended upgrade to get everything up to date.
  sudo unattended-upgrade -d
  WAIT_FOR_APT_GET
  sudo DEBIAN_FRONTEND=noninteractive apt-get -f install -yq
}

USER_FUNCTION_FOR_MASTERNODE () {
# Create function that can control the new masternode daemon.
_MN_DAEMON_FUNC=$( cat << MN_DAEMON_FUNC
# Start of function for ${1}.
${1} () {
  _masternode_dameon_2 "${1}" "${CONTROLLER_BIN}" "${EXPLORER_URL}" "${DAEMON_BIN}" "/home/${1}/${DIRECTORY}/${CONF}" "${BAD_SSL_HACK}" "-1" "-1" "\${1}" "\${2}" "\${3}" "\${4}" "\${5}" "\${6}" "\${7}" "\${8}" "\${9}"
}
complete -F _masternode_dameon_2_completions ${1}
# End of function for ${1}.
MN_DAEMON_FUNC
)
UPDATE_USER_FILE "${_MN_DAEMON_FUNC}" "${1}" "${2}" "${3}"
}

# Create function that can unblock an IP that denyhosts says is bad.
_DENYHOSTS_UNBLOCK=$( cat << "DENYHOSTS_UNBLOCK"
# Start of function for denyhosts_unblock.
denyhosts_unblock () {
  IP_UNBLOCK="$1"
  sudo systemctl stop denyhosts
  sudo sed -i -e "/$IP_UNBLOCK/d" /etc/hosts.deny
  sudo sed -i -e "/^$IP_UNBLOCK/d" /var/lib/denyhosts/hosts
  sudo sed -i -e "/^$IP_UNBLOCK/d" /var/lib/denyhosts/hosts-restricted
  sudo sed -i -e "/^$IP_UNBLOCK/d" /var/lib/denyhosts/hosts-root
  sudo sed -i -e "/^$IP_UNBLOCK/d" /var/lib/denyhosts/hosts-valid
  sudo sed -i -e "/$IP_UNBLOCK/d" /var/lib/denyhosts/users-hosts
  sudo sed -i -e "/^$IP_UNBLOCK/d" /var/lib/denyhosts/hosts-root
  sudo sed -i -e "/refused connect from $IP_UNBLOCK/d" /var/log/auth.log
  sudo sed -i -e "/from $IP_UNBLOCK port/d" /var/log/auth.log
  sudo iptables -D INPUT -s "$IP_UNBLOCK" -j DROP
  sudo ufw reload
  sudo systemctl start denyhosts
}
# End of function for denyhosts_unblock.
DENYHOSTS_UNBLOCK
)

# Create function that can control any masternode daemon.
_MN_DAEMON_MASTER_FUNC=$( cat << "MN_DAEMON_MASTER_FUNC"
# Start of function for _masternode_dameon_2.
_masternode_dameon_2 () {
  CAN_SUDO=$( timeout 1s bash -c 'sudo -n true >/dev/null 2>&1 && sudo -l 2>/dev/null | wc -l ' )
  local TEMP_VAR_A
  local TEMP_VAR_B
  local TEMP_VAR_C
  local TEMP_VAR_D
  local TEMP_VAR_PID
  local RE
  local SP
  local DIR
  local USER_HOME_DIR

  RE='^[0-9]+$'
  SP="/-\\|"
  TEMP_VAR_C="${6}"
  if [[ "${TEMP_VAR_C}" == '-1' ]]
  then
    TEMP_VAR_C=''
  fi

  if [[ -f "${5}" ]]
  then
    DIR=$( dirname "${5}" )
    USER_HOME_DIR=$( dirname "${DIR}" )
    _MASTERNODE_CALLER=$( grep -m 1 'masternode_caller=' "${5}" | cut -d '=' -f2 )
    _MASTERNODE_PREFIX=$( grep -m 1 'masternode_prefix=' "${5}" | cut -d '=' -f2 )
  fi

  if [[ -z "${_MASTERNODE_CALLER}" ]]
  then
    _MASTERNODE_CALLER='masternode'
  fi
  if [[ -z "${_MASTERNODE_PREFIX}" ]]
  then
    _MASTERNODE_PREFIX='mn'
  fi

  if [ "${9}" == "pid" ]
  then
    # shellcheck disable=SC2009
    ps axfo user:80,pid,command | sed -e 's/^[[:space:]]*//' | grep -E "^${1}\s" | grep "[${4:0:1}]${4:1}" | awk '{print $2 }'

  elif [ "${9}" == "uptime" ]
  then
    # shellcheck disable=SC2009
    ps axfo user:80,etimes,command | sed -e 's/^[[:space:]]*//' | grep -E "^${1}\s" | grep "[${4:0:1}]${4:1}" | awk '{print $2 }'

  elif [ "${9}" == "ps" ]
  then
    TEMP_VAR_A=$( "${1}" pid )
    if [[ ! -z "${TEMP_VAR_A}" ]]
    then
      while read -r TEMP_VAR_PID
      do
        ps -up "${TEMP_VAR_PID}"
      done <<< "${TEMP_VAR_A}"
    fi

  elif [ "${9}" == "ps-short" ]
  then
    TEMP_VAR_A=$( "${1}" pid )
    if [[ ! -z "${TEMP_VAR_A}" ]]
    then
      while read -r TEMP_VAR_PID
      do
        ps -p "${TEMP_VAR_PID}" o user,pid,etime,cputime,%cpu,comm
      done <<< "${TEMP_VAR_A}"
    fi

  elif [ "${9}" == "daemon" ]
  then
    echo "${4}"

  elif [ "${9}" == "full_daemon" ] || [ "${9}" == "daemon_full" ]
  then
    echo "${USER_HOME_DIR}/.local/bin/${4}"

  elif [ "${9}" == "cli" ]
  then
    echo "${2}"

  elif [ "${9}" == "full_cli" ] || [ "${9}" == "cli_full" ]
  then
    echo "${USER_HOME_DIR}/.local/bin/${2}"

  elif [ "${9}" == "start" ]
  then
    TEMP_VAR_A=$( "${1}" checksystemd | awk '{print $3}' )
    TEMP_VAR_PID=$( "${1}" pid )

    if [[ -z "${TEMP_VAR_PID}" ]]
    then
      if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
      then
        ( sudo systemctl start "${1}" ) &
      elif [[ "$( whoami )" == "${1}" ]]
      then
        if [[ "${TEMP_VAR_A}" != "auto-restart" ]]
        then
          ( "${USER_HOME_DIR}/.local/bin/${4}" "-datadir=${DIR}/" --daemon ) &
        else
          echo "Waiting for systemd to auto-restart service"
        fi
      else
        ( sudo systemctl start "${1}" ) &
      fi
    else
      echo "Already running"
      "${1}" ps
    fi

    sleep 3
    TEMP_VAR_PID=$( "${1}" pid )
    while [[ -z "${TEMP_VAR_PID}" ]]
    do
      TEMP_VAR_PID=$( "${1}" pid )
      echo -e "\r${SP:i++%${#SP}:1} Waiting for ${1} to start (PID) \c"
      sleep 0.3
      if [[ $( "${1}" failure_after_start | wc -l ) -gt 0 ]]
      then
        break;
      fi
    done
    while [[ ! -z "${TEMP_VAR_PID}" ]] && [[ $( lslocks | grep -F "${4}" | grep -cF "${TEMP_VAR_PID}" ) -lt 1 ]]
    do
      TEMP_VAR_PID=$( "${1}" pid )
      echo -e "\r${SP:i++%${#SP}:1} Waiting for ${1} to start (LOCK) \c"
      sleep 0.3
      if [[ $( "${1}" failure_after_start | wc -l ) -gt 0 ]]
      then
        break;
      fi
    done
    echo

    "${1}" status

  elif [ "${9}" == "failure_after_start" ]
  then
    LAST_FAILURE=$( "${1}" system_log | grep -Fin ": error: couldn't connect to server" | tail -n 1 | cut -d: -f1 )
    LAST_START=$( "${1}" system_log | grep -Fin " Starting" | tail -n 1 | cut -d: -f1 )
    if [[ "${LAST_FAILURE}" -gt "${LAST_START}" ]]
    then
      echo "Failure happened after last start attempt."
    fi

  elif [ "${9}" == "forcestart" ]
  then
    if [[ "$( whoami )" == "${1}" ]]
    then
      "${USER_HOME_DIR}/.local/bin/${4}" "-datadir=${DIR}/" --forcestart --daemon
    else
      sudo su - "${1}" -c " ${4} --forcestart --daemon "
    fi

  elif [ "${9}" == "start-nosystemd" ]
  then
    if [[ "$( whoami )" == "${1}" ]]
    then
      "${USER_HOME_DIR}/.local/bin/${4}" "-datadir=${DIR}/" --daemon
    else
      sudo su - "${1}" -c " ${4} --daemon "
    fi

  elif [ "${9}" == "restart" ]
  then
    if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
    then
      sudo systemctl restart "${1}"
    else
      "${1}" stop
      sleep 1
      "${1}" start
    fi
    sleep 1
    "${1}" status

  elif [ "${9}" == "stop" ]
  then
    TEMP_VAR_PID=$( "${1}" pid )
    if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
    then
      sudo systemctl stop "${1}"  >/dev/null 2>&1
    fi
    "${USER_HOME_DIR}/.local/bin/${2}" "-datadir=${DIR}/" stop >/dev/null 2>&1
    if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
    then
      sudo su - "${1}" -c " ${2} stop " >/dev/null 2>&1
    fi

    if [[ ! -z "${TEMP_VAR_PID}" ]]
    then
      while read -r PID_TO_KILL
      do
        kill "${PID_TO_KILL}" >/dev/null 2>&1
        if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
        then
          sudo kill "${PID_TO_KILL}" >/dev/null 2>&1
        fi
        sleep 0.3
      done <<< "${TEMP_VAR_PID}"
    fi
    while [[ $( lslocks  | grep -c "${DIR}" ) -ne 0 ]] || [[ ! -z $( "${1}" pid ) ]]
    do
      echo -e "\r${SP:i++%${#SP}:1} Waiting for ${1} to shutdown \c"
      sleep 0.3
    done
    echo
    "${1}" status

  elif [ "${9}" == "status" ]
  then
    systemctl status --no-pager --full "${1}"

  elif [ "${9}" == "checksystemd" ] || [ "${9}" == "systemdcheck" ]
  then
    TEMP_VAR_A=$( systemctl list-unit-files | sed -e 's/^[[:space:]]*//' | grep -E "^${1}\." | awk '{print $2}' )
    TEMP_VAR_B=$( systemctl | sed -e 's/^[[:space:]]*//' | grep -E "^${1}\." | awk '{print  $3 " " $4}' )
    echo "${TEMP_VAR_A} ${TEMP_VAR_B}"

  elif [ "${9}" == "update_daemon" ] || [ "${9}" == "daemon_update" ]
  then
    if [[ -z "${BIN_BASE}" ]] || [[ $( "${1}" daemon | grep -c "${BIN_BASE}" ) -eq 0 ]]
    then
      BIN_BASE=$( grep -m 1 'bin_base=' "${5}" | cut -d '=' -f2 )
      DAEMON_DOWNLOAD=$( grep -m 1 'daemon_download=' "${5}" | cut -d '=' -f2 )
    fi
    if [[ -z "${GITHUB_REPO}" ]]
    then
      GITHUB_REPO=$( grep -m 1 'github_repo=' "${5}" | cut -d '=' -f2 )
    fi
    DIRECTORY="${DIR}"
    CONF=$( basename "${5}" )
    DEFAULT_PORT=$( grep -m 1 'defaultport=' "${5}" | cut -d '=' -f2 )
    if [ -z "${DEFAULT_PORT}" ]
    then
      DEFAULT_PORT=$( grep -m 1 'externalip=' "${5}" | cut -d '=' -f2 | cut -d ':' -f2 )
    fi
    COLLATERAL=1
    DAEMON_NAME=${GITHUB_REPO}
    TICKER='FAKE_COIN'
    BLOCKTIME=1
    PROJECT_DIR=$( basename "${GITHUB_REPO}" )
    CONTROLLER_BIN=${2}
    DAEMON_BIN=${4}

    # Use subshell to isolate the masternode setup script.
    (
    IS_EMPTY=$( type DAEMON_DOWNLOAD_SUPER 2>/dev/null )
    if [ -z "${IS_EMPTY}" ]
    then
      COUNTER=0
      rm -f /tmp/___mn.sh
      while [[ ! -f /tmp/___mn.sh ]] || [[ $( grep -Fxc "# End of masternode setup script." /tmp/___mn.sh ) -eq 0 ]]
      do
        rm -f /tmp/___mn.sh
        wget -4qo- goo.gl/uQw9tz -O /tmp/___mn.sh
        COUNTER=$((COUNTER+1))
        if [[ "${COUNTER}" -gt 3 ]]
        then
          echo
          echo "Download failed."
          echo
          return 1 2>/dev/null
        fi
      done

      (
        sleep 2
        rm /tmp/___mn.sh
      ) & disown

      # shellcheck disable=SC1091
      . /tmp/___mn.sh
    fi

    sleep 1
    DAEMON_DOWNLOAD_SUPER "${GITHUB_REPO}" "${BIN_BASE}" "${DAEMON_DOWNLOAD}" "${10}"
    )
    VERSION_REMOTE=$( /var/multi-masternode-data/"${PROJECT_DIR}"/src/"${CONTROLLER_BIN}" -version 2>/dev/null | sed 's/[^0-9.]*\([0-9.]*\).*/\1/' )
    VERSION_LOCAL=$( "${1}" -version 2>/dev/null | sed 's/[^0-9.]*\([0-9.]*\).*/\1/' )
    if [[ $( echo "${VERSION_LOCAL}" | grep -c "${VERSION_REMOTE}" ) -eq 1 ]]
    then
      echo
      echo "Already the latest version (${VERSION_LOCAL}) according to "
      echo "https://github.com/${GITHUB_REPO}/releases/latest"
      "${1}" -version
      echo
      return 1 2>/dev/null
    fi
    echo
    echo "Updating ${VERSION_LOCAL} to the lasest version ${VERSION_REMOTE}"
    echo
    TEMP_VAR_PID=$( "${1}" pid )
    if [[ ! -z "${TEMP_VAR_PID}" ]]
    then
      "${1}" stop
    fi
    if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
    then
      sudo mkdir -p "${USER_HOME_DIR}"/.local/bin
      sudo cp /var/multi-masternode-data/"${PROJECT_DIR}"/src/"${DAEMON_BIN}" "${USER_HOME_DIR}"/.local/bin/
      sudo chmod +x "${USER_HOME_DIR}"/.local/bin/"${DAEMON_BIN}"
      sudo cp /var/multi-masternode-data/"${PROJECT_DIR}"/src/"${CONTROLLER_BIN}" "${USER_HOME_DIR}"/.local/bin/
      sudo chmod +x "${USER_HOME_DIR}"/.local/bin/"${CONTROLLER_BIN}"
      sudo chown -R "${1}":"${1}" "${USER_HOME_DIR}/.local/bin/"
    else
      mkdir -p "${USER_HOME_DIR}"/.local/bin
      cp /var/multi-masternode-data/"${PROJECT_DIR}"/src/"${DAEMON_BIN}" "${USER_HOME_DIR}"/.local/bin/
      chmod +x "${USER_HOME_DIR}"/.local/bin/"${DAEMON_BIN}"
      cp /var/multi-masternode-data/"${PROJECT_DIR}"/src/"${CONTROLLER_BIN}" "${USER_HOME_DIR}"/.local/bin/
      chmod +x "${USER_HOME_DIR}"/.local/bin/"${CONTROLLER_BIN}"
      chown -R "${1}":"${1}" "${USER_HOME_DIR}/.local/bin/"
    fi
    if [[ ! -z "${TEMP_VAR_PID}" ]]
    then
      "${1}" start
    fi
    echo
    "${1}" -version
    echo

  elif [ "${9}" == "remove_daemon" ] || [ "${9}" == "daemon_remove" ]
  then
    sudo true
    echo "User ${1} wil be deleted when this timer reaches 0"
    seconds=8
    date1=$(( $(date +%s) + seconds));
    echo "Press ctrl-c to stop"
    while [ "${date1}" -ge "$(date +%s)" ]
    do
      echo -ne "$(date -u --date @$(( date1 - $(date +%s) )) +%H:%M:%S)\r";
    done
    TEMP_VAR_PID=$( "${1}" pid )
    sudo su - "${1}" -c 'crontab -r'
    sudo systemctl disable "${1}" -f --now
    sudo rm -f /etc/systemd/system/"${1}".service
    if [[ ! -z "${TEMP_VAR_PID}" ]]
    then
      sudo kill -9 "${TEMP_VAR_PID}"
    fi
    sudo userdel -rfRZ "${1}" 2>/dev/null
    sudo systemctl daemon-reload

  elif [ "${9}" == "reindex" ]
  then
    echo "Stopping ${1}"
    "${1}" stop >/dev/null 2>&1
    sleep 5
    echo "Remove local blockchain database"
    FILENAME=$( basename "${5}" )
    if [ "${10}" == "remove_peers" ] || [ "${10}" == "peers_remove" ] || [ "${11}" == "remove_peers" ] || [ "${11}" == "peers_remove" ]
    then
      find "${DIR}" -maxdepth 1 | tail -n +2 | grep -vE "backups|wallet.dat|${FILENAME}" | xargs rm -r
    else
      find "${DIR}" -maxdepth 1 | tail -n +2 | grep -vE "backups|wallet.dat|${FILENAME}|peers.dat" | xargs rm -r
    fi
    if ([ "${10}" == "remove_addnode" ] || [ "${10}" == "addnode_remove" ] || [ "${11}" == "remove_addnode" ] || [ "${11}" == "addnode_remove" ]) && [ -f "${5}" ]
    then
      echo "${5}"
      "${1}" addnode_remove
    fi

    echo "Rebuild local blockchain database"
    if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
    then
      sudo su - "${1}" -c " ${4} --reindex --forcestart --daemon "
    else
      "${USER_HOME_DIR}/.local/bin/${4}" "-datadir=${DIR}/" --reindex --forcestart --daemon
    fi

    sleep 5
    "${1}" sync

    echo
    echo "Stopping ${1}"
    "${1}" stop >/dev/null 2>&1
    sleep 5
    "${1}" start

  elif [ "${9}" == "log_system" ] || [ "${9}" == "system_log" ]
  then
    journalctl -q -u "${1}"

  elif [ "${9}" == "log_daemon" ] || [ "${9}" == "daemon_log" ]
  then
    if [ "${10}" == "location" ] || [ "${10}" == "loc" ]
    then
      if [ -f "${DIR}/debug.log" ]
      then
        echo "${DIR}/debug.log"
      else
        sudo find "${DIR}" -maxdepth 1 -name \*.log -not -empty
      fi
    elif [ -f "${DIR}/debug.log" ]
    then
      if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
      then
        sudo cat "${DIR}/debug.log"
      else
        cat "${DIR}/debug.log"
      fi
    else
      if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
      then
        sudo find "${DIR}" -maxdepth 1 -name \*.log -not -empty -exec cat {} \;
      else
        find "${DIR}" -maxdepth 1 -name \*.log -not -empty -exec cat {} \;
      fi
    fi

  elif [ "${9}" == "remove_peers" ] || [ "${9}" == "peers_remove" ]
  then
    if [ -f "${DIR}/peers.dat" ]
    then
      TEMP_VAR_PID=$( "${1}" pid )
      if [[ ! -z "${TEMP_VAR_PID}" ]]
      then
        "${1}" stop
      fi
      rm -f "${DIR}/peers.dat"
      if [[ ! -z "${TEMP_VAR_PID}" ]]
      then
        sleep 5
        "${1}" start
      fi
    fi

  elif ([ "${9}" == "remove_addnode" ] || [ "${9}" == "addnode_remove" ]) && [ -f "${5}" ]
  then
    TEMP_VAR_PID=$( "${1}" pid )
    if [[ ! -z "${TEMP_VAR_PID}" ]]
    then
      "${1}" stop
    fi

    if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
    then
      sudo sed -i '/addnode\=/d' "${5}"
    else
      sed -i '/addnode\=/d' "${5}"
    fi

    if [[ ! -z "${TEMP_VAR_PID}" ]]
    then
      sleep 5
      "${1}" start
    fi

  elif [ "${9}" == "addnode_to_connect" ] && [ -f "${5}" ]
  then
    TEMP_VAR_PID=$( "${1}" pid )
    if [[ ! -z "${TEMP_VAR_PID}" ]]
    then
      "${1}" stop
    fi

    if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
    then
      sudo sed -i -e 's/addnode\=/connect\=/g' "${5}"
    else
      sed -i -e 's/addnode\=/connect\=/g' "${5}"
    fi

    if [[ ! -z "${TEMP_VAR_PID}" ]]
    then
      sleep 5
      "${1}" start
    fi

  elif [ "${9}" == "connect_to_addnode" ] && [ -f "${5}" ]
  then
    TEMP_VAR_PID=$( "${1}" pid )
    if [[ ! -z "${TEMP_VAR_PID}" ]]
    then
      "${1}" stop
    fi

    if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
    then
      sudo sed -i -e 's/connect\=/addnode\=/g' "${5}"
    else
      sed -i -e 's/connect\=/addnode\=/g' "${5}"
    fi

    if [[ ! -z "${TEMP_VAR_PID}" ]]
    then
      sleep 5
      "${1}" start
    fi

  elif [ "${9}" == "conf" ] && [ -f "${5}" ]
  then
    if [ "${10}" == "location" ] || [ "${10}" == "loc" ]
    then
      echo "${5}"
    else
      sudo cat "${5}"
    fi

  elif [ "${9}" == "masternode.conf" ] || [ "${9}" == "${_MASTERNODE_CALLER}.conf" ]
  then
    if  [ -f "${5}" ]
    then
      PART_A=$( hostname )
      PART_B1=$( grep -m 1 'externalip=' "${5}" | cut -d '=' -f2 )
      PART_B2=$( grep -m 1 'defaultport=' "${5}" | cut -d '=' -f2 )
      PART_C=$( grep -m 1 "${_MASTERNODE_CALLER}privkey=" "${5}" | cut -d '=' -f2 )
      PART_D=$( grep -m 1 'txhash=' "${5}" | cut -d '=' -f2 )
      PART_E=$( grep -m 1 'outputidx=' "${5}" | cut -d '=' -f2 )
      if [ ! -z "${PART_B2}" ]
      then
        PART_B1=$(echo "${PART_B1}" | cut -d ':' -f1)
        PART_B1="${PART_B1}:${PART_B2}"
      fi
      echo
      echo "${1}_${PART_A} ${PART_B1} ${PART_C} ${PART_D} ${PART_E} "
      echo
    fi

  elif [ "${9}" == "privkey" ] && [ -f "${5}" ]
  then
    TEMP_VAR_A="${10}"
    if [[ "${10}" == "genkey" ]] || [[ "${10}" == "keygen" ]]
    then

      TEMP_VAR_PID=$( "${1}" pid )
      if [[ -z "${TEMP_VAR_PID}" ]]
      then
        echo "Starting ${1}"
        "${1}" start
      fi

      TEMP_VAR_A=$( "${1}" "${_MASTERNODE_CALLER}" genkey )
    fi

    if [ -z "${10}" ]
    then
      grep -m 1 "${_MASTERNODE_CALLER}privkey=" "${5}" | cut -d '=' -f2

    elif [[ "${10}" == "remove" ]]
    then
      if [[ $( grep -cF "${_MASTERNODE_CALLER}=" "${5}" ) -ge 1 ]] || [[ $( grep -cF "/${_MASTERNODE_CALLER}privkey=" "${5}" ) -ge 1 ]]
      then
        TEMP_VAR_PIDD=$( "${1}" pid )
        if [[ ! -z "${TEMP_VAR_PIDD}" ]]
        then
          echo "Stopping ${1}"
          "${1}" stop
        fi
        echo "Removing ${_MASTERNODE_CALLER} configuration for ${1}"

        if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
        then
          sudo sed -i "/${_MASTERNODE_CALLER}privkey\=/d" "${5}"
          sudo sed -i "/${_MASTERNODE_CALLER}\=/d" "${5}"
        else
          sed -i "/${_MASTERNODE_CALLER}privkey\=/d" "${5}"
          sed -i "/${_MASTERNODE_CALLER}\=/d" "${5}"
        fi

        if [[ ! -z "${TEMP_VAR_PIDD}" ]]
        then
          echo "Starting ${1}"
          sleep 5
          "${1}" start
        fi
      fi

    elif [[ "${#TEMP_VAR_A}" -ne 51 ]] && [[ "${#TEMP_VAR_A}" -ne 50 ]]
    then
      echo
      echo "New ${_MASTERNODE_CALLER}privkey is not 50/51 char long and thus invalid."
      echo "${TEMP_VAR_A}"
      echo
      return 1 2>/dev/null

    else
      TEMP_VAR_PID=$( "${1}" pid )
      if [[ ! -z "${TEMP_VAR_PID}" ]]
      then
        echo "Stopping ${1}"
        "${1}" stop
        sleep 0.5
      fi

      "${1}" privkey remove
      echo "Reconfiguring ${1}"
      echo "${_MASTERNODE_CALLER}=1" | sudo tee -a "${5}" >/dev/null
      echo "${_MASTERNODE_CALLER}privkey=${TEMP_VAR_A}" | sudo tee -a "${5}" >/dev/null

      if [[ ! -z "${TEMP_VAR_PID}" ]]
      then
        echo "Starting ${1}"
        sleep 3
        "${1}" start
      fi
    fi

  elif [ "${9}" == "masternodeping" ] || [ "${9}" == "${_MASTERNODE_CALLER}ping" ] || [ "${9}" == "${_MASTERNODE_PREFIX}ping" ] || [ "${9}" == "mnping" ]
  then
    DATE_STRING=$( "${1}" daemon_log | grep -i "${_MASTERNODE_CALLER}ping" | tail -n 1 | awk '{print $1 " " $2}' )
    UNIX_TIME_LAST=$( date --date="${DATE_STRING}" +%s )
    if [[ ! -z "${UNIX_TIME_LAST}" ]]
    then
      UNIX_TIME=$( date +%s )
      TIME_DIFF=$(( UNIX_TIME - UNIX_TIME_LAST ))
      echo "${TIME_DIFF}"
    fi

  elif [ "${9}" == "daemon_in_good_state" ]
  then
    if [[ $( "${1}" system_log | grep -Fi ": error: couldn't connect to server" | tail -n 5 | wc -l ) -lt 5 ]]
    then
      return
    fi
    # Get the failure from 5 times ago
    DATE_STRING=$( "${1}" system_log | grep -Fi ": error: couldn't connect to server" | tail -n 5 | head -n 1 | awk '{ print $1 " " $2 " " $3 }' )
    UNIX_TIME_PAST_FAILURE=$( date --date="${DATE_STRING}" +%s 2>/dev/null )
    # Get the last entry in the system log.
    DATE_STRING=$( "${1}" system_log | tail -n 1 | awk '{ print $1 " " $2 " " $3 }' )
    UNIX_TIME_CURRENT_EVENT=$( date --date="${DATE_STRING}" +%s 2>/dev/null )
    UNIX_TIME=$( date +%s )
    if [[ ! -z "${UNIX_TIME_PAST_FAILURE}" ]] && [[ ! -z "${UNIX_TIME_CURRENT_EVENT}" ]]
    then
      TIME_DIFF_LAST_ENTRY=$(( UNIX_TIME - UNIX_TIME_CURRENT_EVENT ))
      TIME_DIFF_LAST_FAILURE=$(( UNIX_TIME_CURRENT_EVENT - UNIX_TIME_PAST_FAILURE ))
      if [[ "${TIME_DIFF_LAST_FAILURE}" -lt 2000 ]] && [[ "${TIME_DIFF_LAST_ENTRY}" -lt 300 ]]
      then
        if [[ $( "${1}" system_log | tail -n 15 | grep -Fic ": Error: Unable to bind to " ) -gt 0 ]] || [[ $( "${1}" daemon | tail -n 50 | grep -Fic "Error: Failed to listen on any port" ) -gt 0 ]]
        then
          echo "ERROR: Daemon can not be started by systemd (Port/IP issue)."
        else
          echo "ERROR: Daemon can not be started by systemd."
        fi
      fi
    fi

  elif [ "${9}" == "grep_daemon_log" ]
  then
    "${1}" daemon_log | grep -Fi "${10}"

  elif [ "${9}" == "grep_system_log" ]
  then
    "${1}" daemon_log | grep -Fi "${10}"

  elif [ "${9}" == "lastblock" ]
  then
    LAST_BLOCK_A=$( "${1}" daemon_log | grep -Fi "UpdateTip: new best=" | tail -n 1 | grep -o -E -i '\sheight\=[0-9]*\s' | grep -o -E "[0-9]*" )
    LAST_BLOCK_C=$( "${1}" daemon_log | grep -o -E -i "Valid at block [0-9]*" | tail -n 1 | grep -o -E "[0-9]*" )
    echo "${LAST_BLOCK_A} ${LAST_BLOCK_C}" | jq -s max

  elif [ "${9}" == "lastblock_time" ]
  then
    DATE_STRING=$( "${1}" daemon_log | grep -Fi "UpdateTip: new best=" | tail -n 1 | awk '{print $1 " " $2}' )
    UNIX_TIME_LAST_BLOCK_A=$( date --date="${DATE_STRING}" +%s )
    DATE_STRING=$( "${1}" daemon_log | grep -Fi "ProcessNewBlock" | tail -n 1 | awk '{print $1 " " $2}' )
    UNIX_TIME_LAST_BLOCK_B=$( date --date="${DATE_STRING}" +%s )
    DATE_STRING=$( "${1}" daemon_log | grep -Fi "Valid at block " | tail -n 1 | awk '{print $1 " " $2}' )
    UNIX_TIME_LAST_BLOCK_C=$( date --date="${DATE_STRING}" +%s )
    UNIX_TIME_LAST_BLOCK=$( echo "${UNIX_TIME_LAST_BLOCK_A} ${UNIX_TIME_LAST_BLOCK_B} ${UNIX_TIME_LAST_BLOCK_C}" | jq -s max )

    DATE_STRING=$( "${1}" daemon_log | tail -n 1 | awk '{print $1 " " $2}' )
    UNIX_TIME_LAST_ENTRY=$( date --date="${DATE_STRING}" +%s )
    TIME_DIFF=0
    if [[ ! -z "${UNIX_TIME_LAST_BLOCK}" ]] && [[ ! -z "${UNIX_TIME_LAST_ENTRY}" ]]
    then
      TIME_DIFF=$(( UNIX_TIME_LAST_ENTRY - UNIX_TIME_LAST_BLOCK ))
    fi
    echo "${TIME_DIFF}"

  elif [ "${9}" == "mnfix" ] || [ "${9}" == "${_MASTERNODE_PREFIX}fix" ]
  then
    if [[ -z $( "${1}" pid ) ]]
    then
      echo "Starting ${1} as it is not running."
      "${1}" start
      sleep 10
    fi

    MN_UPTIME=$( "${1}" uptime | tr -d '[:space:]' )
    MN_STATUS=$( "${1}" "${_MASTERNODE_CALLER}" status )
    MN_SYSTEMD=$( "${1}" checksystemd )
    if [[ "${MN_UPTIME}" -gt 1000 ]] && [[ $( echo "${MN_STATUS}" | grep -ic 'successfully' ) -ge 1 ]]
    then
      if [[ $( "${1}" getconnectioncount ) -lt 4 ]]
      then
        echo "Getting addnodes for ${1}"
        "${1}" dl_addnode
      fi

      if [[ $( echo "${MN_SYSTEMD}" | grep -c 'enabled active running' ) -lt 1 ]]
      then
        if [[ $( echo "${MN_SYSTEMD}" | grep -c 'enabled' ) -lt 1 ]]
        then
          echo "Enable ${1} systemd service on reboot."
          sudo systemctl enable "${USRNAME}" 2>&1
        fi
        if [[ $( echo "${MN_SYSTEMD}" | grep -c 'running' ) -lt 1 ]]
        then
          echo "Restarting ${1} for systemd."
          "${1}" stop
          "${1}" start
        fi
        "${1}" checksystemd
      fi

      if [[ $( "${1}" "${_MASTERNODE_CALLER}ping" ) -gt 1500 ]]
      then
        echo "Restarting ${1} because mn hasn't pinged the network in over 1500 seconds."
        "${1}" restart
        "${1}" "${_MASTERNODE_CALLER}ping"
      fi
    fi

    if [[ $( echo "${MN_SYSTEMD}" | grep -c 'enabled active running' ) -lt 1 ]] && [[ $( "${1}" daemon_in_good_state | grep -Fc "ERROR: Daemon can not be started by systemd." ) -gt 0 ]]
    then
      echo "Systemd can not start ${1}"
      "${1}" stop

      DROPBOX_BLOCKS_N_CHAINS=$( grep -m 1 'blocks_n_chains=' "${5}" | cut -d '=' -f2 )
      DROPBOX_BOOTSTRAP=$( grep -m 1 'bootstrap=' "${5}" | cut -d '=' -f2 )
      if [[ ! -z "${DROPBOX_BLOCKS_N_CHAINS}" ]]
      then
        "${1}" dl_blocks_n_chains
      elif [ ! -z "${DROPBOX_BOOTSTRAP}" ]
      then
        "${1}" dl_bootstrap_reindex
      else
        "${1}" reindex
      fi

      "${1}" start
      "${1}" sync
    fi

  elif [ "${9}" == "mncheck" ] || [ "${9}" == "${_MASTERNODE_PREFIX}check" ]
  then
    if [[ -z $( "${1}" pid ) ]]
    then
      echo "ERROR: ${_MASTERNODE_CALLER} ${1} is not running"
    fi

    MN_UPTIME=$( "${1}" uptime | tr -d '[:space:]' )
    if [[ "${MN_UPTIME}" -gt 2 ]] && [[ "${MN_UPTIME}" -lt 1000 ]]
    then
      echo "INFO: ${_MASTERNODE_CALLER} ${1} has just been started."
    fi

    if [[ $( "${1}" conf | grep -c "${_MASTERNODE_CALLER}=1" ) -lt 1 ]]
    then
      echo "ERROR: ${_MASTERNODE_CALLER} ${1} is not conifgured to be a ${_MASTERNODE_CALLER} (missing ${_MASTERNODE_CALLER}=1)."
    fi

    if [[ $( "${1}" conf | grep -c "${_MASTERNODE_CALLER}privkey=" ) -lt 1 ]]
    then
      echo "ERROR: ${_MASTERNODE_CALLER} ${1} is not conifgured to be a ${_MASTERNODE_CALLER} (missing ${_MASTERNODE_CALLER}privkey=)."
    fi

    MN_STATUS=$( "${1}" "${_MASTERNODE_CALLER}" status )
    if [[ $( echo "${MN_STATUS}" | grep -ic 'successfully' ) -lt 1 ]]
    then
      echo "ERROR: ${_MASTERNODE_CALLER} ${1} has not started (${_MASTERNODE_CALLER} status failed) ${MN_STATUS}."
    fi

    MN_PING_TIME=$( "${1}" "${_MASTERNODE_CALLER}ping" )
    if [[ "${MN_PING_TIME}" -gt 1500 ]]
    then
      echo "ERROR: ${_MASTERNODE_CALLER} ${1} has not pinged the network in over ${MN_PING_TIME} seconds (debug.log does not have a recent ping)."
    fi

    MN_CONNECTION_COUNT=$( "${1}" getconnectioncount )
    if [[ ! "${MN_CONNECTION_COUNT}" =~ ${RE} ]] || [[ "${MN_CONNECTION_COUNT}" -lt 4 ]]
    then
      echo "WARNING: ${_MASTERNODE_CALLER} ${1} connection count is low: ${MN_CONNECTION_COUNT}."
    fi

    MN_SYSTEMD=$( "${1}" checksystemd )
    if [[ $( echo "${MN_SYSTEMD}" | grep -c 'enabled active running' ) -lt 1 ]]
    then
      echo "WARNING: ${_MASTERNODE_CALLER} ${1} systemd is not in a good state (${MN_SYSTEMD})."
    fi

    if [[ $( "${1}" blockcheck 2>/dev/null | wc -l ) -gt 1 ]]
    then
      LOCAL_BLK=$( "${1}" getblockcount )
      PEER_BLK=$( "${1}" getpeerblockcount )
      WEB_BLK=$( "${1}" explorer_blockcount )
      echo "WARNING: ${_MASTERNODE_CALLER} ${1} blockcount is not correct (Local Count:${LOCAL_BLK}, Network Count:${PEER_BLK}, Explorer Count:${WEB_BLK})."
    fi

    LASTBLOCK=$( "${1}" lastblock_time )
    if [[ "${LASTBLOCK}" -gt 1000 ]]
    then
      echo "ERROR: A new block has not been processed in over ${LASTBLOCK} seconds."
    fi

    "${1}" daemon_in_good_state

    "${1}" failure_after_start

    if [[ $( "${1}" "${_MASTERNODE_PREFIX}info" | grep -ci 'enabled' ) -lt 1 ]]
    then
      echo "ERROR: ${_MASTERNODE_CALLER} ${1} is not registered on the network (missing from masternode list)."
    fi

    MN_SYNC=$( "${1}" "${_MASTERNODE_PREFIX}sync status" )
    if [[ $( echo "${MN_SYNC}" | grep -cE ':\s999|"IsBlockchainSynced": true' ) -lt 2 ]]
    then
      echo "WARNING: ${_MASTERNODE_CALLER} ${1} mnsync not done (${MN_SYNC})."
    fi

    MN_WINNER=$( "${1}" "${_MASTERNODE_PREFIX}win" )
    if [[ ! -z "${MN_WINNER}" ]]
    then
      while read -r LINE
      do
        ADDRESS=$( echo "${LINE}" | awk '{print $1}' )
        BLOCK=$( echo "${LINE}" | awk '{print $2}' )
        echo "SUCCESS: ${_MASTERNODE_CALLER} ${1} will send a reward to ${ADDRESS} on block ${BLOCK}."
      done <<< "$( echo "${MN_WINNER}" | sed '/^\s*$/d' )"
    fi

  elif [ "${9}" == "rename" ]
  then
    if [ -z "${10}" ]
    then
      (>&2 echo "Please supply the new name after the command.")
      return 1 2>/dev/null
    fi
    if id "${10}" >/dev/null 2>&1
    then
      (>&2 echo "Username ${10} already exists.")
      return 1 2>/dev/null
    fi

    echo "${1} will be transformed into ${10}"
    sleep 3
    sudo systemctl disable "${1}" -f --now
    "${1}" stop
    sudo sed -i "s/${1}/${10}/g" /etc/systemd/system/"${1}".service
    sudo sed -i "s/${1}$/${10}/g" "${5}"
    if [ -f "${USER_HOME_DIR}/sentinel/sentinel.conf" ]
    then
      sudo sed -i "s/${1}\\//${10}\\//g" "${USER_HOME_DIR}/sentinel/sentinel.conf"
    fi

    sudo mv /etc/systemd/system/"${1}".service /etc/systemd/system/"${10}".service
    sudo usermod --login "${10}" --move-home --home /home/"${10}" "${1}"
    sudo groupmod -n "${10}" "${1}"
    sed -i "s/${1}\\//${10}\\//g" "${HOME:?}"/.bashrc
    sed -i "s/\"${1}\"/\"${10}\"/g" "${HOME:?}"/.bashrc
    sed -i "s/'${1}'/'${10}'/g" "${HOME:?}"/.bashrc
    sed -i "s/${1} ()/${10} ()/g" "${HOME:?}"/.bashrc
    sed -i "s/${1}\\./${10}\\./g" "${HOME:?}"/.bashrc
    sed -i "s/${1}$/${10}/g" "${HOME:?}"/.bashrc

    if [ -f "/var/spool/cron/crontabs/${1}" ]
    then
      sudo sed -i "s/${1}\\//${10}\\//g" "/var/spool/cron/crontabs/${1}"
      sudo mv "/var/spool/cron/crontabs/${1}" "/var/spool/cron/crontabs/${10}"
    fi

    # shellcheck disable=SC1091
    source /var/multi-masternode-data/.bashrc
    sudo systemctl daemon-reload 2>/dev/null
    sleep 1
    sudo systemctl enable "${10}"

    sleep 3
    "${10}" start
    echo

  elif [ "${9}" == "explorer" ]
  then
    echo "${3}"

  elif [ "${9}" == "explorer_blockcount" ] || [ "${9}" == "blockcount_explorer" ]
  then
    if [[ ! -z "${3}" ]]
    then
      if [[ "${3}" == https://www.coinexplorer.net/api/v1/* ]]
      then
        WEBBC=$( wget -4qO- -T 15 -t 2 -o- "${3}block/latest" "${BAD_SSL_HACK}" | jq -r '.result.height' | tr -d '[:space:]' 2>/dev/null )
      else
        WEBBC=$( wget -4qO- -T 15 -t 2 -o- "${3}api/getblockcount" "${TEMP_VAR_C}" )
      fi
      sleep 1
      if [[ $( echo "${WEBBC}" | tr -d '[:space:]') =~ $RE ]]
      then
        echo "${WEBBC}" | tr -d '[:space:]'
      else
        echo "${WEBBC}"
      fi
    fi

  elif [ "${9}" == "chaincheck" ] || [ "${9}" == "checkchain" ]
  then
    if [[ -z "${3}" ]] || [[ "${3}" == https://www.coinexplorer.net/api/v1/* ]]
    then
      return
    fi
    WEBBCI=$( wget -4qO- -T 15 -t 2 -o- "${3}api/getblockchaininfo" "${TEMP_VAR_C}" | jq . |  grep -v "verificationprogress" )
    sleep 1

    BCI=$( "${1}" "getblockchaininfo" 2>&1 | grep -v "verificationprogress" )
    BCI_DIFF=$( diff <( echo "${BCI}" | jq . ) <( echo "${WEBBCI}" | jq . ) )
    if [[ $( echo "${BCI_DIFF}" | tr -d '[:space:]' | wc -c ) -eq 0 ]]
    then
      echo "On the same chain as the explorer"
    else
      echo "Chains do not match"
      echo "${BCI_DIFF}"
      echo "Local blockchain info"
      echo "${BCI}" | jq .
      echo "Remote blockchain info"
      echo "${WEBBCI}" | jq .
    fi

  elif [ "${9}" == "blockcheck" ] || [ "${9}" == "checkblock" ]
  then
    if [[ ! -z "${3}" ]]
    then
      if [[ ! -z "${10}" ]] && [[ ${10} =~ $RE ]]
      then
        WEBBC=${10}
      else
        WEBBC=$( "${1}" explorer_blockcount )
      fi
    else
      WEBBC=$( "${1}" getpeerblockcount )
    fi
    BC=$( "${1}" "getblockcount" 2>&1 )
    if ! [[ $WEBBC =~ $RE ]]
    then
      WEBBC=$( "${1}" getpeerblockcount )
    fi

    if [[ "${WEBBC}" -ne "${BC}" ]]
    then
      WEBBC=$( "${1}" explorer_blockcount )
      if ! [[ $WEBBC =~ $RE ]]
      then
        WEBBC=$( "${1}" getpeerblockcount )
      fi
      BC=$( "${1}" getblockcount 2>&1 )
      if [[ "${WEBBC}" -ne "${BC}" ]]
      then
        echo "Block counts do not match"
        echo "Local blockcount"
        echo "${BC}"
        echo "Remote blockcount"
        echo "${WEBBC}"
        echo
        echo "If the explorer count is correct and problem persists try"
        echo "${1} remove_peers"
        echo "And after 15 minutes if that does not fix it try"
        echo "${1} reindex"
        echo
      fi
    fi

    if [[ $WEBBC =~ $RE ]] && [[ "${WEBBC}" -eq "${BC}" ]]
    then
      echo "Block count looks good: ${BC}"
    fi

  elif [ "${9}" == "getpeerblockcount" ]
  then
    PEER_INFO=$( "${1}" getpeerinfo 2>/dev/null )
    _BLOCK_COUNT=$( echo "${PEER_INFO}" | jq '.[] | select( .banscore < 21 and .synced_headers > 0 ) | .synced_headers ' 2>/dev/null | sort -hr | uniq | head -1 | tr -d '[:space:]'  )
    if [[ -z "${_BLOCK_COUNT}" ]] || [[ ! "${_BLOCK_COUNT}" =~ ${RE} ]]
    then
      _BLOCK_COUNT=$( echo "${PEER_INFO}" | jq '.[] | select( .banscore < 21 and .synced_headers > 0 ) | .startingheight ' 2>/dev/null | sort -hr | uniq | head -1 | tr -d '[:space:]' )
    fi
    if [[ -z "${_BLOCK_COUNT}" ]] || [[ ! "${_BLOCK_COUNT}" =~ ${RE} ]]
    then
      _BLOCK_COUNT=$( echo "${PEER_INFO}" | jq '.[] | .synced_headers ' 2>/dev/null | sort -hr | uniq | head -1 | tr -d '[:space:]' )
    fi
    if [[ -z "${_BLOCK_COUNT}" ]] || [[ ! "${_BLOCK_COUNT}" =~ ${RE} ]]
    then
      _BLOCK_COUNT=$( echo "${PEER_INFO}" | jq '.[] | .startingheight ' 2>/dev/null | sort -hr | uniq | head -1 | tr -d '[:space:]' )
    fi
    if [[ -z "${_BLOCK_COUNT}" ]] || [[ ! "${_BLOCK_COUNT}" =~ ${RE} ]]
    then
      _BLOCK_COUNT=$( "${1}" lastblock 2>/dev/null )
      if [[ ! -z "${_BLOCK_COUNT}" ]] && [[ "${_BLOCK_COUNT}" =~ ${RE} ]] && [[ "${_BLOCK_COUNT}" -gt 2000 ]]
      then
        _BLOCK_COUNT="$(( _BLOCK_COUNT - 1000))"
      fi
    fi
    echo "${_BLOCK_COUNT}"

  elif [ "${9}" == "getmasternodever" ] || \
    [ "${9}" == "getmasternodeversion" ] || \
    [ "${9}" == "masternodever" ] || \
    [ "${9}" == "mnver" ] || \
    [ "${9}" == "get${_MASTERNODE_CALLER}ver" ] || \
    [ "${9}" == "get${_MASTERNODE_CALLER}version" ] || \
    [ "${9}" == "${_MASTERNODE_CALLER}ver" ] || \
    [ "${9}" == "${_MASTERNODE_PREFIX}ver" ]
  then
    "${1}" "${_MASTERNODE_CALLER}" list |  jq '.[] | "\(.version)"' | sort -hr | uniq -c

  elif [ "${9}" == "getpeerver" ] || [ "${9}" == "getpeerversion" ]
  then
    "${1}" getpeerinfo | jq '.[] | "\(.version) \(.subver)"' | sort -hr | uniq -c

  elif [ "${9}" == "getpeerblockver" ] || [ "${9}" == "checkpeers" ] || [ "${9}" == "peercheck" ]
  then
    "${1}" getpeerinfo | jq '.[] | "\(.synced_headers) \(.version) \(.subver)"' | sort -hr | uniq -c

  elif [ "${9}" == "dl_bootstrap" ] || [ "${9}" == "dl_bootstrap_reindex" ]
  then
    if [ -z "${DROPBOX_BOOTSTRAP}" ]
    then
      DROPBOX_BOOTSTRAP=$( grep -m 1 'bootstrap=' "${5}" | cut -d '=' -f2 )
    fi
    if [ -z "${GITHUB_REPO}" ]
    then
      GITHUB_REPO=$( grep -m 1 'github_repo=' "${5}" | cut -d '=' -f2 )
    fi

    if [ -z "${DROPBOX_BOOTSTRAP}" ]
    then
      echo
      echo "Bootstrap download could not be found. Ask for help on discord."
      echo
      return 1 2>/dev/null
    fi

    # Get new bootstrap code.
    PROJECT_DIR=$( basename "${GITHUB_REPO}" )
    if [ ! -f /var/multi-masternode-data/"${PROJECT_DIR}"/bootstrap.dat ] || [[ $( find /var/multi-masternode-data/"${PROJECT_DIR}"/bootstrap.dat -mtime +1 -print ) ]]
    then
      rm -f /var/multi-masternode-data/"${PROJECT_DIR:?}"/bootstrap.dat
      COUNTER=0
      while [[ ! -f /var/multi-masternode-data/"${PROJECT_DIR}"/bootstrap.dat ]]
      do
        echo "Downloading bootstrap."
        wget -4qo- https://www.dropbox.com/s/"${DROPBOX_BOOTSTRAP}"/bootstrap.dat.gz?dl=1 -O "/tmp/${PROJECT_DIR}.bootstrap.dat.gz"
        gunzip -c "/tmp/${PROJECT_DIR}.bootstrap.dat.gz" > /var/multi-masternode-data/"${PROJECT_DIR}"/bootstrap.dat
        chmod 666 /var/multi-masternode-data/"${PROJECT_DIR}"/bootstrap.dat
        rm "/tmp/${PROJECT_DIR}.bootstrap.dat.gz"
        echo -e "\r\c"

        COUNTER=$(( COUNTER+1 ))
        if [[ "${COUNTER}" -gt 3 ]]
        then
          break;
        fi
      done
    fi

    TEMP_VAR_PID=$( "${1}" pid )
    if [[ ! -z "${TEMP_VAR_PID}" ]]
    then
      echo "Stopping ${1}"
      "${1}" stop >/dev/null 2>&1
    fi
    if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
    then
      sudo cp /var/multi-masternode-data/"${PROJECT_DIR}"/bootstrap.dat "${DIR}"/bootstrap.dat
      sudo chmod 666 "${DIR}"/bootstrap.dat
      sudo chown -R "${1}:${1}" "${DIR}"
    else
      cp /var/multi-masternode-data/"${PROJECT_DIR}"/bootstrap.dat "${DIR}"/bootstrap.dat
      chmod 666 "${DIR}"/bootstrap.dat
      chown -R "${1}:${1}" "${DIR}"
    fi

    if [ "${9}" == "dl_bootstrap_reindex" ]
    then
      sleep 5
      "${1}" reindex "${10}" "${11}"
    elif [[ ! -z "${TEMP_VAR_PID}" ]]
    then
      sleep 5
      "${1}" start
    fi

  elif [ "${9}" == "dl_blocks_n_chains" ]
  then
    if [[ -z "${DROPBOX_BLOCKS_N_CHAINS}" ]]
    then
      DROPBOX_BLOCKS_N_CHAINS=$( grep -m 1 'blocks_n_chains=' "${5}" | cut -d '=' -f2 )
    fi
    if [[ -z "${GITHUB_REPO}" ]]
    then
      GITHUB_REPO=$( grep -m 1 'github_repo=' "${5}" | cut -d '=' -f2 )
    fi

    if [[ -z "${DROPBOX_BLOCKS_N_CHAINS}" ]]
    then
      echo
      echo "Blocks and chains source could not be found. Try dl_bootstrap."
      echo
      return 1 2>/dev/null
    fi

    PROJECT_DIR=$( basename "${GITHUB_REPO}" )
    # Get new bootstrap code.
    if [ ! -d /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/blocks/ ] || [ ! -d /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/chainstate/ ] || [[ $( find /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/blocks/ -maxdepth 0 -mtime +3 -print ) ]]
    then
      mkdir -p /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains
      rm -rf /var/multi-masternode-data/"${PROJECT_DIR:?}"/blocks_n_chains/blocks/
      rm -rf /var/multi-masternode-data/"${PROJECT_DIR:?}"/blocks_n_chains/chainstate/
      COUNTER=0
      while [[ ! -d /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/blocks/ ]] || [ ! -d /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/chainstate/ ]
      do
        rm -rf /var/multi-masternode-data/"${PROJECT_DIR:?}"/blocks_n_chains/blocks/
        rm -rf /var/multi-masternode-data/"${PROJECT_DIR:?}"/blocks_n_chains/chainstate/

        echo "Downloading blocks and chainstate."
        wget -4qo- https://www.dropbox.com/s/"${DROPBOX_BLOCKS_N_CHAINS}"/blocks_n_chains.tar.gz?dl=1 -O "/tmp/${PROJECT_DIR}.blocks_n_chains.tar.gz"
        tar -xzf "/tmp/${PROJECT_DIR}.blocks_n_chains.tar.gz" -C /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains
        rm "/tmp/${PROJECT_DIR}.blocks_n_chains.tar.gz"
        echo -e "\r\c"

        COUNTER=$(( COUNTER+1 ))
        if [[ "${COUNTER}" -gt 3 ]]
        then
          break;
        fi
      done
    fi

    TEMP_VAR_PID=$( "${1}" pid )
    if [[ ! -z "${TEMP_VAR_PID}" ]]
    then
      "${1}" stop
    fi

    # Clear folder.
    FILENAME=$( basename "${5}" )
    if [[ -d "${DIR}" ]]
    then
      find "${DIR}" -maxdepth 1 | tail -n +2 | grep -vE "backups|wallet.dat|${FILENAME}|peers.dat" | xargs rm -rf
    fi

    if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
    then
      sudo mkdir -p "${DIR}"/blocks/
      sudo mkdir -p "${DIR}"/chainstate/
      sudo sh -c "find /var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/ -type f -exec chmod 666 {} \;"
      sudo sh -c "find /var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/ -type d -exec chmod 777 {} \;"
      sudo touch -m /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/blocks/
      sudo touch -m /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/chainstate/
      sudo cp -r /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/blocks/*     "${DIR}"/blocks/
      sudo cp -r /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/chainstate/* "${DIR}"/chainstate/
      sudo mkdir -p "${DIR}"/backups/
      if [[ -d /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/sporks/ ]]
      then
        sudo mkdir -p "${DIR}"/sporks/
        sudo touch -m /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/sporks/
        sudo cp -r /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/sporks/* "${DIR}"/sporks/
      fi
      if [[ -d /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/zerocoin/ ]]
      then
        sudo mkdir -p "${DIR}"/zerocoin/
        sudo touch -m /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/zerocoin/
        sudo cp -r /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/zerocoin/* "${DIR}"/zerocoin/
      fi
      if [[ -d /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/database/ ]]
      then
        sudo mkdir -p "${DIR}"/database/
        sudo touch -m /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/database/
        sudo cp -r /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/database/* "${DIR}"/database/
      fi
      if [[ -d /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/rewards/ ]]
      then
        sudo mkdir -p "${DIR}"/rewards/
        sudo touch -m /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/rewards/
        sudo cp -r /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/rewards/* "${DIR}"/rewards/
      fi
      if [[ -f /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/mncache.dat ]] ; then
        sudo cp -r /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/mncache.dat "${DIR}"/
      fi
      if [[ -f /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/fee_estimates.dat ]] ; then
        sudo cp -r /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/fee_estimates.dat "${DIR}"/
      fi
      if [[ -f /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/db.log ]] ; then
        sudo cp -r /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/db.log "${DIR}"/
      fi
      if [[ -f /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/mnpayments.dat ]] ; then
        sudo cp -r /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/mnpayments.dat "${DIR}"/
      fi
      if [[ -f /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/snpayments.dat ]] ; then
        sudo cp -r /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/snpayments.dat "${DIR}"/
      fi
      if [[ -f /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/budget.dat ]] ; then
        sudo cp -r /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/budget.dat "${DIR}"/
      fi
      if [[ -f /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/netfulfilled.dat ]] ; then
        sudo cp -r /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/netfulfilled.dat "${DIR}"/
      fi
      if [[ -f /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/version.dat ]] ; then
        sudo cp -r /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/version.dat "${DIR}"/
      fi
      sudo chown -R "${1}:${1}" "${DIR}"/
    else
      mkdir -p "${DIR}"/blocks/
      mkdir -p "${DIR}"/chainstate/
      find /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/ -type f -exec chmod 666 {} \;
      find /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/ -type d -exec chmod 777 {} \;
      touch -m /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/blocks/
      touch -m /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/chainstate/
      cp -r /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/blocks/*     "${DIR}"/blocks/
      cp -r /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/chainstate/* "${DIR}"/chainstate/
      mkdir -p "${DIR}"/backups/
      if [[ -d /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/sporks/ ]]
      then
        mkdir -p "${DIR}"/sporks/
        touch -m /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/sporks/
        cp -r /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/sporks/* "${DIR}"/sporks/
      fi
      if [[ -d /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/zerocoin/ ]]
      then
        mkdir -p "${DIR}"/zerocoin/
        touch -m /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/zerocoin/
        cp -r /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/zerocoin/* "${DIR}"/zerocoin/
      fi
      if [[ -d /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/database/ ]]
      then
        mkdir -p "${DIR}"/database/
        touch -m /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/database/
        cp -r /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/database/* "${DIR}"/database/
      fi
      if [[ -d /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/rewards/ ]]
      then
        mkdir -p "${DIR}"/rewards/
        touch -m /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/rewards/
        cp -r /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/rewards/* "${DIR}"/rewards/
      fi
      if [[ -f /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/mncache.dat ]] ; then
        cp -r /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/mncache.dat "${DIR}"/
      fi
      if [[ -f /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/fee_estimates.dat ]] ; then
        cp -r /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/fee_estimates.dat "${DIR}"/
      fi
      if [[ -f /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/db.log ]] ; then
        cp -r /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/db.log "${DIR}"/
      fi
      if [[ -f /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/mnpayments.dat ]] ; then
        cp -r /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/mnpayments.dat "${DIR}"/
      fi
      if [[ -f /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/snpayments.dat ]] ; then
        cp -r /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/snpayments.dat "${DIR}"/
      fi
      if [[ -f /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/budget.dat ]] ; then
        cp -r /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/budget.dat "${DIR}"/
      fi
      if [[ -f /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/netfulfilled.dat ]] ; then
        cp -r /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/netfulfilled.dat "${DIR}"/
      fi
      if [[ -f /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/version.dat ]] ; then
        cp -r /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/version.dat "${DIR}"/
      fi
      chown -R "${1}:${1}" "${DIR}"/
    fi

    if [[ ! -z "${TEMP_VAR_PID}" ]]
    then
      "${1}" start
    fi

  elif [ "${9}" == "dl_addnode" ]
  then
    DROPBOX_ADDNODES=$( grep -m 1 'nodelist=' "${5}" | cut -d '=' -f2 )
    if [ ! -z "${DROPBOX_ADDNODES}" ]
    then
      echo "Downloading addnode list."
      ADDNODES=$( wget -4qO- -o- https://www.dropbox.com/s/"${DROPBOX_ADDNODES}"/peers_1.txt?dl=1 | grep 'addnode=' | shuf )
      TEMP_VAR_PID=$( "${1}" pid )
      if [[ ! -z "${TEMP_VAR_PID}" ]]
      then
        "${1}" stop
      fi

      if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
      then
        sudo sed -i '/addnode\=/d' "${5}"
        echo "${ADDNODES}" | tr " " "\\n" | sudo tee -a "${5}" >/dev/null "${5}"
      else
        sed -i '/addnode\=/d' "${5}"
        echo "${ADDNODES}" | tr " " "\\n" >> "${5}"
      fi

      if [[ ! -z "${TEMP_VAR_PID}" ]]
      then
        sleep 5
        "${1}" start
      fi
    fi

  elif [ "${9}" == "addnode_list" ] || [ "${9}" == "list_addnode" ]
  then
    # Get the port.
    EXTERNAL_IP=$( grep -m 1 'externalip=' "${5}" | cut -d '=' -f2 )
    DEFAULT_PORT=$( grep -m 1 'defaultport=' "${5}" | cut -d '=' -f2 )
    if [ -z "${DEFAULT_PORT}" ]
    then
      DEFAULT_PORT=$(echo "${EXTERNAL_IP}" | cut -d ':' -f2)
    fi

    if [[ -z "${11}" ]]
    then
      if [[ ! -z "${10}" ]] && [[ ${10} =~ $RE ]]
      then
        WEBBC=${10}
      else
        WEBBC=$( "${1}" explorer_blockcount )
      fi
      LASTBLOCK=$("${1}" getblockcount 2>/dev/null)
      if [[ ! $WEBBC =~ $RE ]]
      then
        echo "Explorer is down."
        echo "Can not generate addnode list."
        return
      elif [[ "${WEBBC}" -ne "${LASTBLOCK}" ]]
      then
        echo "Local blockcount ${LASTBLOCK} and Remote blockcount ${WEBBC} do not match."
        echo "Can not generate addnode list."
        return
      fi
    fi

    BLKCOUNTL=$((LASTBLOCK-1))
    BLKCOUNTH=$((LASTBLOCK+1))
    ADDNODE_LIST=$( "${1}" getpeerinfo | jq ".[] | select ( .synced_headers >= ${BLKCOUNTL} and .synced_headers <= ${BLKCOUNTH} and .banscore < 60 ) | .addr " | sed 's/\"//g' | sed "s/\:${DEFAULT_PORT}//g" | awk '{print "addnode="$1}' )
    if [ "${10}" == "ipv4" ]
    then
      echo "${ADDNODE_LIST}" | grep -v '\=\['
    elif [ "${10}" == "ipv6" ]
    then
      echo "${ADDNODE_LIST}" | grep '\=\[' | cat
    else
      echo "${ADDNODE_LIST}"
    fi

  elif [ "${9}" == "addnode_console" ] || [ "${9}" == "console_addnode" ]
  then
    # Get the port.
    EXTERNAL_IP=$( grep -m 1 'externalip=' "${5}" | cut -d '=' -f2 )
    DEFAULT_PORT=$( grep -m 1 'defaultport=' "${5}" | cut -d '=' -f2 )
    if [ -z "${DEFAULT_PORT}" ]
    then
      DEFAULT_PORT=$(echo "${EXTERNAL_IP}" | cut -d ':' -f2)
    fi

    if [[ -z "${11}" ]]
    then
      if [[ ! -z "${10}" ]] && [[ ${10} =~ $RE ]]
      then
        WEBBC=${10}
      else
        WEBBC=$( "${1}" explorer_blockcount )
      fi
      LASTBLOCK=$("${1}" getblockcount 2>/dev/null)
      if ! [[ $WEBBC =~ $RE ]]
      then
        echo "Explorer is down."
        echo "Can not generate addnode console list."
        return
      elif [[ "${WEBBC}" -ne "${LASTBLOCK}" ]]
      then
        echo "Local blockcount ${LASTBLOCK} and Remote blockcount ${WEBBC} do not match."
        echo "Can not generate addnode console list."
        return
      fi
    fi

    BLKCOUNTL=$((LASTBLOCK-1))
    BLKCOUNTH=$((LASTBLOCK+1))
    ADDNODE_LIST=$( "${1}" getpeerinfo | jq ".[] | select ( .synced_headers >= ${BLKCOUNTL} and .synced_headers <= ${BLKCOUNTH} and .banscore < 60 ) | .addr " | sed 's/\"//g' | sed "s/\:${DEFAULT_PORT}//g" | awk '{print "addnode " $1 " add"}' )
    if [ "${10}" == "ipv4" ]
    then
      echo "${ADDNODE_LIST}" | grep -v '\s\[.*\sadd'
    elif [ "${10}" == "ipv6" ]
    then
      echo "${ADDNODE_LIST}" | grep '\s\[.*\sadd' | cat
    else
      echo "${ADDNODE_LIST}"
    fi

  elif [ "${9}" == "mninfo" ] || [ "${9}" == "${_MASTERNODE_PREFIX}info" ]
  then
    MASTERNODE_STATUS=$( "${1}" "${_MASTERNODE_CALLER}" status )
    if [[ $( echo "${MASTERNODE_STATUS}" | grep -ic "${_MASTERNODE_CALLER} successfully started" ) -ge 1 ]]
    then
      # Get collateral info.
      TXID=$( echo "${MASTERNODE_STATUS}" | jq -r .[] | head -n 1 | grep -o -w -E '[[:alnum:]]{64}' )
      OUTPUTIDX=$( echo "${MASTERNODE_STATUS}" | jq '.outputidx' 2>/dev/null | grep -v 'null' )
      if [[ -z "${OUTPUTIDX}" ]]
      then
        OUTPUTIDX=$( echo "${MASTERNODE_STATUS}" | jq -r .[] | head -n 1 | grep -o -w -E '[[:alnum:]]{64}-[0-9]{1,2}' | cut -d '-' -f2 )
      fi
      if [[ -z "${OUTPUTIDX}" ]]
      then
        OUTPUTIDX=$( echo "${MASTERNODE_STATUS}" | jq -r .[] | head -n 1 | grep -o -w -E '[[:alnum:]]{64},\s[0-9]{1,2}' | awk '{print $2}' )
      fi

      # Get masternode list info.
      MASTERNODE_LIST=$( "${1}" "${_MASTERNODE_CALLER}" list )
      LIST_STATUS=$( echo "${MASTERNODE_LIST}" | jq ".[] | select( .txhash == \"$TXID\" and .outidx == $OUTPUTIDX )" 2>/dev/null )
      if [[ -z "${LIST_STATUS}" ]]
      then
        LIST_STATUS=$( echo "${MASTERNODE_LIST}" | jq ".[] | select( .txhash == \"$TXID\" )" 2>/dev/null )
      fi
      if [[ -z "${LIST_STATUS}" ]]
      then
        LIST_STATUS=$( echo "${MASTERNODE_LIST}" | grep "${TXID}-${OUTPUTIDX}"  2>/dev/null )
      fi
      if [[ -z "${LIST_STATUS}" ]]
      then
        LIST_STATUS=$( echo "${MASTERNODE_LIST}" | grep "${TXID}, ${OUTPUTIDX}"  2>/dev/null )
      fi
      if [[ -z "${LIST_STATUS}" ]]
      then
        LIST_STATUS=$( echo "${MASTERNODE_LIST}" | grep "${TXID}"  2>/dev/null )
      fi

      # Output info.
      JSON_ERROR=$( echo "$LIST_STATUS" | jq . 2>&1 >/dev/null )
      if [ -z "${JSON_ERROR}" ]
      then
        echo "$LIST_STATUS" | jq .
      else
        echo "$LIST_STATUS"
      fi
    fi

  elif [ "${9}" == "mnaddr" ] || [ "${9}" == "${_MASTERNODE_PREFIX}addr" ]
  then
    MASTERNODE_STATUS=$( "${1}" "${_MASTERNODE_CALLER}" status )
    if [[ $( echo "${MASTERNODE_STATUS}" | grep -ic "${_MASTERNODE_CALLER} successfully started" ) -ge 1 ]]
    then
      MN_ADDR=$( echo "${MASTERNODE_STATUS}" | jq -r ".addr" 2>/dev/null )
      if [[ -z "${MN_ADDR}" ]] || [[ "${MN_ADDR}" == "null" ]]
      then
        MN_ADDR=$( echo "${MASTERNODE_STATUS}" | jq -r ".pubkey" 2>/dev/null )
      fi
      if [[ -z "${MN_ADDR}" ]] || [[ "${MN_ADDR}" == "null" ]]
      then
        MN_ADDR=$( echo "${MASTERNODE_STATUS}" | jq -r ".payee" 2>/dev/null )
      fi
      echo "${MN_ADDR}"
    fi

  elif [ "${9}" == "mnwin" ] || [ "${9}" == "${_MASTERNODE_PREFIX}win" ]
  then
    # Get masternode address.
    if [[ -z "${10}" ]]
    then
      MN_ADDR=$( "${1}" "${_MASTERNODE_PREFIX}addr" )
    else
      MN_ADDR=${10}
    fi

    # Return if no masternode address.
    if [[ -z "${MN_ADDR}" ]]
    then
      return
    fi

    # Return if no masternode winners does not contain masternode address.
    MASTERNODE_WINNERS=$( "${1}" "${_MASTERNODE_CALLER}" winners | sed 's/: " /: "/g' )
    if [[ $( echo "${MASTERNODE_WINNERS}" | grep -cF "${MN_ADDR}" ) -lt 1 ]]
    then
      return
    fi

    # Get masternode winner and block height.
    MN_WINNER=$( echo "${MASTERNODE_WINNERS}" | jq ".[]" )

    OUTPUT=''
    # Pivx Syntax.
    while read -r BLK
    do
      BLK_WINNERS=$( echo "${MN_WINNER}" | jq "select ( .nHeight == ${BLK} ) " 2>/dev/null )
      if [[ $( echo "${BLK_WINNERS}" | jq '.winner | max_by( .nVotes )' 2>/dev/null | grep -c "${MN_ADDR}" ) -gt 0 ]]
      then
        OUTPUT=$( echo -e "${OUTPUT}\n${MN_ADDR} ${BLK}" )
        continue
      fi
      if [[ $( echo "${BLK_WINNERS}" | jq '.winner' 2>/dev/null | grep -c "${MN_ADDR}" ) -gt 0 ]]
      then
        OUTPUT=$( echo -e "${OUTPUT}\n${MN_ADDR} ${BLK}" )
      fi
    done <<< "$( echo "${MN_WINNER}" | jq ".nHeight" 2>/dev/null  )"

    # Dash syntax.
    if [[ -z "${OUTPUT}" ]] || [[ ! ${OUTPUT} =~ ${RE} ]]
    then
      while read -r BLK
      do
        if [[ $( echo "${MASTERNODE_WINNERS}" | grep "${BLK}" | tr -d -c ',' | wc -c ) -eq 1 ]]
        then
          OUTPUT=$( echo -e "${OUTPUT}\n${MN_ADDR} ${BLK}" )
        else
          if [[ $( echo "${MASTERNODE_WINNERS}" | grep "${BLK}" | awk '{first = $1; $1 = ""; print $0}' | tr ',' '\n' | tr -d '"' | tr ':' ' ' | awk '{print $2 " " $1}' | sort -hr | head -n 1 | grep -c "${MN_ADDR}" ) -gt 0 ]]
          then
            OUTPUT=$( echo -e "${OUTPUT}\n${MN_ADDR} ${BLK}" )
          fi
        fi
      done <<< "$( echo "${MASTERNODE_WINNERS}" | grep "${MN_ADDR}" | grep -o '"[0-9]*"' | grep -o '[0-9]*' 2>/dev/null )"
    fi

    # Smartnode syntax.
    if [[ -z "${OUTPUT}" ]] || [[ ! ${OUTPUT} =~ ${RE} ]]
    then
      MN_WINNER=$( echo "${MASTERNODE_WINNERS}" | grep -vi 'norewardblock' | head -n -2 2>/dev/null )
      while read -r BLK
      do
        if [[ $( echo "$MN_WINNER }}" | jq ".[\"${BLK}\"].votes.${MN_ADDR}" 2>/dev/null ) =~ ${RE} ]]
        then
          OUTPUT=$( echo -e "${OUTPUT}\n${MN_ADDR} ${BLK}" )
        fi
      done <<< "$( echo "$MN_WINNER }}" | jq -r 'keys[]' 2>/dev/null )"
    fi
    echo "${OUTPUT}" | sed '/^\s*$/d'

  elif [ "${9}" == "sync" ]
  then
    local i
    local CONNECTIONCOUNT
    local LASTBLOCK
    local BIG_COUNTER
    local START_COUNTER
    local WEBBLOCK
    local CURRENTBLOCK
    local END
    local PEER_BLOCK_COUNT
    local UP
    local DEL
    local BLOCKCOUNT_FALLBACK_VALUE
    BLOCKCOUNT_FALLBACK_VALUE="${10}"
    i=1
    BIG_COUNTER=0
    START_COUNTER=0

    if ! [[ ${BLOCKCOUNT_FALLBACK_VALUE} =~ ${RE} ]] || [[ -z "${BLOCKCOUNT_FALLBACK_VALUE}" ]]
    then
      echo "Getting the block count from the network"
      BLOCKCOUNT_FALLBACK_VALUE=$( "${1}" getpeerblockcount )
      echo "${BLOCKCOUNT_FALLBACK_VALUE}"
    fi
    if [[ -z "${DAEMON_CONNECTIONS}" ]]
    then
      DAEMON_CONNECTIONS=4
    fi

    # Get block count from the explorer.
    echo "Getting the block count from the explorer."
    WEBBLOCK=$( "${1}" explorer_blockcount )
    echo "${WEBBLOCK}"
    if ! [[ ${WEBBLOCK} =~ ${RE} ]]
    then
      echo "Explorers output is not good: ${WEBBLOCK}"
      echo "Using a fallback value."
      WEBBLOCK=$BLOCKCOUNT_FALLBACK_VALUE
    fi
    if ! [[ ${WEBBLOCK} =~ ${RE} ]]
    then
      echo "Explorers output is not good: ${WEBBLOCK}"
      echo "Using a fallback value."
      WEBBLOCK=1000
    fi
    stty sane 2>/dev/null
    echo "You can watch the log to see the exact details of the sync by"
    echo "running this in another terminal:"
    echo "${1} daemon_log loc | xargs watch -n 0.3 tail -n 15"
    echo "Explorer Count: ${WEBBLOCK}"
    echo "Waiting for at least ${DAEMON_CONNECTIONS} connections."
    echo
    echo "Initializing blocks, the faster your CPU that faster this goes."
    echo

    DAEMON_LOG=$( "${1}" daemon_log loc )
    CONNECTIONCOUNT=0;
    LASTBLOCK=0
    echo -e "\r${SP:i++%${#SP}:1} Connection Count: ${CONNECTIONCOUNT}\tBlockcount: ${LASTBLOCK} \n"
    echo
    echo
    echo "Contents of ${DAEMON_LOG}"
    echo
    echo
    echo
    echo
    echo

    sleep 1
    CONNECTIONCOUNT=$( "${1}" getconnectioncount 2>/dev/null )
    # If connectioncount is not a number set it to 0.
    if ! [[ $CONNECTIONCOUNT =~ $RE ]]
    then
      CONNECTIONCOUNT=0;
    fi

    LASTBLOCK=$( "${1}" getblockcount 2>/dev/null )
    # If blockcount is not a number set it to 0.
    if ! [[ ${LASTBLOCK} =~ ${RE} ]] ; then
      LASTBLOCK=0
    fi

    stty sane 2>/dev/null
    UP=$( tput cuu1 )
    DEL=$( tput el )

    "${1}" verifychain >/dev/null 2>&1

    sleep 3
    while :
    do
      # Auto restart if daemon dies.
      # shellcheck disable=SC2009
      TEMP_VAR_PID=$( "${1}" pid )
      if [[ -z "${TEMP_VAR_PID}" ]]
      then
        START_COUNTER=$(( START_COUNTER + 1 ))
        if [[ "${START_COUNTER}" -gt 2 ]]
        then
          START_COUNTER=0
          echo "Starting the daemon with -reindex."
          "${1}" reindex
        else
          echo "Starting the daemon again."
          "${1}" start
          sleep 15
        fi
      fi

      if [[ -z ${DAEMON_LOG} ]]
      then
        DAEMON_LOG=$( "${1}" daemon_log loc )
      fi

      CONNECTIONCOUNT=$( "${1}" getconnectioncount 2>/dev/null )
      # If connectioncount is not a number set it to 0.
      if ! [[ $CONNECTIONCOUNT =~ $RE ]]
      then
        CONNECTIONCOUNT=0;
      fi

      LASTBLOCK=$( "${1}" getblockcount 2>/dev/null | tr -d '[:space:]' )
      # If blockcount is not a number set it to 0.
      if ! [[ ${LASTBLOCK} =~ ${RE} ]]
      then
        LASTBLOCK=0;
      fi

      # Update console 34 times in 10 seconds before doing a check.
      END=34
      while [ ${END} -gt 0 ];
      do
        stty sane 2>/dev/null
        END=$(( END - 1 ))
        CURRENTBLOCK=$( "${1}" getblockcount 2>/dev/null | tr -d '[:space:]' )
        # If blockcount is not a number set it to 0.
        if ! [[ ${CURRENTBLOCK} =~ ${RE} ]] ; then
          CURRENTBLOCK=0;
        fi

        echo -e "${UP}${DEL}${UP}${DEL}${UP}${DEL}${UP}${DEL}${UP}${DEL}${UP}${DEL}${UP}${DEL}${UP}${DEL}${UP}${DEL}${UP}${DEL}\c"
        echo -e "${SP:i++%${#SP}:1} Connection Count: ${CONNECTIONCOUNT} \tBlockcount: ${LASTBLOCK}\n"
        if [[ -z "${TEMP_VAR_PID}" ]]
        then
          TEMP_VAR_PID=$( "${1}" pid )
        fi
        if [[ -z "${TEMP_VAR_PID}" ]]
        then
          echo
          echo
        else
          "${1}" ps-short
        fi
        echo "Contents of ${DAEMON_LOG}"
        if [[ -f "${DAEMON_LOG}" ]]
        then
          if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
          then
            sudo tail -n 5 "${DAEMON_LOG}" | awk '{$1=$2=""; print $0}' | sed 's/best\=.\{65\}//g' | tr -cd "[:print:]\n" | cut -c 3-81
          else
            tail -n 5 "${DAEMON_LOG}" | awk '{$1=$2=""; print $0}' | sed 's/best\=.\{65\}//g' | tr -cd "[:print:]\n" | cut -c 3-81
          fi
        else
          echo
          echo
          echo
          echo
          echo
        fi
        if [ "${CURRENTBLOCK}" -ge "${WEBBLOCK}" ] && [[ $CONNECTIONCOUNT -ge $DAEMON_CONNECTIONS ]]
        then
          break
        fi
        sleep 0.4
      done

      if [ "${LASTBLOCK}" -eq "${CURRENTBLOCK}" ] && [ "${CURRENTBLOCK}" -ge "${WEBBLOCK}" ]
      then
        # Check blockcount from peers.
        PEER_BLOCK_COUNT=$( "${1}" getpeerblockcount )
        if ! [[ ${PEER_BLOCK_COUNT} =~ ${RE} ]] && [[ $CONNECTIONCOUNT -ge $DAEMON_CONNECTIONS ]]
        then
          break
        fi
        if [[ "${CURRENTBLOCK}" -ge "${PEER_BLOCK_COUNT}" ]] && [[ $CONNECTIONCOUNT -ge $DAEMON_CONNECTIONS ]]
        then
          break
        fi
      fi

      # Restart daemon if blockcount is stuck for a long time.
      if [ "${LASTBLOCK}" -eq "${CURRENTBLOCK}" ]
      then
        BIG_COUNTER=$(( BIG_COUNTER + 1 ))
      else
        BIG_COUNTER=0
      fi
      if [ "${BIG_COUNTER}" -gt 15  ] && [[ "${RESTART_IN_SYNC}" -eq 1 ]]
      then
        "${1}" restart
        sleep 15
        echo
        echo
        echo
        echo
        echo
        echo
        echo
        BIG_COUNTER=0
        START_COUNTER=$(( START_COUNTER + 1 ))
      fi
      # Reindex daemon if blockcount is stuck 3 times in a row.
      if [[ "${START_COUNTER}" -gt 3 ]]
      then
        START_COUNTER=0
        echo "Starting the daemon with -reindex."
        "${1}" reindex
      fi
    done
    stty sane 2>/dev/null
    echo

  else
    if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
    then
      JSON_STRING=$( sudo su - "${1}" -c " ${2} ${9} ${10} ${11} ${12} ${13} ${14} ${15} ${16} ${17} " 2>&1 )
    else
      # shellcheck disable=SC2086
      JSON_STRING=$( "${USER_HOME_DIR}/.local/bin/${2}" "-datadir=${DIR}/" "${9}" ${10} ${11} ${12} ${13} ${14} ${15} ${16} ${17} 2>&1 )
    fi

    if [ -x "$(command -v jq)" ]
    then
      JSON_ERROR=$( echo "${JSON_STRING}" | jq . 2>&1 >/dev/null )
      if [ -z "${JSON_ERROR}" ]
      then
        echo "${JSON_STRING}" | jq .
      else
        if [[ "${JSON_STRING:0:8}" == "error: {" ]]
        then
          echo "${JSON_STRING:6}" | jq . | sed 's/\\n/\n/g; s/\\t/\t/g; s/\\"/"/g'
        else
          echo "${JSON_STRING}"
        fi
      fi
    else
      echo "${JSON_STRING}"
    fi
  fi
}
# End of function for _masternode_dameon_2.
MN_DAEMON_MASTER_FUNC
)

_MN_DAEMON_COMP=$( cat << "MN_DAEMON_COMP"
# Start of function for _masternode_dameon_2_completions.
_masternode_dameon_2_completions() {
  if [[ "${COMP_WORDS[0]}" != 'all_mn_run' ]]
  then
    LEVEL1=$(
      (
        ( bash -ic "${COMP_WORDS[0]} help" | grep -v "\=\=" | awk '{print $1}' ) & pid=$!
        ( sleep 2 >/dev/null 2>&1 ; kill $pid >/dev/null 2>&1 ) & watcher=$!
        wait $pid >/dev/null 2>&1 ; kill $watcher >/dev/null 2>&1
      ) 2>&1
    )
  fi
  LEVEL1_ALT=' addnode_console addnode_list addnode_remove addnode_to_connect blockcheck blockcount_explorer chaincheck checkblock checkchain checkpeers checksystemd cli cli_full conf connect_to_addnode console_addnode daemon daemon_full daemon_in_good_state daemon_log daemon_remove daemon_update dl_addnode dl_blocks_n_chains dl_bootstrap dl_bootstrap_reindex explorer explorer_blockcount failure_after_start forcestart full_cli full_daemon getpeerblockcount getpeerblockver getpeerver getpeerversion grep_daemon_log grep_system_log lastblock lastblock_time list_addnode log_daemon log_system peercheck peers_remove pid privkey ps ps-short reindex remove_addnode remove_daemon remove_peers rename restart start start-nosystemd status stop sync system_log systemdcheck update_daemon uptime '

  if [[ $( echo "${LEVEL1}" | grep -c "masternode" ) -ge 1 ]]
  then
    LEVEL1_ALT="${LEVEL1_ALT} masternode.conf masternodeping mnaddr mncheck mnfix mninfo mnver mnwin"
  elif [[ $( echo "${LEVEL1}" | grep -c "smartnode" ) -ge 1 ]]
  then
    LEVEL1_ALT="${LEVEL1_ALT} smartnode.conf smartnodeping snaddr sncheck snfix sninfo snver snwin"
  fi

  # keep the suggestions in a local variable
  if [ "${#COMP_WORDS[@]}" == "2" ]
  then
    COMPREPLY=($( compgen -W "$LEVEL1 $LEVEL1_ALT" -- "${COMP_WORDS[1]}" ))
  elif [ "${#COMP_WORDS[@]}" -gt 2 ]
  then
    LEVEL2=''
    LEVEL3=''
    if [[ "${COMP_WORDS[1]}" == "daemon_log" ]] || \
        [[ "${COMP_WORDS[1]}" == "log_daemon" ]] || \
        [[ "${COMP_WORDS[1]}" == "conf" ]]
    then
      LEVEL2='loc location '

    elif [[ "${COMP_WORDS[1]}" == "addnode_list" ]] || \
          [[ "${COMP_WORDS[1]}" == "list_addnode" ]] || \
          [[ "${COMP_WORDS[1]}" == "addnode_console" ]] || \
          [[ "${COMP_WORDS[1]}" == "console_addnode" ]]
    then
      LEVEL2='ipv4 ipv6 '

    elif [[ "${COMP_WORDS[1]}" == "masternode" ]]
    then
      LEVEL2='count current debug genkey outputs start start-alias start-all start-missing start-disabled status list list-conf winners'

    elif [[ "${COMP_WORDS[1]}" == "mnsync" ]]
    then
      LEVEL2=' status reset '

    elif [[ "${COMP_WORDS[1]}" == "smartnode" ]]
    then
      LEVEL2='count current genkey outputs start-alias start-all start-missing start-disabled status list list-conf winner winners'

    elif [[ "${COMP_WORDS[1]}" == "snsync" ]]
    then
      LEVEL2=' status next reset '

    elif [[ "${COMP_WORDS[1]}" == "addnode" ]]
    then
      LEVEL3=' add remove onetry '

    elif [[ "${COMP_WORDS[1]}" == "reindex" ]] || \
          [[ "${COMP_WORDS[1]}" == "dl_bootstrap_reindex" ]]
    then
      if [[ "${COMP_WORDS[2]}" == "remove_peers" ]] || \
          [[ "${COMP_WORDS[2]}" == "peers_remove" ]]
      then
        LEVEL3='remove_addnode addnode_remove'
      elif [[ "${COMP_WORDS[2]}" == "remove_addnode" ]] || \
            [[ "${COMP_WORDS[2]}" == "addnode_remove" ]]
      then
        LEVEL3='remove_peers peers_remove'
      else
        LEVEL2='remove_peers peers_remove remove_addnode addnode_remove'
      fi
    fi

    if [[ ! -z "${LEVEL3}" ]] && [ "${#COMP_WORDS[@]}" -eq 4 ]
    then
      COMPREPLY=($( compgen -W "$LEVEL3" -- "${COMP_WORDS[3]}" ))

    elif [[ ! -z "${LEVEL2}" ]] && [ "${#COMP_WORDS[@]}" -eq 3 ]
    then
      COMPREPLY=($( compgen -W "$LEVEL2" -- "${COMP_WORDS[2]}" ))

    fi
  fi
  return 0
}
# End of function for _masternode_dameon_2_completions.
MN_DAEMON_COMP
)

# Create function that will run the same command on all masternodes.
_ALL_MN_RUN=$( cat << "ALL_MN_RUN"
# Start of function for all_mn_run.
all_mn_run () {
  local MN_USRNAME
  find /home/* -maxdepth 0 -type d | tr '/' ' ' | awk '{print $2}' | while read -r MN_USRNAME
  do
    IS_EMPTY=$( type "${MN_USRNAME}" 2>/dev/null )
    if [ ! -z "${IS_EMPTY}" ]
    then
      echo "${MN_USRNAME}"
      ${MN_USRNAME} "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"
      echo
    fi
  done
}
# End of function for all_mn_run.
ALL_MN_RUN
)

USER_FUNCTION_FOR_ALL_MASTERNODES () {
  UPDATE_USER_FILE "${_MN_DAEMON_MASTER_FUNC}" "_masternode_dameon_2" "${HOME}/.bashrc" "/var/multi-masternode-data/___temp.sh"
  UPDATE_USER_FILE "${_MN_DAEMON_COMP}" "_masternode_dameon_2_completions" "${HOME}/.bashrc" "/var/multi-masternode-data/___temp.sh"
  UPDATE_USER_FILE "${_ALL_MN_RUN}" "all_mn_run" "${HOME}/.bashrc" "/var/multi-masternode-data/___temp.sh"
}

UPDATE_DAEMON_ADD_CRON () {
  local IS_EMPTY=''
  local MN_USRNAME=''

  local BIN_BASE=''
  local GITHUB_REPO=''
  local CONF_FILE_TOP=''
  local CONF_FILE=''
  local DAEMON_DOWNLOAD=''
  local DATA_DIRECTORY=''

  BIN_BASE=${1}
  GITHUB_REPO=${2}
  CONF_FILE_TOP=${3}
  DAEMON_DOWNLOAD=${4}
  DATA_DIRECTORY=${5}
  CONF_DROPBOX_ADDNODES=${6}
  CONF_DROPBOX_BOOTSTRAP=${7}
  CONF_DROPBOX_BLOCKS_N_CHAINS=${8}

  # Daemon Binary.
  if [[ -z "${DAEMON_BIN}" ]]
  then
    DAEMON_BIN="${BIN_BASE}d"
  fi
  # Control Binary.
  if [[ -z "${CONTROLLER_BIN}" ]]
  then
    CONTROLLER_BIN="${BIN_BASE}-cli"
  fi
  if [[ -z "${DIRECTORY}" ]]
  then
    DIRECTORY=${DATA_DIRECTORY}
  fi
  if [[ -z "${CONF}" ]]
  then
    CONF=${CONF_FILE_TOP}
  fi

  USER_FUNCTION_FOR_ALL_MASTERNODES
  # shellcheck source=/root/.bashrc
  source ~/.bashrc
  source /var/multi-masternode-data/.bashrc
  source /var/multi-masternode-data/___temp.sh

  find /home/* -maxdepth 0 -type d | tr '/' ' ' | awk '{print $2}' | while read -r MN_USRNAME
  do
    IS_EMPTY=$( type "${MN_USRNAME}" 2>/dev/null )
    if [ -z "${IS_EMPTY}" ] || [[ $( "${MN_USRNAME}" daemon ) != "${DAEMON_BIN}" ]]
    then
      continue
    fi
    echo "Working on ${MN_USRNAME}"
    CONF_FILE=$( "${MN_USRNAME}" conf loc )
    if [[ -z "${CONF_FILE}" ]]
    then
      CONF_FILE="/home/${MN_USRNAME}/${DATA_DIRECTORY}/${CONF_FILE_TOP}"
    fi
    echo "Target configuation file ${CONF_FILE}"

    if [[ $( grep -c 'github_repo' < "${CONF_FILE}" ) -eq 0 ]]
    then
      echo "Adding github_repo=${GITHUB_REPO}"
      echo -e "\n# github_repo=${GITHUB_REPO}" >> "${CONF_FILE}"
    fi
    if [[ $( grep -c 'bin_base' < "${CONF_FILE}" ) -eq 0 ]]
    then
      echo "Adding bin_base=${BIN_BASE}"
      echo -e "\n# bin_base=${BIN_BASE}"  >> "${CONF_FILE}"
    fi
    if [[ $( grep -c 'daemon_download' < "${CONF_FILE}" ) -eq 0 ]]
    then
      echo "Adding daemon_download=${DAEMON_DOWNLOAD}"
      echo -e "\n# daemon_download=${DAEMON_DOWNLOAD}"  >> "${CONF_FILE}"
    fi
    if [[ $( grep -c 'nodelist' < "${CONF_FILE}" ) -eq 0 ]]
    then
      echo "Adding nodelist=${CONF_DROPBOX_ADDNODES}"
      echo -e "\n# nodelist=${CONF_DROPBOX_ADDNODES}"  >> "${CONF_FILE}"
    fi
    if [[ $( grep -c 'bootstrap' < "${CONF_FILE}" ) -eq 0 ]]
    then
      echo "Adding bootstrap=${CONF_DROPBOX_BOOTSTRAP}"
      echo -e "\n# bootstrap=${CONF_DROPBOX_BOOTSTRAP}"  >> "${CONF_FILE}"
    fi
    if [[ $( grep -c 'blocks_n_chains' < "${CONF_FILE}" ) -eq 0 ]]
    then
      echo "Adding blocks_n_chains=${CONF_DROPBOX_BLOCKS_N_CHAINS}"
      echo -e "\n# blocks_n_chains=${CONF_DROPBOX_BLOCKS_N_CHAINS}"  >> "${CONF_FILE}"
    fi

    if [[ $( sudo su - "${MN_USRNAME}" -c 'crontab -l' 2>/dev/null | grep -cF "${MN_USRNAME} update_daemon 2>&1" ) -eq 0  ]]
    then
      echo 'Setting up crontab for auto updating in the future.'
      MINUTES=$((RANDOM % 60))
      sudo su - "${MN_USRNAME}" -c " ( crontab -l 2>/dev/null ; echo \"${MINUTES} */6 * * * bash -ic 'source /var/multi-masternode-data/.bashrc; ${MN_USRNAME} update_daemon 2>&1'\" ) | crontab - "
    fi

    if [[ $( sudo su - "${MN_USRNAME}" -c 'crontab -l' | grep -cF "${MN_USRNAME} mnfix 2>&1" ) -eq 0  ]]
    then
      echo 'Setting up crontab to auto fix the daemon.'
      MINUTES=$(( RANDOM % 19 ))
      MINUTES_A=$(( MINUTES + 20 ))
      MINUTES_B=$(( MINUTES + 40 ))
      sudo su - "${MN_USRNAME}" -c " ( crontab -l ; echo \"${MINUTES},${MINUTES_A},${MINUTES_B} * * * * bash -ic 'source /var/multi-masternode-data/.bashrc; ${MN_USRNAME} mnfix 2>&1'\" ) | crontab - "
    fi
    PROJECT_DIR=$( basename "${GITHUB_REPO}" )
    sudo sh -c "find /var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/ -type f -exec chmod 666 {} \;"
    sudo sh -c "find /var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/ -type d -exec chmod 777 {} \;"

    if [[ ! -z "${EXPLORER_URL}" ]]
    then
      USER_FUNCTION_FOR_MASTERNODE "${MN_USRNAME}" "${HOME}/.bashrc" "/var/multi-masternode-data/___temp.sh"
    fi

    "${MN_USRNAME}" update_daemon
  done
}

DAEMON_SETUP_THREAD () {
CHECK_SYSTEM
if [ $? == "1" ]
then
  return 1 2>/dev/null || exit 1
fi
rm -f /var/multi-masternode-data/___temp.sh

# m c a r p e r
UPDATE_USER_FILE "${_DENYHOSTS_UNBLOCK}" "denyhosts_unblock" "${HOME}/.bashrc" "/var/multi-masternode-data/___temp.sh"
USER_FUNCTION_FOR_ALL_MASTERNODES

# Set Defaults
echo "Using wget to get public IP."
PUBIPADDRESS="$( wget -4qO- -T 15 -t 2 -o- ipinfo.io/ip )"
if [ -z "${PUBIPADDRESS}" ]
then
  PUBIPADDRESS="$( wget -4qO- -T 15 -t 2 -o- icanhazip.com )"
fi
PRIVIPADDRESS="$( ip route get 8.8.8.8 | sed 's/ uid .*//' | awk '{print $NF; exit}' )"
# Set alias as the hostname.
MNALIAS="$( hostname )"

ASCII_ART

# Install JQ if not installed
if [ ! -x "$( command -v jq )" ]
then
  # Start sub process to install jq.
  sudo su -c 'bash -c "
    WAIT_FOR_APT_GET () {
      while [[ $( sudo lslocks | grep -c \"apt-get\|dpkg\|unattended-upgrades\" ) -ne 0 ]]; do sleep 0.5; done
    }

    export DEBIAN_FRONTEND=noninteractive >/dev/null 2>&1
    WAIT_FOR_APT_GET
    timeout 30s sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq jq bc >/dev/null 2>&1
    # Update apt-get info.
    WAIT_FOR_APT_GET
    timeout 10s sudo DEBIAN_FRONTEND=noninteractive dpkg --configure -a >/dev/null 2>&1
    WAIT_FOR_APT_GET
    timeout 30s sudo DEBIAN_FRONTEND=noninteractive add-apt-repository universe >/dev/null 2>&1
    WAIT_FOR_APT_GET
    timeout 60s sudo DEBIAN_FRONTEND=noninteractive apt-get update -yq >/dev/null 2>&1
    WAIT_FOR_APT_GET
    timeout 30s sudo DEBIAN_FRONTEND=noninteractive apt-get -f install -yq >/dev/null 2>&1
    WAIT_FOR_APT_GET
    timeout 30s sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq jq bc >/dev/null 2>&1
    WAIT_FOR_APT_GET
    sudo dpkg --configure -a >/dev/null 2>&1
  "' & disown >/dev/null 2>&1
fi

# Check if default port is being used; if not use it.
read -r LOWERPORT UPPERPORT < /proc/sys/net/ipv4/ip_local_port_range
PORTB=''
if [ -z "${PORTB}" ] && [ -x "$( command -v netstat )" ] && [[ $( sudo netstat -tulpn | grep "/${DAEMON_BIN}" | grep ":${DEFAULT_PORT}" | wc -c ) -gt 0 ]]
then
  PORTB="${DEFAULT_PORT}a"
fi
if [ -z "${PORTB}" ] && [ -x "$( command -v netstat )" ] && [[ $( sudo lslocks | tail -n +2 | awk '{print $2 "/"}' | sort -u | while read -r PID; do sudo netstat -tulpn | grep "${PID}" | grep ":${DEFAULT_PORT}" ; done | wc -c ) -gt 0 ]]
then
  PORTB="${DEFAULT_PORT}b"
fi
if [ -z "${PORTB}" ] && [ -x "$( command -v iptables )" ] && [[ $( sudo iptables -t nat -L | grep "${DEFAULT_PORT}" | wc -c ) -gt 0 ]]
then
  PORTB="${DEFAULT_PORT}c"
fi

if [[ "${MULTI_IP_MODE}" -eq 2 ]]
then
  if [[ -z "${PORTB}" ]]
  then
    PORTB=${DEFAULT_PORT}

  elif [[ "${PORTB}" == "${DEFAULT_PORT}b" ]]
  then
    echo
    echo "Port already used by another service."
    echo "Please use another IP Address."
    echo "Or open up port ${DEFAULT_PORT} for ${DAEMON_NAME}."
    echo
    echo "Process using port ${DEFAULT_PORT}:"
    USED_PORT=$( sudo netstat -tulpn | grep ":${DEFAULT_PORT}" )
    PID=$( echo "${USED_PORT}" | awk '{print $7}' | cut -d '/' -f1 )
    ps -up "${PID}"
    echo "${USED_PORT}"
    echo
    return 1 2>/dev/null

  elif [[ "${PORTB}" == "${DEFAULT_PORT}a" ]] || [[ "${PORTB}" == "${DEFAULT_PORT}c" ]]
  then
    if [[ $( sudo lsmod | grep -cF 'dummy' ) -eq 0 ]]
    then
      sudo modprobe dummy
    fi
    # Create dummy Network Interface
    sudo ip link add dummy0 type dummy 2>/dev/null
    ETHCOUNTER=10
    PREFIX='eth'
    INTERFACE_NAME="${PREFIX}${ETHCOUNTER}"
    PRIVIPADDRESS="192.168.${ETHCOUNTER}.2"
    while :
    do
      if [[ $( sudo netstat -tulpn | grep -cF "${PRIVIPADDRESS}:${DEFAULT_PORT}" ) -eq 0 ]]
      then
        break
      fi
      if [[ $( sudo ip link | grep -cF "${INTERFACE_NAME}" ) -eq 0 ]]
      then
        break
      fi
      ETHCOUNTER=$(( ETHCOUNTER+1 ))
      INTERFACE_NAME="${PREFIX}${ETHCOUNTER}"
      PRIVIPADDRESS="192.168.${ETHCOUNTER}.2"
    done

    # Give dummy network interface an IP.
    if [[ $( ip link | grep -cF "${INTERFACE_NAME}:" ) -eq 0 ]]
    then
      sudo ip link set name "${INTERFACE_NAME}" dev dummy0
      sudo ip addr add "192.168.${ETHCOUNTER}.2/24" brd + dev "${INTERFACE_NAME}" label "${INTERFACE_NAME}":0
    fi

    PORTB=${DEFAULT_PORT}
  fi

elif [[ "${MULTI_IP_MODE}" -eq 3 ]]
then
  if [[ -z "${PORTB}" ]]
  then
    PORTB=${DEFAULT_PORT}

  elif [[ "${PORTB}" == "${DEFAULT_PORT}b" ]] || [[ "${PORTB}" == "${DEFAULT_PORT}a" ]] || [[ "${PORTB}" == "${DEFAULT_PORT}c" ]]
  then

    PUB_PRIV_SAME=0
    if [ "${PRIVIPADDRESS}" == "${PUBIPADDRESS}" ]
    then
      PUB_PRIV_SAME=1
    fi

    while read -r OTHER_IP
    do
      if [[ "$( sudo netstat -tulpn | grep -cF "${OTHER_IP}:${DEFAULT_PORT}" )" -eq 0 ]]
      then
        PUBIPADDRESS="${OTHER_IP}"
        break
      fi
    done <<< "$( sudo ip -o addr show | grep -v 'inet6' | grep -v 'scope host' | awk '{print $4}' | cut -d '/' -f 1 |grep -vE '^(192\.168|10\.|172\.1[6789]\.|172\.2[0-9]\.|172\.3[01]\.)' | grep -v "${PUBIPADDRESS}" )"

    if [ "${PRIVIPADDRESS}" != "${PUBIPADDRESS}" ] && [ "${PUB_PRIV_SAME}" -eq 1 ]
    then
      PRIVIPADDRESS="${PUBIPADDRESS}"
    fi

    if [[ "$( sudo netstat -tulpn | grep -cF "${PRIVIPADDRESS}:${DEFAULT_PORT}" )" -ge 1 ]]
    then
      echo
      echo "Port already used by another service."
      echo "Please use another IP Address."
      echo "Or open up port ${DEFAULT_PORT} for ${DAEMON_NAME}."
      echo
      echo "Process using port ${DEFAULT_PORT}:"
      USED_PORT=$( sudo netstat -tulpn | grep ":${DEFAULT_PORT}" )
      PIDS=$( echo "${USED_PORT}" | awk '{print $7}' | cut -d '/' -f1 )
      while read -r PID
      do
        ps -up "${PID}"
      done <<< "${PIDS}"

      echo "${USED_PORT}"
      echo
      return 1 2>/dev/null
    else
      PORTB=${DEFAULT_PORT}
    fi
  fi

elif [ -z "${PORTB}" ]
then
  PORTB=${DEFAULT_PORT}
else
  PORTB=''
  # Find open port if one wasn't provided.
  if [ -z "${PORTB}" ]
  echo "Searching for an unused port for daemon"
  then
    while :
    do
      PORTB=$( shuf -i "${LOWERPORT}"-"${UPPERPORT}" -n 1 )
      sudo ss -lpn 2>/dev/null | grep -q ":${PORTB} " || break
    done
  fi
fi

if [ -x "$( command -v ufw )" ]
then
  # Open up port.
  sudo ufw allow "${DEFAULT_PORT}" >/dev/null 2>&1
fi

# Find open port.
echo "Searching for an unused port for rpc"
while :
do
  PORTA=$( shuf -i "${LOWERPORT}"-"${UPPERPORT}" -n 1 )
  sudo ss -lpn 2>/dev/null | grep -q ":${PORTA} " || break
done

# $1 sets starting username counter
UNCOUNTER=1
# $2 sets txhash
TXHASH=''
# $3 sets output index
OUTPUTIDX=''
# $4 sets mn key
MNKEY=''
# $5 if set will skip confirmation prompt.
SKIP_CONFIRM=''

# Allow for loose args
# Set MNKEY
if [[ ${#ARG1} -eq 51 ]] || [[ ${#ARG1} -eq 50 ]]
then
  MNKEY=${ARG1}
  ARG1=''
fi
if [[ ${#ARG2} -eq 51 ]] || [[ ${#ARG2} -eq 50 ]]
then
  MNKEY=${ARG2}
  ARG2=''
fi
if [[ ${#ARG3} -eq 51 ]] || [[ ${#ARG3} -eq 50 ]]
then
  MNKEY=${ARG3}
  ARG3=''
fi
if [[ ${#ARG5} -eq 51 ]] || [[ ${#ARG5} -eq 50 ]]
then
  MNKEY=${ARG5}
  ARG5=''
fi

# Set TXHASH
if [[ ${#ARG1} -eq 64 ]]
then
  TXHASH=${ARG1}
  ARG1=''
fi
if [[ ${#ARG3} -eq 64 ]]
then
  TXHASH=${ARG3}
  ARG3=''
fi
if [[ ${#ARG4} -eq 64 ]]
then
  TXHASH=${ARG4}
  ARG4=''
fi
if [[ ${#ARG5} -eq 64 ]]
then
  TXHASH=${ARG5}
  ARG5=''
fi

# Set OUTPUTIDX and SKIP_CONFIRM.
if [[ ${ARG5} =~ $RE ]] && [[ ${#ARG5} -lt 3 ]]
then
  OUTPUTIDX=${ARG5}
  SKIP_CONFIRM='y'
fi

# Unset first arg if nonsense
if ! [[ ${ARG1} =~ $RE ]]
then
  ARG1=''
fi
# Unset second arg if nonsense
if [[ ${#ARG2} -ne 64 ]]
then
  ARG2=''
fi
# Unset third arg if nonsense
if [[ ${#ARG3} -gt 3 ]]
then
  ARG3=''
fi
# Unset forth arg if nonsense
if [[ ${#ARG4} -ne 51 ]] && [[ ${#ARG4} -ne 50 ]]
then
  ARG4=''
fi

# Get skip final confirmation from arg.
if [ ! -z "${ARG5}" ] && [ "${ARG5}" != "-1" ]
then
  SKIP_CONFIRM="${ARG5}"
fi

echo "${DAEMON_NAME} daemon ${MASTERNODE_CALLER} setup script"
echo

if [ ! -z "${ARG2}" ] && [ "${ARG2}" != "-1" ] && [ "${ARG2}" != "0" ]
then
  TXHASH="${ARG2}"
fi

if [ ! -z "${ARG3}" ] && [ "${ARG3}" != "-1" ]
then
  OUTPUTIDX="${ARG3}"
fi
WEBBLOCK=''

# Ask for txhash.
if [ "${ARG2}" != "0" ] && [ -z "${SKIP_CONFIRM}" ]
then
  while :
  do
    echo "Collateral required: ${COLLATERAL}"
    echo
    echo "In your wallet, go to tools -> debug -> console and type:"
    echo "${MASTERNODE_CALLER} outputs"
    echo "Paste the info for this ${MASTERNODE_CALLER}; or leave it blank to skip and do it later."
    if [ -z "${TXHASH}" ]
    then
      read -r -e -i "${TXHASH}" -p "txhash: " input 2>&1
      TXHASH="${input:-$TXHASH}"
    else
      echo "txhash: ${TXHASH}"
      sleep 0.5
    fi

    # No txid passed in, break out.
    if [ -z "${TXHASH}" ]
    then
      break
    fi

    # Trim extra info.
    TXHASH="$( echo -e "${TXHASH}" | sed 's/\://g' | sed 's/\"//g' | sed 's/,//g' | sed 's/txhash//g' | cut -d '-' -f1 | grep -o -w -E '[[:alnum:]]{64}' )"
    TXHASH_LENGTH=$( printf "%s" "${TXHASH}" | wc -m )

    # TXID is not 64 char.
    if [ "${TXHASH_LENGTH}" -ne 64 ]
    then
      echo
      echo "txhash is not 64 characters long: ${TXHASH}."
      echo
      TXHASH=''
      continue
    fi

    if [[ ! -z "${EXPLORER_URL}" ]]
    then
      echo "Getting the block count from the explorer."
      if [[ "${EXPLORER_URL}" == https://www.coinexplorer.net/api/v1/* ]]
      then
        WEBBLOCK=$( wget -4qO- -T 15 -t 2 -o- "${EXPLORER_URL}block/latest" "${BAD_SSL_HACK}" | jq -r '.result.height' | tr -d '[:space:]' 2>/dev/null )
      else
        WEBBLOCK=$( wget -4qO- -T 15 -t 2 -o- "${EXPLORER_URL}api/getblockcount" "${BAD_SSL_HACK}" | tr -d '[:space:]' )
      fi
      sleep "${EXPLORER_SLEEP}"
    fi
    if ! [[ ${WEBBLOCK} =~ ${RE} ]]
    then
      echo "Explorers output is not good: ${WEBBLOCK}"
      echo "Going to skip verification"
      echo

      while :
      do
        # Ask for outputidx.
        OUTPUTIDX_ALT=''
        if [ -z "${OUTPUTIDX}" ]
        then
          read -r -e -i "${OUTPUTIDX}" -p "outputidx: " input 2>&1
        else
          echo "outputidx: ${OUTPUTIDX}"
          sleep 0.5
        fi
        OUTPUTIDX_ALT="${input:-$OUTPUTIDX_ALT}"
        OUTPUTIDX_ALT="$( echo -e "${OUTPUTIDX_ALT}" | tr -d '[:space:]' | sed 's/\://g' | sed 's/\"//g' | sed 's/outputidx//g' | sed 's/outidx//g' | sed 's/,//g' )"
        if [[ -z "${OUTPUTIDX_ALT}" ]]
        then
          TXHASH=''
          break
        fi
        if [[ ${OUTPUTIDX_ALT} =~ ${RE} ]]
        then
          OUTPUTIDX="${OUTPUTIDX_ALT}"
          break
        fi
      done
      break
    fi

    # Install jq if not available.
    if [ ! -x "$( command -v jq )" ]
    then
      # Update apt-get info.
      WAIT_FOR_APT_GET
      sudo DEBIAN_FRONTEND=noninteractive dpkg --configure -a
      WAIT_FOR_APT_GET
      sudo DEBIAN_FRONTEND=noninteractive add-apt-repository universe
      WAIT_FOR_APT_GET
      sudo DEBIAN_FRONTEND=noninteractive apt-get update -yq
      WAIT_FOR_APT_GET
      sudo DEBIAN_FRONTEND=noninteractive apt-get -f install -yq
      WAIT_FOR_APT_GET
      sudo dpkg --configure -a
      # Install jq
      WAIT_FOR_APT_GET
      sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq jq bc
    fi

    # Exit if jq can not be installed.
    if ! [ -x "$( command -v jq )" ]
    then
      echo
      echo "jq not installed; exiting. This command failed"
      echo "sudo apt-get install -yq jq bc"
      echo
      return 1 2>/dev/null || exit 1
    fi

    echo "Downloading transaction from the explorer."
    if [[ "${EXPLORER_URL}" == https://www.coinexplorer.net/api/v1/* ]]
    then
      OUTPUTIDX_RAW=$( wget -4qO- -T 15 -t 2 -o- "${EXPLORER_URL}transaction?txid=${TXHASH}" "${BAD_SSL_HACK}" | jq '.result' 2>/dev/null )
    else
      OUTPUTIDX_RAW=$( wget -4qO- -T 15 -t 2 -o- "${EXPLORER_URL}api/getrawtransaction?txid=${TXHASH}&decrypt=1" "${BAD_SSL_HACK}" )
    fi
    sleep "${EXPLORER_SLEEP}"
    JSON_ERROR=$( echo "${OUTPUTIDX_RAW}" | jq . 2>&1 >/dev/null )

    # Make sure txid is valid.
    if [ ! -z "${JSON_ERROR}" ] || [ -z "${OUTPUTIDX_RAW}" ]
    then
      echo
      echo "txhash is not a valid transaction id: ${TXHASH}."
      echo
      TXHASH=''
      continue
    fi

    # Get the output index.
    OUTPUTIDX_WEB=$( echo "${OUTPUTIDX_RAW}" | tr '[:upper:]' '[:lower:]' | jq ".vout[] | select( .value == ${COLLATERAL} ) | .n" )
    OUTPUTIDX_COUNT=$( echo "${OUTPUTIDX_WEB}" | wc -l )
    if [[ -z "${OUTPUTIDX_COUNT}" ]] || [[ -z "${OUTPUTIDX_WEB}" ]]
    then
      echo
      echo "txhash does not contain the collateral: ${TXHASH}."
      echo
      TXHASH=''
      continue
    fi

    if [[ "${OUTPUTIDX_COUNT}" -gt 1 ]]
    then
      while :
      do
        echo "Possible output index values for this txid"
        echo "${OUTPUTIDX_WEB}"
        echo
        # Ask for outputidx.
        OUTPUTIDX_ALT=''
        if [ -z "${OUTPUTIDX}" ]
        then
          read -r -e -i "${OUTPUTIDX}" -p "outputidx: " input 2>&1
        else
          echo "outputidx: ${OUTPUTIDX}"
          sleep 0.5
        fi
        OUTPUTIDX_ALT="${input:-$OUTPUTIDX_ALT}"
        OUTPUTIDX_ALT="$( echo -e "${OUTPUTIDX_ALT}" | tr -d '[:space:]' | sed 's/\://g' | sed 's/\"//g' | sed 's/outputidx//g' | sed 's/outidx//g' | sed 's/,//g' )"
        if echo "${OUTPUTIDX_WEB}" | grep "^${OUTPUTIDX_ALT}$"
        then
          OUTPUTIDX="${OUTPUTIDX_ALT}"
          break
        fi
        if [ -z "${OUTPUTIDX_ALT}" ]
        then
          TXHASH=''
          break
        fi
      done
    elif [[ "${OUTPUTIDX_COUNT}" -eq 1 ]]
    then
      OUTPUTIDX="${OUTPUTIDX_WEB}"
    fi

    # No output index or txid. Start over.
    if  [ -z "${OUTPUTIDX}" ] || [ -z "${TXHASH}" ]
    then
      echo
      echo "No output index or transaction id selected."
      echo
      TXHASH=''
      continue
    fi

    # Make sure collateral is still valid.
    MN_WALLET_ADDR=$( echo "$OUTPUTIDX_RAW" | tr '[:upper:]' '[:lower:]' | jq -r ".vout[] | select( .n == ${OUTPUTIDX} ) | .scriptpubkey.addresses | .[] " )
    MN_WALLET_ADDR=$( echo "$OUTPUTIDX_RAW" | grep -io "${MN_WALLET_ADDR}" )
    OUTPUTIDX_CONFIRMS=$( echo "${OUTPUTIDX_RAW}" | tr '[:upper:]' '[:lower:]' | jq '.confirmations' )
    MN_WALLET_ADDR_BALANCE=''
    echo "Downloading address from the explorer."
    if [[ "${EXPLORER_URL}" == https://www.coinexplorer.net/api/v1/* ]]
    then
      MN_WALLET_ADDR_UNSPENT=$( wget -4qO- -T 15 -t 2 -o- "${EXPLORER_URL}address/unspent?address=${MN_WALLET_ADDR}" "${BAD_SSL_HACK}" | jq -r ".result[] | select( .txid == \"${TXHASH}\" ) | .time" 2>/dev/null )
      if [[ ! -z "${MN_WALLET_ADDR_UNSPENT}" ]]
      then
        echo "${TXHASH} is good"
        break
      else
        echo
        echo "txhash no longer holds the collateral."
        TXHASH=''
        continue
      fi
    else
      MN_WALLET_ADDR_DETAILS=$( wget -4qO- -T 15 -t 2 -o- "${EXPLORER_URL}ext/getaddress/${MN_WALLET_ADDR}" "${BAD_SSL_HACK}"  )
    fi
    sleep "${EXPLORER_SLEEP}"
    if [[ -z "${MN_WALLET_ADDR_BALANCE}" ]]
    then
      MN_WALLET_ADDR_BALANCE=$( echo "${MN_WALLET_ADDR_DETAILS}" | jq -r ".balance" )
    fi
    if [[ "${MN_WALLET_ADDR_BALANCE}" == "null" ]] && [[ "${OUTPUTIDX_CONFIRMS}" -lt 10 ]]
    then
      echo "${TXHASH} is really new"
      echo "Assuming it is still good"
      break
    fi
    if [[ $( echo "${MN_WALLET_ADDR_BALANCE}<${COLLATERAL}" | bc ) -eq 1 ]]
    then
      echo
      echo "txhash no longer holds the collateral; moved: ${TXHASH}."
      echo "Balance is below ${COLLATERAL}."
      echo "${EXPLORER_URL}ext/getaddress/${MN_WALLET_ADDR}"
      echo
      TXHASH=''
      continue
    fi

    # Make sure it didn't get staked.
    TXIDS_AFTER_COLLATERAL=$( echo "${MN_WALLET_ADDR_DETAILS}" | jq -r ".last_txs[][] " | grep -vE "vin|vout" | sed -n -e "/${TXHASH}/,\$p" | grep -v "${TXHASH}" )
    if [ -z "${TXIDS_AFTER_COLLATERAL}" ]
    then
      echo "${TXHASH} is good"
      break
    fi

    # Check each tx after the given tx to see if it was used as an input.
    while read -r OTHERTXIDS
    do
      echo "Downloading transaction from the explorer."
      OUTPUTIDX_RAW=$( wget -4qO- -T 15 -t 2 -o- "${EXPLORER_URL}api/getrawtransaction?txid=${OTHERTXIDS}&decrypt=1" "${BAD_SSL_HACK}" | tr '[:upper:]' '[:lower:]' )
      sleep "${EXPLORER_SLEEP}"
      if [[ $( echo "$OUTPUTIDX_RAW" | jq ".vin[] | select( .txid == \"${TXHASH}\" )" | wc -c ) -gt 0 ]]
      then
        echo
        echo "txid no longer holds the collateral; staked or split up: ${TXHASH}."
        echo "txid that broke up the collateral"
        echo "${OTHERTXIDS}"
        echo "${EXPLORER_URL}api/getrawtransaction?txid=${OTHERTXIDS}&decrypt=1"
        echo
        TXHASH=''
        break
      fi
    done <<< "${TXIDS_AFTER_COLLATERAL}"

    if [ ! -z "${TXHASH}" ]
    then
      echo "${TXHASH} is good"
      break
    else
      continue
    fi
  done
fi

# Get mnkey from arg.
if [ ! -z "${ARG4}" ] && [ "${ARG4}" != "-1" ]
then
  MNKEY="${ARG4}"
fi

# Auto pick a user that is blank.
if [ ! -z "${ARG1}" ] && [[ $ARG1 =~ $RE ]] && [ "${ARG1}" != "-1" ]
then
  UNCOUNTER="${ARG1}"
fi
USRNAME="${DAEMON_PREFIX}${UNCOUNTER}"
while :
do
  if id "${USRNAME}" >/dev/null 2>&1; then
    UNCOUNTER=$(( UNCOUNTER+1 ))
    USRNAME="${DAEMON_PREFIX}${UNCOUNTER}"
  else
    break
  fi
done

echo -e "Username to run ${DAEMON_NAME} as: \\e[1;4m${USRNAME}\\e[0m"
# Get public and private ip addresses.
if [ "${PUBIPADDRESS}" != "${PRIVIPADDRESS}" ] && [ "${PRIVIPADDRESS}" == "0" ]
then
  PRIVIPADDRESS="${PUBIPADDRESS}"
fi
if [ "${PUBIPADDRESS}" != "${PRIVIPADDRESS}" ]
then
  echo -e "Public IPv4 Address:  \\e[1;4m${PUBIPADDRESS}\\e[0m"
  echo -e "Private IPv4 Address: \\e[1;4m${PRIVIPADDRESS}\\e[0m"
else
  echo -e "IPv4 Address:         \\e[1;4m${PUBIPADDRESS}\\e[0m"
fi
if [ -z "${PORTB}" ]
then
  echo -e "Port:                 \\e[2m(auto find available port)\\e[0m"
else
  echo -e "Port:                 \\e[1;4m${PORTB}\\e[0m"
fi
if [ -z "${MNKEY}" ]
then
  echo -e "${MASTERNODE_CALLER}privkey:    \\e[2m(auto generate one)\\e[0m"
else
  echo -e "${MASTERNODE_CALLER}privkey:    \\e[1;4m${MNKEY}\\e[0m"
fi
echo -e "txhash:               \\e[1;4m${TXHASH}\\e[0m"
echo -e "outputidx:            \\e[1;4m${OUTPUTIDX}\\e[0m"
echo -e "alias:                \\e[1;4m${USRNAME}_${MNALIAS}\\e[0m"
echo

REPLY='y'
echo "The full string to paste into the ${MASTERNODE_CALLER}.conf file"
echo "will be shown at the end of the setup script."
echo -e "\\e[4mPress Enter to continue\\e[0m"
if [ -z "${SKIP_CONFIRM}" ]
then
  read -r -p $'Use given defaults \e[7m(y/n)\e[0m? ' -e -i "${REPLY}" input 2>&1
else
  echo -e "Use given defaults \e[7m(y/n)\e[0m? ${REPLY}"
fi
REPLY="${input:-$REPLY}"
sudo true

if [[ $REPLY =~ ^[Nn] ]]
then
  # Create new user for daemon.
  echo
  echo "If you are unsure about what to type in, press enter to select the default."
  echo

  # Ask for username.
  while :
  do
    read -r -e -i "${USRNAME}" -p "Username (lowercase): " input 2>&1
    USRNAME="${input:-$USRNAME}"
    # Convert to lowercase.
    USRNAME=$( echo "${USRNAME}" | awk '{print tolower($0)}' )

    if id "${USRNAME}" >/dev/null 2>&1; then
      echo "User ${USRNAME} already exists."
    else
      break
    fi
  done

  # Get IPv4 public address.
  while :
  do
    read -r -e -i "${PUBIPADDRESS}" -p "Public IPv4 Address: " input 2>&1
    PUBIPADDRESS="${input:-$PUBIPADDRESS}"
    if VALID_IP "${PUBIPADDRESS}"
    then
      break;
    else
      echo "${PUBIPADDRESS} is not a valid IP"
      echo "Using wget to get public IP."
      PUBIPADDRESS="$( wget -4qO- -T 15 -t 2 -o- ipinfo.io/ip )"
      if [ -z "${PUBIPADDRESS}" ]
      then
        PUBIPADDRESS="$( wget -4qO- -T 15 -t 2 -o- icanhazip.com )"
      fi
    fi
  done

  # Get IPv4 private address.
  if [ "${PUBIPADDRESS}" != "${PRIVIPADDRESS}" ]
  then
    if [ "${PRIVIPADDRESS}" == "0" ]
    then
      PRIVIPADDRESS="${PUBIPADDRESS}"
    fi
    while :
    do
      read -r -e -i "${PRIVIPADDRESS}" -p "Private IPv4 Address: " input 2>&1
      PRIVIPADDRESS="${input:-$PRIVIPADDRESS}"
      if VALID_IP "${PRIVIPADDRESS}"
      then
        break;
      else
        echo "${PRIVIPADDRESS} is not a valid IP"
        PRIVIPADDRESS="$( ip route get 8.8.8.8 | sed 's/ uid .*//' | awk '{print $NF; exit}' )"
      fi
    done
  fi

  # Get port if user want's to supply one.
  echo
  echo "Recommended you leave this blank to have script pick a free port automatically"
  while :
  do
    read -r -e -i "${PORTB}" -p "Port: " input 2>&1
    PORTB="${input:-$PORTB}"
    if [ -z "${PORTB}" ]
    then
      break
    else
      if PORT_IS_OK "${PORTB}"
      then
        break
      else
        PORTB=''
      fi
    fi
  done

  # Get private key if user want's to supply one.
  echo
  echo "Recommend you leave this blank to have script automatically generate one"
  read -r -e -i "${MNKEY}" -p "${MASTERNODE_CALLER}privkey: " input 2>&1
  MNKEY="${input:-$MNKEY}"
else
  echo "Using the above default values."
fi

echo
echo "Starting the ${DAEMON_NAME} install process; please wait for this to finish."
echo "The script ends when you see the big string to add to the ${MASTERNODE_CALLER}.conf file."
echo "Let the script run and keep your terminal open."
echo
read -r -t 10 -p "Hit ENTER to continue or wait 10 seconds" 2>&1
echo
sudo true

# Find running daemons to copy from for faster sync.
# shellcheck disable=SC2009
RUNNING_DAEMON_USERS=$( sudo ps axo etimes,user:80,command | grep "${DAEMON_GREP}" | grep -v "bash" | grep -v "watch" | awk '$1 > 10' | awk '{ print $2 }' )
ALL_DAEMON_USERS=''

# Load in functions
if [ -z "${PS1}" ]
then
  PS1="\\"
fi
cd ~ || return 1 2>/dev/null
# shellcheck source=/root/.bashrc
source ~/.bashrc
if [ "${PS1}" == "\\" ]
then
  PS1=''
fi

# Find daemons with bash functions
ALL_USERS_IN_HOME=$( sudo find /home/* -maxdepth 0 -type d 2>/dev/null | tr '/' ' ' | awk '{print $2}' )
while read -r MN_USRNAME
do
  IS_EMPTY=$( type "${MN_USRNAME}" 2>/dev/null )
  if [ ! -z "${IS_EMPTY}" ]
  then
    if [[ -z "${ALL_DAEMON_USERS}" ]]
    then
      ALL_DAEMON_USERS="${MN_USRNAME}"
    else
      ALL_DAEMON_USERS=$( printf "%s\n%s" "${ALL_DAEMON_USERS}" "${MN_USRNAME}" )
    fi
  fi
done <<< "${ALL_USERS_IN_HOME}"

# Find running damons with matching bash functions
RUNNING_DAEMON_USERS=$( echo "${RUNNING_DAEMON_USERS}" | sort )
ALL_DAEMON_USERS=$( echo "${ALL_DAEMON_USERS}" | sort )
BOTH_LISTS=$( sort <( echo "${RUNNING_DAEMON_USERS}" | tr " " "\n" ) <( echo "${ALL_DAEMON_USERS}" | tr " " "\n" )| uniq -d | grep -Ev "^$" )

# Make sure daemon has the correct block count.
while read -r GOOD_MN_USRNAME
do
  if [[ -z "${GOOD_MN_USRNAME}" ]] || [[ "${GOOD_MN_USRNAME}" == 'root' ]]
  then
    break
  fi
  echo "Checking ${GOOD_MN_USRNAME}"
  if [[ $( "${GOOD_MN_USRNAME}" blockcheck 2>/dev/null | wc -l ) -eq 1 ]]
  then
    # Generate key and stop master node.
    if [ -z "${MNKEY}" ]
    then
      echo "Generate ${MASTERNODE_CALLER} genkey on ${GOOD_MN_USRNAME}"
      MNKEY=$( "${GOOD_MN_USRNAME}" "${MASTERNODE_CALLER}" genkey )
    fi

    # If daemon is slow and we have BLOCKS_N_CHAINS then don't stop n copy.
    if [[ "${SLOW_DAEMON_START}" -eq 1 ]] && [[ ! -z "${DROPBOX_BLOCKS_N_CHAINS}" ]]
    then
      break;
    fi

    # Copy this Daemon.
    echo "Stopping ${GOOD_MN_USRNAME}"
    "${GOOD_MN_USRNAME}" stop >/dev/null 2>&1

    while [[ $( sudo lslocks | grep -cF "${GOOD_MN_USRNAME}/${DIRECTORY}" ) -ne 0 ]]
    do
      echo -e "\r${SP:i++%${#SP}:1} Waiting for ${GOOD_MN_USRNAME} to shutdown \c"
      sleep 0.3
    done
    echo

    echo "Coping /home/${GOOD_MN_USRNAME} to /home/${USRNAME} for faster sync."
    sudo rm -rf /home/"${USRNAME:?}"
    sudo cp -r /home/"${GOOD_MN_USRNAME}" /home/"${USRNAME}"
    sleep 0.1
    echo "Starting ${GOOD_MN_USRNAME}"
    "${GOOD_MN_USRNAME}" start >/dev/null 2>&1
    sleep 0.2
    FAST_SYNC=1
    break
  fi
done <<< "${BOTH_LISTS}"

sudo true
if [[ "${FAST_SYNC}" -eq 1 ]]
then
  DAEMON_DOWNLOAD_SUPER "${GITHUB_REPO}" "${BIN_BASE}" "${DAEMON_DOWNLOAD}"
(
  INITIAL_PROGRAMS >/dev/null 2>&1
  SYSTEM_UPDATE_UPGRADE >/dev/null 2>&1
) & disown >/dev/null 2>&1
else
  INITIAL_PROGRAMS
  COUNTER=0
  while [[ $( ldd /var/multi-masternode-data/"${PROJECT_DIR}"/src/"${DAEMON_BIN}" | grep -cF 'not found' ) -ne 0 ]] || [[ $( ldd /var/multi-masternode-data/"${PROJECT_DIR}"/src/"${CONTROLLER_BIN}" | grep -cF 'not found' ) -ne 0 ]]
  do
    sudo dpkg -D1 --configure -a
    sleep 1
    sudo pkill dpkg
    sudo pkill apt
    sudo pkill apt-get
    sleep 1
    ((COUNTER++))
    if [[ "${COUNTER}" -gt 2 ]]
    then
      echo
      echo "The following shared objects are missing for ${DAEMON_BIN}."
      ldd /var/multi-masternode-data/"${PROJECT_DIR}"/src/"${DAEMON_BIN}" | grep -F 'not found'
      echo "The following shared objects are missing for ${CONTROLLER_BIN}"
      ldd /var/multi-masternode-data/"${PROJECT_DIR}"/src/"${CONTROLLER_BIN}" | grep -F 'not found'
      echo
      echo "reboot this linux instace by running: "
      echo "reboot"
      echo "and the try installing again."
      echo
      echo "If this exact same issue keeps happening please let mcarper know in discord."
      echo "The contents of ${DAEMON_SETUP_LOG} can be viewed by running this."
      echo "cat ${DAEMON_SETUP_LOG}"
      echo
      break
    fi
    echo "Trying for the ${COUNTER} time."
    INITIAL_PROGRAMS
  done

  ( SYSTEM_UPDATE_UPGRADE >/dev/null 2>&1 ) & disown >/dev/null 2>&1
fi

if [ ! -f /var/multi-masternode-data/"${PROJECT_DIR}"/src/"${DAEMON_BIN}" ] || [ ! -f /var/multi-masternode-data/"${PROJECT_DIR}"/src/"${CONTROLLER_BIN}" ]
then
  echo
  echo "Daemon download and install failed. "
  echo /var/multi-masternode-data/"${PROJECT_DIR}"/src/"${DAEMON_BIN}"
  echo /var/multi-masternode-data/"${PROJECT_DIR}"/src/"${DAEMON_BIN}"
  echo "Do not exist."
  echo
  return 1 2>/dev/null || exit 1
fi

# Set new user password to a big string.
sudo true
if ! sudo useradd -m "${USRNAME}" -s /bin/bash 2>/dev/null
then
  if ! sudo useradd -g "${USRNAME}" -m "${USRNAME}" -s /bin/bash 2>/dev/null
  then
    echo
    echo "User ${USRNAME} exists. Please start this script over."
    echo
    return 1 2>/dev/null || exit 1
  fi
fi
sudo cp -r /etc/skel/. /home/"${USRNAME}"

if [ -f "/var/spool/cron/crontabs/${USRNAME}" ]
then
  sudo chown "${USRNAME}:${USRNAME}" "/var/spool/cron/crontabs/${USRNAME}"
fi

echo
UNCOUNTER=44
if ! [ -x "$( command -v pwgen )" ]
then
  USERPASS=$( openssl rand -hex 44 )
  while [[ $( echo "${USRNAME}:${USERPASS}" | sudo chpasswd 2>&1 | wc -l ) -ne 0 ]]
  do
    UNCOUNTER=$(( UNCOUNTER+1 ))
    USERPASS=$( openssl rand -hex  "${UNCOUNTER}" )
  done
else
  USERPASS=$( pwgen -1 -s 44 )
  while [[ $( echo "${USRNAME}:${USERPASS}" | sudo chpasswd 2>&1 | wc -l ) -ne 0 ]]
  do
    UNCOUNTER=$(( UNCOUNTER+1 ))
    USERPASS=$( pwgen -1 -ys "${UNCOUNTER}" )
  done
fi

# Good starting point is the home dir.
cd ~/ || return 1 2>/dev/null

# Update system clock.
sudo timedatectl set-ntp off
sudo timedatectl set-ntp on
# Increase open files limit.
ulimit -n 32768
if ! grep -Fxq "* hard nofile 32768" /etc/security/limits.conf
then
  echo "* hard nofile 32768" | sudo tee -a /etc/security/limits.conf >/dev/null
fi
if ! grep -Fxq "* soft nofile 32768" /etc/security/limits.conf >/dev/null
then
  sudo echo "* soft nofile 32768" | sudo tee -a /etc/security/limits.conf >/dev/null
fi
if ! grep -Fxq "root hard nofile 32768" /etc/security/limits.conf >/dev/null
then
  sudo echo "root hard nofile 32768" | sudo tee -a /etc/security/limits.conf >/dev/null
fi
if ! grep -Fxq "root soft nofile 32768" /etc/security/limits.conf >/dev/null
then
  sudo echo "root soft nofile 32768" | sudo tee -a /etc/security/limits.conf >/dev/null
fi

# m c a r p e r
USER_FUNCTION_FOR_MASTERNODE "${USRNAME}" "${HOME}/.bashrc" "/var/multi-masternode-data/___temp.sh"

# Load in the bash function into this instance.
if [ -z "${PS1}" ]
then
  PS1="\\"
fi
# shellcheck source=/root/.bashrc
source ~/.bashrc
if [ "${PS1}" == "\\" ]
then
  PS1=''
fi

IS_EMPTY=$( type "${USRNAME}" 2>/dev/null )
if [ -z "${IS_EMPTY}" ]
then
  # shellcheck disable=SC1091
  . /var/multi-masternode-data/___temp.sh
fi

# Copy daemon code to new users home dir.
echo "Copy daemon code to /home/${USRNAME}/.local/bin"
sudo mkdir -p /home/"${USRNAME}"/.local/bin
sudo cp /var/multi-masternode-data/"${PROJECT_DIR}"/src/"${DAEMON_BIN}" /home/"${USRNAME}"/.local/bin/
sudo chmod +x /home/"${USRNAME}"/.local/bin/"${DAEMON_BIN}"
sudo cp /var/multi-masternode-data/"${PROJECT_DIR}"/src/"${CONTROLLER_BIN}" /home/"${USRNAME}"/.local/bin/
sudo chmod +x /home/"${USRNAME}"/.local/bin/"${CONTROLLER_BIN}"

# Generate random password.
if ! [ -x "$( command -v pwgen )" ]
then
  PWA="$( openssl rand -hex 44 )"
else
  PWA="$( pwgen -1 -s 44 )"
fi

# Create new config.
PROFILE_FIX=$( cat << "PROFILE_FIX"

# set PATH so it includes users private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi
PROFILE_FIX
)

if [ -d "/home/${USRNAME}/${DIRECTORY}/" ]
then
  sudo chown -R "${USRNAME}":"${USRNAME}" "/home/${USRNAME}/"
  sleep 0.2
  if [[ ! -f "/home/${USRNAME}/.profile" ]]
  then
    sudo su - "${USRNAME}" -c "/home/${USRNAME}/.profile"
  fi
  if [[ $( grep -cF "PATH=\"\$HOME/.local/bin:\$PATH\"" "/home/${USRNAME}/.profile" ) -ne 1 ]]
  then
    echo "Adding"
    echo "${PROFILE_FIX}" | sudo tee -a "/home/${USRNAME}/.profile" >/dev/null
  fi
fi

# Make sure daemon data folder exists
sudo su - "${USRNAME}" -c "mkdir -p /home/${USRNAME}/${DIRECTORY}/"
sudo chown -R "${USRNAME}":"${USRNAME}" "/home/${USRNAME}/"
# Remove old conf and create new conf
sudo rm -f "/home/${USRNAME}/${DIRECTORY}/${CONF}"
sudo su - "${USRNAME}" -c "touch /home/${USRNAME}/${DIRECTORY}/${CONF}"

if [[ "${FAST_SYNC}" -ne 1 ]]
then
  if [[ ! -z "${DROPBOX_BLOCKS_N_CHAINS}" ]]
  then
    "${USRNAME}" dl_blocks_n_chains
  fi

  if [[ ! -d /var/multi-masternode-data/"${PROJECT_DIR}"/blocks_n_chains/blocks/ ]] && [[ ! -z "${DROPBOX_BOOTSTRAP}" ]] && [[ "${USE_DROPBOX_BOOTSTRAP}" -eq 1 ]]
  then
    "${USRNAME}" dl_bootstrap
  fi
  sudo chown -R "${USRNAME}:${USRNAME}" /home/"${USRNAME}"/"${DIRECTORY}"/
fi

# Setup systemd to start masternode on restart.
TIMEOUT='30s'
if [[ "${SLOW_DAEMON_START}" -eq 1 ]]
then
  TIMEOUT='240s'
fi

echo "Creating systemd ${MASTERNODE_CALLER} service for ${DAEMON_NAME}"
cat << SYSTEMD_CONF | sudo tee /etc/systemd/system/"${USRNAME}".service >/dev/null
[Unit]
Description=${DAEMON_NAME} ${MASTERNODE_CALLER} for user ${USRNAME}
After=network.target

[Service]
Type=forking
User=${USRNAME}
WorkingDirectory=/home/${USRNAME}
PIDFile=/home/${USRNAME}/${DIRECTORY}/${DAEMON_BIN}.pid
ExecStart=/home/${USRNAME}/.local/bin/${DAEMON_BIN} --daemon
ExecStartPost=/bin/sleep 1
ExecStop=/home/${USRNAME}/.local/bin/${CONTROLLER_BIN} stop
Restart=always
RestartSec=${TIMEOUT}
TimeoutSec=${TIMEOUT}

[Install]
WantedBy=multi-user.target
SYSTEMD_CONF
sudo systemctl daemon-reload

# Make sure ports are still open.
if [[ "$( sudo ss -lpn 2>/dev/null | grep -c ":${PORTB}\s" )" -eq 1 ]]
then
  echo "Searching for an unused port for daemon"
  while :
  do
    PORTB=$( shuf -i "${LOWERPORT}"-"${UPPERPORT}" -n 1 )
    sudo ss -lpn 2>/dev/null | grep -q ":${PORTB} " || break
  done
fi
if [[ "$( sudo ss -lpn 2>/dev/null | grep -c ":${PORTA}\s" )" -eq 1 ]]
then
  echo "Searching for an unused port for rpc"
  while :
  do
    PORTA=$( shuf -i "${LOWERPORT}"-"${UPPERPORT}" -n 1 )
    sudo ss -lpn 2>/dev/null | grep -q ":${PORTA} " || break
  done
fi

if [[ "$( sudo ufw status | grep -v '(v6)' | awk '{print $1}' | grep -c "^${PORTB}$" )" -eq 0 ]]
then
  sudo ufw allow "${PORTB}"
fi
echo "y" | sudo ufw enable >/dev/null 2>&1
sudo ufw reload

# Create conf file.
cat << COIN_CONF | sudo tee /home/"${USRNAME}"/"${DIRECTORY}"/"${CONF}" >/dev/null
rpcuser=${RPC_USERNAME}_rpc_${USRNAME}
rpcpassword=${PWA}
rpcallowip=127.0.0.1
rpcport=${PORTA}
server=1
daemon=1
externalip=${PUBIPADDRESS}:${PORTB}
bind=${PRIVIPADDRESS}:${PORTB}
${EXTRA_CONFIG}
# nodelist=${DROPBOX_ADDNODES}
# bootstrap=${DROPBOX_BOOTSTRAP}
# blocks_n_chains=${DROPBOX_BLOCKS_N_CHAINS}
# github_repo=${GITHUB_REPO}
# bin_base=${BIN_BASE}
# daemon_download=${DAEMON_DOWNLOAD}
# masternode_caller=${MASTERNODE_CALLER}
# masternode_prefix=${MASTERNODE_PREFIX}
COIN_CONF

if [[ "${MULTI_IP_MODE}" -ne 0 ]]
then
  echo "# defaultport=${DEFAULT_PORT}" | sudo tee -a /home/"${USRNAME}"/"${DIRECTORY}"/"${CONF}" >/dev/null
fi
if [ ! -z "${TXHASH}" ]
then
  echo "# txhash=${TXHASH}" | sudo tee -a /home/"${USRNAME}"/"${DIRECTORY}"/"${CONF}" >/dev/null
fi
if [ ! -z "${OUTPUTIDX}" ]
then
  echo "# outputidx=${OUTPUTIDX}" | sudo tee -a /home/"${USRNAME}"/"${DIRECTORY}"/"${CONF}" >/dev/null
fi

# Get addnode section for the config file.
# m c a r p e r
if [[ "${FAST_SYNC}" -ne 1 ]] && [[ "${USE_DROPBOX_ADDNODES}" -eq 1 ]]
then
  "${USRNAME}" dl_addnode
fi

if [ ! -z "${MNKEY}" ]
then
  # Add private key to config and make masternode.
  "${USRNAME}" privkey "${MNKEY}"
else
  # Use connect for sync that doesn't drop out.
  if [[ $( "${USRNAME}" conf | grep -c 'addnode' ) -gt "${DAEMON_CONNECTIONS}" ]]
  then
    "${USRNAME}" addnode_to_connect
  fi
fi

IS_EMPTY=$( type "DAEMON_PRE_RUN" 2>/dev/null )
if [ ! -z "${IS_EMPTY}" ]
then
  DAEMON_PRE_RUN "${USRNAME}"
fi

# Run daemon as the user mn1 and update block-chain.
echo
echo -e "\r\c"
stty sane 2>/dev/null
sudo true
echo "Starting the daemon."
"${USRNAME}" start
sudo true
"${USRNAME}" "sync" "${BLOCKCOUNT_FALLBACK_VALUE}"

# Get privkey from conf.
MNKEY=$( "${USRNAME}" privkey )

# Generate key and stop master node.
if [ -z "${MNKEY}" ]
then
  echo "Generate ${MASTERNODE_CALLER} genkey on ${USRNAME}"
  MNKEY=$( "${USRNAME}" "${MASTERNODE_CALLER}" genkey )
  echo "Stopping ${USRNAME}"
  "${USRNAME}" stop >/dev/null 2>&1
  "${USRNAME}" privkey "${MNKEY}" >/dev/null 2>&1

  if [[ "${DAEMON_CYCLE}" -eq 1 ]]
  then
    echo "Cycling the daemon on and off."
    "${USRNAME}" restart >/dev/null 2>&1
    "${USRNAME}" stop >/dev/null 2>&1
  fi

  # Start daemon.
  "${USRNAME}" connect_to_addnode
  echo "Starting the daemon."
  "${USRNAME}" start

else
  if [[ "${DAEMON_CYCLE}" -eq 1 ]]
  then
    echo "Cycling the daemon on and off."
    "${USRNAME}" restart >/dev/null 2>&1
  fi
fi
# Enable masternode to run on system start.
sudo systemctl enable "${USRNAME}" 2>&1

# Wait for daemon.
if [[ "${SLOW_DAEMON_START}" -eq 1 ]]
then
  CPU_USAGE=$( mpstat 1 1 | awk '$3 ~ /CPU/ { for(i=1;i<=NF;i++) { if ($i ~ /%idle/) field=i } } $3 ~ /all/ { printf("%d",100 - $field) }' )
  while [[ "${CPU_USAGE}" -gt 50 ]]
  do
    echo -e "\r${SP:i++%${#SP}:1} Waiting for the daemon to be ready \c"
    CPU_USAGE=$( mpstat 1 1 | awk '$3 ~ /CPU/ { for(i=1;i<=NF;i++) { if ($i ~ /%idle/) field=i } } $3 ~ /all/ { printf("%d",100 - $field) }' )
    sleep 0.1
  done
fi

# Output firewall info.
echo
sudo ufw status
sleep 1

if [[ ! -z "${MNSYNC_WAIT_FOR}" ]]
then
  sudo true
  while [[ $( "${USRNAME}" "${MASTERNODE_PREFIX}sync" status | grep -cF "${MNSYNC_WAIT_FOR}" ) -eq 0 ]]
  do
    echo -e "\r${SP:i++%${#SP}:1} Waiting for ${MASTERNODE_PREFIX}sync status to be ${MNSYNC_WAIT_FOR} \c"
    sleep 0.5
  done
  echo
  sudo true
fi

# Output masternode info.
"${USRNAME}" "${MASTERNODE_CALLER}" status
"${USRNAME}" "${MASTERNODE_CALLER}" debug
sleep 1

IS_EMPTY=$( type "SENTINEL_SETUP" 2>/dev/null )
if [ ! -z "${IS_EMPTY}" ]
then
  sudo true
  SENTINEL_SETUP "${USRNAME}"
fi

if [[ ! -z "${TXHASH}" ]] && [[ ! -z "${EXPLORER_URL}" ]] && [[ ! "${EXPLORER_URL}" == https://www.coinexplorer.net/api/v1/* ]]
then
  echo "Downloading transaction from the explorer."
  OUTPUTIDX_RAW=$( wget -4qO- -T 15 -t 2 -o- "${EXPLORER_URL}api/getrawtransaction?txid=${TXHASH}&decrypt=1" "${BAD_SSL_HACK}" | tr '[:upper:]' '[:lower:]' )
  sleep "${EXPLORER_SLEEP}"
  TXID_CONFIRMATIONS=$( echo "${OUTPUTIDX_RAW}" | jq ".confirmations" )
  if [[ -z "${TXID_CONFIRMATIONS}" ]]
  then
    TXID_CONFIRMATIONS=1
  fi
  echo
fi

if [[ "${MULTI_IP_MODE}" -eq 0 ]]
then
  DEFAULT_PORT="${PORTB}"
fi

# Add Crontab if not set.
touch /var/multi-masternode-data/.bashrc
chmod 666 /var/multi-masternode-data/.bashrc
sudo cp ~/.bashrc /var/multi-masternode-data/.bashrc
if [[ $( crontab -l | grep -cF "cp ${HOME}/.bashrc /var/multi-masternode-data/.bashrc" ) -eq 0  ]]
then
  ( crontab -l ; echo "0 * * * * cp ${HOME}/.bashrc /var/multi-masternode-data/.bashrc" ) | crontab -
fi

if [[ $( sudo su - "${USRNAME}" -c 'crontab -l' | grep -cF "${USRNAME} update_daemon 2>&1" ) -eq 0  ]]
then
  echo 'Setting up crontab for auto update'
  MINUTES=$((RANDOM % 60))
  sudo su - "${USRNAME}" -c " ( crontab -l ; echo \"${MINUTES} */6 * * * bash -ic 'source /var/multi-masternode-data/.bashrc; ${USRNAME} update_daemon 2>&1'\" ) | crontab - "
fi

if [[ $( sudo su - "${USRNAME}" -c 'crontab -l' | grep -cF "${USRNAME} mnfix 2>&1" ) -eq 0  ]]
then
  echo 'Setting up crontab to auto fix the daemon'
  MINUTES=$(( RANDOM % 19 ))
  MINUTES_A=$(( MINUTES + 20 ))
  MINUTES_B=$(( MINUTES + 40 ))
  sudo su - "${USRNAME}" -c " ( crontab -l ; echo \"${MINUTES},${MINUTES_A},${MINUTES_B} * * * * bash -ic 'source /var/multi-masternode-data/.bashrc; ${USRNAME} mnfix 2>&1'\" ) | crontab - "
fi

# Show crontab contents.
sudo su - "${USRNAME}" -c 'crontab -l'
touch "${DAEMON_SETUP_INFO}"

IS_EMPTY=$( type "DAEMON_POST_RUN" 2>/dev/null )
if [ ! -z "${IS_EMPTY}" ]
then
  DAEMON_POST_RUN "${USRNAME}"
fi

# Output more info.
echo
echo "Password for ${USRNAME} is"
echo "${USERPASS}"
echo "Commands to control the daemon"
echo "${USRNAME} status"
echo "${USRNAME} start"
echo "${USRNAME} restart"
echo "${USRNAME} stop"
echo
RUNNING_PORTS=$( sudo lslocks | tail -n +2 | awk '{print $2 "/"}' | sort -u | while read -r PID; do sudo netstat -tulpn | grep "${PID}" | grep -v -E 'tcp6|:25\s' | awk '{print $4}' | cut -d ':' -f2; done )
OPEN_PORTS=$( sudo ufw status | grep -v '(v6)' | tail -n +5 | awk '{print $1}' )
BOTH_LISTS=$( sort <( echo "$RUNNING_PORTS" | tr " " "\n" ) <( echo "$OPEN_PORTS" | tr " " "\n" ) | uniq -d )
MISSING_FIREWALL_RULES=$( sort <( echo "$RUNNING_PORTS" | tr " " "\n" ) <( echo "$BOTH_LISTS" | tr " " "\n" ) | uniq -u )
if [[ $( echo "${MISSING_FIREWALL_RULES}" | wc -w ) -ne 0 ]]
then
  echo "NOTICE: If you are running another masternode on the vps make sure to open any ports needed with this command:"
  sudo lslocks | tail -n +2 | awk '{print $2 "/"}' | sort -u | while read -r PID
  do
    MISSING_FIREWALL_RULE=$( sudo netstat -tulpn | grep "${PID}" | grep -v -E 'tcp6|:25\s' | grep ":${MISSING_FIREWALL_RULES}" | awk '{print $4 "\t\t" $7}' )
    if [ ! -z "${MISSING_FIREWALL_RULE}" ]
    then
      MISSING_PORT=$( echo "${MISSING_FIREWALL_RULE}" | awk '{print $1}' | cut -d ':' -f2 )
      echo "sudo ufw allow ${MISSING_PORT}"
    fi
  done
  echo
fi
echo "Alternative ways to issue commands via ${CONTROLLER_BIN}"
echo "/home/${USRNAME}/.local/bin/${CONTROLLER_BIN} -datadir=/home/${USRNAME}/${DIRECTORY}/"
echo "sudo su - ${USRNAME} -c '${CONTROLLER_BIN} '"
echo
echo "# Send a tip in ${TICKER} to mc for making this script"
echo "${TIPS}"
echo
echo "Check if master node started remotely"
echo "${USRNAME} ${MASTERNODE_CALLER} debug"
echo "${USRNAME} ${MASTERNODE_CALLER} status"
echo
echo "Keep this terminal open until you have started the ${MASTERNODE_CALLER} from your wallet. "
echo "If ${MASTERNODE_PREFIX} start was successful you should see this message displayed in this shell: "
echo "'${MASTERNODE_CALLER} ${USRNAME} started remotely'. "
echo "If you do not see that message, then start it again from your wallet."
echo "IP and port daemon is using"
echo -e "${PUBIPADDRESS}:${PORTB}"
echo
echo "${MASTERNODE_CALLER}privkey"
"${USRNAME}" privkey
echo
if [ ! -z "${TXID_CONFIRMATIONS}" ] && [ "${TXID_CONFIRMATIONS}" -lt 16 ]
then
  echo -e "\\e[4mTXID: ${TXHASH} \\e[0m"
  echo -e "\\e[4mis only ${TXID_CONFIRMATIONS} bolcks old. \\e[0m"
  echo -e "\\e[1;4mWait until the txid is 16 blocks old before starting the ${MASTERNODE_PREFIX}. \\e[0m"
  echo
fi
echo "You might need to add this to your desktop wallet ${CONF}"
echo "file in order to start the ${MASTERNODE_CALLER}"
REMOTE_IP=$( who | tr '()' ' ' | awk '{print $5}' | head -n1 )
echo "externalip=${REMOTE_IP}"
echo
echo "Command to start the ${MASTERNODE_CALLER} from the "
echo "desktop/hot/control wallet's debug console:"
echo -e "\\e[1mstart${MASTERNODE_CALLER} alias false ${USRNAME}_${MNALIAS}\\e[0m"
echo "or"
echo -e "\\e[1m${MASTERNODE_CALLER} start-alias ${USRNAME}_${MNALIAS}\\e[0m"
echo
# Print masternode.conf string.
echo "The line that goes into ${MASTERNODE_CALLER}.conf will have 4 spaces total."
echo "You will need to restart the desktop wallet for the ${MASTERNODE_CALLER} to appear."
if [ ! -z "${TXHASH}" ]
then
  echo "Full string to paste into ${MASTERNODE_CALLER}.conf (all on one line)."
  echo -e "\\e[1;4m${USRNAME}_${MNALIAS} ${PUBIPADDRESS}:${DEFAULT_PORT} ${MNKEY} ${TXHASH} ${OUTPUTIDX}\\e[0m"
  echo "${USRNAME}_${MNALIAS} ${PUBIPADDRESS}:${DEFAULT_PORT} ${MNKEY} ${TXHASH} ${OUTPUTIDX}" >> "${DAEMON_SETUP_INFO}"
else
  echo "There is almost a full string to paste into the ${MASTERNODE_CALLER}.conf file."
  echo -e "Run \\e[4m${MASTERNODE_CALLER} outputs\\e[0m and add the txhash and outputidx to the line below."
  echo "The values when done will be all on one line with 4 spaces total."
  echo -e "\\e[1;4m${USRNAME}_${MNALIAS} ${PUBIPADDRESS}:${DEFAULT_PORT} ${MNKEY}\\e[0m"
  echo "${USRNAME}_${MNALIAS} ${PUBIPADDRESS}:${DEFAULT_PORT} ${MNKEY} " >> "${DAEMON_SETUP_INFO}"
fi
echo

if [ -z "${SKIP_CONFIRM}" ] && [[ "${MINI_MONITOR_RUN}" -ne 0 ]]
then
  # Start sub process mini monitor that will exit once masternode has started.
  (
  # Load in the bash function into this instance.
  if [ -z "${PS1}" ]
  then
    PS1="\\"
  fi
  cd ~/ || return 1
  # shellcheck source=/root/.bashrc
  source ~/.bashrc
  if [ "${PS1}" == "\\" ]
  then
    PS1=''
  fi

  IS_EMPTY=$( type "${USRNAME}" 2>/dev/null )
  if [ -z "${IS_EMPTY}" ]
  then
    # shellcheck disable=SC1091
    . /var/multi-masternode-data/___temp.sh
  fi

  COUNTER=0
  while :
  do
    # Break out of loop if daemon gets deleted.
    if [ ! -f /home/"${USRNAME}"/.local/bin/"${DAEMON_BIN}" ]
    then
      break
    fi

    # Additional checks if the txhash and output index are here.
    if [[ ! -z "${TXHASH}" ]] && [[ ! -z "${OUTPUTIDX}" ]] && [[ ! -z "${EXPLORER_URL}" ]] && [[ ! "${EXPLORER_URL}" == https://www.coinexplorer.net/api/v1/* ]]
    then
      # Check the collateral once every 2 minutes.
      COUNTER=$(( COUNTER - 1 ))
      if [[ ${COUNTER} =~ ${RE} ]] && [[ "${COUNTER}" -eq 24 ]]
      then
        COUNTER=0
        OUTPUTIDX_RAW=$( wget -4qO- -T 15 -t 2 -o- "${EXPLORER_URL}api/getrawtransaction?txid=${TXHASH}&decrypt=1" "${BAD_SSL_HACK}" )
        sleep "${EXPLORER_SLEEP}"
        MN_WALLET_ADDR=$( echo "$OUTPUTIDX_RAW" | tr '[:upper:]' '[:lower:]' | jq -r ".vout[] | select( .n == ${OUTPUTIDX} ) | .scriptpubkey.addresses | .[] " 2>/dev/null )
        MN_WALLET_ADDR=$( echo "$OUTPUTIDX_RAW" | grep -io "${MN_WALLET_ADDR}" )
        MN_WALLET_ADDR_DETAILS=$( wget -4qO- -T 15 -t 2 -o- "${EXPLORER_URL}ext/getaddress/${MN_WALLET_ADDR}" "${BAD_SSL_HACK}" | tr '[:upper:]' '[:lower:]' )
        sleep "${EXPLORER_SLEEP}"
        MN_WALLET_ADDR_BALANCE=$( echo "${MN_WALLET_ADDR_DETAILS}" | jq -r ".balance" 2>/dev/null )

        if [[ $( echo "${MN_WALLET_ADDR_BALANCE}<${COLLATERAL}" | bc ) -eq 1 ]]
        then
          echo
          echo "txhash no longer holds the collateral; moved: ${TXHASH}."
          echo
          TXHASH=''
          OUTPUTIDX=''
          continue
        fi

        # Make sure it didn't get staked.
        TXIDS_AFTER_COLLATERAL=$( echo "${MN_WALLET_ADDR_DETAILS}" | jq -r ".last_txs[][] " 2>/dev/null | grep -vE "vin|vout" | sed -n -e "/${TXHASH}/,\$p" | grep -v "${TXHASH}" )
        if [ ! -z "${TXIDS_AFTER_COLLATERAL}" ]
        then
          # Check each tx after the given tx to see if it was used as an input.
          while read -r OTHERTXIDS
          do
            OUTPUTIDX_RAW=$( wget -4qO- -T 15 -t 2 -o- "${EXPLORER_URL}api/getrawtransaction?txid=${OTHERTXIDS}&decrypt=1" "${BAD_SSL_HACK}" | tr '[:upper:]' '[:lower:]' )
            sleep "${EXPLORER_SLEEP}"
            if [[ $( echo "$OUTPUTIDX_RAW" | jq ".vin[] | select( .txid == \"${TXHASH}\" )" 2>/dev/null | wc -c ) -gt 0 ]]
            then
              echo
              echo "txid no longer holds the collateral; staked: ${TXHASH}."
              echo
              TXHASH=''
              OUTPUTIDX=''
              break
            fi
          done <<< "${TXIDS_AFTER_COLLATERAL}"
        fi
      fi

      # Check txhash and output index for negative active time.
      if [[ "${MINI_MONITOR_MN_LIST}" -eq 1 ]]
      then
        MNACTIVETIME=$( "${USRNAME}" "${MASTERNODE_CALLER}" list 2>/dev/null | \
          jq --arg OUTPUTIDX "${OUTPUTIDX}" --arg TXHASH "${TXHASH}" \
          ".[] | select( .txhash == \"${TXHASH}\" and .outidx == ${OUTPUTIDX} ) | .activetime" 2>/dev/null )
        if [ ! -z "${MNACTIVETIME}" ] && [ "${MNACTIVETIME}" -lt "0" ]
        then
          echo "${USRNAME}_${MNALIAS}"
          echo "Start ${MASTERNODE_CALLER} again from desktop wallet."
          echo "Please wait for your transaction to be older than 16 blocks and try again."
          echo "You might need to restart the daemon by running this on the vps"
          echo
          echo "${USRNAME} restart"
          echo
          echo "Activetime for the ${MASTERNODE_CALLER} was negative ${MNACTIVETIME}"
           "${USRNAME}" "${MASTERNODE_CALLER}" list 2>/dev/null | \
            jq --arg OUTPUTIDX "${OUTPUTIDX}" --arg TXHASH "${TXHASH}" \
            ".[] | select( .txhash == \"${TXHASH}\" and .outidx == ${OUTPUTIDX} )" 2>/dev/null
          echo
          sleep 60
        fi
      fi
    fi

    # Check status number.
    MNSTATUS=$( "${USRNAME}" "${MASTERNODE_CALLER}" status 2>/dev/null | jq -r '.status' 2>/dev/null )
    if [ ! -z "${MNSTATUS}" ] && [ "${MNSTATUS}" == "${MINI_MONITOR_MN_STATUS}" ]
    then
      MNCOUNT=$( "${USRNAME}" "${MASTERNODE_CALLER}" count 2>/dev/null )
      if [[ "${MINI_MONITOR_MN_COUNT_JSON}" -eq 1 ]]
      then
        MNCOUNT=$( echo "${MNCOUNT}" | jq -r '.total' 2>/dev/null )
      fi
      echo
      "${USRNAME}" "${MASTERNODE_CALLER}" status
      echo
      echo -e "\\e[1;4m ${MASTERNODE_CALLER} ${USRNAME} successfully started! \\e[0m"
      echo "This is ${MASTERNODE_CALLER} number ${MNCOUNT} in the network."
      if [[ "${MINI_MONITOR_MN_QUEUE}" -eq 1 ]]
      then
        MNHOURS=$( echo "${MNCOUNT} * ${BLOCKTIME} / 1200" | bc -l )
        printf "First payout will be in approximately %.*f hours\\n" 1 "${MNHOURS}"
      fi
      echo
      echo "Press Enter to continue"
      echo
      break
    fi

    # Restart masternode if not out of loop after 16 blocks.
    MN_UPTIME=$( "${USRNAME}" uptime 2>/dev/null | tr -d '[:space:]' )
    BLOCKS_16=$( echo "16 * ${BLOCKTIME}" | bc )
    if [ "${MN_UPTIME}" -gt "${BLOCKS_16}" ]
    then
      (
      "${USRNAME}" stop >/dev/null 2>&1
      "${USRNAME}" start >/dev/null 2>&1
      )
    fi
    sleep 5

  done
  return 1 2>/dev/null
  ) & disown
fi
stty sane 2>/dev/null
rm -f /var/multi-masternode-data/___temp.sh
sleep 1

}
stty sane 2>/dev/null
echo "Script Loaded."
# End of masternode setup script.
