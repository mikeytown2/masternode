DAEMON_BIN='energid'
  \#\!/bin/bash
  DAEMON_BIN='energid'
  \#\!/bin/bash
  DAEMON_BIN='energid'
  #!/bin/bash
# shellcheck disable=SC2031
# shellcheck disable=SC1091

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
stty sane 2>/dev/null

USRNAME=''
# Chars for spinner.
SP="/-\\|"
# Regex to check if output is a number.
RE='^[0-9]+$'
RE_FLOAT='^[+-]?([0-9]+\.?|[0-9]*\.[0-9]+)$'
# Set cli args
ARG1=${1}
ARG2=${2}
ARG3=${3}
ARG4=${4}
ARG5=${5}
ARG6=${6}

BITBUCKET_REGEX='^https://bitbucket\.org/+*'
# GITHUB_REGEX='^https://github\.com/+*'

if [[ -z "${MASTERNODE_CALLER}" ]]
then
  MASTERNODE_CALLER='masternode '
fi
if [[ -z "${MASTERNODE_NAME}" ]]
then
  MASTERNODE_NAME="${MASTERNODE_CALLER%% }"
fi
if [[ -z "${MASTERNODE_PREFIX}" ]]
then
  MASTERNODE_PREFIX='mn'
fi
if [[ -z "${MASTERNODE_GENKEY_COMMAND}" ]]
then
  MASTERNODE_GENKEY_COMMAND="${MASTERNODE_CALLER}genkey"
fi
if [[ -z "${MASTERNODE_PRIVKEY}" ]]
then
  MASTERNODE_PRIVKEY="${MASTERNODE_NAME}privkey"
fi
if [[ -z "${MASTERNODE_CONF}" ]]
then
  MASTERNODE_CONF="${MASTERNODE_NAME}.conf"
fi
if [[ -z "${MASTERNODE_LIST}" ]]
then
  MASTERNODE_LIST="${MASTERNODE_CALLER} list"
fi


# Blocktime in seconds.
if [[ -z "${BLOCKTIME}" ]]
then
  BLOCKTIME=60
fi

if [[ -z "${GIT_CDN}" ]]
then
  GIT_CDN='https://rawcdn.githack.com/'
fi

if [[ -z "${GIT_RAW}" ]]
then
  GIT_RAW='https://raw.githubusercontent.com/'
fi

if [[ -z "${GIT_PATH_PREFIX}" ]]
then
  GIT_PATH_PREFIX=''
fi

if [[ -z "${GIT_API}" ]]
then
  GIT_API='https://api.github.com/repos/'
fi

if [[ ! -z "${GITHUB_REPO}" ]]
then
  if [[ ${GITHUB_REPO} =~ ${BITBUCKET_REGEX} ]]
  then
    GITHUB_REPO="$( echo "${ARG2/'https://bitbucket.org/'/}" | sed 's/^\///g' | tr '/' ' ' | awk '{print $1 "/" $2}' | sed 's/\.git$//g' )"
    GIT_CDN='https://bb.githack.com/'
    GIT_RAW='https://bitbucket.org/'
    GIT_API='https://api.bitbucket.org/2.0/repositories/'
    GIT_PATH_PREFIX='/raw'
  fi
fi

if [[ "${ARG1}" == 'GENERATE_SCRIPT' ]]
then
  stty sane 2>/dev/null
  if [[ -z "${ARG2}" ]]
  then
    read -r -e -i "${ARG2}" -p "Github URL: " input 2>&1
    ARG2="${input:-$ARG2}"
  fi

  if [[ -z "${ARG3}" ]]
  then
    read -r -e -i "${ARG3}" -p "Explorer URL: " input 2>&1
    ARG3="${input:-$ARG3}"
  fi

  # extract the path
  if [[ ${ARG2} =~ ${BITBUCKET_REGEX} ]]
  then
    GITHUB_REPO="$( echo "${ARG2/'https://bitbucket.org/'/}" | sed 's/^\///g' | tr '/' ' ' | awk '{print $1 "/" $2}' | sed 's/\.git$//g' )"
    GIT_CDN='https://bb.githack.com/'
    GIT_RAW='https://bitbucket.org/'
    GIT_API='https://api.bitbucket.org/2.0/repositories/'
    GIT_PATH_PREFIX='/raw'
  fi

  if [[ -z "${GITHUB_REPO}" ]]
  then
    GITHUB_REPO="$( echo "${ARG2/'https://github.com/'/}" | sed 's/^\///g' | tr '/' ' ' | awk '{print $1 "/" $2}' | sed 's/\.git$//g' )"
  fi
  SENTINEL_GITHUB="$( echo "${GITHUB_REPO}" | cut -d '/' -f1 )"
  SENTINEL_GITHUB="${SENTINEL_GITHUB}/sentinel"

  _LIB_INIT=$( wget -4qO- -o- "${GIT_CDN}${SENTINEL_GITHUB}${GIT_PATH_PREFIX}/master/lib/init.py" )
  if [[ -z "${_LIB_INIT}" ]]
  then
    _LIB_INIT=$( wget -4qO- -o- "${GIT_RAW}${SENTINEL_GITHUB}${GIT_PATH_PREFIX}/master/lib/init.py" )
  fi
  if [[ -z "${_LIB_INIT}" ]]
  then
    SENTINEL_GITHUB="$( echo "${GITHUB_REPO}" | cut -d '/' -f1 )"
    echo "https://github.com/search?q=user%3A${SENTINEL_GITHUB}+sentinel&type=Repositories"
    SENTINEL_GITHUB=$( wget -4qO- -o- "https://github.com/search?q=user%3A${SENTINEL_GITHUB}+sentinel&type=Repositories" | hxclean | hxnormalize -x | hxselect -s '\n' '.repo-list h3 a' | grep -o "href=[\"\|']/${SENTINEL_GITHUB}/.*[\"\|']" | tr '"' ' ' | tr "'" ' ' | awk '{ print $2 }' | sed 's/^\///g' )
  fi
  if [[ ! -z "${SENTINEL_GITHUB}" ]]
  then
    echo "${GIT_CDN}${SENTINEL_GITHUB}${GIT_PATH_PREFIX}/master/lib/init.py"
    echo "${SENTINEL_GITHUB}"
    _LIB_INIT=$( wget -4qO- -o- "${GIT_CDN}${SENTINEL_GITHUB}${GIT_PATH_PREFIX}/master/lib/init.py" )
    if [[ -z "${_LIB_INIT}" ]]
    then
      _LIB_INIT=$( wget -4qO- -o- "${GIT_RAW}${SENTINEL_GITHUB}${GIT_PATH_PREFIX}/master/lib/init.py" )
    fi
  fi

  if [[ -z "${_LIB_INIT}" ]]
  then
    _SPORK_FILE=$( wget -4qO- -o- "${GIT_CDN}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/src/spork.cpp" )
    if [[ -z "${_CONFIGURE_AC}" ]]
    then
      _SPORK_FILE=$( wget -4qO- -o- "${GIT_RAW}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/src/spork.cpp" )
    fi
    if [[ $( echo "${_SPORK_FILE}" | grep -ci 'sentinel' ) -gt 0 ]]
    then
      SENTINEL_GITHUB='dashpay/sentinel'
      echo "${GIT_CDN}${SENTINEL_GITHUB}${GIT_PATH_PREFIX}/master/lib/init.py"
      echo "${SENTINEL_GITHUB}"
      _LIB_INIT=$( wget -4qO- -o- "${GIT_CDN}${SENTINEL_GITHUB}${GIT_PATH_PREFIX}/master/lib/init.py" )
      if [[ -z "${_LIB_INIT}" ]]
      then
        _LIB_INIT=$( wget -4qO- -o- "${GIT_RAW}${SENTINEL_GITHUB}${GIT_PATH_PREFIX}/master/lib/init.py" )
      fi
    fi
  fi

  # Get conf line.
  if [[ ! -z "${_LIB_INIT}" ]]
  then
    SENTINEL_CONF_START=$( echo "${_LIB_INIT}" | grep -Fi 'io.open(config.' | grep -o '(.*)' | sed 's/config\.//g' | tr '(' ' ' | tr ')' ' ' | awk '{print $1}' )
  fi
  EXPLORER_URL=${ARG3}
fi

FIRST_SYNC=0
if [[ "${ARG1}" == 'FIRST_SYNC' ]]
then
  FIRST_SYNC=1
fi

GET_MISSING_COIN_PARAMS () {
if [[ ! -z "${GITHUB_REPO}" ]]
then
  if [[ -z "${BIN_BASE}" ]]
  then
    _CONFIGURE_AC=$( wget -4qO- -o- "${GIT_CDN}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/configure.ac" )
    if [[ -z "${_CONFIGURE_AC}" ]]
    then
      _CONFIGURE_AC=$( wget -4qO- -o- "${GIT_RAW}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/configure.ac" )
    fi
    DAEMON_BIN=$( echo "${_CONFIGURE_AC}" | grep -m 1 "BITCOIN_DAEMON_NAME" | cut -d '=' -f2 )
    CONTROLLER_BIN=$( echo "${_CONFIGURE_AC}" | grep -m 1 "BITCOIN_CLI_NAME" | cut -d '=' -f2 )
    if [[ -z "${DAEMON_BIN}" ]]
    then
      _CONFIGURE_AC=$( wget -4qO- -o- "${GIT_CDN}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/Makefile.am" )
      if [[ -z "${_CONFIGURE_AC}" ]]
      then
        _CONFIGURE_AC=$( wget -4qO- -o- "${GIT_RAW}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/Makefile.am" )
      fi
      DAEMON_BIN=$( echo "${_CONFIGURE_AC}" | grep -m 1 "BITCOIND_BIN" | cut -d '=' -f2 | cut -d '/' -f3 | cut -d '$' -f1 )
      CONTROLLER_BIN=$( echo "${_CONFIGURE_AC}" | grep -m 1 "BITCOIN_CLI_BIN" | cut -d '=' -f2 | cut -d '/' -f3 | cut -d '$' -f1 )
    fi
    if [[ -z "${DAEMON_BIN}" ]]
    then
      _CONFIGURE_AC=$( wget -4qO- -o- "${GIT_CDN}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/src/makefile.unix" )
      if [[ -z "${_CONFIGURE_AC}" ]]
      then
        _CONFIGURE_AC=$( wget -4qO- -o- "${GIT_RAW}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/src/makefile.unix" )
      fi
      DAEMON_BIN=$( echo "${_CONFIGURE_AC}" | grep -m 1 -E "all:[[:space:]]" | cut -d ':' -f2 | awk '{print $1}' )
    fi

    if [[ -z "${DAEMON_BIN}" ]]
    then
      _CONFIGURE_AC=$( wget -4qO- -o- "${GIT_CDN}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/src/Makefile.am" )
      if [[ -z "${_CONFIGURE_AC}" ]]
      then
        _CONFIGURE_AC=$( wget -4qO- -o- "${GIT_RAW}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/src/Makefile.am" )
      fi
      DAEMON_BIN=$( echo "${_CONFIGURE_AC}" | grep 'bin_PROGRAMS '| cut -d '=' -f2 | sed '/^$/d' | tr '\n' ' ' | awk '{print $1}' )
      CONTROLLER_BIN=$( echo "${_CONFIGURE_AC}" | grep 'bin_PROGRAMS '| cut -d '=' -f2 | sed '/^$/d' | tr '\n' ' ' | awk '{print $2}' )
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
  fi

  # GitHub Project Folder
  PROJECT_DIR=$( echo "${GITHUB_REPO}" | tr '/' '_' )

  if [[ -z "${DIRECTORY}" ]] || [[ -z "${CONF}" ]]
  then
    _SRC_UTIL=$( wget -4qO- -o- "${GIT_CDN}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/src/util.cpp" )
    if [[ -z "${_SRC_UTIL}" ]]
    then
      _SRC_UTIL=$( wget -4qO- -o- "${GIT_RAW}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/src/util.cpp" )
    fi
    DIRECTORY=$( echo "${_SRC_UTIL}" | grep -m 1 -E $'return[[:space:]]pathRet[[:space:]]/[[:space:]](\"|\')\.' | grep -oE '/.*' | grep -oE ' .*' | awk '{print $1}' | sed 's/^"\(.*\)".*/\1/' )
    # '
    CONF=$( echo "${_SRC_UTIL}" | grep -F -m 1 'boost::filesystem::path pathConfigFile(GetArg("-conf",' | awk '{print $3}' | sed 's/^"\(.*\)".*/\1/' | tr ');' ' ' | sed 's/^ *//;s/ *$//' )
    if [[ -z "${CONF}" ]]
    then
      CONF=$( echo "${_SRC_UTIL}" | grep -F -m 1 'BITCOIN_CONF_FILENAME' | cut -d '=' -f2 | sed 's/^ *//;s/ *$//' | sed 's/^"\(.*\)".*/\1/' )
    fi
    if [[ $( echo "${CONF}" | grep -cE '.*\.conf$' ) -eq 0 ]]
    then
      CONF=$( echo "${_SRC_UTIL}" | grep -m 1 -E "${CONF}.*=.*" | cut -d '=' -f2 | sed 's/^ *//;s/ *$//' | sed 's/^"\(.*\)".*/\1/' )
    fi
  fi

  if [[ -z "${DEFAULT_PORT}" ]]
  then
    _SRC_CHAIN=$( wget -4qO- -o- "${GIT_CDN}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/src/chainparams.cpp" )
    if [[ -z "${_SRC_CHAIN}" ]]
    then
      _SRC_CHAIN=$( wget -4qO- -o- "${GIT_RAW}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/src/chainparams.cpp" )
    fi
    DEFAULT_PORT=$( echo "${_SRC_CHAIN}" | grep -m 1 -E "DefaultPort.*=.*" | cut -d '=' -f2 | tr ');' ' ' | sed 's/^ *//;s/ *$//' | awk '{ print $1}' )
    if [[ -z "${DEFAULT_PORT}" ]]
    then
      DEFAULT_PORT=$( echo "${_SRC_CHAIN}" | grep -m 1 -E "nP2pPort.*=.*" | cut -d '=' -f2 | tr ');' ' ' | sed 's/^ *//;s/ *$//' | awk '{ print $1}' )
    fi
  fi

  if [[ -z "${TICKER}" ]]
  then
    _BITCOINUNITS=$( wget -4qO- -o- "${GIT_CDN}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/src/bitcoinunits.cpp" )
    if [[ -z "${_BITCOINUNITS}" ]]
    then
      _BITCOINUNITS=$( wget -4qO- -o- "${GIT_CDN}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/src/qt/bitcoinunits.cpp" )
    fi
    if [[ -z "${_BITCOINUNITS}" ]]
    then
      _BITCOINUNITS=$( wget -4qO- -o- "${GIT_RAW}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/src/bitcoinunits.cpp" )
    fi
    if [[ -z "${_BITCOINUNITS}" ]]
    then
      _BITCOINUNITS=$( wget -4qO- -o- "${GIT_RAW}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/src/qt/bitcoinunits.cpp" )
    fi

    COIN_NAME=$( echo "${_BITCOINUNITS}" | grep -m 1 "unitlist.append" | grep -o '(.*)' | sed 's/(//g' | sed 's/)//g' | grep -oE '[A-Z0-9]+' | sed 's/^ *//;s/ *$//' )
    if [[ "${COIN_NAME}" == 'BTC' ]]
    then
      COIN_NAME=$( echo "${_BITCOINUNITS}" | grep -m 1 "case BTC: return QString" | grep -o '(.*)' | sed 's/(//g' | sed 's/)//g' | sed 's/^"\(.*\)".*/\1/' | sed 's/^ *//;s/ *$//' | grep -oE '[A-Z0-9]+' )
    fi
    if [[ -z "${COIN_NAME}" ]]
    then
      COIN_NAME=$( echo "${BIN_BASE}" | tr '[:lower:]' '[:upper:]' )
    fi
    TICKER=${COIN_NAME:0:4}
    TICKER_LOWER=$( echo "${COIN_NAME}" | tr '[:upper:]' '[:lower:]' )
  fi

  if [[ -z "${DAEMON_NAME}" ]]
  then
    _BITCOINGUI=$( wget -4qO- -o- "${GIT_CDN}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/src/qt/bitcoingui.cpp" )
    if [[ -z "${_BITCOINGUI}" ]]
    then
      _BITCOINGUI=$( wget -4qO- -o- "${GIT_RAW}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/src/qt/bitcoingui.cpp" )
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
  fi

  if [[ -z "${COLLATERAL}" ]]
  then
    COLLATERAL=$( echo "${_SRC_CHAIN}" | grep -iE "Collateral.*=.*" | cut -d '=' -f2 | tr ');' ' ' | sed 's/^ *//;s/ *$//' | cut -d '*' -f1 | grep -o '[0-9]*' )
    if [[ -z "${COLLATERAL}" ]]
    then
      COLLATERAL=$( echo "${_SRC_CHAIN}" | grep  -iE "Colleteral.*=.*" | cut -d '=' -f2 | tr ');' ' ' | sed 's/^ *//;s/ *$//' | cut -d '*' -f1 | grep -o '[0-9]*' )
    fi
    if [[ -z "${COLLATERAL}" ]]
    then
      _MNINFO=$( wget -4qO- -o- "${GIT_CDN}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/src/activemasternode.cpp" )
      if [[ -z "${_MNINFO}" ]]
      then
        _MNINFO=$( wget -4qO- -o- "${GIT_RAW}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/src/activemasternode.cpp" )
      fi
      COLLATERAL=$( echo "${_MNINFO}" | grep -iF "out.tx->vout[out.i].nValue" | cut -d '=' -f3 | cut -d '*' -f1 | grep -o '[0-9]*' )
    fi
    if [[ -z "${COLLATERAL}" ]]
    then
      _MNINFO=$( wget -4qO- -o- "${GIT_CDN}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/src/masternode.h" )
      if [[ -z "${_MNINFO}" ]]
      then
        _MNINFO=$( wget -4qO- -o- "${GIT_RAW}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/src/masternode.h" )
      fi
      COLLATERAL=$( echo "${_MNINFO}" | grep -m 1 -iE "Collateral.*=.*" | cut -d '=' -f2 | tr ');' ' ' | sed 's/^ *//;s/ *$//' | cut -d '*' -f1 | grep -o '[0-9]*' )
      if [[ -z "${COLLATERAL}" ]]
      then
       COLLATERAL=$( echo "${_MNINFO}" | grep -m 1 -iE "MASTERNODEAMOUNT.*=.*" | cut -d '=' -f2 | tr ');' ' ' | sed 's/^ *//;s/ *$//' | cut -d '*' -f1 | grep -o '[0-9]*' )
      fi
      if [[ -z "${COLLATERAL}" ]]
      then
       COLLATERAL=$( echo "${_MNINFO}" | grep -m 1 -iF "MASTERNODE_COLLATERAL " | grep -o '[0-9]*' )
      fi
    fi
    if [[ -z "${COLLATERAL}" ]]
    then
      _MNINFO=$( wget -4qO- -o- "${GIT_CDN}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/src/smartnode/smartnode.h" )
      if [[ -z "${_MNINFO}" ]]
      then
        _MNINFO=$( wget -4qO- -o- "${GIT_RAW}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/src/smartnode/smartnode.h" )
      fi
      COLLATERAL=$( echo "${_MNINFO}" | grep -iE "COIN_REQUIRED.*=.*" | cut -d '=' -f2 | tr ');' ' ' | sed 's/^ *//;s/ *$//' | cut -d '*' -f1 | grep -o '[0-9]*' )
    fi
    if [[ -z "${COLLATERAL}" ]]
    then
      _MNINFO=$( wget -4qO- -o- "${GIT_CDN}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/src/main.h" )
      if [[ -z "${_MNINFO}" ]]
      then
        _MNINFO=$( wget -4qO- -o- "${GIT_RAW}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/src/main.h" )
      fi
      COLLATERAL=$( echo "${_MNINFO}" | grep -iE "MNCollateral" | grep -o '{.*}' | grep -Eo '[0-9]+' | tail -n 1 )
      if [[ -z "${COLLATERAL}" ]]
      then
        COLLATERAL=$( echo "${_MNINFO}" | grep -iE "MASTERNODE_COLLATERAL" | grep -Eo '[0-9]+' | tail -n 1 )
      fi
    fi
    if [[ -z "${COLLATERAL}" ]]
    then
      _MNINFO=$( wget -4qO- -o- "${GIT_CDN}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/src/chainparams.cpp" )
      if [[ -z "${_MNINFO}" ]]
      then
        _MNINFO=$( wget -4qO- -o- "${GIT_RAW}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/src/chainparams.cpp" )
      fi
      COLLATERAL=$( echo "${_MNINFO}" | grep -iE "Collateral" | cut -d '=' -f2 | tr ');' ' ' | sed 's/^ *//;s/ *$//' | cut -d '*' -f1 | grep -o '[0-9]*' )
    fi
    if [[ -z "${COLLATERAL}" ]]
    then
      _MNINFO=$( wget -4qO- -o- "${GIT_CDN}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/src/activeservicenode.h" )
      if [[ -z "${_MNINFO}" ]]
      then
        _MNINFO=$( wget -4qO- -o- "${GIT_RAW}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/src/activeservicenode.h" )
      fi
      COLLATERAL=$( echo "${_MNINFO}" | grep -iE "SERVICENODE_REQUIRED_AMOUNT" | grep -o '[0-9]*' )
    fi
    if [[ -z "${COLLATERAL}" ]]
    then
      _MNINFO=$( wget -4qO- -o- "${GIT_CDN}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/src/masternode.cpp" )
      if [[ -z "${_MNINFO}" ]]
      then
        _MNINFO=$( wget -4qO- -o- "${GIT_RAW}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/src/masternode.cpp" )
      fi
      COLLATERAL=$( echo "${_MNINFO}" | grep -iF "if(coin.out.nValue != " | grep -o '[0-9]*' )
      if [[ -z "${COLLATERAL}" ]]
      then
        COLLATERAL=$( echo "${_MNINFO}" | grep -iF "if(coins.vout[vin.prevout.n].nValue != " | grep -o '[0-9]*' )
      fi
      if [[ -z "${COLLATERAL}" ]]
      then
        COLLATERAL=$( echo "${_MNINFO}" | grep -iF "MASTERNODE_COLLATERAL_HIGH" | grep -o '[0-9]*' )
      fi

    fi
    if [[ -z "${COLLATERAL}" ]]
    then
      MNINFO=$( wget -4qO- -o- "${GIT_CDN}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/src/main.h" )
      if [[ -z "${_MNINFO}" ]]
      then
        _MNINFO=$( wget -4qO- -o- "${GIT_RAW}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/src/main.h" )
      fi
      COLLATERAL=$( echo "${MNINFO}" | awk '/GetMstrNodCollateral/ { show=1 } show; /}/ { show=0 }' | tr '\n' ' ' | grep -o '{.*}' | grep -Eo '[0-9]+' | tail -n 1 )
      if [[ -z "${COLLATERAL}" ]]
      then
        COLLATERAL=$( echo "${MNINFO}" | awk '/MasternodeCollateral/ { show=1 } show; /}/ { show=0 }' | tr '\n' ' ' | grep -o '{.*}' | grep -Eo '[0-9]+' | tail -n 1 )
      fi
    fi
    if [[ -z "${COLLATERAL}" ]]
    then
      _MNINFO=$( wget -4qO- -o- "${GIT_CDN}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/src/znode.h" )
      if [[ -z "${_MNINFO}" ]]
      then
        _MNINFO=$( wget -4qO- -o- "${GIT_RAW}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/src/znode.h" )
      fi
      COLLATERAL=$( echo "${_MNINFO}" | grep -m 1 -iE "ZNODE_COIN_REQUIRED.*=.*" | cut -d '=' -f2 | tr ');' ' ' | sed 's/^ *//;s/ *$//' | cut -d '*' -f1 | grep -o '[0-9]*' )
    fi
    if [[ -z "${COLLATERAL}" ]]
    then
      _MNINFO=$( wget -4qO- -o- "${GIT_CDN}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/src/bznode.h" )
      if [[ -z "${_MNINFO}" ]]
      then
        _MNINFO=$( wget -4qO- -o- "${GIT_RAW}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/src/bznode.h" )
      fi
      COLLATERAL=$( echo "${_MNINFO}" | grep -m 1 -iE "BZNODE_COIN_REQUIRED.*=.*" | cut -d '=' -f2 | tr ');' ' ' | sed 's/^ *//;s/ *$//' | cut -d '*' -f1 | grep -o '[0-9]*' )
    fi
    if [[ -z "${COLLATERAL}" ]]
    then
      _MNINFO=$( wget -4qO- -o- "${GIT_CDN}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/src/protocol.h" )
      if [[ -z "${_MNINFO}" ]]
      then
        _MNINFO=$( wget -4qO- -o- "${GIT_RAW}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/src/protocol.h" )
      fi
      COLLATERAL=$( echo "${_MNINFO}" | grep -iE "MASTERNODEAMOUNT" | grep -o '[0-9]*' )
    fi

    COLLATERAL=$( echo "${COLLATERAL}" | head -n 1 )
  fi

  if [[ -z "${BLOCKTIME}" ]]
  then
    _SRC_CHAIN=$( wget -4qO- -o- "${GIT_CDN}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/src/chainparams.cpp" )
    if [[ -z "${_SRC_CHAIN}" ]]
    then
      _SRC_CHAIN=$( wget -4qO- -o- "${GIT_RAW}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/src/chainparams.cpp" )
    fi
    BLOCKTIME=$( echo "${_SRC_CHAIN}" | grep -m 1 -E "TargetSpacing[[:space:]]*=.*" )
    if [[ -z "${BLOCKTIME}" ]]
    then
      _SRC_MAIN=$( wget -4qO- -o- "${GIT_CDN}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/src/main.cpp" )
      if [[ -z "${_SRC_MAIN}" ]]
      then
        _SRC_MAIN=$( wget -4qO- -o- "${GIT_RAW}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/src/main.cpp" )
      fi
      BLOCKTIME=$( echo "${_SRC_MAIN}" | grep -m 1 -E "TargetSpacing[[:space:]]*=.*" )
    fi
    if [[ -z "${BLOCKTIME}" ]]
    then
      _SRC_MAIN=$( wget -4qO- -o- "${GIT_CDN}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/src/main.h" )
      if [[ -z "${_SRC_MAIN}" ]]
      then
        _SRC_MAIN=$( wget -4qO- -o- "${GIT_RAW}${GITHUB_REPO}${GIT_PATH_PREFIX}/master/src/main.h" )
      fi
      BLOCKTIME=$( echo "${_SRC_MAIN}" | grep -m 1 -E "TARGET_SPACING[[:space:]]*=.*" )
    fi
    BLOCKTIME=$( echo "${BLOCKTIME}" | cut -d ';' -f1 | cut -d '=' -f2 | bc )
  fi
fi
}
GET_MISSING_COIN_PARAMS

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
if [[ -z "${DAEMON_SETUP_LOG}" ]] && [[ "${TICKER_LOWER}" != 'fake_coin' ]]
then
  # Log filename.
  DAEMON_SETUP_LOG="/tmp/${TICKER_LOWER}.log"
  # Log to a file.
  rm -f "${DAEMON_SETUP_LOG}" 2>/dev/null
  touch "${DAEMON_SETUP_LOG}" 2>/dev/null
  chmod 600 "${DAEMON_SETUP_LOG}" 2>/dev/null
#   exec >  >(tee -ia "${DAEMON_SETUP_LOG}") 2>/dev/null
#   exec 2> >(tee -ia "${DAEMON_SETUP_LOG}" >&2) 2>/dev/null
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

if [[ -z "${EXPLORER_URL}" ]]
then
  EXPLORER_URL=''
fi

# Set the endpoint getting the blockcount.
if [[ -z "${EXPLORER_BLOCKCOUNT_PATH}" ]]
then
  EXPLORER_BLOCKCOUNT_PATH='api/getblockcount'
fi

if [[ -z "${EXPLORER_BLOCKCOUNT_OFFSET}" ]]
then
  EXPLORER_BLOCKCOUNT_OFFSET='+0'
fi

# Set the endpoint getting the rawtransaction.
if [[ -z "${EXPLORER_RAWTRANSACTION_PATH}" ]]
then
  EXPLORER_RAWTRANSACTION_PATH='api/getrawtransaction?txid='
fi
EXPLORER_RAWTRANSACTION_PATH=$( echo "${EXPLORER_RAWTRANSACTION_PATH}" | tr -d '\040\011\012\015' )

# Set the endpoint getting the rawtransaction.
if [[ -z "${EXPLORER_RAWTRANSACTION_PATH_SUFFIX}" ]]
then
  EXPLORER_RAWTRANSACTION_PATH_SUFFIX='&decrypt=1'
fi
EXPLORER_RAWTRANSACTION_PATH_SUFFIX=$( echo "${EXPLORER_RAWTRANSACTION_PATH_SUFFIX}" | tr -d '\040\011\012\015' )

# Set the endpoint getting info on the address.
if [[ -z "${EXPLORER_GETADDRESS_PATH}" ]]
then
  EXPLORER_GETADDRESS_PATH='ext/getaddress/'
fi
EXPLORER_GETADDRESS_PATH=$( echo "${EXPLORER_GETADDRESS_PATH}" | tr -d '\040\011\012\015' )

# Set the endpoint getting info on the address.
if [[ -z "${EXPLORER_AMOUNT_ADJUST}" ]]
then
  EXPLORER_AMOUNT_ADJUST=1
fi

# Set the endpoint getting info on peers.
if [[ -z "${EXPLORER_PEERS}" ]]
then
  EXPLORER_PEERS='api/getpeerinfo'
fi

# If set to 1 then use blocks n chains from dropbox.
if [[ -z "${USE_DROPBOX_BLOCKS_N_CHAINS}" ]]
then
  USE_DROPBOX_BLOCKS_N_CHAINS=1
fi

# If set to 1 then use bootstrap from dropbox.
if [[ -z "${USE_DROPBOX_BOOTSTRAP}" ]]
then
  USE_DROPBOX_BOOTSTRAP=1
fi

# If set to 1 then use addnodes from dropbox.
if [[ -z "${USE_DROPBOX_ADDNODES}" ]]
then
  USE_DROPBOX_ADDNODES=1
fi

# If set to 1 then use connect instead of addnodes for initial sync.
if [[ -z "${USE_CONNECT}" ]]
then
  USE_CONNECT=1
fi

if [[ -z "${IPV4}" ]]
then
  IPV4=1
fi
if [[ -z "${IPV6}" ]]
then
  IPV6=0
fi
if [[ -z "${TOR}" ]]
then
  TOR=0
fi

NO_MN=0
if [[ "${ARG1}" == 'NO_MN' ]]
then
  NO_MN=1
fi

if [[ -z "${COLLATERAL}" ]]
then
  NO_MN=1
fi

rm -f /var/multi-masternode-data/___temp.sh
if [[ -r /tmp/___mn.sh ]] && [[ $( stat --format '%a' /tmp/___mn.sh ) -ne 666 ]]
then
  chmod 666 /tmp/___mn.sh
fi

# Install sudo if not there.
if [ ! -x "$( command -v sudo )" ]
then
  DEBIAN_FRONTEND=noninteractive apt-get install -yq sudo
fi

WAIT_FOR_APT_GET () {
  ONCE=0
  while [[ $( sudo lslocks -n -o COMMAND,PID,PATH | grep -c 'apt-get\|dpkg\|unattended-upgrades' ) -ne 0 ]]
  do
    if [[ "${ONCE}" -eq 0 ]]
    then
      while read -r LOCKINFO
      do
        PID=$( echo "${LOCKINFO}" | awk '{print $2}' )
        ps -up "${PID}"
        echo "${LOCKINFO}"
      done <<< "$( sudo lslocks -n -o COMMAND,PID,PATH | grep 'apt-get\|dpkg\|unattended-upgrades' )"
      ONCE=1
      if [[ ${ARG6} == 'y' ]]
      then
        echo "Waiting for apt-get to finish"
      fi
    fi
    if [[ ${ARG6} == 'y' ]]
    then
      printf "."
    else
      echo -e "\\r${SP:i++%${#SP}:1} Waiting for apt-get to finish... \\c"
    fi
    sleep 0.3
  done
  echo
  echo -e "\\r\\c"
  stty sane 2>/dev/null
}

DAEMON_DOWNLOAD_EXTRACT () {
  PROJECT_DIR=${1}
  DAEMON_BIN=${2}
  CONTROLLER_BIN=${3}
  DAEMON_DOWNLOAD_URL=${4}

  UBUNTU_VERSION=$( lsb_release -sr )
  FOUND_DAEMON=0
  FOUND_CLI=0
  while read -r GITHUB_URL
  do
    if [[ -z "${GITHUB_URL}" ]]
    then
      continue
    fi
    BIN_FILENAME=$( basename "${GITHUB_URL}" | tr -d '\r'  )
    echo "URL: ${GITHUB_URL}"
    stty sane 2>/dev/null
    wget -4 "${GITHUB_URL}" -O /var/multi-masternode-data/latest-github-releasese/"${BIN_FILENAME}" -q --show-progress --progress=bar:force 2>&1
    sleep 0.6
    echo
    mkdir -p /var/multi-masternode-data/"${PROJECT_DIR}"/src
    if [[ $( echo "${BIN_FILENAME}" | grep -c '.tar.gz$' ) -eq 1 ]] || [[ $( echo "${BIN_FILENAME}" | grep -c '.tgz$' ) -eq 1 ]]
    then
      echo "Decompressing tar.gz archive."
      if [[ -x "$( command -v pv )" ]]
      then
        pv "/var/multi-masternode-data/latest-github-releasese/${BIN_FILENAME}" | tar -xz -C /var/multi-masternode-data/"${PROJECT_DIR}"/src 2>&1
      else
       tar -xzf /var/multi-masternode-data/latest-github-releasese/"${BIN_FILENAME}" -C /var/multi-masternode-data/"${PROJECT_DIR}"/src
      fi

    elif [[ $( echo "${BIN_FILENAME}" | grep -c '.tar.xz$' ) -eq 1 ]]
    then
      echo "Decompressing tar.xz archive."
     if [[ -x "$( command -v pv )" ]]
     then
       pv "/var/multi-masternode-data/latest-github-releasese/${BIN_FILENAME}" | tar -xJ -C /var/multi-masternode-data/"${PROJECT_DIR}"/src 2>&1
     else
        tar -xJf /var/multi-masternode-data/latest-github-releasese/"${BIN_FILENAME}" -C /var/multi-masternode-data/"${PROJECT_DIR}"/src
     fi

    elif [[ $( echo "${BIN_FILENAME}" | grep -c '.zip$' ) -eq 1 ]]
    then
      echo "Unzipping file."
      unzip -o /var/multi-masternode-data/latest-github-releasese/"${BIN_FILENAME}" -d /var/multi-masternode-data/"${PROJECT_DIR}"/src/

    elif [[ $( echo "${BIN_FILENAME}" | grep -c '.deb$' ) -eq 1 ]]
    then
      echo "Installing deb package."
      sudo -n dpkg --install /var/multi-masternode-data/latest-github-releasese/"${BIN_FILENAME}"
      echo "Extracting deb package."
      dpkg -x /var/multi-masternode-data/latest-github-releasese/"${BIN_FILENAME}" /var/multi-masternode-data/"${PROJECT_DIR}"/src/

    elif [[ $( echo "${BIN_FILENAME}" | grep -c '.gz$' ) -eq 1 ]]
    then
      echo "Decompressing gz archive."
      mv /var/multi-masternode-data/latest-github-releasese/"${BIN_FILENAME}" /var/multi-masternode-data/"${PROJECT_DIR}"/src/"${BIN_FILENAME}"
      gunzip /var/multi-masternode-data/"${PROJECT_DIR}"/src/"${BIN_FILENAME}"

    else
      echo "Copying over."
      mv /var/multi-masternode-data/latest-github-releasese/"${BIN_FILENAME}" /var/multi-masternode-data/"${PROJECT_DIR}"/src/
    fi

    cd ~/ || return 1 2>/dev/null
    find /var/multi-masternode-data/"${PROJECT_DIR}"/src/ -name "$DAEMON_BIN" -size +128k 2>/dev/null
    find /var/multi-masternode-data/"${PROJECT_DIR}"/src/ -name "$DAEMON_BIN" -size +128k -exec cp {} /var/multi-masternode-data/"${PROJECT_DIR}"/src/  \; 2>/dev/null
    find /var/multi-masternode-data/"${PROJECT_DIR}"/src/ -name "$CONTROLLER_BIN" -size +128k 2>/dev/null
    find /var/multi-masternode-data/"${PROJECT_DIR}"/src/ -name "$CONTROLLER_BIN" -size +128k -exec cp {} /var/multi-masternode-data/"${PROJECT_DIR}"/src/  \; 2>/dev/null

    if [[ -s "/var/multi-masternode-data/${PROJECT_DIR}/src/${BIN_FILENAME}" ]] && \
      [[ "${BIN_FILENAME}" == ${DAEMON_BIN}* ]] && \
      [[ $( ldd "/var/multi-masternode-data/${PROJECT_DIR}/src/${BIN_FILENAME}" | grep -ciF 'not a dynamic executable' ) -eq 0 ]]
    then
      echo "Renaming ${BIN_FILENAME} to ${DAEMON_BIN}"
      mv "/var/multi-masternode-data/${PROJECT_DIR}/src/${BIN_FILENAME}" "/var/multi-masternode-data/${PROJECT_DIR}/src/${DAEMON_BIN}"
    fi
    if [[ -s "/var/multi-masternode-data/${PROJECT_DIR}/src/${BIN_FILENAME}" ]] && \
      [[ "${BIN_FILENAME}" == ${CONTROLLER_BIN}* ]] && \
      [[ $( ldd "/var/multi-masternode-data/${PROJECT_DIR}/src/${BIN_FILENAME}" | grep -ciF 'not a dynamic executable' ) -eq 0 ]]
    then
      echo "Renaming ${BIN_FILENAME} to ${CONTROLLER_BIN}"
      mv "/var/multi-masternode-data/${PROJECT_DIR}/src/${BIN_FILENAME}" "/var/multi-masternode-data/${PROJECT_DIR}/src/${CONTROLLER_BIN}"
    fi

    if [[ -s "/var/multi-masternode-data/${PROJECT_DIR}/src/${DAEMON_BIN}" ]]
    then
      echo "Setting executable bit for daemon ${DAEMON_BIN}"
      echo "/var/multi-masternode-data/${PROJECT_DIR}/src/${DAEMON_BIN}"
      sudo -n chmod +x "/var/multi-masternode-data/${PROJECT_DIR}/src/${DAEMON_BIN}" 2>/dev/null
      chmod +x "/var/multi-masternode-data/${PROJECT_DIR}/src/${DAEMON_BIN}" 2>/dev/null
      if [[ $( timeout --foreground --signal=SIGKILL 3s ldd "/var/multi-masternode-data/${PROJECT_DIR}/src/${DAEMON_BIN}" | wc -l ) -gt 2 ]]
      then
        if [[ "${UBUNTU_VERSION}" == 16.* ]] && \
          [[ $( timeout --foreground --signal=SIGKILL 3s ldd "/var/multi-masternode-data/${PROJECT_DIR}/src/${DAEMON_BIN}" | grep -cE 'libboost.*1.65' ) -gt 0 ]]
        then
          echo "ldd has wrong libboost version 1.65"
          rm "/var/multi-masternode-data/${PROJECT_DIR}/src/${DAEMON_BIN}"
        elif [[ $( timeout --foreground --signal=SIGKILL 3s ldd "/var/multi-masternode-data/${PROJECT_DIR}/src/${DAEMON_BIN}" | grep -cE 'libboost.*1.54' ) -gt 0 ]]
        then
          echo "ldd has wrong libboost version 1.54"
          rm "/var/multi-masternode-data/${PROJECT_DIR}/src/${DAEMON_BIN}"
        else
          echo "Good"
          FOUND_DAEMON=1
        fi
      else
        echo "ldd failed."
        rm "/var/multi-masternode-data/${PROJECT_DIR}/src/${DAEMON_BIN}"
      fi
    fi
    if [[ -s "/var/multi-masternode-data/${PROJECT_DIR}/src/${CONTROLLER_BIN}" ]]
    then
      echo "Setting executable bit for controller ${CONTROLLER_BIN}"
      echo "/var/multi-masternode-data/${PROJECT_DIR}/src/${CONTROLLER_BIN}"
      sudo -n chmod +x "/var/multi-masternode-data/${PROJECT_DIR}/src/${CONTROLLER_BIN}" 2>/dev/null
      chmod +x "/var/multi-masternode-data/${PROJECT_DIR}/src/${CONTROLLER_BIN}" 2>/dev/null
      if [[ $( timeout --signal=SIGKILL 1s ldd "/var/multi-masternode-data/${PROJECT_DIR}/src/${CONTROLLER_BIN}" | wc -l ) -gt 2 ]]
      then
        if [[ "${UBUNTU_VERSION}" == 16.* ]] && \
          [[ $( timeout --signal=SIGKILL 1s ldd "/var/multi-masternode-data/${PROJECT_DIR}/src/${CONTROLLER_BIN}" | grep -cE 'libboost.*1.65' ) -gt 0 ]]
        then
          echo "ldd has wrong libboost version 1.65"
          rm "/var/multi-masternode-data/${PROJECT_DIR}/src/${CONTROLLER_BIN}"
        elif [[ $( timeout --signal=SIGKILL 1s ldd "/var/multi-masternode-data/${PROJECT_DIR}/src/${CONTROLLER_BIN}" | grep -cE 'libboost.*1.54' ) -gt 0 ]]
        then
          echo "ldd has wrong libboost version 1.54"
          rm "/var/multi-masternode-data/${PROJECT_DIR}/src/${CONTROLLER_BIN}"
        else
          echo "Good"
          FOUND_CLI=1
        fi
      else
        echo "ldd failed."
        rm "/var/multi-masternode-data/${PROJECT_DIR}/src/${CONTROLLER_BIN}"
      fi
    fi

    # Break out of loop if we got what we needed.
    if [[ "${FOUND_DAEMON}" -eq 1 ]] && [[ "${FOUND_CLI}" -eq 1 ]]
    then
      break
    fi
  done <<< "${DAEMON_DOWNLOAD_URL}"
}

DAEMON_DOWNLOAD_SUPER () {
  if [ ! -x "$( command -v jq )" ] || \
    [ ! -x "$( command -v curl )" ] || \
    [ ! -x "$( command -v gzip )" ] || \
    [ ! -x "$( command -v tar )" ] || \
    [ ! -x "$( command -v unzip )" ]
  then
    WAIT_FOR_APT_GET
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq \
      curl \
      gzip \
      unzip \
      xz-utils \
      jq \
      bc \
      html-xml-utils
  fi

  REPO=${1}
  BIN_BASE=${2}
  DAEMON_DOWNLOAD_URL=${3}
  FILENAME=$( echo "${REPO}" | tr '/' '_' )
  RELEASE_TAG='latest'
  if [[ ! -z "${4}" ]] && [[ "${4}" != 'force' ]] && [[ "${4}" != 'force_skip_download' ]]
  then
    rm "/var/multi-masternode-data/latest-github-releasese/${FILENAME}.json"
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
  PROJECT_DIR=$( echo "${REPO}" | tr '/' '_' )

  DAEMON_BIN="${BIN_BASE}d"
  DAEMON_GREP="[${DAEMON_BIN:0:1}]${DAEMON_BIN:1}"
  if [[ -z "${CONTROLLER_BIN}" ]]
  then
    CONTROLLER_BIN="${BIN_BASE}-cli"
  fi

  if [[ ! "${DAEMON_DOWNLOAD_URL}" == http* ]]
  then
    DAEMON_DOWNLOAD_URL=''
  fi

  # curl & curl cache.
  if [[ -z "${DAEMON_DOWNLOAD_URL}" ]]
  then
    TIMESTAMP=9999
    if [[ -s "/var/multi-masternode-data/latest-github-releasese/${FILENAME}.json" ]]
    then
      # Get timestamp.
      TIMESTAMP=$( stat -c %Y "/var/multi-masternode-data/latest-github-releasese/${FILENAME}.json" )
    fi
    echo "Downloading ${RELEASE_TAG} release info from github."
    curl -sL --max-time 10 "https://api.github.com/repos/${REPO}/releases/${RELEASE_TAG}" -z "$( date --rfc-2822 -d "@${TIMESTAMP}" )" -o "/var/multi-masternode-data/latest-github-releasese/${FILENAME}.json"

    LATEST=$( cat "/var/multi-masternode-data/latest-github-releasese/${FILENAME}.json" )
    if [[ $( echo "${LATEST}" | grep -c 'browser_download_url' ) -eq 0 ]]
    then
      echo "Downloading ${RELEASE_TAG} release info from github."
      curl -sL --max-time 10 "https://api.github.com/repos/${REPO}/releases/${RELEASE_TAG}" -o "/var/multi-masternode-data/latest-github-releasese/${FILENAME}.json"
      LATEST=$( cat "/var/multi-masternode-data/latest-github-releasese/${FILENAME}.json" )
    fi
    if [[ $( echo "${LATEST}" | grep -c 'browser_download_url' ) -eq 0 ]]
    then
      FILENAME_RELEASES=$( echo "${REPO}-releases" | tr '/' '_' )
      TIMESTAMP_RELEASES=9999
      if [[ -s /var/multi-masternode-data/latest-github-releasese/"${FILENAME_RELEASES}".json ]]
      then
        # Get timestamp.
        TIMESTAMP_RELEASES=$( stat -c %Y /var/multi-masternode-data/latest-github-releasese/"${FILENAME_RELEASES}".json )
      fi
      echo "Downloading all releases from github."
      curl -sL --max-time 10 "https://api.github.com/repos/${REPO}/releases" -z "$( date --rfc-2822 -d "@${TIMESTAMP_RELEASES}" )" -o "/var/multi-masternode-data/latest-github-releasese/${FILENAME_RELEASES}.json"
      RELEASE_ID=$( jq '.[].id' < "/var/multi-masternode-data/latest-github-releasese/${FILENAME_RELEASES}.json" )
      echo "Downloading latest release info from github."
      curl -sL --max-time 10 "https://api.github.com/repos/${REPO}/releases/${RELEASE_ID}" -o "/var/multi-masternode-data/latest-github-releasese/${FILENAME}.json"
      LATEST=$( cat "/var/multi-masternode-data/latest-github-releasese/${FILENAME}.json" )
    fi

    VERSION_REMOTE=$( echo "${LATEST}" | jq -r '.tag_name' | sed 's/[^0-9.]*\([0-9.]*\).*/\1/' )
    echo "Remote version: ${VERSION_REMOTE}"
    if [[ -s "/var/multi-masternode-data/${PROJECT_DIR}/src/${CONTROLLER_BIN}" ]] && \
      [[ -s "/var/multi-masternode-data/${PROJECT_DIR}/src/${DAEMON_BIN}" ]] && \
      [[ $( echo "${CONTROLLER_BIN}" | grep -cE "cli$" ) -gt 0 ]]
    then
      # Set executable bit.
      if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
      then
        sudo chmod +x "/var/multi-masternode-data/${PROJECT_DIR}/src/${CONTROLLER_BIN}"
        sudo chmod +x "/var/multi-masternode-data/${PROJECT_DIR}/src/${DAEMON_BIN}"
      else
        chmod +x "/var/multi-masternode-data/${PROJECT_DIR}/src/${CONTROLLER_BIN}"
        chmod +x "/var/multi-masternode-data/${PROJECT_DIR}/src/${DAEMON_BIN}"
      fi

      VERSION_LOCAL=$( timeout --signal=SIGKILL 9s "/var/multi-masternode-data/${PROJECT_DIR}/src/${CONTROLLER_BIN}" --help 2>/dev/null | head -n 1 | sed 's/[^0-9.]*\([0-9.]*\).*/\1/' )
      if [[ -z "${VERSION_LOCAL}" ]]
      then
        VERSION_LOCAL=$( timeout --signal=SIGKILL 9s "/var/multi-masternode-data/${PROJECT_DIR}/src/${CONTROLLER_BIN}" -version 2>/dev/null | sed 's/[^0-9.]*\([0-9.]*\).*/\1/' )
      fi

      echo "Local version: ${VERSION_LOCAL}"
      if [[ $( echo "${VERSION_LOCAL}" | grep -c "${VERSION_REMOTE}" ) -eq 1 ]] && [[ "${4}" != 'force' ]]
      then
        return 1 2>/dev/null
      fi
    fi

    ALL_DOWNLOADS=$( echo "${LATEST}" | jq -r '.assets[].browser_download_url' )
    # Remove useless files.
    DOWNLOADS=$( echo "${ALL_DOWNLOADS}" | grep -iv 'win' | grep -iv 'arm-RPi' | grep -iv '\-qt' | grep -iv 'raspbian' | grep -v '.dmg$' | grep -v '.exe$' | grep -v '.sh$' | grep -v '.pdf$' | grep -v '.sig$' | grep -v '.asc$' | grep -iv 'MacOS' | grep -iv 'OSX' | grep -iv 'HighSierra' | grep -iv 'arm' | grep -iv 'bootstrap' | grep -iv '14.04' )

    # Try to pick the correct file.
    LINES=$( echo "${DOWNLOADS}" | sed '/^[[:space:]]*$/d' | wc -l )
    if [[ "${LINES}" -eq 0 ]]
    then
      echo "ERROR! Will try all files below."
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
    if [[ $( echo "${DAEMON_DOWNLOAD_URL}" | sed '/^[[:space:]]*$/d' | wc -l ) -gt 1 ]]
    then
      DAEMON_DOWNLOAD_URL_TEST=$( echo "${DAEMON_DOWNLOAD_URL}" | grep -i '64' )
      if [[ ! -z "${DAEMON_DOWNLOAD_URL_TEST}" ]]
      then
        DAEMON_DOWNLOAD_URL=${DAEMON_DOWNLOAD_URL_TEST}
      fi
    fi

    # If more than 1 pick the one without debug in it.
    if [[ $( echo "${DAEMON_DOWNLOAD_URL}" | sed '/^[[:space:]]*$/d' | wc -l ) -gt 1 ]]
    then
      DAEMON_DOWNLOAD_URL=$( echo "${DAEMON_DOWNLOAD_URL}" | grep -vi 'debug' )
    fi
  fi
  if [[ -z "${DAEMON_DOWNLOAD_URL}" ]]
  then
    echo
    echo "Could not find linux wallet from https://api.github.com/repos/${REPO}/releases/latest"
    echo "${DOWNLOADS}"
    echo
  else
    echo "Removing old files."
    rm -rf /var/multi-masternode-data/"${PROJECT_DIR}"/src/
    echo "Downloading latest release from github."

    DAEMON_DOWNLOAD_EXTRACT_OUTPUT=$( DAEMON_DOWNLOAD_EXTRACT "${PROJECT_DIR}" "${DAEMON_BIN}" "${CONTROLLER_BIN}" "${DAEMON_DOWNLOAD_URL}" )
    echo "${DAEMON_DOWNLOAD_EXTRACT_OUTPUT}"
  fi

  if [[ -z "${DAEMON_DOWNLOAD_URL}" ]] || \
    [[ ! -f "/var/multi-masternode-data/${PROJECT_DIR}/src/${DAEMON_BIN}" ]] || \
    [[ ! -f "/var/multi-masternode-data/${PROJECT_DIR}/src/${CONTROLLER_BIN}" ]] || \
    [[ $( echo "${DAEMON_DOWNLOAD_EXTRACT_OUTPUT}" | grep -c "executable bit for daemon" ) -eq 0 ]] || \
    [[ $( echo "${DAEMON_DOWNLOAD_EXTRACT_OUTPUT}" | grep -c "executable bit for controller" ) -eq 0 ]]
  then
    FILENAME_RELEASES=$( echo "${REPO}-releases" | tr '/' '_' )
    TIMESTAMP_RELEASES=9999
    if [[ -s /var/multi-masternode-data/latest-github-releasese/"${FILENAME_RELEASES}".json ]]
    then
      # Get timestamp.
      TIMESTAMP_RELEASES=$( stat -c %Y /var/multi-masternode-data/latest-github-releasese/"${FILENAME_RELEASES}".json )
    fi
    echo "Downloading all releases from github."
    rm -rf /var/multi-masternode-data/"${PROJECT_DIR}"/src/
    curl -sL --max-time 10 "https://api.github.com/repos/${REPO}/releases" -z "$( date --rfc-2822 -d "@${TIMESTAMP_RELEASES}" )" -o "/var/multi-masternode-data/latest-github-releasese/${FILENAME_RELEASES}.json"

    DAEMON_DOWNLOAD_URL_ALL=$( jq -r '.[].assets[].browser_download_url' < "/var/multi-masternode-data/latest-github-releasese/${FILENAME_RELEASES}.json" )
    DAEMON_DOWNLOAD_URL_ALL_BODY=$( jq -r '.[].body' < "/var/multi-masternode-data/latest-github-releasese/${FILENAME_RELEASES}.json" )
    DAEMON_DOWNLOAD_URL_ALL_BODY=$( echo "${DAEMON_DOWNLOAD_URL_ALL_BODY}" | grep -Eo '(https?://[^ ]+)' | tr -d ')' | tr -d '(' | tr -d '\r' )
    DAEMON_DOWNLOAD_URL=$( echo "${DAEMON_DOWNLOAD_URL_ALL}" | grep -iv 'win' | grep -iv 'arm-RPi' | grep -iv '\-qt' | grep -iv 'raspbian' | grep -v '.dmg$' | grep -v '.exe$' | grep -v '.sh$' | grep -v '.pdf$' | grep -v '.sig$' | grep -v '.asc$' | grep -iv 'MacOS' | grep -iv 'HighSierra' | grep -iv 'arm' )
    if [[ -z "${DAEMON_DOWNLOAD_URL}" ]]
    then
      DAEMON_DOWNLOAD_URL="${DAEMON_DOWNLOAD_URL_ALL}"
    fi
    if [[ -z "${DAEMON_DOWNLOAD_URL}" ]]
    then
      DAEMON_DOWNLOAD_URL="${DAEMON_DOWNLOAD_URL_ALL_BODY}"
    fi

    DAEMON_DOWNLOAD_EXTRACT "${PROJECT_DIR}" "${DAEMON_BIN}" "${CONTROLLER_BIN}" "${DAEMON_DOWNLOAD_URL}"
  fi
  if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
  then
    sudo -n sh -c "find /var/multi-masternode-data/ -type f -exec chmod 666 {} \\;"
    sudo -n sh -c "find /var/multi-masternode-data/ -type d -exec chmod 777 {} \\;"
  else
    find "/var/multi-masternode-data/" -type f -exec chmod 666 {} \;
    find "/var/multi-masternode-data/" -type d -exec chmod 777 {} \;
  fi
}

UPDATE_USER_FILE () {
  STRING=${1}
  FUNCTION_NAME=${2}
  FILENAME=${3/#\~/$HOME}
  ALT_FILENAME=${4/#\~/$HOME}

  # Replace ${FUNCTION_NAME} function if it exists.
  FUNC_START=$( grep -Fxn "# Start of function for ${FUNCTION_NAME}." "${FILENAME}" | sed 's/:/ /g' | awk '{print $1 }' | sort -r )
  FUNC_END=$( grep -Fxn "# End of function for ${FUNCTION_NAME}." "${FILENAME}" | sed 's/:/ /g' | awk '{print $1 }' | sort -r )
  if [ ! -z "${FUNC_START}" ] && [ ! -z "${FUNC_END}" ]
  then
    paste <( echo "${FUNC_START}" ) <( echo "${FUNC_END}" ) -d ' ' | while read -r START END
    do
      sed -i "${START},${END}d" "${FILENAME}"
    done
  fi
  # Remove empty lines at end of file.
  sed -i -r '${/^[[:space:]]*$/d;}' "${FILENAME}"
  echo "" >> "${FILENAME}"
  # Add in ${FUNCTION_NAME} function.
  {
    echo "${STRING}"; echo ""
  } >> "${FILENAME}"

  if [[ ! -z "${ALT_FILENAME}" ]]
  then
    DIR=$( dirname "${ALT_FILENAME}" )
    sudo mkdir -p "${DIR}"
    sudo chmod -R a+rw "${DIR}"
    touch "${ALT_FILENAME}"
    {
      echo "${STRING}"; echo ""
    } >> "${ALT_FILENAME}"
  fi

  # Remove double empty lines in the file.
  sed -i '/^$/N;/^\n$/D' "${FILENAME}"
}

CHECK_COLLATERAL_INDEX () {
  OUTPUTIDX_RAW=${1}
  TXHASH=${2}
  OUTPUTIDX=${3}
  COLLATERAL=${4}
  BAD_SSL_HACK=${5}
  TEMP_FILE=${6}

  # Make sure collateral is still valid.
  MN_WALLET_ADDR=$( echo "${OUTPUTIDX_RAW}" | tr '[:upper:]' '[:lower:]' | jq -r ".vout[] | select( (.n)|tonumber == ${OUTPUTIDX} )" 2>/dev/null )
  if [[ -z "${MN_WALLET_ADDR}" ]]
  then
    MN_WALLET_ADDR=$( echo "${OUTPUTIDX_RAW}" | tr '[:upper:]' '[:lower:]' | jq ".outputs | to_entries[] | select( (.key)|tonumber == ${OUTPUTIDX} ) | .value" 2>/dev/null )
  fi
  MN_WALLET_ADDR_ALT=$( echo "${MN_WALLET_ADDR}" | jq -r '.scriptpubkey.addresses | .[]' 2>/dev/null | grep -vE '^null$' | sed 's/^ *//; s/ *$//; /^$/d' )
  if [[ -z "${MN_WALLET_ADDR_ALT}" ]]
  then
    MN_WALLET_ADDR_ALT=$( echo "${MN_WALLET_ADDR}" | jq -r '.address' 2>/dev/null | grep -vE '^null$' | sed 's/^ *//; s/ *$//; /^$/d' )
  fi
  if [[ -z "${MN_WALLET_ADDR_ALT}" ]]
  then
    MN_WALLET_ADDR_ALT=$( echo "${MN_WALLET_ADDR}" | jq -r '.addr' 2>/dev/null | grep -vE '^null$' | sed 's/^ *//; s/ *$//; /^$/d' )
  fi
  MN_WALLET_ADDR="${MN_WALLET_ADDR_ALT}"
  # Get correct upper/lower case for the address.
  MN_WALLET_ADDR=$( echo "${OUTPUTIDX_RAW}" | jq '.' | grep -io -m 1 "${MN_WALLET_ADDR}" )

  OUTPUTIDX_CONFIRMS=$( echo "${OUTPUTIDX_RAW}" | tr '[:upper:]' '[:lower:]' | jq '.confirmations' 2>/dev/null )
  MN_WALLET_ADDR_BALANCE=''

  if [[ "${EXPLORER_URL}" == https://www.coinexplorer.net/api/v1/* ]]
  then
    MN_WALLET_ADDR_UNSPENT=$( wget -4qO- -T 15 -t 2 -o- "${EXPLORER_URL}address/unspent?address=${MN_WALLET_ADDR}" "${BAD_SSL_HACK}" | jq -r ".result[] | select( .txid == \"${TXHASH}\" ) | .time" 2>/dev/null )
    if [[ ! -z "${MN_WALLET_ADDR_UNSPENT}" ]]
    then
      echo "${OUTPUTIDX}"
      return
    else
      echo "txhash no longer holds the collateral."
      return 1
    fi
  else
    MN_WALLET_ADDR_DETAILS=$( wget -4qO- -T 15 -t 2 -o- "${EXPLORER_URL}${EXPLORER_GETADDRESS_PATH}${MN_WALLET_ADDR}" "${BAD_SSL_HACK}"  )
  fi
  sleep "${EXPLORER_SLEEP}"
  echo "${MN_WALLET_ADDR_DETAILS}" > "${TEMP_FILE}.${OUTPUTIDX}"

  ( echo "Getting info about the wallet address." >/dev/tty ) 2>/dev/null
  ( echo "${EXPLORER_URL}${EXPLORER_GETADDRESS_PATH}${MN_WALLET_ADDR}" >/dev/tty ) 2>/dev/null

  # Get address balance.
  if [[ -z "${MN_WALLET_ADDR_BALANCE}" ]]
  then
    MN_WALLET_ADDR_BALANCE=$( echo "${MN_WALLET_ADDR_DETAILS}" | jq -r ".balance" 2>/dev/null )
    if [[ ! "${MN_WALLET_ADDR_BALANCE}" =~ $RE_FLOAT ]]
    then
      MN_WALLET_ADDR_BALANCE=$( echo "${MN_WALLET_ADDR_DETAILS}" | jq -r ".data" 2>/dev/null )
    fi
    if [[ ! "${MN_WALLET_ADDR_BALANCE}" =~ $RE_FLOAT ]]
    then
      MN_WALLET_ADDR_BALANCE=${MN_WALLET_ADDR_DETAILS}
    fi
  fi

  if [[ "${MN_WALLET_ADDR_BALANCE}" == "null" ]] && [[ "${OUTPUTIDX_CONFIRMS}" -lt 10 ]]
  then
    echo "${OUTPUTIDX}"
    return
  fi
  MN_WALLET_ADDR_BALANCE=$( echo "${MN_WALLET_ADDR_BALANCE} / ${EXPLORER_AMOUNT_ADJUST}" | bc )
  while read -r COLLATERAL_LEVEL
  do
    if [[ $( echo "${MN_WALLET_ADDR_BALANCE}>=${COLLATERAL_LEVEL}" | bc ) -eq 1 ]]
    then
      echo "${OUTPUTIDX}"
      return
    fi
  done <<< "${COLLATERAL}"
  echo "txhash no longer holds the collateral; moved: ${TXHASH}."
  return 2
}

IS_PORT_OPEN() {
  PRIVIPADDRESS=${1}
  PORT_TO_TEST=${2}
  BIND=${3}
  VERBOSE=${4}
  INET=${5}
  PUB_IPADDRESS=${6}

  if [[ -z "${BIND}" ]]
  then
    if [[ ${PRIVIPADDRESS} =~ .*:.* ]]
    then
      PRIVIPADDRESS_SHORT=$( sipcalc "${PRIVIPADDRESS}" | grep -iF 'Compressed address' | cut -d '-' -f2 | awk '{print $1}' )
      BIND="\[${PRIVIPADDRESS_SHORT}\]:${PORT_TO_TEST}"
    else
      BIND="${PRIVIPADDRESS}:${PORT_TO_TEST}"
    fi
  fi

  # see if port is used.
  PORTS_USED=$( sudo -n ss -lpn 2>/dev/null | grep -P "${BIND} " )
  # see if netcat can bind to port.
  # shellcheck disable=SC2009
  NETCAT_PIDS=$( ps -aux | grep -E '[n]etcat.*\-p.*\-l' | awk '{print $2}' )

  # Clean start for netcat test.
  while read -r NETCAT_PID
  do
    kill -9 "${NETCAT_PID}" >/dev/null 2>&1
  done <<< "${NETCAT_PIDS}"

  NETCAT_TEST=$( sudo -n timeout --signal=SIGKILL 0.3s netcat -p "${PORT_TO_TEST}" -l "${PRIVIPADDRESS}" 2>&1 )
  NETCAT_PID=$!
  kill -9 "${NETCAT_PID}" >/dev/null 2>&1
  sleep 0.1

  # Clean up after.
  # shellcheck disable=SC2009
  NETCAT_PIDS=$( ps -aux | grep -E '[n]etcat.*\-p.*\-l' | awk '{print $2}' )
  while read -r NETCAT_PID
  do
    kill -9 "${NETCAT_PID}" >/dev/null 2>&1
  done <<< "${NETCAT_PIDS}"

  if [[ "${VERBOSE}" -eq 1 ]]
  then
  {
    echo
    echo "${INET} ${PUB_IPADDRESS} ${PRIVIPADDRESS}:${PORT_TO_TEST}"
    echo "netcat test"
    echo "${NETCAT_TEST}"
    echo "ports in use test"
    echo "${PORTS_USED}"
  } >>/tmp/ipv46-verbose.log
  fi

  # echo 0 if port is not open.
  if [[ "${#PORTS_USED}" -gt 10 ]] || [[ $( echo "${NETCAT_TEST}" | grep -ci 'in use' ) -gt 0 ]]
  then
    echo "0"
  else
    echo "${PORT_TO_TEST}"
  fi
}

FIND_FREE_PORT() {
  PRIVIPADDRESS=${1}
  if [[ -r /proc/sys/net/ipv4/ip_local_port_range ]]
  then
    read -r LOWERPORT UPPERPORT < /proc/sys/net/ipv4/ip_local_port_range
  fi
  if [[ ! $LOWERPORT =~ $RE ]] || [[ ! $UPPERPORT =~ $RE ]]
  then
    read -r LOWERPORT UPPERPORT <<< "$( sudo sysctl net.ipv4.ip_local_port_range | cut -d '=' -f2 )"
  fi
  if [[ ! $LOWERPORT =~ $RE ]] || [[ ! $UPPERPORT =~ $RE ]]
  then
    LOWERPORT=32769
    UPPERPORT=60998
  fi

  LAST_PORT=0
  while :
  do
    PORT_TO_TEST=$( shuf -i "${LOWERPORT}"-"${UPPERPORT}" -n 1 )
    while [[ "${LAST_PORT}" == "${PORT_TO_TEST}" ]]
    do
      PORT_TO_TEST=$( shuf -i "${LOWERPORT}"-"${UPPERPORT}" -n 1 )
      sleep 0.3
    done
    LAST_PORT="${PORT_TO_TEST}"
    if [[ $( IS_PORT_OPEN "${PRIVIPADDRESS}" "${PORT_TO_TEST}" | tail -n 1 ) -eq 0 ]]
    then
      continue
    fi
    if [[ $( IS_PORT_OPEN "127.0.0.1" "${PORT_TO_TEST}" | tail -n 1 ) -eq 0 ]]
    then
      continue
    fi
    if [[ $( IS_PORT_OPEN "0.0.0.0" "${PORT_TO_TEST}" | tail -n 1 ) -eq 0 ]]
    then
      continue
    fi
    if [[ $( IS_PORT_OPEN "::" "${PORT_TO_TEST}" "\[::.*\]:${PORT_TO_TEST}" | tail -n 1 ) -eq 0 ]]
    then
      continue
    fi
    break
  done
  echo "${PORT_TO_TEST}"
}

GET_FREE_IPV46() {
  IP_ADDRESSES=${1}
  PORT_TO_TEST=${2}
  VERBOSE=${3}
  OUTPUT_TEXT=''
  while read -r INET PUBIPADDRESS PRIVIPADDRESS
  do
    ( echo -e "Testing if port ${PORT_TO_TEST} on ${PRIVIPADDRESS} is open\\t\\r\\c" >/dev/tty ) 2>/dev/null
    if [[ $( IS_PORT_OPEN "${PRIVIPADDRESS}" "${PORT_TO_TEST}" "" "${VERBOSE}" "${INET}" "${PUB_IPADDRESS}" | tail -n 1 ) -eq 0 ]]
    then
      continue
    fi
    OUTPUT_TEXT=$( echo -e "${OUTPUT_TEXT}\\n${INET} ${PUBIPADDRESS} ${PRIVIPADDRESS}" )
  done <<< "${IP_ADDRESSES}"
  ( echo "" >/dev/tty ) 2>/dev/null
  echo "${OUTPUT_TEXT}" | sed '/^[[:space:]]*$/d'
}

GET_PUBLIC_IPV46() {
  IP_ADDRESSES=${1}
  VERBOSE=${2}
  OUTPUT_TEXT=''
  while read -r INET OTHER_IP
  do
    ( echo -e "Testing if ${OTHER_IP} is routable \\t\\r\\c" >/dev/tty ) 2>/dev/null
    PRIVIPADDRESS=''
    PUBIPADDRESS=''
    # Get public IP
    if [[ "${INET}" == "inet6" ]]
    then
      PUBIPADDRESS=$( timeout --signal=SIGKILL 10s wget -6qO- -T 10 -t 2 -o- "--bind-address=${OTHER_IP}" http://v6.ident.me )
    else
      PUBIPADDRESS=$( timeout --signal=SIGKILL 10s wget -4qO- -T 10 -t 2 -o- "--bind-address=${OTHER_IP}" http://ipinfo.io/ip )
    fi

    # See if public IP was found.
    if [[ -z "${PUBIPADDRESS}" ]]
    then
      if [[ "${VERBOSE}" -eq 1 ]]
      then
        if [[ "${INET}" == "inet6" ]]
        then
          echo -e "\\nwget -6qO- -T 10 -t 2 -o- \"--bind-address=${OTHER_IP}\" http://v6.ident.me\\nfailed" >>/tmp/ipv46-verbose.log
        else
          echo -e "\\nwget -4qO- -T 10 -t 2 -o- \"--bind-address=${OTHER_IP}\" http://ipinfo.io/ip\\nfailed" >>/tmp/ipv46-verbose.log
        fi
      fi
      continue
    fi

    PRIVIPADDRESS="${OTHER_IP}"
    OUTPUT_TEXT=$( echo -e "${OUTPUT_TEXT}\\n${INET} ${PUBIPADDRESS} ${PRIVIPADDRESS}" )
  done <<< "$( echo "${IP_ADDRESSES}" | cut -d '/' -f1 )"
  ( echo "" >/dev/tty ) 2>/dev/null
  echo "${OUTPUT_TEXT}" | sed '/^[[:space:]]*$/d'
}

FIND_OPEN_PORT_IPV46 () {
  local PRIVIPADDRESS
  local PUBIPADDRESS
  local INET
  local OTHER_IP
  local IPV6
  local OUTPUT_TEXT
  PORT_TO_TEST=${1}
  IPV4=${2}
  IPV6=${3}
  TOR=${4}
  MULTI_IP_MODE=${5}
  DAEMON_BIN=${6}
  VERBOSE=${7}
  OUTPUT_TEXT=''
  if [[ -z "${IPV4}" ]]
  then
    IPV4=0
  fi
  if [[ -z "${IPV6}" ]]
  then
    IPV6=0
  fi
  if [[ -z "${TOR}" ]]
  then
    TOR=0
  fi
  if [[ -z "${VERBOSE}" ]]
  then
    VERBOSE=0
  fi
  IPV4_ADDRESSES=''
  IPV6_ADDRESSES=''
  FREE_IPV4=''
  FREE_IPV6=''
  PUBLIC_IPV4=''
  PUBLIC_IPV6=''
  NEXT_DAEMON='N'
  PORT_TO_USE=${PORT_TO_TEST}

  RUNNING_NETWORK=$( sudo -n ss -lpn 2>/dev/null )
  # Get running daemons.
  RUNNING_DAEMONS=$( echo "${RUNNING_NETWORK}" | grep -F "\"${DAEMON_BIN}\"" | awk '{print $7 "\t" $5}' )
  # Get running on this port.
  PORT_IN_USE_BY=$( echo "${RUNNING_DAEMONS}" | awk '{print $2}' | grep ":${PORT_TO_TEST}$" )
  if [[ "${VERBOSE}" -eq 1 ]]
  then
    echo "
RUNNING_DAEMONS
>${RUNNING_DAEMONS}<

PORT_IN_USE_BY
>${PORT_IN_USE_BY}<"
  fi


  # Get number of daemon running on ipv4, ipv6, tor.

  if [[ "${IPV4}" -gt 0 ]]
  then
    ( echo "Testing IPv4 addresses" >/dev/tty ) 2>/dev/null
    echo -n "" > /tmp/ipv46-verbose.log
    IPV4_ADDRESSES=$( sudo ip -o addr show | grep -v 'inet6' | grep -v 'scope host' | grep -v 'scope link' | awk '{print $3 " " $4}' | sort -V )
    PUBLIC_IPV4=$( GET_PUBLIC_IPV46 "${IPV4_ADDRESSES}" "${VERBOSE}" | sed '/^[[:space:]]*$/d' )
    FREE_IPV4=$( GET_FREE_IPV46 "${PUBLIC_IPV4}" "${PORT_TO_TEST}" "${VERBOSE}" | sort -V | sed '/^[[:space:]]*$/d' )
    # shellcheck disable=SC2063
    RUNNING_IPV4_COUNT=$( echo "${RUNNING_DAEMONS}" | grep -vF '[' | grep -vF '*' | grep -c '.\|:' )
    # shellcheck disable=SC2063
    RUNNING_IPV4=$( echo "${RUNNING_DAEMONS}" | grep -vF '[' | grep -vF '*' )

    if [[ "${VERBOSE}" -eq 1 ]]
    then
      echo ""
      echo "IPV46 LOG"
      cat /tmp/ipv46-verbose.log
      echo "
RUNNING_DAEMONS
>${RUNNING_DAEMONS}<

IPV4_ADDRESSES
>${IPV4_ADDRESSES}<

PUBLIC_IPV4
>${PUBLIC_IPV4}<

FREE_IPV4
>${FREE_IPV4}<

RUNNING_IPV4_COUNT
>${RUNNING_IPV4_COUNT}<

RUNNING_IPV4
>${RUNNING_IPV4}<"
    fi

  fi
  if [[ "${IPV6}" -gt 0 ]]
  then
    ( echo "Testing IPv6 addresses" >/dev/tty ) 2>/dev/null
    echo -n "" > /tmp/ipv46-verbose.log
    IPV6_ADDRESSES=$( sudo ip -o addr show | grep 'inet6' | grep -v 'scope host' | grep -v 'scope link' | awk '{print $3 " " $4}' | sort -V )
    PUBLIC_IPV6=$( GET_PUBLIC_IPV46 "${IPV6_ADDRESSES}" "${VERBOSE}" | sed '/^[[:space:]]*$/d' )
    FREE_IPV6=$( GET_FREE_IPV46 "${PUBLIC_IPV6}" "${PORT_TO_TEST}" "${VERBOSE}" | sort -V | sed '/^[[:space:]]*$/d' )
    RUNNING_IPV6_COUNT=$( echo "${RUNNING_DAEMONS}" | grep -cF '[' )

    if [[ "${VERBOSE}" -eq 1 ]]
    then
      echo ""
      echo "IPV46 LOG"
      cat /tmp/ipv46-verbose.log
      echo "
RUNNING_DAEMONS
>${RUNNING_DAEMONS}<

IPV6_ADDRESSES
>${IPV6_ADDRESSES}<

PUBLIC_IPV6
>${PUBLIC_IPV6}<

FREE_IPV6
>${FREE_IPV6}<

RUNNING_IPV6_COUNT
>${RUNNING_IPV6_COUNT}<"
    fi

  fi
#   if [[ "${TOR}" -gt 0 ]]
#   then
#     RUNNING_DAEMONS_TOR=''
#     TOR_ADDRESSES=''
#     PUBLIC_TOR=''
#     FREE_TOR=''
#     RUNNING_TOR=''
#   fi
  if [[ -z "${RUNNING_IPV4_COUNT}" ]]
  then
    RUNNING_IPV4_COUNT=0
  fi
  if [[ -z "${RUNNING_IPV6_COUNT}" ]]
  then
    RUNNING_IPV6_COUNT=0
  fi
  if [[ -z "${RUNNING_TOR}" ]]
  then
    RUNNING_TOR=0
  fi

  if [[ "${IPV4}" -gt 0 ]] && [[ "${IPV6}" -eq 0 ]] && [[ "${TOR}" -eq 0 ]]
  then
    # Only IPv4 Support
    NEXT_DAEMON='4'
  elif [[ "${IPV4}" -eq 0 ]] && [[ "${IPV6}" -gt 0 ]] && [[ "${TOR}" -eq 0 ]]
  then
    # Only IPv6 Support
    NEXT_DAEMON='6'
  elif [[ "${IPV4}" -eq 0 ]] && [[ "${IPV6}" -eq 0 ]] && [[ "${TOR}" -gt 0 ]]
  then
    # Only TOR Support
    NEXT_DAEMON='T'

  elif [[ "${RUNNING_IPV4_COUNT}" -eq 0 ]] && [[ ! -z "${FREE_IPV4}" ]] && [[ "${IPV4}" -gt 0 ]]
  then
    # First one, use IPv4
    NEXT_DAEMON='4'
  elif [[ "${RUNNING_IPV6_COUNT}" -eq 0 ]] && [[ -z "${FREE_IPV6}" ]] && [[ "${IPV4}" -gt 0 ]]
  then
    # No IPv6 Support on VPS
    NEXT_DAEMON='4'
  elif [[ "${RUNNING_IPV4_COUNT}" -eq 0 ]] && [[ -z "${FREE_IPV4}" ]] && [[ "${IPV6}" -gt 0 ]]
  then
    # No IPv4 Support on VPS
    NEXT_DAEMON='6'
  elif [[ "${RUNNING_IPV6_COUNT}" -ge "${RUNNING_IPV4_COUNT}" ]] && [[ "${IPV4}" -gt 0 ]]
  then
    # More IPv4 than IPv6, use IPv6.
    NEXT_DAEMON='4'
  elif [[ "${RUNNING_IPV6_COUNT}" -lt "${RUNNING_IPV4_COUNT}" ]] && [[ "${IPV6}" -gt 0 ]]
  then
    # More IPv6 than IPv4, use IPv4.
    NEXT_DAEMON='6'
  fi

  if [[ "${VERBOSE}" -eq 1 ]]
  then
    echo "
NEXT_DAEMON
>${NEXT_DAEMON}<

MULTI_IP_MODE
>${MULTI_IP_MODE}<"
  fi

  FINAL_IP_ADDRESS=''
  if [[ "${NEXT_DAEMON}" == "4" ]]
  then

    PUBIPADDRESS=$( echo "${FREE_IPV4}" | awk '{print $2}' | head -n 1 )
    PRIVIPADDRESS=$( echo "${FREE_IPV4}" | awk '{print $3}' | head -n 1 )

    if [[ -z "${PUBIPADDRESS}" ]] || [[ -z "${PRIVIPADDRESS}" ]]
    then
      if [[ -z "${MULTI_IP_MODE}" ]] || [[ "${MULTI_IP_MODE}" -eq 0 ]] || [[ "${MULTI_IP_MODE}" -eq 1 ]]
      then
        FINAL_IP_ADDRESS=$( echo "${RUNNING_IPV4}" | grep -vF '0.0.0.0' | grep -vF '127.0.0.1' | cut -d ':' -f2 | awk '{print $2}' | sort -hr | uniq -c | sort -hr | tail -n 1 | awk '{print $2}' )
        if [[ "${#FINAL_IP_ADDRESS}" -lt 8 ]]
        then
          FINAL_IP_ADDRESS=$( echo "${PUBLIC_IPV4}" | awk '{print $3}' | head -n 1 )
        fi
        PUBIPADDRESS=$( echo "${PUBLIC_IPV4}" | grep -E "${FINAL_IP_ADDRESS}$" | awk '{print $2}' )
        PRIVIPADDRESS=${FINAL_IP_ADDRESS}
        # Find open port.
        PORT_TO_USE=$( FIND_FREE_PORT "${PRIVIPADDRESS}" | tail -n 1 )

        if [[ "${VERBOSE}" -eq 1 ]]
        then
          echo "
FINAL_IP_ADDRESS
>${FINAL_IP_ADDRESS}<

PUBIPADDRESS
>${PUBIPADDRESS}<

PRIVIPADDRESS
>${PRIVIPADDRESS}<

PORT_TO_USE
>${PORT_TO_USE}<"
        fi

      elif [[ "${IPV6}" -gt 0 ]] && [[ ! -z "${PUBLIC_IPV6}" ]]
      then
        NEXT_DAEMON='6'
      elif [[ "${TOR}" -gt 0 ]]
      then
        NEXT_DAEMON='T'
      else
        NEXT_DAEMON='N'
      fi
    fi
  fi

  ( echo "Going to use a IPv${NEXT_DAEMON} address" >/dev/tty ) 2>/dev/null

  if [[ "${NEXT_DAEMON}" == "6" ]] && [[ ! -z "${PUBLIC_IPV6}" ]]
  then
    FINAL_IP_ADDRESS=$( echo "${FREE_IPV6}" | head -n 1 | awk '{print $2}' )
    if [[ "${#FINAL_IP_ADDRESS}" -gt 7 ]]
    then
      PRIVIPADDRESS=$( echo "${IPV6_ADDRESSES}" | grep -iF "${FINAL_IP_ADDRESS}/" | cut -d '/' -f1 | awk '{print $2}' )
      PUBIPADDRESS=${FINAL_IP_ADDRESS}
    fi

    if [[ "${VERBOSE}" -eq 1 ]]
    then
      echo "
FINAL_IP_ADDRESS
>${FINAL_IP_ADDRESS}<

PUBIPADDRESS
>${PUBIPADDRESS}<

PRIVIPADDRESS
>${PRIVIPADDRESS}<"
    fi

    if [[ -z "${PUBIPADDRESS}" ]] || [[ -z "${PRIVIPADDRESS}" ]]
    then
      # Get Private IPv6 Address
      IPV6_BASE=$( echo "${PUBLIC_IPV6}" | awk '{print $3}' )
      # Get Private IPv6 Address with subnet.
      IPV6_BASE=$( echo "${IPV6_ADDRESSES}" | awk '{print $2}' | grep -iF "${IPV6_BASE}/" | grep -v '/128' | grep -v '/127' | tail -n 1 )
      # Get Private IPv6 Address interface name.
      IPV6_INTERFACE=$( sudo ip -o addr show | grep -iF "${IPV6_BASE}" | awk '{print $2}' )

      if [[ "${VERBOSE}" -eq 1 ]]
      then
        echo "
IPV6_BASE
>${IPV6_BASE}<

IPV6_INTERFACE
>${IPV6_INTERFACE}<"
      fi

      # Install needed libraries.
      if [[ $( dpkg -l python3-pip | grep -ciF "python3-pip" ) -eq 0 ]] || \
        [[ $( dpkg -l python-pip | grep -ciF "python-pip" ) -eq 0 ]] || \
        [[ $( dpkg -l subnetcalc | grep -ciF "subnetcalc" ) -eq 0 ]] || \
        [[ $( dpkg -l sipcalc | grep -ciF "sipcalc" ) -eq 0 ]] || \
        [[ $( dpkg -l python-yaml | grep -ciF "python-yaml" ) -eq 0 ]]
      then
        WAIT_FOR_APT_GET >/dev/null 2>&1
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq \
          python3-pip \
          python-pip \
          subnetcalc \
          sipcalc \
          python-yaml >/dev/null 2>&1
      fi
      if [[ $( pip list 2>/dev/null | grep -ciF "pyaml" ) -eq 0 ]]
      then
        pip install pyaml >/dev/null 2>&1
      fi

      # Get ipv6 subnet info.
      SUBNET_CALC=$( subnetcalc "${IPV6_BASE}" )
#       IPV6_BASE_START=$( echo "${SUBNET_CALC}" | grep 'Host Range' | awk '{print $5}' )
      IPV6_BASE_END=$( echo "${SUBNET_CALC}" | grep 'Host Range' | awk '{print $7}' )
      IPV6_BASE_BITS=$( echo "${SUBNET_CALC}" | grep 'Hosts Bits' | cut -d '=' -f2 | awk '{print $1}' )
      IPV6_BASE_NEXT=$( echo "${IPV6_BASE}" | cut -d '/' -f1 )
      IPV6_NETWORK=$( echo "${SUBNET_CALC}" | grep Network | cut -d '=' -f2 | awk '{print $1}' | sed 's/\:\://g' )

      # Get the next interface to add.
      NEW_IP=1
      while [[ $( echo "${IPV6_ADDRESSES}" | grep -cF "${IPV6_BASE_NEXT}/" ) -gt 0 ]]
      do
        sleep 0.1
        LAST_HEX=$( echo "${IPV6_BASE_NEXT}" | grep -o ':[0-9a-f]*$' | cut -d ':' -f2 | tr '[:lower:]' '[:upper:]' )
        LAST_HEX=$( echo "obase=ibase=16; ${LAST_HEX} + 1" | bc )
        IPV6_BASE_NEXT=$( echo "${IPV6_BASE_NEXT}" | sed "s/\\:\\([a-f0-9]*\\)$/\\:${LAST_HEX}/g" | tr '[:upper:]' '[:lower:]' )
        if [[ "${IPV6_BASE_NEXT}" == "${IPV6_BASE_END}" ]]
        then
          NEXT_DAEMON='N'
          NEW_IP=0
          IPV6_BASE_NEXT=''
        fi

        if [[ "${VERBOSE}" -eq 1 ]]
        then
          echo "
IPV6_ADDRESSES
>${IPV6_ADDRESSES}<

IPV6_BASE_NEXT
>${IPV6_BASE_NEXT}<"
        fi
      done

      # Add the interface
      if [[ "${NEW_IP}" -eq 1 ]]
      then
        if [ -x "$( command -v netplan )" ]
        then
          cat > ~/mnipyaml.py <<"EOF"
#!/usr/bin/env python
import pyaml
import yaml
import sys
with open(sys.argv[1], 'r') as stream:
  try:
    config = yaml.safe_load(stream)
    if sys.argv[2] == "":
      if len(config['network']['ethernets']) == 1:
        sys.argv[2] = next(iter(config['network']['ethernets']))
    if sys.argv[3] not in config['network']['ethernets'][sys.argv[2]]['addresses']:
      config['network']['ethernets'][sys.argv[2]]['addresses'].append(sys.argv[3])
      print pyaml.dump(config)
      newconfig = open(sys.argv[1], 'w')
      newconfig.write(pyaml.dump(config))
  except yaml.YAMLError as exc:
    print(exc)
EOF

          SIP_CALC=$( sipcalc "${IPV6_BASE}" )
          TARGET_FILE=$( grep -rliF "${IPV6_INTERFACE}" '/etc/netplan/'  | head -n 1 )
          IPV6_NETWORK_EXPANDED=$( echo "${SIP_CALC}" | grep -i '^Expanded Address' | cut -d '-' -f2 | awk '{print $1}' )
          if [[ -z "${TARGET_FILE}" ]]
          then
            TARGET_FILE=$( grep -rliF "${IPV6_NETWORK}" '/etc/netplan/'  | head -n 1 )
            IPV6_INTERFACE=''
          fi
          if [[ -z "${TARGET_FILE}" ]]
          then
            TARGET_FILE=$( grep -rliF "${IPV6_NETWORK_EXPANDED}" '/etc/netplan/'  | head -n 1 )
            IPV6_INTERFACE=''
          fi

          TARGET_FILE_BASENAME=$( basename "${TARGET_FILE}" )
          cp "${TARGET_FILE}" "/tmp/${TARGET_FILE_BASENAME}.bak"
          ( python ~/mnipyaml.py "${TARGET_FILE}" "${IPV6_INTERFACE}" "${IPV6_BASE_NEXT}/${IPV6_BASE_BITS}" >/dev/tty ) 2>/dev/null
          ( netplan apply >/dev/tty 2>&1 ) 2>/dev/null
          rm ~/mnipyaml.py >/dev/null 2>&1
          sleep 1

        if [[ "${VERBOSE}" -eq 1 ]]
        then
          echo "
IPV6_NETWORK
>${IPV6_NETWORK}<

IPV6_INTERFACE
>${IPV6_INTERFACE}<

TARGET_FILE
>${TARGET_FILE}<"
        fi


          COUNTER=0
          PUBIPADDRESS=$( timeout --signal=SIGKILL 10s wget -6qO- -T 10 -t 2 -o- "--bind-address=${IPV6_BASE_NEXT}" http://v6.ident.me )
          while [[ -z "${PUBIPADDRESS}" ]]
          do
            COUNTER=$(( COUNTER + 1 ))
            if [[ "${COUNTER}" -gt 10 ]]
            then
              break
            fi
            ( netplan apply >/dev/tty 2>&1 ) 2>/dev/null
            sleep ${COUNTER}
            PUBIPADDRESS=$( timeout --signal=SIGKILL 10s wget -6qO- -T 10 -t 2 -o- "--bind-address=${IPV6_BASE_NEXT}" http://v6.ident.me )
          done
          if [[ -z "${PUBIPADDRESS}" ]]
          then
            cp "/tmp/${TARGET_FILE_BASENAME}.bak" "${TARGET_FILE}"
            netplan apply >/dev/null 2>&1
            NEXT_DAEMON="N"
          fi
          rm -f "/tmp/${TARGET_FILE_BASENAME}.bak"

        else
          if [[ -z "${MULTI_IP_MODE}" ]] || [[ "${MULTI_IP_MODE}" -eq 0 ]] || [[ "${MULTI_IP_MODE}" -eq 1 ]]
          then
            # Use existing IPv6 address with another port.
            PUBIPADDRESS=$( echo "${IPV6_BASE}" | cut -d '/' -f1)
            PRIVIPADDRESS=$( echo "${IPV6_BASE}" | cut -d '/' -f1)
            IPV6_BASE_NEXT=$( echo "${IPV6_BASE}" | cut -d '/' -f1)
            # Find open port.
            PORT_TO_USE=$( FIND_FREE_PORT "${PRIVIPADDRESS}" | tail -n 1 )

          else
            # Create a new IPv6 address.
            # Get Config file.
            SIP_CALC=$( sipcalc "${IPV6_BASE}" )
            TARGET_FILE=$( grep -rliF "${IPV6_INTERFACE}" '/etc/network/'  | head -n 1 )
            IPV6_NETWORK_EXPANDED=$( echo "${SIP_CALC}" | grep -i '^Expanded Address' | cut -d '-' -f2 | awk '{print $1}' )
            if [[ -z "${TARGET_FILE}" ]]
            then
              TARGET_FILE=$( grep -rliF "${IPV6_NETWORK}" '/etc/network/'  | head -n 1 )
              IPV6_INTERFACE=''
            fi
            if [[ -z "${TARGET_FILE}" ]]
            then
              TARGET_FILE=$( grep -rliF "${IPV6_NETWORK_EXPANDED}" '/etc/network/'  | head -n 1 )
              IPV6_INTERFACE=''
            fi

            # Backup config.
            TARGET_FILE_BASENAME=$( basename "${TARGET_FILE}" )
            cp "${TARGET_FILE}" "/tmp/${TARGET_FILE_BASENAME}.bak"

            # Generate configuration for this IP
            NAMESERVER_IP=$( grep '.*:.*:' /etc/resolv.conf | awk '{print $2}' | head -n 1 )
            GATEWAY=$( route -A inet6 | awk '{print $2 }' | grep -v '^::' | tail -n 1 )
_ADD_IPV6_NET=$( cat << ADD_IPV6_NET
# Start of function for ${IPV6_BASE_NEXT}.
iface ${IPV6_INTERFACE} inet6 static
        address ${IPV6_BASE_NEXT}
        netmask ${IPV6_BASE_BITS}
        gateway ${GATEWAY}
        autoconf 0
        dns-nameservers ${NAMESERVER_IP}
# End of function for ${IPV6_BASE_NEXT}.
ADD_IPV6_NET
)
            # Add IP
            UPDATE_USER_FILE "${_ADD_IPV6_NET}" "${IPV6_BASE_NEXT}" "${TARGET_FILE}"
            # Test IP.
            COUNTER=0
            PUBIPADDRESS=$( timeout --signal=SIGKILL 10s wget -6qO- -T 10 -t 2 -o- "--bind-address=${IPV6_BASE_NEXT}" http://v6.ident.me )
            while [[ -z "${PUBIPADDRESS}" ]]
            do
              COUNTER=$(( COUNTER + 1 ))
              if [[ "${COUNTER}" -gt 10 ]]
              then
                break
              fi
              sudo service networking restart >/dev/null 2>&1
              sleep ${COUNTER}
              PUBIPADDRESS=$( timeout --signal=SIGKILL 10s wget -6qO- -T 10 -t 2 -o- "--bind-address=${IPV6_BASE_NEXT}" http://v6.ident.me )
            done
            if [[ -z "${PUBIPADDRESS}" ]]
            then
              cp "/tmp/${TARGET_FILE_BASENAME}.bak" "${TARGET_FILE}"
              sudo service networking restart >/dev/null 2>&1
              NEXT_DAEMON="N"
            fi
            rm -f "/tmp/${TARGET_FILE_BASENAME}.bak"
          fi
        fi
      fi
      PUBIPADDRESS=${IPV6_BASE_NEXT}
      PRIVIPADDRESS=${IPV6_BASE_NEXT}

      if [[ "${VERBOSE}" -eq 1 ]]
      then
        echo "
PUBIPADDRESS
>${PUBIPADDRESS}<

PRIVIPADDRESS
>${PRIVIPADDRESS}<"
      fi
    fi
  fi

  if [[ "${NEXT_DAEMON}" == "N" ]]
  then
    return
  fi

  if [[ ! -z "${PUBIPADDRESS}" ]]
  then
    echo "${NEXT_DAEMON} ${PUBIPADDRESS} ${PRIVIPADDRESS} ${PORT_TO_USE}"
  fi

  rm -f /tmp/ipv46-verbose.log
}

GENERATE_SCRIPT () {

  RED='\033[0;31m'
  NC='\033[0m'

  if [[ -z "${DAEMON_BIN}" ]]
  then
    echo -e "${RED}No Daemon Bin Found!${NC}"
  else
    echo "${DAEMON_BIN}"
  fi
  if [[ -z "${CONTROLLER_BIN}" ]]
  then
    echo -e "${RED}No Controller Bin Found!${NC}"
  else
    echo "${CONTROLLER_BIN}"
  fi
  echo
  echo "Getting the block count from the explorer."
  if [[ "${EXPLORER_URL}" == https://www.coinexplorer.net/api/v1/* ]]
  then
    BLOCKCOUNT=$( timeout --signal=SIGKILL 15s wget -4qO- -T 15 -t 2 -o- "${EXPLORER_URL}block/latest" "${BAD_SSL_HACK}" | jq -r '.result.height' | tr -d '[:space:]' )
  else
    BLOCKCOUNT=$( timeout --signal=SIGKILL 15s wget -4qO- -T 15 -t 2 -o- "${EXPLORER_URL}${EXPLORER_BLOCKCOUNT_PATH}" "${BAD_SSL_HACK}" | tr -d '[:space:]' )
  fi

  EXTRA_LINES=''
  if [[ ! "${BLOCKCOUNT}" =~ ${RE} ]]
  then
    echo -e "${RED}${BLOCKCOUNT}${NC}"
    EXTRA_LINES="
EXPLORER_BLOCKCOUNT_PATH=''
EXPLORER_RAWTRANSACTION_PATH=''
EXPLORER_RAWTRANSACTION_PATH_SUFFIX=' '
EXPLORER_GETADDRESS_PATH=''
EXPLORER_BLOCKCOUNT_OFFSET='+0'
BAD_SSL_HACK='--no-check-certificate'
"
  else
    echo "${BLOCKCOUNT}"
  fi

  echo
  echo
  echo "# Github user and project."
  if [[ -z "${GITHUB_REPO}" ]]
  then
    echo -e "${RED}GITHUB_REPO='${GITHUB_REPO}'${NC}"
  else
    echo "GITHUB_REPO='${GITHUB_REPO}'"
  fi
  echo "# Display Name."
  if [[ -z "${DAEMON_NAME}" ]]
  then
    echo -e "${RED}DAEMON_NAME='${DAEMON_NAME}'${NC}"
  else
    echo "DAEMON_NAME='${DAEMON_NAME}'"
  fi
  echo "# Coin Ticker."
  if [[ -z "${TICKER}" ]]
  then
    echo -e "${RED}TICKER='${TICKER}'${NC}"
  else
    echo "TICKER='${TICKER}'"
  fi
  echo "# Binary base name."
    if [[ -z "${BIN_BASE}" ]]
  then
    echo -e "${RED}BIN_BASE='${BIN_BASE}${NC}"
  else
    echo "BIN_BASE='${BIN_BASE}'"
  fi
  echo "# Directory."
  if [[ -z "${DIRECTORY}" ]]
  then
    echo -e "${RED}DIRECTORY='${DIRECTORY}'${NC}"
  else
    echo "DIRECTORY='${DIRECTORY}'"
  fi
  echo "# Conf File."
  if [[ -z "${CONF}" ]]
  then
    echo -e "${RED}CONF='${CONF}'${NC}"
  else
    echo "CONF='${CONF}'"
  fi
  echo "# Port."
  if [[ -z "${DEFAULT_PORT}" ]]
  then
    echo -e "${RED}DEFAULT_PORT=${DEFAULT_PORT}${NC}"
  else
    echo "DEFAULT_PORT=${DEFAULT_PORT}"
  fi
  echo "# Explorer URL"
  if [[ -z "${EXPLORER_URL}" ]]
  then
    echo -e "${RED}EXPLORER_URL='${EXPLORER_URL}'${EXTRA_LINES}${NC}"
  else
    echo "EXPLORER_URL='${EXPLORER_URL}'${EXTRA_LINES}"
  fi
  echo "# Amount of Collateral needed."
  if [[ -z "${COLLATERAL}" ]]
  then
    echo -e "${RED}COLLATERAL=${COLLATERAL}${NC}"
  else
    echo "COLLATERAL=${COLLATERAL}"
  fi
  echo "# Direct Daemon Download if github has no releases."
  echo "DAEMON_DOWNLOAD=''"
  echo "# Blocktime in seconds."
  if [[ -z "${BLOCKTIME}" ]]
  then
      echo -e "${RED}BLOCKTIME=${BLOCKTIME}${NC}"
  else
    echo "BLOCKTIME=${BLOCKTIME}"
  fi
  echo

  BIN_BASE_LOWER=$( echo "${BIN_BASE}" | tr '[:upper:]' '[:lower:]' )
  BIN_BASE_UPPER=$( echo "${BIN_BASE}" | tr '[:lower:]' '[:upper:]' )

  ASCII_ART_TEXT=$( echo -e "\\n ${DAEMON_NAME}" )
  if [ ! -x "$( command -v figlet )" ]
  then
    WAIT_FOR_APT_GET
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq figlet
  fi
  if [ -x "$( command -v figlet )" ]
  then
    ASCII_ART_TEXT=$( figlet "${DAEMON_NAME}" | sed '/^[[:space:]]*$/d' )
  fi

  EXTRA_CONFIG_GEN=''
  if [[ "${DAEMON_BIN}" == "${CONTROLLER_BIN}" ]]
  then
    EXTRA_CONFIG_GEN=$( echo -e "${EXTRA_CONFIG_GEN}\\n# Control Binary." )
    EXTRA_CONFIG_GEN=$( echo -e "${EXTRA_CONFIG_GEN}\\nCONTROLLER_BIN='${CONTROLLER_BIN}'" )
  fi

  if [[ ! -z "${SENTINEL_GITHUB}" ]] && [[ ! -z "${SENTINEL_CONF_START}" ]]
  then
    EXTRA_CONFIG_GEN=$( echo -e "${EXTRA_CONFIG_GEN}\\n# Sentinel Info." )
    EXTRA_CONFIG_GEN=$( echo -e "${EXTRA_CONFIG_GEN}\\nSENTINEL_GITHUB='${SENTINEL_GITHUB}'" )
    EXTRA_CONFIG_GEN=$( echo -e "${EXTRA_CONFIG_GEN}\\nSENTINEL_CONF_START='${SENTINEL_CONF_START}'" )
  fi

MN_DAEMON_FILE=$( cat << MN_DAEMON_FILE
#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

\`\`\`
bash -ic "\$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/${BIN_BASE_LOWER}d.sh)" ; source ~/.bashrc
\`\`\`

'

# Github user and project.
GITHUB_REPO='${GITHUB_REPO}'
# Display Name.
DAEMON_NAME='${DAEMON_NAME}'
# Coin Ticker.
TICKER='${TICKER}'
# Binary base name.
BIN_BASE='${BIN_BASE}'
# Directory.
DIRECTORY='${DIRECTORY}'
# Conf File.
CONF='${CONF}'
# Port.
DEFAULT_PORT=${DEFAULT_PORT}
# Explorer URL.
EXPLORER_URL='${EXPLORER_URL}'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Amount of Collateral needed.
COLLATERAL=${COLLATERAL}
# Direct Daemon Download if github has no releases.
DAEMON_DOWNLOAD=''
# Blocktime in seconds.
BLOCKTIME=${BLOCKTIME}
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Multiple on single IP.
MULTI_IP_MODE=1
${EXTRA_CONFIG_GEN}

# Tip Address.
TIPS=''
# Dropbox Addnodes.
DROPBOX_ADDNODES=''
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP=''
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS=''

ASCII_ART () {
echo -e "\\e[0m"
clear 2> /dev/null
cat << "${BIN_BASE_UPPER}"
${ASCII_ART_TEXT}

${BIN_BASE_UPPER}
}

# Discord User Info
# @mcarper#0918
# 401161988744544258
cd ~/ || exit
COUNTER=0
rm -f ~/___mn.sh
while [[ ! -f ~/___mn.sh ]] || [[ \$( grep -Fxc "# End of masternode setup script." ~/___mn.sh ) -eq 0 ]]
do
  rm -f ~/___mn.sh
  echo "Downloading Masternode Setup Script."
  wget -4qo- gist.githubusercontent.com/mikeytown2/1637d98130ac7dfbfa4d24bac0598107/raw/mcarper.sh -O ~/___mn.sh
  COUNTER=$((COUNTER+1))
  if [[ "\${COUNTER}" -gt 3 ]]
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

MN_DAEMON_FILE
)

  if [[ ! -f "/root/${BIN_BASE_LOWER}d.sh" ]]
  then
    {
      echo "${MN_DAEMON_FILE}"; echo ""
    } >> "/root/${BIN_BASE_LOWER}d.sh"
  fi

  DAEMON_DOWNLOAD_SUPER "${GITHUB_REPO}" "${BIN_BASE}" "${DAEMON_DOWNLOAD}"

}

if [[ "${ARG1}" == 'PORT_TEST' ]]
then
  FIND_OPEN_PORT_IPV46 "${ARG2}" "${ARG3}" "${ARG4}" "${ARG5}" "${6}" "${7}" "${8}"
  return 1 2>/dev/null || exit 1
fi

ADD_APPARMOR_CONF () {
  APPARMOR_USRNAME=${1}
  APPARMOR_DIRECTORY=${2}
  APPARMOR_CONF=${3}
  DAEMON_FULL=${4}
  CONTROLLER_FULL=${5}
  SENTINEL_FULL=${6}
  APPARMOR_CONF_SYSTEMD=${7}

  USR_HOME="$( getent passwd "${APPARMOR_USRNAME}" | cut -d: -f6 )"

  DATE=$( date -u +'%a %b %e %H:%M:%S %Y' )

  if [[ -z "${SENTINEL_FULL}" ]]
  then
    SENTINEL_FULL="${USR_HOME}/sentinel/venv/bin/python2"
  fi
  if [[ -z "${SENTINEL_PY}" ]]
  then
    SENTINEL_PY="${USR_HOME}/sentinel/bin/sentinel.py"
  fi
  if [[ -z "${SENTINEL_BASE_DIR}" ]]
  then
    SENTINEL_BASE_DIR="${USR_HOME}/sentinel/"
  fi

  if [[ -z "${APPARMOR_CONF_SYSTEMD}" ]]
  then
    APPARMOR_CONF_SYSTEMD="/etc/apparmor.d/multi-masternode-data"
  fi

  if [[ ! -f "${APPARMOR_CONF_SYSTEMD}" ]]
  then
  cat << APPARMOR_HEADER | sudo tee "${APPARMOR_CONF_SYSTEMD}" >/dev/null
# Last Modified: ${DATE}
#include <tunables/global>

APPARMOR_HEADER
  fi

  if [[ ${#DAEMON_FULL} -gt 2 ]]
  then
    echo "Adding apparmor for ${DAEMON_FULL}"
    if [[ $( grep -c -m 1 "${DAEMON_FULL}" "${APPARMOR_CONF_SYSTEMD}" ) -gt 0 ]]
    then
      START=$( grep -Fxn "${DAEMON_FULL} {" "${APPARMOR_CONF_SYSTEMD}"  | sed 's/:/ /g' | awk '{print $1 }' )
      if [[ "${START}" -gt 0 ]]
      then
        END=$( tail -n "+${START}" "${APPARMOR_CONF_SYSTEMD}" | grep -xn -m 1 '^}$' | sed 's/:/ /g' | awk '{print $1 }' )
      fi
      if [[ "${END}" -gt 0 ]]
      then
        END=$(( START + END - 1 ))
        sudo sed -i "${START},${END}d" "${APPARMOR_CONF_SYSTEMD}"
      fi
    fi

    sudo sed -i "1s/.*/# Last Modified: ${DATE}/" "${APPARMOR_CONF_SYSTEMD}"
    cat << APPARMOR_DAEMON | sudo tee -a "${APPARMOR_CONF_SYSTEMD}" >/dev/null
${DAEMON_FULL} {
  #include <abstractions/apache2-common>
  #include <abstractions/base>
  #include <abstractions/user-tmp>

  deny capability dac_override,

  ${USR_HOME}/* r,
  ${USR_HOME}/${APPARMOR_DIRECTORY}/ rwk,
  ${USR_HOME}/${APPARMOR_DIRECTORY}/** rwk,
  ${DAEMON_FULL} mr,
  /lib/x86_64-linux-gnu/ld-*.so mr,
  owner ${USR_HOME}/${APPARMOR_DIRECTORY}/ rwk,
  owner ${USR_HOME}/${APPARMOR_DIRECTORY}/** rwk,
}

APPARMOR_DAEMON
  fi

  if [[ ${#CONTROLLER_FULL} -gt 2 ]] && [[ "${CONTROLLER_FULL}" != "${DAEMON_FULL}" ]]
  then
    echo "Adding apparmor for ${CONTROLLER_FULL}"
    if [[ $( grep -c -m 1 "${CONTROLLER_FULL}" "${APPARMOR_CONF_SYSTEMD}" ) -gt 0 ]]
    then
      START=$( grep -Fxn "${CONTROLLER_FULL} {" "${APPARMOR_CONF_SYSTEMD}"  | sed 's/:/ /g' | awk '{print $1 }' )
      if [[ "${START}" -gt 0 ]]
      then
        END=$( tail -n "+${START}" "${APPARMOR_CONF_SYSTEMD}" | grep -xn -m 1 '^}$' | sed 's/:/ /g' | awk '{print $1 }' )
      fi
      if [[ "${END}" -gt 0 ]]
      then
        END=$(( START + END - 1 ))
        sudo sed -i "${START},${END}d" "${APPARMOR_CONF_SYSTEMD}"
      fi
    fi

    sudo sed -i "1s/.*/# Last Modified: ${DATE}/" "${APPARMOR_CONF_SYSTEMD}"
    cat << APPARMOR_CLI | sudo tee -a "${APPARMOR_CONF_SYSTEMD}" >/dev/null
${CONTROLLER_FULL} {
  #include <abstractions/base>
  #include <abstractions/nameservice>

  deny capability dac_override,

  ${CONTROLLER_FULL} mr,
  /lib/x86_64-linux-gnu/ld-*.so mr,
  ${USR_HOME}/${APPARMOR_DIRECTORY}/ rw,
  ${USR_HOME}/${APPARMOR_DIRECTORY}/** rw,
  owner ${USR_HOME}/${APPARMOR_DIRECTORY}/ rw,
  owner ${USR_HOME}/${APPARMOR_DIRECTORY}/** rw,
}

APPARMOR_CLI
  fi

  if [[ -s "${SENTINEL_FULL}" ]] || [[ -s "${SENTINEL_PY}" ]]
  then
    echo "Adding apparmor for ${SENTINEL_FULL}"
    if [[ $( grep -c -m 1 "${SENTINEL_FULL}" "${APPARMOR_CONF_SYSTEMD}" ) -gt 0 ]]
    then
      START=$( grep -Fxn "${SENTINEL_FULL} {" "${APPARMOR_CONF_SYSTEMD}"  | sed 's/:/ /g' | awk '{print $1 }' )
      if [[ "${START}" -gt 0 ]]
      then
        END=$( tail -n "+${START}" "${APPARMOR_CONF_SYSTEMD}" | grep -xn -m 1 '^}$' | sed 's/:/ /g' | awk '{print $1 }' )
      fi
      if [[ "${END}" -gt 0 ]]
      then
        END=$(( START + END - 1 ))
        sudo sed -i "${START},${END}d" "${APPARMOR_CONF_SYSTEMD}"
      fi
    fi

    sudo sed -i "1s/.*/# Last Modified: ${DATE}/" "${APPARMOR_CONF_SYSTEMD}"
    cat << APPARMOR_SENTINEL | sudo tee -a "${APPARMOR_CONF_SYSTEMD}" >/dev/null
${SENTINEL_FULL} {
  #include <abstractions/base>
  #include <abstractions/bash>
  #include <abstractions/consoles>
  #include <abstractions/nameservice>
  #include <abstractions/python>
  #include <abstractions/user-tmp>

  /bin/dash mrix,
  /bin/uname Ux,
  /etc/ r,
  /etc/mime.types r,
  /etc/debian_version r,
  ${USR_HOME}/${APPARMOR_DIRECTORY}/${APPARMOR_CONF} r,
  ${USR_HOME}/.cache/ w,
  ${SENTINEL_BASE_DIR}** rw,
  ${SENTINEL_BASE_DIR}database/sentinel.db rwk,
  ${SENTINEL_FULL} mr,
  ${SENTINEL_BASE_DIR}venv/lib/python2.7/site-packages/simplejson/_speedups.so mrw,
  /lib/x86_64-linux-gnu/ld-*.so mr,
  /proc/*/status r,
  /sbin/ldconfig mrix,
  /sbin/ldconfig.real mrix,
  /usr/bin/ r,
  /usr/bin/lsb_release Ux,
  /usr/bin/x86_64-linux-gnu-gcc-7 Ux,
  /usr/share/distro-info/debian.csv r,
  /usr/share/python-wheels/ r,
  /usr/share/python-wheels/* r,
  owner ${USR_HOME}/ r,
  owner ${USR_HOME}/.cache/pip/** r,
  owner ${USR_HOME}/.cache/pip/** w,
  owner ${USR_HOME}/${APPARMOR_DIRECTORY}/${APPARMOR_CONF} r,
  owner ${SENTINEL_BASE_DIR} rwk,
  owner ${SENTINEL_BASE_DIR}** rwk,
  owner /proc/*/mounts r,
}

APPARMOR_SENTINEL
  fi

  echo "Reload apparmor."
  sudo systemctl reload apparmor.service
}

SENTINEL_GENERIC_SETUP () {
  local USRNAME
  local SENTINEL_GITHUB
  local SENTINEL_CONF_START
  USRNAME=${1}
  SENTINEL_GITHUB=${2}
  SENTINEL_CONF_START=${3}
  CONF_LOCATION=${4}

  if ! id "${USRNAME}" >/dev/null 2>&1
  then
    echo "The user ${USRNAME} does not exist."
    return
  fi

  USR_HOME="$( getent passwd "${USRNAME}" | cut -d: -f6 )"
  if [[ ! -d "${USR_HOME}" ]]
  then
    echo "The folder ${USR_HOME} does not exist."
    return
  fi

  if [[ ! "${SENTINEL_GITHUB}" == http* ]]
  then
    SENTINEL_GITHUB=$( echo "github.com/${SENTINEL_GITHUB}" | sed 's,//,/,g' )
    SENTINEL_GITHUB="https://${SENTINEL_GITHUB}"
  fi

  # Get Repo.
  echo

  echo "Removing ${USR_HOME}/sentinel/"
  rm -rf "${USR_HOME:?}/sentinel/"
  echo "Getting sentinel from ${SENTINEL_GITHUB}."
  git clone "${SENTINEL_GITHUB}" "${USR_HOME}/sentinel/"
  git -C "${USR_HOME}/sentinel/" clean -x -f -d
  git -C "${USR_HOME}/sentinel/" reset --hard
  echo "Chown."
  sudo chown -R "${USRNAME}":"${USRNAME}" "${USR_HOME}/"

  if [[ ! -f "${USR_HOME}/sentinel/lib/init.py" ]]
  then
    echo "git clone ${SENTINEL_GITHUB} ${USR_HOME}/sentinel/ failed"
    return
  fi

  if [[ -z "${SENTINEL_CONF_START}" ]]
  then
    # Get conf line.
    SENTINEL_CONF_START=$(  grep -Fi 'io.open(config.' "${USR_HOME}/sentinel/lib/init.py" | grep -o '(.*)' | sed 's/config\.//g' | tr '(' ' ' | tr ')' ' ' | awk '{print $1}' )
  fi

  if [[ -z "${CONF_LOCATION}" ]]
  then
    # shellcheck disable=SC1090
    source "${HOME}/.bashrc"
    if [[ -f /var/multi-masternode-data/.bashrc ]]
    then
      # shellcheck disable=SC1091
      source /var/multi-masternode-data/.bashrc
    fi
    if [[ -f /var/multi-masternode-data/___temp.sh ]]
    then
      # shellcheck disable=SC1091
      source /var/multi-masternode-data/___temp.sh
    fi

    CONF_LOCATION=$( ${USRNAME} conf loc )
    CONF_LOCATION="${CONF_LOCATION#$USR_HOME/}"
  fi

  # Install needed software.
  WAIT_FOR_APT_GET
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    virtualenv \
    python-virtualenv

  echo "Add conf."
  echo "${SENTINEL_CONF_START}=${USR_HOME}/${CONF_LOCATION}"
  echo "${SENTINEL_CONF_START}=${USR_HOME}/${CONF_LOCATION}" | sudo tee -a "${USR_HOME}/sentinel/sentinel.conf" >/dev/null

  # Add apparmor.
  echo "Setup AppArmor for sentinel."
  CONF_NAME=$( basename "${CONF_LOCATION}" )
  DIR=$( dirname "${CONF_LOCATION}" )
  ADD_APPARMOR_CONF "${USRNAME}" "${DIR}" "${CONF_NAME}" "" "" "${USR_HOME}/sentinel/venv/bin/python2"

  # Setup virtualenv venv and requirements.
  echo "Setup python."
  sudo su "${USRNAME}" -c "cd ${USR_HOME}/sentinel/ ; virtualenv ${USR_HOME}/sentinel/venv ; ${USR_HOME}/sentinel/venv/bin/pip install -r ${USR_HOME}/sentinel/requirements.txt"
  echo "Run ${USR_HOME}/sentinel/bin/sentinel.py"
  echo "sudo su ${USRNAME} -c 'cd ${USR_HOME}/sentinel/ ; ${USR_HOME}/sentinel/venv/bin/python ${USR_HOME}/sentinel/bin/sentinel.py'"
  if [[ "$( sudo su "${USRNAME}" -c "cd ${USR_HOME}/sentinel/ ; ${USR_HOME}/sentinel/venv/bin/python ${USR_HOME}/sentinel/bin/sentinel.py" 2>&1 | grep -c 'Missing dependencies\|ImportError' )" -gt 0 ]]
  then
    wget https://www.dropbox.com/s/zmsp1r3xwt3bb26/sentinel-venv.tar.gz?dl=1 -O "${USR_HOME}/sentinel/sentinel-venv.tar.gz" -q --show-progress --progress=bar:force
    rm -rf "${USR_HOME:?}/sentinel/venv"
    tar -xf "${USR_HOME}/sentinel/sentinel-venv.tar.gz" -C "${USR_HOME}/sentinel/"
    echo "Chown."
    sudo chown -R "${USRNAME}":"${USRNAME}" "${USR_HOME}/"
  fi
  echo "Testing... if no output then masternode is running and sentinel is good."
  echo
  sudo su "${USRNAME}" -c "cd ${USR_HOME}/sentinel/ ; ${USR_HOME}/sentinel/venv/bin/python ${USR_HOME}/sentinel/bin/sentinel.py"
  echo
  echo "End of output."

  # Add Crontab if not set.
  # shellcheck disable=SC2063
  if [[ $( sudo su "${USRNAME}" -c 'crontab -l' | grep -cF "* * * * * cd ${USR_HOME}/sentinel/ ; ${USR_HOME}/sentinel/venv/bin/python ${USR_HOME}/sentinel/bin/sentinel.py 2>&1 >> sentinel-cron.log" ) -eq 0  ]]
  then
    echo 'Setting up crontab for sentinel.'
    sudo su "${USRNAME}" -c " ( crontab -l ; echo \"* * * * * cd ${USR_HOME}/sentinel/ ; ${USR_HOME}/sentinel/venv/bin/python ${USR_HOME}/sentinel/bin/sentinel.py 2>&1 >> sentinel-cron.log\" ) | crontab - "
    # Show crontab contents.
    sudo su "${USRNAME}" -c 'crontab -l'
  fi
}

if [[ "${ARG1}" == 'SENTINEL_INSTALL' ]]
then
  if [[ -z "${ARG3}" ]]
  then
    ARG3="${SENTINEL_GITHUB}"
  fi
  if [[ -z "${ARG2}" ]]
  then
    CONF_N_USRNAMES=''
    COUNTER=0
    # shellcheck disable=SC2034
    while read -r USRNAME DEL_1 DEL_2 DEL_3 DEL_4 DEL_5 DEL_6 DEL_7 DEL_8 USR_HOME_DIR USR_HOME_DIR_ALT DEL_9
    do
      if [[ "${USR_HOME_DIR}" == 'X' ]]
      then
        USR_HOME_DIR=${USR_HOME_DIR_ALT}
      fi

      if [[ "${#USR_HOME_DIR}" -lt 3 ]] || [[ ${USR_HOME_DIR} == /var/run/* ]] || [[ ${USR_HOME_DIR} == '/proc' ]]
      then
        continue
      fi

      CONF_LOCATIONS=$( find "${USR_HOME_DIR}" -name "${CONF}" 2>/dev/null )
      if [[ -z "${CONF_LOCATIONS}" ]]
      then
        continue
      fi

      MN_USRNAME=$( basename "${USR_HOME_DIR}" )
      if [ "$( type "${MN_USRNAME}" 2>/dev/null | grep -c '_masternode_dameon_2' )" -gt 0 ]
      then
        if [[ $( "${MN_USRNAME}" cli ) == "${CONTROLLER_BIN}" ]]
        then
          CONF_LOCATIONS=$( "${MN_USRNAME}" conf loc )
        else
          CONF_LOCATIONS=''
        fi
      fi

      while read -r CONF_LOCATION
      do
        CONF_N_USRNAMES="${CONF_N_USRNAMES}
${USRNAME} ${CONF_LOCATION}"
      done <<< "${CONF_LOCATIONS}"
    done <<< "$( cut -d: -f1 /etc/passwd | getent passwd | sed 's/:/ X /g' )"

    CONF_N_USRNAMES=$( echo "${CONF_N_USRNAMES}" | sed '/^[[:space:]]*$/d' )
    ROOT_ENTRY=$( echo "${CONF_N_USRNAMES}" | grep -E '^root .*' )
    CONF_N_USRNAMES=$( echo "${CONF_N_USRNAMES}" | sed '/^root .*/d' )
    CONF_N_USRNAMES="${CONF_N_USRNAMES}
${ROOT_ENTRY}"
    CONF_N_USRNAMES=$( echo "${CONF_N_USRNAMES}" | sed '/^[[:space:]]*$/d' )

    while read -r USRNAME CONF_LOCATION
    do
      SENTINEL_GENERIC_SETUP "${USRNAME}" "${ARG3}" "${ARG4}" "${ARG5}"
      sleep 2
    done <<< "${CONF_N_USRNAMES}"
  else
    SENTINEL_GENERIC_SETUP "${ARG2}" "${ARG3}" "${ARG4}" "${ARG5}"
  fi
  return 1 2>/dev/null || exit 1
fi

if [[ "${DAEMON_BIN}" != "apollond" ]] && \
  [[ "${DAEMON_BIN}" != "harcomiad" ]] && \
  [[ "${DAEMON_BIN}" != "unigridd" ]] && \
  [[ "${DAEMON_BIN}" != "trbod" ]] && \
  [[ "${DAEMON_BIN}" != "dogecashd" ]] && \
  [[ "${DAEMON_BIN}" != "phonecoind" ]] && \
  [[ "${DAEMON_BIN}" != "blocknoded" ]] && \
  [[ "${DAEMON_BIN}" != "craved" ]] && \
  [[ "${DAEMON_BIN}" != "sekod" ]] && \
  [[ "${DAEMON_BIN}" != "mogwaid" ]] && \
  [[ "${DAEMON_BIN}" != "adeptiod" ]] && \
  [[ "${DAEMON_BIN}" != "dreamteam3d" ]] && \
  [[ "${DAEMON_BIN}" != "gossipd" ]] && \
  [[ "${DAEMON_BIN}" != "darkpaycoind" ]] && \
  [[ "${DAEMON_BIN}" != "resqd" ]] && \
  [[ "${DAEMON_BIN}" != "zealiumd" ]] && \
  [[ "${DAEMON_BIN}" != "abpd" ]] && \
  [[ "${DAEMON_BIN}" != "logiscoind" ]] && \
  [[ "${DAEMON_BIN}" != "h2od" ]] && \
  [[ "${DAEMON_BIN}" != "coin2playd" ]] && \
  [[ "${DAEMON_BIN}" != "read" ]] && \
  [[ "${DAEMON_BIN}" != "millenniumclubd" ]] && \
  [[ "${DAEMON_BIN}" != "adultchaind" ]] && \
  [[ "${DAEMON_BIN}" != "stoned" ]] && \
  [[ "${DAEMON_BIN}" != "zoombad" ]] && \
  [[ "${DAEMON_BIN}" != "vizzotopd" ]] && \
  [[ "${DAEMON_BIN}" != "tourd" ]] && \
  [[ "${DAEMON_BIN}" != "bifrostd" ]] && \
  [[ "${DAEMON_BIN}" != "powocoind" ]] && \
  [[ "${DAEMON_BIN}" != "tittiecoind" ]] && \
  [[ "${DAEMON_BIN}" != "armageddond" ]] && \
  [[ "${DAEMON_BIN}" != "atheneumd" ]] && \
  [[ "${DAEMON_BIN}" != "blocknetdxd" ]] && \
  [[ "${DAEMON_BIN}" != "catocoind" ]] && \
  [[ "${DAEMON_BIN}" != "ctscd" ]] && \
  [[ "${DAEMON_BIN}" != "decentroniumd" ]] && \
  [[ "${DAEMON_BIN}" != "dinerod" ]] && \
  [[ "${DAEMON_BIN}" != "energid" ]] && \
  [[ "${DAEMON_BIN}" != "foxd" ]] && \
  [[ "${DAEMON_BIN}" != "galileld" ]] && \
  [[ "${DAEMON_BIN}" != "huzud" ]] && \
  [[ "${DAEMON_BIN}" != "lightpaycoind" ]] && \
  [[ "${DAEMON_BIN}" != "Lindad" ]] && \
  [[ "${DAEMON_BIN}" != "myced" ]] && \
  [[ "${DAEMON_BIN}" != "primestoned" ]] && \
  [[ "${DAEMON_BIN}" != "printexd" ]] && \
  [[ "${DAEMON_BIN}" != "pured" ]] && \
  [[ "${DAEMON_BIN}" != "qmcd" ]] && \
  [[ "${DAEMON_BIN}" != "quotationd" ]] && \
  [[ "${DAEMON_BIN}" != "recod" ]] && \
  [[ "${DAEMON_BIN}" != "resqd" ]] && \
  [[ "${DAEMON_BIN}" != "stakecubed" ]] && \
  [[ "${DAEMON_BIN}" != "stakeshared" ]] && \
  [[ "${DAEMON_BIN}" != "smartcashd" ]] && \
  [[ "${DAEMON_BIN}" != "securecloudd" ]] && \
  [[ "${DAEMON_BIN}" != "swippd" ]] && \
  [[ "${DAEMON_BIN}" != "venoxd" ]]
then
  UNLOCKED=0
  # See if this VPS has the key to unlock running any mn on a box.
  if [[ -r ~/masternode.mcarper.key ]] && [[ $( diff -u <(ssh-keygen -y -f ~/masternode.mcarper.key) <(echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCwIOLUbVu5LjI4wwJnC9WgNOIBw2UA1OspDOQ0l+8jnEQfBCf3t1ZhGhyq3slKQylxl3HSBp6AOiJx7wmmUjYHNCXO52I/WWWwC9iFyiVrai1FtvNTt1Y6QyaN+tNdOcXbHRRk0zgzVyRSdHoRsqznGuZNpXb+qbNVDo+Dlb2Oubd9Fwa/tV7nMfm63hnRGJGLA1c4MnV+x9SBRndP16FBEOhqFKzRXuQixHPoV2AH8NyrkMCqVKn1ahNEYSluJ0Q9V6K99WCx2J5TsAYq/q6B3DQISTRp2KwoZOWSMIrAjZWFd/e3RTfDF8+vQ/mtFQdtZK67pKDKLWczsKwVuV8j') | wc -l ) -eq 0 ]]
  then
    UNLOCKED=1

  elif [[ -r ~/masternode.myce.key ]] && [[ $( diff -u <(ssh-keygen -y -f ~/masternode.myce.key) <(echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKBoxK4UIxn23tUvAcPDp3Y24zg2aRDjCEgLiUMW06wswzzuhzdGXay9WbzgfyAIwPyO4jFqVYugSXsOgl2K44c4spzLZCLvQHUCrz9l0rRwkzfBH2RYicAS419DjN/q2aelDejtGRBU3c/KOZCaRXKcVHCcuLyG3+mEtifsI9QMqzHHTJYTwGilOIF3JgktpD1PR930rYqV7Ld89yFyqiX3iuSrATg8cnTL0UsJyP/gWnnog0APBvPqE7d/ABNlkS45TNG7mlxJ4hzqM9Znh6tmXuOzOlE3LArGOQTr4gC6RzmUKhGDUaLzhx8TFKK/PX2aTe42rqZCz2TrK+CpiD') | wc -l ) -eq 0 ]]
  then
    UNLOCKED=1

  elif [[ -r ~/masternode.abacus.key ]] && [[ $( diff -u <(ssh-keygen -y -f ~/masternode.abacus.key) <(echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDb0FpaC5PQ/6f5Fr3B0opCmneu9EvYDkXFfu43MnPR1lKWADgqnE9KPSDugJq4XwPvGLNkEMmJK/x60X6EGVi529pZ7DCf2WFRiOjnrvaLtLhdnEn40bFEjYYEQrNr1zdyp26bTYEff3C214P0yJP5UkA0mV3r7RZYRFpLlsju6CqsMDv6ALhYPWUBDClKZGYHTCNd3d4NbLFKU3Wa8qITSiJC92dD5C/2ZHYK+T9bwGh324YwMaFjZ8AvE0HnSQVRk0r4FyeajP9Bg70bU/yIFL21pD1w209J+qJLKtyrTPD8Qc3Q4Z/q9lGXULO4PcOaSZEN6hzQjQrVr9FkI1jT') | wc -l ) -eq 0 ]]
  then
    UNLOCKED=1

  elif [[ -r ~/masternode.mill.key ]] && [[ $( diff -u <(ssh-keygen -y -f ~/masternode.mill.key) <(echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCsZSfqVpvpCcneZu4nPqNdeVkyx4yMX1J5Dr4eo/4j+srJn7fyMS4MpwgeyO+/m9mpg4xb8gX5oPY6eXLDij4Aup6zU3IcM5SoEWA6Wy/JydeVEgq06fxsTvpB/jv33oHROLtgPVn4ktt7Rp8ZCSqVVpsXrEIurT9mg7vJr2YqK1655TMYLl2rMLcYgwhRTLcpLtu8YTUAih+d8ymE8dWZ2nNaAXL0fl+8OIQuraHGMZRk1EBysPeO2IFnUOAzyWkCy5Z938mQcESxmjPf3kKOwNwjeNCMBHawZ1APfcDfsZdtyISf7JWOIyV249XHVYrCVo2NduAvoZX3OXgxY4Ez') | wc -l ) -eq 0 ]]
  then
    UNLOCKED=1
  fi

  if [[ "${UNLOCKED}" -eq 0 ]]
  then
    echo
    echo "Contact @mcarper on twitter or discord for help."
    echo
    return 1 2>/dev/null || exit 1
  fi
fi

CHECK_SYSTEM () {
  local OS
  local VER
  local TARGET
  local FREEPSPACE_ALL
  local FREEPSPACE_BOOT
  local ARCH

  # Only run if user has sudo.
  sudo true >/dev/null 2>&1
  USRNAME_CURRENT=$( whoami )
  CAN_SUDO=0
  CAN_SUDO=$( timeout --foreground --signal=SIGKILL 1s bash -c "sudo -l 2>/dev/null | grep -v '${USRNAME_CURRENT}' | wc -l " )
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
  if [ -r /etc/os-release ]; then
    # freedesktop.org and systemd
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
  elif type lsb_release >/dev/null 2>&1; then
    # linuxbase.org
    OS=$( lsb_release -si )
    VER=$( lsb_release -sr )
  elif [ -r /etc/lsb-release ]; then
    # For some versions of Debian/Ubuntu without lsb_release command
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
  elif [ -r /etc/debian_version ]; then
    # Older Debian/Ubuntu/etc.
    OS=Debian
    VER=$( cat /etc/debian_version )
  elif [ -r /etc/SuSe-release ]; then
    # Older SuSE/etc.
    ...
  elif [ -r /etc/redhat-release ]; then
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
    WAIT_FOR_APT_GET
    sudo apt autoremove
    WAIT_FOR_APT_GET
    sudo dpkg -l linux-* | awk '/^ii/{ print $2}' | grep -v -e "$( uname -r | cut -f1,2 -d "-" )" | grep -e '[0-9]' | grep -E "(image|headers)" | xargs sudo DEBIAN_FRONTEND=noninteractive apt-get -y purge
    WAIT_FOR_APT_GET
    sudo DEBIAN_FRONTEND=noninteractive apt -y autoremove
    WAIT_FOR_APT_GET
    sudo DEBIAN_FRONTEND=noninteractive apt-get clean
    rm -R -- /var/multi-masternode-data/*/

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
    stty sane 2>/dev/null
    if [[ "${SWAP_FREE}" -lt 524288 ]]
    then
      echo "Free Swap Space: ${SWAP_FREE} kb"
      echo
      echo "This linux box may not have enough resources to run a ${MASTERNODE_NAME} daemon."
      echo "If I were you I'd get a better linux box."
      echo "ctrl-c to exit this script."
      echo
      read -r -t 10 -p "Hit ENTER to continue or wait 10 seconds" 2>&1
    else
      echo "Note: This linux box may not have enough free memory to run a ${MASTERNODE_NAME} daemon."
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
  UNIX_TIME=$( date -u +%s )
  TIME_DIFF=$(( UNIX_TIME - LAST_UPDATED ))
  if [[ "${TIME_DIFF}" -gt 43200 ]]
  then
    WAIT_FOR_APT_GET
    sudo DEBIAN_FRONTEND=noninteractive apt-get update -yq
  fi

  # Make sure python3 is available.
  if [ ! -x "$( command -v python3 )" ]
  then
    WAIT_FOR_APT_GET
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq python3
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
    unrar \
    xz-utils \
    procps \
    jq \
    htop \
    git \
    gpw \
    bc \
    pv \
    sysstat \
    glances \
    psmisc \
    at \
    python3-pip \
    python-pip \
    subnetcalc \
    net-tools \
    sipcalc \
    python-yaml \
    html-xml-utils \
    apparmor \
    ack-grep \
    pcregrep \
    snapd \
    aria2 \
    dbus-user-session

  # Turn on firewall, allow ssh port first; default is 22.
  SSH_PORT=22
  SSH_PORT_SETTING=$( sudo grep -E '^Port [0-9]*' /etc/ssh/ssh_config | grep -o '[0-9]*' | head -n 1 )
  if [[ ! -z "${SSH_PORT_SETTING}" ]] && [[ $SSH_PORT_SETTING =~ $RE ]]
  then
    sudo ufw allow "${SSH_PORT_SETTING}" >/dev/null 2>&1
  else
    sudo ufw allow "${SSH_PORT}" >/dev/null 2>&1
  fi
  if [[ -f "${HOME}/.ssh/config" ]]
  then
    SSH_PORT_SETTING=$( grep -E '^Port [0-9]*' "${HOME}/.ssh/config" | grep -o '[0-9]*' | head -n 1 )
    if [[ ! -z "${SSH_PORT_SETTING}" ]] && [[ $SSH_PORT_SETTING =~ $RE ]]
    then
      sudo ufw allow "${SSH_PORT_SETTING}" >/dev/null 2>&1
    fi
  fi
  # Maybe search all users to other ports but this would be highly unsual.

  echo "y" | sudo ufw enable >/dev/null 2>&1
  sudo ufw reload

  COUNTER=0
  DAEMON_DOWNLOAD_SUPER "${GITHUB_REPO}" "${BIN_BASE}" "${DAEMON_DOWNLOAD}"
  while [[ ! -f "/var/multi-masternode-data/${PROJECT_DIR}/src/${DAEMON_BIN}" ]]
  do
    DAEMON_DOWNLOAD_SUPER "${GITHUB_REPO}" "${BIN_BASE}" "${DAEMON_DOWNLOAD}"
    echo -e "\\r\\c"
    COUNTER=$(( COUNTER+1 ))
    if [[ "${COUNTER}" -gt 3 ]]
    then
      break;
    fi
  done

  WAIT_FOR_APT_GET
  sudo dpkg --configure -a
  if [[ $( ldd "/var/multi-masternode-data/${PROJECT_DIR}/src/${DAEMON_BIN}" | grep -cF 'not found' ) -ne 0 ]] || [[ $( ldd "/var/multi-masternode-data/${PROJECT_DIR}/src/${CONTROLLER_BIN}" | grep -cF 'not found' ) -ne 0 ]]
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

    # shellcheck disable=SC2941
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
    WAIT_FOR_APT_GET
    sudo apt install --reinstall libsodium18=1.0.8-5
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
      libminiupnpc10 \
      libzmq5 \
      libdb4.8-dev \
      libdb4.8++-dev
  fi

  if [[ $( ldd "/var/multi-masternode-data/${PROJECT_DIR}/src/${DAEMON_BIN}" | grep -cF 'not found' ) -ne 0 ]] || [[ $( ldd "/var/multi-masternode-data/${PROJECT_DIR}/src/${CONTROLLER_BIN}" | grep -cF 'not found' ) -ne 0 ]]
  then
    WAIT_FOR_APT_GET
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq libdb5.3++-dev
  fi

  if [[ $( ldd "/var/multi-masternode-data/${PROJECT_DIR}/src/${DAEMON_BIN}" | grep -cF 'not found' ) -ne 0 ]] || [[ $( ldd "/var/multi-masternode-data/${PROJECT_DIR}/src/${CONTROLLER_BIN}" | grep -cF 'not found' ) -ne 0 ]]
  then
    WAIT_FOR_APT_GET
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq \
      libboost-system1.65.1 \
      libboost-filesystem1.65.1 \
      libboost-program-options1.65.1 \
      libboost-thread1.65.1 \
      libboost-chrono1.65.1 \
      libevent-2.1-6 \
      libevent-core-2.1-6 \
      libevent-extra-2.1-6 \
      libevent-openssl-2.1-6 \
      libevent-pthreads-2.1-6
  fi

  WAIT_FOR_APT_GET
  sudo DEBIAN_FRONTEND=noninteractive apt-get -f install -yq

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
(sudo -n renice 15 $BASHPID

  local TOTAL_RAM
  local TARGET_SWAP
  local SWAP_SIZE
  local FREE_HD
  local MIN_SWAP

  # Log to a file.
  exec >  >( tee -ia "${DAEMON_SETUP_LOG}" )
  exec 2> >( tee -ia "${DAEMON_SETUP_LOG}" >&2 )

  echo "Make swap file if one does not exist."
  if [ ! -x "$( command -v bc )" ] || [ ! -x "$( command -v jq )" ] || [[ ! -x "$( command -v pv )" ]]
  then
    WAIT_FOR_APT_GET
    sudo -n nice -n 15 sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq bc jq pv
  fi
  SWAP_SIZE=$( echo "scale=2; $( grep -i 'Swap' /proc/meminfo | awk '{print $2}' | xargs | jq -s max ) / 1024" | bc | awk '{printf("%d\n",$1 + 0.5)}' )
  if [ -z "${SWAP_SIZE}" ]
  then
    SWAP_SIZE=0
  fi
  TOTAL_RAM=$( echo "scale=2; $( awk '/MemTotal/ {print $2}' /proc/meminfo ) / 1024" | bc | awk '{printf("%d\n",$1 + 0.5)}' )
  FREE_HD=$( echo "scale=2; $( df -P . | tail -1 | awk '{print $4}' ) / 1024" | bc | awk '{printf("%d\n",$1 + 0.5)}' )
  MIN_SWAP=4096
  TARGET_SWAP=$(( TOTAL_RAM * 5 ))
  TARGET_SWAP=$(( TARGET_SWAP > MIN_SWAP ? TARGET_SWAP : MIN_SWAP ))
  TARGET_SWAP=$(( FREE_HD / 5 < TARGET_SWAP ? FREE_HD / 5 : TARGET_SWAP ))

  if [[ "${SWAP_SIZE}" -lt "${TARGET_SWAP}" ]] && [[ ! -f /var/swap.img ]]
  then
    if [[ ! -x "$( command -v pv )" ]]
    then
      WAIT_FOR_APT_GET
      sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq pv
    fi
    TARGET_SWAP=$( echo "${TARGET_SWAP} * 1024 * 1024" | bc)
    sudo touch /var/swap.img
    sudo chmod 666 /var/swap.img
    # Rate limit swap creation to prevent system lockup.
    nice -n 15 < /dev/zero head -c "${TARGET_SWAP}" | pv -q --rate-limit 70m > /var/swap.img
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
  sudo -n nice -n 15 sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq libc6
  WAIT_FOR_APT_GET
  sudo -n nice -n 15 sudo DEBIAN_FRONTEND=noninteractive apt-get -yq -o DPkg::options::="--force-confdef" \
  -o DPkg::options::="--force-confold"  install grub-pc
  WAIT_FOR_APT_GET
  sudo -n nice -n 15 sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -yq
  WAIT_FOR_APT_GET
  sudo -n nice -n 15 sudo DEBIAN_FRONTEND=noninteractive apt-get -f install -yq
  echo "# Updating system"
  WAIT_FOR_APT_GET
  sudo -n nice -n 15 sudo DEBIAN_FRONTEND=noninteractive apt-get -yq -o Dpkg::Options::="--force-confdef" \
  -o Dpkg::Options::="--force-confold" dist-upgrade
#   WAIT_FOR_APT_GET
  sudo -n nice -n 15 sudo DEBIAN_FRONTEND=noninteractive apt-get -f install -yq

  WAIT_FOR_APT_GET
  sudo -n nice -n 15 sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq unattended-upgrades

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
  sudo -n nice -n 15 sudo unattended-upgrade -d
  WAIT_FOR_APT_GET
  sudo -n nice -n 15 sudo DEBIAN_FRONTEND=noninteractive apt-get -f install -yq
)
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

USER_FUNCTION_FOR_MN_CLI () {
CONF=${1}
CONTROLLER_BIN=${2}
DAEMON_BIN=${3}
EXPLORER_URL=${4}
BAD_SSL_HACK=${5}
# Create function that can control the new masternode daemon.
_MN_DAEMON_FUNC=$( cat << MN_DAEMON_FUNC_CLI
# Start of function for ${CONTROLLER_BIN}.
function ${CONTROLLER_BIN} () {
  _daemon_mn_run "${CONF}" "${CONTROLLER_BIN}" "${DAEMON_BIN}" "${EXPLORER_URL}" "${BAD_SSL_HACK}" "\${1}" "\${2}" "\${3}" "\${4}" "\${5}" "\${6}" "\${7}" "\${8}" "\${9}"
}
complete -F _masternode_dameon_2_completions ${CONTROLLER_BIN}
# End of function for ${CONTROLLER_BIN}.
MN_DAEMON_FUNC_CLI
)
UPDATE_USER_FILE "${_MN_DAEMON_FUNC}" "${CONTROLLER_BIN}" "${6}" "${7}"
}

sleep 0.1
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
_MN_DAEMON_MASTER_FUNC=$( cat << "MN_DAEMON_MASTER_FUNCD"

# Start of function for _masternode_dameon_2.
_masternode_dameon_2 () {
  stty sane 2>/dev/null
  local TEMP_VAR_A
  local TEMP_VAR_B
  local TEMP_VAR_C
  local TEMP_VAR_D
  local TEMP_VAR_PID
  local RE
  local SP
  local DIR
  local USER_HOME_DIR
  local ARG9
  local ARG10
  local ARG11
  local ARG12
  local ARG13
  local ARG14
  local ARG15
  local ARG16
  local ARG17
  local i
  local DAEMON_CONNECTIONS
  local EXPLORER_BLOCKCOUNT_OFFSET
  local CAN_SUDO
  local DATADIR
  local _MASTERNODE_CALLER
  local _MASTERNODE_PREFIX
  local _MASTERNODE_GENKEY_COMMAND
  local GITHUB_REPO
  local DAEMON_DOWNLOAD
  local REPLY
  local PROJECT_DIR

  ARG9=''
  ARG10=''
  ARG11=''
  ARG12=''
  ARG13=''
  ARG14=''
  ARG15=''
  ARG16=''
  ARG17=''
  if [[ ! -z "${9}" ]]
  then
    ARG9=$( printf '%q' "${9}" | sed "s/\\\\\\ / /g" )
  fi
  if [[ ! -z "${10}" ]]
  then
    ARG10=$( printf '%q' "${10}" | sed "s/\\\\\\ / /g" )
  fi
  if [[ ! -z "${11}" ]]
  then
    ARG11=$( printf '%q' "${11}" | sed "s/\\\\\\ / /g" )
  fi
  if [[ ! -z "${12}" ]]
  then
    ARG12=$( printf '%q' "${12}" | sed "s/\\\\\\ / /g" )
  fi
  if [[ ! -z "${13}" ]]
  then
    ARG13=$( printf '%q' "${13}" | sed "s/\\\\\\ / /g" )
  fi
  if [[ ! -z "${14}" ]]
  then
    ARG14=$( printf '%q' "${14}" | sed "s/\\\\\\ / /g" )
  fi
  if [[ ! -z "${15}" ]]
  then
    ARG15=$( printf '%q' "${15}" | sed "s/\\\\\\ / /g" )
  fi
  if [[ ! -z "${16}" ]]
  then
    ARG16=$( printf '%q' "${16}" | sed "s/\\\\\\ / /g" )
  fi
  if [[ ! -z "${17}" ]]
  then
    ARG17=$( printf '%q' "${17}" | sed "s/\\\\\\ / /g" )
  fi

  # If running inside of cron, assume you can not do sudo.
  CAN_SUDO=0
  USRNAME_CURRENT=$( whoami )
  if [[ -x "$( command -v pstree )" ]] && [[ "$( pstree -s $$ | grep -c cron )" -eq 0 ]]
  then
    CAN_SUDO=$( timeout --foreground --signal=SIGKILL 1s bash -c "sudo -n true >/dev/null 2>&1 && sudo -n -l 2>/dev/null | grep -v '${USRNAME_CURRENT}' | wc -l " 2>/dev/null )
  fi

  RE='^[0-9]+$'
  SP="/-\\|"
  TEMP_VAR_C="${6}"
  if [[ "${TEMP_VAR_C}" == '-1' ]]
  then
    TEMP_VAR_C=''
  fi

  # Find daemon binary.
  USR_HOME="$( getent passwd "${1}" | cut -d: -f6 )"
  DAEMON_BIN_LOC="${USR_HOME}/.local/bin/${4}"
  if [[ ! -f "${DAEMON_BIN_LOC}" ]]
  then
    DAEMON_BIN_LOC=$( which "${4}" )
  fi
  if [[ -z "${DAEMON_BIN_LOC}" ]]
  then
    while read -r DIR_ROOT
    do
      if [[ "${DIR_ROOT}" == '/' ]] || \
        [[ "${DIR_ROOT}" == '/boot' ]] || \
        [[ "${DIR_ROOT}" == '/dev' ]] || \
        [[ "${DIR_ROOT}" == '/etc' ]] || \
        [[ "${DIR_ROOT}" == '/home' ]] || \
        [[ "${DIR_ROOT}" == '/lib' ]] || \
        [[ "${DIR_ROOT}" == '/lib64' ]] || \
        [[ "${DIR_ROOT}" == '/lost+found' ]] || \
        [[ "${DIR_ROOT}" == '/media' ]] || \
        [[ "${DIR_ROOT}" == '/mnt' ]] || \
        [[ "${DIR_ROOT}" == '/proc' ]] || \
        [[ "${DIR_ROOT}" == '/run' ]] || \
        [[ "${DIR_ROOT}" == '/snap' ]] || \
        [[ "${DIR_ROOT}" == '/srv' ]] || \
        [[ "${DIR_ROOT}" == '/sys' ]]
      then
        continue
      fi
      DAEMON_BIN_LOC=$( find "${DIR_ROOT}" -executable -type f -name "${4}" -print -quit 2>/dev/null )
      if [[ ! -z "${DAEMON_BIN_LOC}" ]]
      then
        break
      fi
    done <<< "$( find / -maxdepth 1 -type d | sort )"
  fi
  if [[ -z "${DAEMON_BIN_LOC}" ]]
  then
    DAEMON_BIN_LOC=$( find "/" -executable -type f -name "${4}" -print -quit 2>/dev/null )
  fi
  DAEMON_BIN_DIR=$( dirname "${DAEMON_BIN_LOC}" )
  CLI_BIN_LOC="${DAEMON_BIN_DIR}/${2}"

  # Adjust datadir folder if needed.
  DIR=$( dirname "${5}" )
  DATADIR=${DIR}
  USER_HOME_DIR=$( dirname "${DIR}" )
  if [[ "${USER_HOME_DIR}" != "${USR_HOME}" ]]
  then
    USER_HOME_DIR=$( echo "${DIR}" | grep -o ".*${1}/" | grep -o ".*${1}" )
    DATADIR=$( echo "${DIR}" | grep -o ".*${USER_HOME_DIR}/.*/" )
    DATADIR=${DATADIR%/}
  fi

  _DAEMON_SYSTEMD_FILENAME=''
  # Find systemd file
  _DAEMON_SYSTEMD_FILE="/etc/systemd/system/${1}.service"
  if [[ ! -f "${_DAEMON_SYSTEMD_FILE}" ]]
  then
    # shellcheck disable=SC2033
    _DAEMON_SYSTEMD_FILE=$( grep -rl "${DATADIR}" /etc/systemd/system/ | xargs grep -l "${1}" )
  fi
  if [[ ! -f "${_DAEMON_SYSTEMD_FILE}" ]]
  then
    # shellcheck disable=SC2033
    _DAEMON_SYSTEMD_FILE=$( grep -rl "${1}" /etc/systemd/system/ | xargs grep -l "${4}" )
  fi
  if [[ ! -z "${_DAEMON_SYSTEMD_FILE}" ]]
  then
    _DAEMON_SYSTEMD_FILENAME=$( basename "${_DAEMON_SYSTEMD_FILE}" )
  fi

  EXPLORER_BLOCKCOUNT_OFFSET='0'
  if [[ -r "${5}" ]]
  then
    _MASTERNODE_CALLER=$( grep -m 1 'masternode_caller=' "${5}" | cut -d '=' -f2 )
    _MASTERNODE_NAME=$( grep -m 1 'masternode_name=' "${5}" | cut -d '=' -f2 )
    _MASTERNODE_PREFIX=$( grep -m 1 'masternode_prefix=' "${5}" | cut -d '=' -f2 )
    _MASTERNODE_GENKEY_COMMAND=$( grep -m 1 'masternode_genkey_command=' "${5}" | cut -d '=' -f2 )
    _MASTERNODE_PRIVKEY=$( grep -m 1 'masternode_privkey=' "${5}" | cut -d '=' -f2 )
    _MASTERNODE_CONF=$( grep -m 1 'masternode_conf=' "${5}" | cut -d '=' -f2 )
    _MASTERNODE_LIST=$( grep -m 1 'masternode_list=' "${5}" | cut -d '=' -f2 )

    EXPLORER_BLOCKCOUNT_OFFSET=$( grep -m 1 'explorer_blockcount_offset=' "${5}" | grep -o '=.*' | cut -c2- )
  fi
  EXPLORER_BLOCKCOUNT_OFFSET="${EXPLORER_BLOCKCOUNT_OFFSET//[+-]}"

  if [[ -z "${_MASTERNODE_CALLER}" ]]
  then
    _MASTERNODE_CALLER='masternode '
  fi
  if [[ "${_MASTERNODE_CALLER}" == 'masternode' ]]
  then
    _MASTERNODE_CALLER='masternode '
  fi
  if [[ -z "${_MASTERNODE_NAME}" ]]
  then
    _MASTERNODE_NAME="${_MASTERNODE_CALLER%% }"
  fi
  if [[ -z "${_MASTERNODE_PREFIX}" ]]
  then
    _MASTERNODE_PREFIX='mn'
  fi
  if [[ -z "${_MASTERNODE_GENKEY_COMMAND}" ]]
  then
    _MASTERNODE_GENKEY_COMMAND="${_MASTERNODE_CALLER}genkey"
  fi
  if [[ -z "${_MASTERNODE_PRIVKEY}" ]]
  then
    _MASTERNODE_PRIVKEY="${_MASTERNODE_NAME}privkey"
  fi
  if [[ -z "${_MASTERNODE_CONF}" ]]
  then
    _MASTERNODE_CONF="${_MASTERNODE_NAME}.conf"
  fi
  if [[ -z "${_MASTERNODE_LIST}" ]]
  then
    _MASTERNODE_LIST="${_MASTERNODE_CALLER}list"
  fi

  # Speedbump for dangerous commands.
  if [[ "${ARG9}" =~ get.*seed.* ]] || [[ "${ARG9}" =~ dump.* ]] || [[ "${ARG9}" =~ send.* ]]
  then
  (
    echo -e "\033[1;31m !!! WARNING !!! \033[0m"
    sleep 1
    echo -e "\033[1;31m ${ARG9} can be used to steal your coins. \033[0m"
    sleep 2
    echo -e "\033[1;31m !!! WARNING !!! \033[0m"
    sleep 1
    echo
    read -p "Are you sure (y/n)? " -n 1 -r
    echo
    REPLY=${REPLY,,} # tolower
    if [[ "${REPLY}" != y ]]
    then
      return 1 2>/dev/null
    fi
  )
  fi

  if [ "${ARG9}" == "help-bashrc" ]
  then
  (
    LEVEL1=$( grep -F " elif [ \"\${ARG9}\" == " "${HOME}/.bashrc" | cut -d ']' -f1 | cut -d '=' -f3 | tr -d '"' | awk '{ print $1 }' | sort | grep -v 'up_gdrive' | grep -v 'up_dbox' | grep -v "'" )
    LEVEL2=$( grep -F " elif [ \"\${ARG9}\" == " "${HOME}/.bashrc" | cut -d '|' -f3 | cut -d ']' -f1 | cut -d '=' -f3 | tr -d '"' | awk '{ print $1 }' | sort | grep -v 'up_gdrive' | grep -v 'up_dbox' | grep -v "'" | grep -vF "\$" )
    LEVEL3=$( grep -F " elif [ \"\${ARG9}\" == " "${HOME}/.bashrc" | cut -d '|' -f5 | cut -d ']' -f1 | cut -d '=' -f3 | tr -d '"' | awk '{ print $1 }' | sort | grep -v 'up_gdrive' | grep -v 'up_dbox' | grep -v "'" | grep -vF "\$" )
    echo -e "${LEVEL1}\n${LEVEL2}\n${LEVEL3}\n" | sort -u | sed '/^[[:space:]]*$/d'
  )
  elif [ "${ARG9}" == "pid" ]
  then
  (
    # shellcheck disable=SC2009
    ps axfo user:32,pid,command | sed -e 's/^[[:space:]]*//' | grep -E "^${1}\s" | grep "[${4:0:1}]${4:1}" | grep -vF 'bash -' | awk '{print $2 }'
  )

  elif [ "${ARG9}" == "uptime" ]
  then
  (
    # shellcheck disable=SC2009
    ps axfo user:32,etimes,command | sed -e 's/^[[:space:]]*//' | grep -E "^${1}\s" | grep "[${4:0:1}]${4:1}" | grep -vF 'bash -' | awk '{print $2 }'
  )

  elif [ "${ARG9}" == "ps" ]
  then
  (
    TEMP_VAR_A=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" pid )
    if [[ ! -z "${TEMP_VAR_A}" ]]
    then
      while read -r TEMP_VAR_PID
      do
        ps -up "${TEMP_VAR_PID}"
      done <<< "${TEMP_VAR_A}"
    fi
  )

  elif [ "${ARG9}" == "unlock_wallet_for_staking" ]
  then
  (
    DATADIR_FILENAME=$( echo "${DATADIR}" | tr '/' '_' )
    if [[ -f "${HOME}/.pwd/${DATADIR_FILENAME}" ]]
    then
      WALLET_PASSWORD=$( head -n 1 "${HOME}/.pwd/${DATADIR_FILENAME}" )
      RPCUSER=$( grep -m 1 'rpcuser=' "${5}" | cut -d '=' -f2 )
      RPCPASSWORD=$( grep -m 1 'rpcpassword=' "${5}" | cut -d '=' -f2 )
      RPCPORT=$( grep -m 1 'rpcport=' "${5}" | cut -d '=' -f2 )

      curl -u "${RPCUSER}:${RPCPASSWORD}" --data-binary "{\"jsonrpc\": \"1.0\", \"id\":\"unlocked for staking\", \"method\":\"walletpassphrase\", \"params\":[\"${WALLET_PASSWORD}\", 999999, true] }" -H 'content-type: text/plain;' "http://127.0.0.1:${RPCPORT}/" 2>/dev/null | jq

      WALLET_UNLOCKED=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" getstakingstatus | jq '.walletunlocked' )
      if [[ "${WALLET_UNLOCKED}" != 'true' ]]
      then
        _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" walletpassphrase "${WALLET_PASSWORD}" 9999999999 true
      fi
    fi
  )

  elif [ "${ARG9}" == "crontab" ]
  then
  (
    if [[ "$( whoami )" == "${1}" ]]
    then
      crontab "${ARG10}"
    else
      sudo su - "${1}" -c " crontab ${ARG10} "
    fi
  )

  elif [ "${ARG9}" == "home_folder" ]
  then
  (
    echo "${USER_HOME_DIR}"
  )

  elif [ "${ARG9}" == "up_dbox" ] && [[ -s /home/mn-dropbox.sh ]]
  then
  (
    if [[ -s "${HOME}/.bashrc" ]]
    then
      cp "${HOME}/.bashrc" /var/multi-masternode-data/.bashrc
    fi
    bash /home/mn-dropbox.sh "${1}" now "${ARG10}" "${ARG11}"

    FILENAME=$( echo "${4}" | tr '[:upper:]' '[:lower:]' )
    if [[ -s "${HOME}/${FILENAME}.sh" ]] && [[ -s "${USER_HOME_DIR}/dropbox.txt" ]]
    then
      echo
      echo "${HOME}/${FILENAME}.sh"
      DROPBOX_VALUES=$( <"${USER_HOME_DIR}/dropbox.txt" )
      _DBOX_ADDNODE=$( echo "${DROPBOX_VALUES}" | grep -m 1 '^DROPBOX_ADDNODES=' )
      echo "${_DBOX_ADDNODE}"
      _DBOX_BOOTSTRAP=$( echo "${DROPBOX_VALUES}" | grep -m 1 '^DROPBOX_BOOTSTRAP=' )
      echo "${_DBOX_BOOTSTRAP}"
      _DBOX_BLOCKS_N_CHAINS=$( echo "${DROPBOX_VALUES}" | grep -m 1 '^DROPBOX_BLOCKS_N_CHAINS=' )
      echo "${_DBOX_BLOCKS_N_CHAINS}"
      echo
      sed -i "s/^DROPBOX_ADDNODES=.*/${_DBOX_ADDNODE}/"  "${HOME}/${FILENAME}.sh"
      sed -i "s/^DROPBOX_BOOTSTRAP=.*/${_DBOX_BOOTSTRAP}/"  "${HOME}/${FILENAME}.sh"
      sed -i "s/^DROPBOX_BLOCKS_N_CHAINS=.*/${_DBOX_BLOCKS_N_CHAINS}/"  "${HOME}/${FILENAME}.sh"
    fi
  )

  elif [ "${ARG9}" == "up_gdrive" ] && [[ -s /home/gdrive-folder ]]
  then
  (
    GDRIVE_FOLDER=$( </home/gdrive-folder )
    TIPS_ADDR=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" getaccountaddress mntips 2>/dev/null )
    FILENAME=$( echo "${4}" | tr '[:upper:]' '[:lower:]' )
    if [[ -s "${HOME}/${FILENAME}.sh" ]]
    then
      sed -i "s/^TIPS=.*/TIPS='${TIPS_ADDR}'/"  "${HOME}/${FILENAME}.sh"
    fi
    echo "mn1 address"
    _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" getaccountaddress mn1
    echo
    BIN_BASE_LOWER=$( grep -m 1 'bin_base=' "${5}" | cut -d '=' -f2 | tr '[:upper:]' '[:lower:]' )

    # Try to save keys first.
    "${CLI_BIN_LOC}" "-datadir=${DATADIR}/" "dumpwallet" "${DATADIR}/${BIN_BASE_LOWER}.txt" 2>&1
    GET_SEED_COMMAND=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" help | grep -E 'get.*seed' )
    if [[ ! -z "${GET_SEED_COMMAND}" ]]
    then
      "${CLI_BIN_LOC}" "-datadir=${DATADIR}/" "${GET_SEED_COMMAND}" > "${DATADIR}/${BIN_BASE_LOWER}.${GET_SEED_COMMAND}.json"
      if [[ -s "${DATADIR}/${BIN_BASE_LOWER}.${GET_SEED_COMMAND}.json" ]]
      then
        echo "Using ${GET_SEED_COMMAND}"
        /root/.local/bin/gdrive upload --parent "${GDRIVE_FOLDER}" "${DATADIR}/${BIN_BASE_LOWER}.${GET_SEED_COMMAND}.json"
        rm "${DATADIR}/${BIN_BASE_LOWER}.${GET_SEED_COMMAND}.json"
      fi
    fi

    # Backup private keys.
    if [[ -s "${DATADIR}/${BIN_BASE_LOWER}.txt" ]]
    then
      echo 'Using dumpwallet'
      /root/.local/bin/gdrive upload --parent "${GDRIVE_FOLDER}" "${DATADIR}/${BIN_BASE_LOWER}.txt"
      rm "${DATADIR}/${BIN_BASE_LOWER}.txt"
    fi

    # Backup wallet.dat as well.
    _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" backupwallet "${USER_HOME_DIR}/${BIN_BASE_LOWER}.wallet.dat"
    if [[ -s "${USER_HOME_DIR}/${BIN_BASE_LOWER}.wallet.dat" ]]
    then
      echo 'Using backupwallet'
      /root/.local/bin/gdrive upload --parent "${GDRIVE_FOLDER}" "${USER_HOME_DIR}/${BIN_BASE_LOWER}.wallet.dat"
      rm "${USER_HOME_DIR}/${BIN_BASE_LOWER}.wallet.dat"
    else
      unset -v latest_file
      local latest_file
      while read -r file
      do
        echo "${file}"
        if [[ "${file}" -nt "${latest_file}" ]]
        then
          latest_file=${file}
        fi
      done <<< "$( echo "${DATADIR}/backups/"* | tr " " "\n" )"

      if [[ -s "${latest_file}" ]]
      then
        echo 'Using backup folder'
        cp "${latest_file}" "${USER_HOME_DIR}/${BIN_BASE_LOWER}.wallet.dat"
        /root/.local/bin/gdrive upload --parent "${GDRIVE_FOLDER}" "${USER_HOME_DIR}/${BIN_BASE_LOWER}.wallet.dat"
      else
        echo 'Using real wallet file'
        _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" stop
        cp "${DATADIR}/wallet.dat" "${USER_HOME_DIR}/${BIN_BASE_LOWER}.wallet.dat"
        _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" start
        if [[ -s "${USER_HOME_DIR}/${BIN_BASE_LOWER}.wallet.dat" ]]
        then
          /root/.local/bin/gdrive upload --parent "${GDRIVE_FOLDER}" "${USER_HOME_DIR}/${BIN_BASE_LOWER}.wallet.dat"
        else
          echo "Wallet backup can not be made."
        fi
      fi
    fi
  )

  elif [ "${ARG9}" == "ps-short" ]
  then
  (
    TEMP_VAR_A=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" pid )
    if [[ ! -z "${TEMP_VAR_A}" ]]
    then
      OLDEST_PID_TIME=0
      TARGET_PID=''
      while read -r TEMP_VAR_PID
      do
        PID_TIME_SEC=$( ps -p "${TEMP_VAR_PID}" o pid,etimes | tail -n 1 )
        if [[ $( echo "${PID_TIME_SEC}" | awk '{print $2 }' ) -ge "${OLDEST_PID_TIME}" ]]
        then
          OLDEST_PID_TIME="$( echo "${PID_TIME_SEC}" | awk '{print $2 }' )"
          TARGET_PID="$( echo "${PID_TIME_SEC}" | awk '{print $1 }' )"
        fi
      done <<< "${TEMP_VAR_A}"
      ps -p "${TARGET_PID}" o user,pid,etime,cputime,%cpu,comm
    fi
  )

  elif [ "${ARG9}" == "daemon" ]
  then
  (
    if [ "${ARG10}" == "location" ] || [ "${ARG10}" == "loc" ]
    then
      echo "${DAEMON_BIN_LOC}"
    else
      echo "${4}"
    fi
  )

  elif [ "${ARG9}" == "cli" ]
  then
  (
    if [ "${ARG10}" == "location" ] || [ "${ARG10}" == "loc" ]
    then
      echo "${CLI_BIN_LOC}"
    else
      echo "${2}"
    fi
  )

  elif [ "${ARG9}" == "start" ]
  then
  (
    TEMP_VAR_A=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" checksystemd | awk '{print $3}' )
    TEMP_VAR_PID=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" pid )

    if [[ -z "${TEMP_VAR_PID}" ]]
    then
      echo "Starting ${1}"
      (
      sudo -n systemctl stop "${_DAEMON_SYSTEMD_FILENAME}"  >/dev/null 2>&1
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" stop  >/dev/null 2>&1
      sudo -n systemctl reset-failed "${_DAEMON_SYSTEMD_FILENAME}"  >/dev/null 2>&1
      sudo -n systemctl start "${_DAEMON_SYSTEMD_FILENAME}"  >/dev/null 2>&1
      sleep 1
      TEMP_VAR_PID=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" pid )
      if [[ -z "${TEMP_VAR_PID}" ]]
      then
        _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" start-nosystemd  >/dev/null 2>&1
      fi
      ) &
    else
      echo "Already running"
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" ps
      return
    fi

    TEMP_VAR_PID=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" pid )
    # shellcheck disable=SC2030,SC2031
    COUNTER=0
    if [ "${ARG10}" == "y" ]
    then
      echo "Waiting for ${1} to start (PID)"
    fi
    while [[ -z "${TEMP_VAR_PID}" ]]
    do
      TEMP_VAR_PID=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" pid )
      COUNTER=$((COUNTER+1))
      if [ "${ARG10}" == "y" ]
      then
        printf "."
      else
        echo -e "\\r${SP:i++%${#SP}:1} Waiting for ${1} to start (PID) \\c"
      fi
      sleep 0.3
      if [[ $( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" failure_after_start | sed '/^[[:space:]]*$/d' | wc -l ) -gt 0 ]] || [[ "${COUNTER}" -gt 50 ]]
      then
        break;
      fi
    done

    if [ "${ARG10}" == "y" ]
    then
      echo "Waiting for ${1} to start (PID)"
    fi
    while [[ ! -z "${TEMP_VAR_PID}" ]] && [[ $( lslocks -n -o COMMAND,PID,PATH | grep -F "${4}" | grep -cF "${TEMP_VAR_PID}" ) -lt 1 ]]
    do
      TEMP_VAR_PID=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" pid )
      if [ "${ARG10}" == "y" ]
      then
        printf "."
      else
        echo -e "\\r${SP:i++%${#SP}:1} Waiting for ${1} to start (LOCK) \\c"
      fi
      sleep 0.3
      if [[ $( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" failure_after_start | sed '/^[[:space:]]*$/d' | wc -l ) -gt 0 ]]
      then
        break;
      fi
    done
    echo

    _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" status
    _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" ps
  )

  elif [ "${ARG9}" == "journalctl" ]
  then
  (
    if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
    then
      sudo journalctl -xb | grep -v 'COMMAND\=/bin/true\|COMMAND\=list\| pam_unix\|COMMAND\=/usr/bin/tail\| sshd\|UFW BLOCK\| CRON\| sudo\[\| su\[' | grep -C 5 "${4}\|${1}" | tail -n 100 | ack --passthru "${4}|${1}"
    else
      journalctl -xb | grep -v 'COMMAND\=/bin/true\|COMMAND\=list\| pam_unix\|COMMAND\=/usr/bin/tail\| sshd\|UFW BLOCK\| CRON\| sudo\[\| su\[' | grep -C 5 "${4}\|${1}" | tail -n 100 | ack --passthru "${4}|${1}"
    fi
  )

  elif [ "${ARG9}" == "failure_after_start" ]
  then
  (
    LAST_FAILURE=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" system_log | grep -aFin ": error: couldn't connect to server" | tail -n 1 | cut -d: -f1 )
    LAST_START=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" system_log | grep -aFin " Starting" | tail -n 1 | cut -d: -f1 )
    if [[ "${LAST_FAILURE}" -gt "${LAST_START}" ]]
    then
      echo "Failure happened after last start attempt."
    fi
  )

  elif [ "${ARG9}" == "forcestart" ]
  then
  (
    if [[ "$( whoami )" == "${1}" ]]
    then
      "${DAEMON_BIN_LOC}" "-datadir=${DATADIR}/" --forcestart --daemon
    else
      sudo su "${1}" -c "${DAEMON_BIN_LOC} --forcestart --daemon "
    fi
  )

  elif [ "${ARG9}" == "start-nosystemd" ]
  then
  (
    if [[ "$( whoami )" == "${1}" ]]
    then
      "${DAEMON_BIN_LOC}" "-datadir=${DATADIR}/" --daemon
    else
      sudo su "${1}" -c "${DAEMON_BIN_LOC} --daemon "
    fi
  )

  elif [ "${ARG9}" == "start-rescan" ]
  then
  (
    if [[ "$( whoami )" == "${1}" ]]
    then
      "${DAEMON_BIN_LOC}" "-datadir=${DATADIR}/" --daemon -rescan
    else
      sudo su "${1}" -c "${DAEMON_BIN_LOC} --daemon -rescan "
    fi
  )

  elif [ "${ARG9}" == "start-recover" ]
  then
  (
    if [[ "$( whoami )" == "${1}" ]]
    then
      "${DAEMON_BIN_LOC}" "-datadir=${DATADIR}/" --daemon -zapwallettxes=1
    else
      sudo su "${1}" -c "${DAEMON_BIN_LOC} --daemon -zapwallettxes=1 "
    fi
  )

  elif [ "${ARG9}" == "start-recover2" ]
  then
  (
    if [[ "$( whoami )" == "${1}" ]]
    then
      "${DAEMON_BIN_LOC}" "-datadir=${DATADIR}/" --daemon -zapwallettxes=2
    else
      sudo su "${1}" -c "${DAEMON_BIN_LOC} --daemon -zapwallettxes=2 "
    fi
  )

  elif [ "${ARG9}" == "restart" ]
  then
  (
    _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" stop
    sleep 1
    _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" start
  )

  elif [ "${ARG9}" == "stop" ]
  then
  (
    if [[ "${ARG10}" == 'no_wait' ]]
    then
      ( sudo -n systemctl stop "${_DAEMON_SYSTEMD_FILENAME}" & disown
        sudo -n su "${1}" -c "${CLI_BIN_LOC} stop & disown " & disown
        "${CLI_BIN_LOC}" "-datadir=${DATADIR}/" stop & disown
      ) & disown
      return
    fi

    _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" ps
    echo "systemctl stop"
    sudo -n systemctl stop "${_DAEMON_SYSTEMD_FILENAME}"  >/dev/null 2>&1
    echo "${2} stop"

    "${CLI_BIN_LOC}" "-datadir=${DATADIR}/" stop >/dev/null 2>&1
    if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
    then
      echo "${2} stop"
      sudo su "${1}" -c "${CLI_BIN_LOC} stop " >/dev/null 2>&1
    fi

    # Skip waiting for the confirmation that the pid and locks are gone.
    if [[ "${ARG10}" == 'skip' ]]
    then
      return
    fi

    if [[ ! -z $( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" pid ) ]]
    then
      # shellcheck disable=SC2030,SC2031
      COUNTER=0
      while [[ ! -z $( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" pid ) ]]
      do
        while read -r PID_TO_KILL
        do
          if [[ "${#PID_TO_KILL}" -lt 1 ]]
          then
            break
          fi
          COUNTER=$((COUNTER+1))
          if [ "${ARG10}" == "y" ]
          then
            printf "."
          else
            echo -e "\\r${SP:i++%${#SP}:1} Waiting for ${1} to shutdown (pid ${PID_TO_KILL}) \\c"
          fi

          # Do nothing for the first 25 seconds.
          if [[ "${COUNTER}" -lt 50 ]]
          then
            continue
          fi

          kill "${PID_TO_KILL}"
          if [[ "${COUNTER}" -gt 99 ]]
          then
            kill -9 "${PID_TO_KILL}" >/dev/null 2>&1
          fi
          if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
          then
            sudo kill "${PID_TO_KILL}" >/dev/null 2>&1
            if [[ "${COUNTER}" -gt 99 ]]
            then
              sudo kill -9 "${PID_TO_KILL}" >/dev/null 2>&1
            fi
          fi
          if [[ "${COUNTER}" -gt 111 ]]
          then
            break
          fi
          sleep 0.5
        done <<< "$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" pid )"
      done
    fi
    _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" pid
    # shellcheck disable=SC2030,SC2031
    COUNTER=0
    while [[ $( lslocks -n -o COMMAND,PID,PATH | grep -c "${DIR}" ) -ne 0 ]]
    do
      COUNTER=$((COUNTER+1))
      if [ "${ARG10}" == "y" ]
      then
        printf "."
      else
        echo -e "\\r${SP:i++%${#SP}:1} Waiting for ${1} to shutdown (lock in ${DIR}) \\c"
      fi
      sleep 0.5
      if [[ "${COUNTER}" -gt 50 ]]
      then
        "${CLI_BIN_LOC}" "-datadir=${DATADIR}/" stop >/dev/null 2>&1
        if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
        then
          sudo su "${1}" -c "${CLI_BIN_LOC} stop " >/dev/null 2>&1
        fi
      fi
      if [[ "${COUNTER}" -gt 111 ]]
      then
        break
      fi
    done
    echo
    _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" pid
    _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" status
  )

  elif [ "${ARG9}" == "disable" ]
  then
  (
    _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" stop
    if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
    then
      sudo touch "${USER_HOME_DIR}/disabled"
    else
      touch "${USER_HOME_DIR}/disabled"
    fi
  )

  elif [ "${ARG9}" == "enable" ]
  then
  (
    _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" start
    (
      sleep 60
      if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
      then
        sudo rm "${USER_HOME_DIR}/disabled" >/dev/null 2>&1 disown
      else
        rm "${USER_HOME_DIR}/disabled" >/dev/null 2>&1 disown
      fi
    )& disown
  )

  elif [ "${ARG9}" == "status" ]
  then
  (
    _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" ps
    if [[ ! -z "${_DAEMON_SYSTEMD_FILE}" ]]
    then
      systemctl status --no-pager --full "${_DAEMON_SYSTEMD_FILENAME}"
    else
      echo 'PID'
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" pid
      echo 'Uptime'
     _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" uptime
    fi
  )

  elif [ "${ARG9}" == "checksystemd" ] || [ "${ARG9}" == "systemdcheck" ]
  then
  (
    TEMP_VAR_A=$( systemctl list-unit-files | sed -e 's/^[[:space:]]*//' | grep -E "^${_DAEMON_SYSTEMD_FILENAME}" | awk '{print $2}' )
    TEMP_VAR_B=$( systemctl | sed -e 's/^[[:space:]]*//' | grep -E "^${_DAEMON_SYSTEMD_FILENAME}" | awk '{print  $3 " " $4}' )
    echo "${TEMP_VAR_A} ${TEMP_VAR_B}"
  )

  elif [ "${ARG9}" == "githubrepo" ]
  then
  (
    if [[ -z "${GITHUB_REPO}" ]] || [[ $( grep -c 'github_repo=' "${5}" ) -gt 0 ]]
    then
      # shellcheck disable=SC2030,SC2031
      GITHUB_REPO=$( grep -m 1 'github_repo=' "${5}" | cut -d '=' -f2 )
    fi
    echo "${GITHUB_REPO}"
  )

  elif [ "${ARG9}" == "update_script" ] || [ "${ARG9}" == "script_update" ]
  then
  # Use subshell to isolate the masternode setup script.
  (
    COUNTER=0
    rm -f /tmp/___mn.sh 2>/dev/null
    while [[ ! -f /tmp/___mn.sh ]] || [[ $( grep -Fxc "# End of masternode setup script." /tmp/___mn.sh ) -eq 0 ]]
    do
      rm -f /tmp/___mn.sh 2>/dev/null
      wget -4qo- gist.githubusercontent.com/mikeytown2/1637d98130ac7dfbfa4d24bac0598107/raw/mcarper.sh -O /tmp/___mn.sh
      chmod 666 /tmp/___mn.sh
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
      rm /tmp/___mn.sh 2>/dev/null
    ) & disown
  )
  # shellcheck source=/root/.bashrc
  source "${HOME:?}/.bashrc"
  touch /var/multi-masternode-data/.bashrc
  cp "${HOME:?}/.bashrc" /var/multi-masternode-data/.bashrc
  chmod 666 /var/multi-masternode-data/.bashrc

  elif [ "${ARG9}" == "update_daemon" ] || [ "${ARG9}" == "daemon_update" ]
  then
  (
    # shellcheck disable=SC2030,SC2031
    if [[ -z "${BIN_BASE}" ]] || [[ $( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" daemon | grep -c "${BIN_BASE}" ) -eq 0 ]]
    then
      # shellcheck disable=SC2030,SC2031
      BIN_BASE=$( grep -m 1 'bin_base=' "${5}" | cut -d '=' -f2 )
      DAEMON_DOWNLOAD=$( grep -m 1 'daemon_download=' "${5}" | grep -o '=.*' | cut -c2- | tr " " "\n" )
    fi
    # shellcheck disable=SC2030,SC2031
    if [[ -z "${GITHUB_REPO}" ]] || [[ $( grep -c 'github_repo=' "${5}" ) -gt 0 ]]
    then
      # shellcheck disable=SC2030,SC2031
      GITHUB_REPO=$( grep -m 1 'github_repo=' "${5}" | cut -d '=' -f2 )
    fi
    DIRECTORY="${DIR}"
    CONF=$( basename "${5}" )
    DEFAULT_PORT=$( grep -m 1 'defaultport=' "${5}" | cut -d '=' -f2 )
    if [ -z "${DEFAULT_PORT}" ] || [[ $( grep -c 'externalip=' "${5}" ) -gt 0 ]]
    then
      DEFAULT_PORT=$( grep -m 1 'externalip=' "${5}" | cut -d '=' -f2 | cut -d ':' -f2 )
    fi
    COLLATERAL=1
    DAEMON_NAME=${GITHUB_REPO}
    TICKER='FAKE_COIN'
    BLOCKTIME=1
    PROJECT_DIR=$( echo "${GITHUB_REPO}" | tr '/' '_' )
    CONTROLLER_BIN=${2}
    DAEMON_BIN=${4}

    # Use subshell to isolate the masternode setup script.
    (
    IS_EMPTY=$( type DAEMON_DOWNLOAD_SUPER 2>/dev/null )
    if [ -z "${IS_EMPTY}" ]
    then
      # shellcheck disable=SC2030,SC2031
      COUNTER=0
      rm -f /tmp/___mn.sh 2>/dev/null
      while [[ ! -f /tmp/___mn.sh ]] || [[ $( grep -Fxc "# End of masternode setup script." /tmp/___mn.sh ) -eq 0 ]]
      do
        rm -f /tmp/___mn.sh 2>/dev/null
        wget -4qo- gist.githubusercontent.com/mikeytown2/1637d98130ac7dfbfa4d24bac0598107/raw/mcarper.sh -O /tmp/___mn.sh
        chmod 666 /tmp/___mn.sh
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
        rm /tmp/___mn.sh 2>/dev/null
      ) & disown

      # shellcheck disable=SC1091
      . /tmp/___mn.sh
    fi

    sleep 1
    DAEMON_DOWNLOAD_SUPER "${GITHUB_REPO}" "${BIN_BASE}" "${DAEMON_DOWNLOAD}" "${ARG10}"
    )

    # Set executable bit.
    if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
    then
      sudo chmod +x "/var/multi-masternode-data/${PROJECT_DIR}/src/${CONTROLLER_BIN}"
      sudo chmod +x "/var/multi-masternode-data/${PROJECT_DIR}/src/${DAEMON_BIN}"
    else
      chmod +x "/var/multi-masternode-data/${PROJECT_DIR}/src/${CONTROLLER_BIN}"
      chmod +x "/var/multi-masternode-data/${PROJECT_DIR}/src/${DAEMON_BIN}"
    fi

    VERSION_REMOTE=$( timeout --signal=SIGKILL 9s "/var/multi-masternode-data/${PROJECT_DIR}/src/${CONTROLLER_BIN}" --help 2>/dev/null | head -n 1 | sed 's/[^0-9.]*\([0-9.]*\).*/\1/' )
    if [[ -z "${VERSION_REMOTE}" ]]
    then
      VERSION_REMOTE=$( timeout --signal=SIGKILL 9s "/var/multi-masternode-data/${PROJECT_DIR}/src/${CONTROLLER_BIN}" -version 2>/dev/null | sed 's/[^0-9.]*\([0-9.]*\).*/\1/' )
    fi
    VERSION_LOCAL=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" --help 2>/dev/null | head -n 1 | sed 's/[^0-9.]*\([0-9.]*\).*/\1/' )
    if [[ -z "${VERSION_LOCAL}" ]]
    then
      VERSION_LOCAL=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" -version 2>/dev/null | head -n 1 | sed 's/[^0-9.]*\([0-9.]*\).*/\1/' )
    fi
    if [[ $( echo "${VERSION_LOCAL}" | grep -c "${VERSION_REMOTE}" ) -eq 1 ]] && [[ "${ARG10}" != 'force' ]] && [[ "${ARG10}" != 'force_skip_download' ]]
    then
      echo
      echo "Already the latest version (${VERSION_LOCAL}) according to "
      echo "https://github.com/${GITHUB_REPO}/releases/latest"
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" --help | head -n 1
      echo
      return 1 2>/dev/null
    fi
    dt=$( date -u '+%d/%m/%Y %H:%M:%S' )
    echo
    # shellcheck disable=SC2030,SC2031
    echo "${dt} Updating ${VERSION_LOCAL} to the latest version ${VERSION_REMOTE} for ${1}" 2>&1 | tee -a "${USR_HOME}/update.log"
    echo
    TEMP_VAR_PID=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" pid )
    if [[ ! -z "${TEMP_VAR_PID}" ]]
    then
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" stop
    fi
    if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
    then
      sudo mkdir -p "${USER_HOME_DIR}"/.local/bin
      sudo cp "/var/multi-masternode-data/${PROJECT_DIR}/src/${DAEMON_BIN}" "${USER_HOME_DIR}"/.local/bin/
      sudo chmod +x "${USER_HOME_DIR}"/.local/bin/"${DAEMON_BIN}"
      sudo cp "/var/multi-masternode-data/${PROJECT_DIR}/src/${CONTROLLER_BIN}" "${USER_HOME_DIR}"/.local/bin/
      sudo chmod +x "${USER_HOME_DIR}"/.local/bin/"${CONTROLLER_BIN}"
      sudo chown -R "${1}":"${1}" "${USER_HOME_DIR}"
    else
      mkdir -p "${USER_HOME_DIR}"/.local/bin
      cp "/var/multi-masternode-data/${PROJECT_DIR}/src/${DAEMON_BIN}" "${USER_HOME_DIR}"/.local/bin/
      chmod +x "${USER_HOME_DIR}"/.local/bin/"${DAEMON_BIN}"
      cp "/var/multi-masternode-data/${PROJECT_DIR}/src/${CONTROLLER_BIN}" "${USER_HOME_DIR}"/.local/bin/
      chmod +x "${USER_HOME_DIR}"/.local/bin/"${CONTROLLER_BIN}"
      chown -R "${1}":"${1}" "${USER_HOME_DIR}"
    fi
    if [[ ! -z "${TEMP_VAR_PID}" ]]
    then
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" start
    fi
    echo
    # shellcheck disable=SC2030,SC2031
    _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" --help | head -n 1 2>&1 | tee -a "${USR_HOME}/update.log"
    echo

    if [[ ! -z "${TEMP_VAR_PID}" ]]
    then
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" wait_for_loaded
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" blockcheck_fix
    fi
    echo "bash -ic 'source /var/multi-masternode-data/.bashrc; ${1} blockcheck_fix 2>&1'" | at now +24 hours 2>&1 | grep -v "commands will be executed using"
    echo "bash -ic 'source /var/multi-masternode-data/.bashrc; ${1} blockcheck_reindex 2>&1'" | at now +48 hours 2>&1 | grep -v "commands will be executed using"
    echo "bash -ic 'source /var/multi-masternode-data/.bashrc; ${1} blockcheck_reindex 2>&1'" | at now +72 hours  2>&1 | grep -v "commands will be executed using"
  )

  elif [ "${ARG9}" == "wait_for_loaded" ]
  then
  (
    TEMP_VAR_PID=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" pid )
    if [[ -z "${TEMP_VAR_PID}" ]]
    then
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" start
      sleep 10
    fi

    GETINFO=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "${_MASTERNODE_CALLER}"status )
    if [[ "${#GETINFO}" -lt 7 ]]
    then
      GETINFO=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "${_MASTERNODE_CALLER}"debug )
      if [[ "${#GETINFO}" -lt 7 ]]
      then
        GETINFO=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" getinfo )
      fi
    fi
    WAIT_FOR=1000
    MIN_WIDTH=20
    COUNTER=0

    echo "Waiting for the daemon to load..."
    echo
    while [[ $( echo "${GETINFO}" | grep -ci '^error:' ) -gt 0 ]] || \
      [[ $( echo "${GETINFO}" | grep -ci 'loading block index' ) -gt 0 ]] || \
      [[ $( echo "${GETINFO}" | grep -ci 'loading wallet' ) -gt 0 ]] || \
      [[ $( echo "${GETINFO}" | grep -ci 'Node just started' ) -gt 0 ]] || \
      [[ $( echo "${GETINFO}" | grep -ci 'Rescanning.' ) -gt 0 ]] || \
      [[ $( echo "${GETINFO}" | grep -ci 'Rewinding blocks.' ) -gt 0 ]] || \
      [[ $( echo "${GETINFO}" | grep -ci 'Loading fulfilled requests cache.' ) -gt 0 ]] || \
      [[ $( echo "${GETINFO}" | grep -ci 'Verifying blocks' ) -gt 0 ]]
    do
      LAST_LINE=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" daemon_log tail 1 )
      if [[ "$( echo "${LAST_LINE}" | grep -ic 'Shutdown: done' )" -gt 0 ]]
      then
        echo
        echo "Node shutdown."
        break
      fi

      if [ "${ARG10}" == "y" ]
      then
        printf "."
      else
        tput cuu1
        TERM_WIDTH=$( tput cols )
        TERM_WIDTH=$(( TERM_WIDTH > MIN_WIDTH ? TERM_WIDTH : MIN_WIDTH ))
        TERM_WIDTH=$(( TERM_WIDTH - 1 ))
        LINE="${SP:COUNTER++%${#SP}:1} ${LAST_LINE}"
        printf "%-${TERM_WIDTH}s\n" "${LINE:0:${TERM_WIDTH}}"
      fi

      if [[ "${COUNTER}" -gt "${WAIT_FOR}" ]]
      then
        echo
        echo "Moving forward after waiting over 5 min."
        break
      fi
      sleep 0.3
      if [[ $(( COUNTER % 9 )) -eq 0 ]]
      then
        GETINFO=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "${_MASTERNODE_CALLER}"status )
        if [[ "${#GETINFO}" -lt 7 ]]
        then
          GETINFO=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "${_MASTERNODE_CALLER}"debug )
          if [[ "${#GETINFO}" -lt 7 ]]
          then
            GETINFO=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" getinfo )
          fi
        fi
      fi

    done
    echo
  )

  elif [ "${ARG9}" == "blockcheck_fix" ]
  then
  (
    if [[ $( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" blockcheck 2>/dev/null | sed '/^[[:space:]]*$/d' | wc -l ) -gt 1 ]]
    then
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" stop
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" remove_addnode

      DROPBOX_BLOCKS_N_CHAINS=$( grep -m 1 'blocks_n_chains=' "${5}" | cut -d '=' -f2 )
      DROPBOX_BOOTSTRAP=$( grep -m 1 'bootstrap=' "${5}" | cut -d '=' -f2 )
      if [[ ! -z "${DROPBOX_BLOCKS_N_CHAINS}" ]]
      then
        _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" dl_blocks_n_chains force
      elif [ ! -z "${DROPBOX_BOOTSTRAP}" ]
      then
        _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" dl_bootstrap
      else
        _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" reindex
      fi

      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" start
    fi
  )

  elif [ "${ARG9}" == "blockcheck_reindex" ]
  then
  (
    if [[ $( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" blockcheck 2>/dev/null | sed '/^[[:space:]]*$/d' | wc -l ) -gt 1 ]]
    then
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" stop
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" remove_addnode
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" reindex
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" start
    fi
  )

  elif [ "${ARG9}" == "remove_daemon" ] || [ "${ARG9}" == "daemon_remove" ]
  then
  (
    sudo true >/dev/null 2>&1
    USR_EXISTS=$( id -u "${1}" 2>/dev/null )
    DAEMON_BALANCE=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" getbalance )
    if [[ "${DAEMON_BALANCE}" != 0 ]] && [[ ! "${DAEMON_BALANCE}" =~ $RE_FLOAT ]]
    then
      echo "WARNING! Balance is not zero!"
      REPLY=n
      read -r -p $'Still Delete? \e[7m(y/n)\e[0m? ' -e -i "${REPLY}" input 2>&1
      REPLY="${input:-$REPLY}"
      if [[ ! $REPLY =~ ^[Yy] ]]
      then
        return
      fi
    fi
    if [ ! "${ARG10}" == "force" ] && [ "${#USR_EXISTS}" -gt 0 ]
    then
      echo "User ${1} will be deleted when this timer reaches 0"
      seconds=8
      date1=$(( $(date -u +%s) + seconds));
      echo "Press ctrl-c to stop"
      while [ "${date1}" -ge "$(date -u +%s)" ]
      do
        echo -ne "$(date -u --date @$(( date1 - $(date -u +%s) )) +%H:%M:%S)\r";
      done
    fi
    TEMP_VAR_PID=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" pid )
    if [[ ! -z "${TEMP_VAR_PID}" ]]
    then
      echo "kill -9 ${TEMP_VAR_PID}"
      sudo kill -9 "${TEMP_VAR_PID}"
    fi
    echo "Disable Systemd for ${_DAEMON_SYSTEMD_FILENAME}"
    sudo systemctl disable "${_DAEMON_SYSTEMD_FILENAME}" -f --now 2>/dev/null
    sudo rm -f "/etc/systemd/system/${_DAEMON_SYSTEMD_FILENAME}"
    sudo systemctl daemon-reload
    if [[ ! -z "${TEMP_VAR_PID}" ]]
    then
      sudo kill -9 "${TEMP_VAR_PID}"
    fi
    if [[ "${1}" != 'root' ]]
    then
      echo "Deleting user ${1}."
      sudo su "${1}" -c 'crontab -r' 2>/dev/null
      sudo userdel -rfRZ "${1}" 2>/dev/null
    else
      echo "Deleting datadir ${DATADIR}."
      if [[ ! -z "${DATADIR}" ]]
      then
        sudo rm -rf "${DATADIR:?}"
      fi
    fi

    if [ -r "/etc/sudoers.d/${1}" ]
    then
      # Remove sudoers file.
      sudo rm -rf "/etc/sudoers.d/${1}"
    fi

    # Change apparmor.
    LINES="${DAEMON_BIN_LOC}
${CLI_BIN_LOC}
${USER_HOME_DIR}/sentinel/venv/bin/python2
"
    while read -r SEARCH_LINE
    do
      if [[ $( grep -c "${SEARCH_LINE}" /etc/apparmor.d/multi-masternode-data ) -gt 0 ]]
      then
        END=0
        START=$( grep -Fxn "${SEARCH_LINE} {" /etc/apparmor.d/multi-masternode-data | sed 's/:/ /g' | awk '{print $1 }' )
        if [[ "${START}" -gt 0 ]] && [[ "${#START}" -gt 0 ]]
        then
          END=$( tail -n "+${START}" /etc/apparmor.d/multi-masternode-data | grep -xn -m 1 '^}$' | sed 's/:/ /g' | awk '{print $1 }' )
        fi
        if [[ "${END}" -gt 0 ]]
        then
          END=$(( START + END - 1 ))
          echo "Removing ${SEARCH_LINE} from apparmor"
          sed -i "${START},${END}d" /etc/apparmor.d/multi-masternode-data
        fi
      fi
    done <<< "${LINES}"
    sudo systemctl reload apparmor.service

    # Remove from .bashrc.
    if [[ $( grep -c "# Start of function for ${1}." "${HOME}/.bashrc" ) -gt 0 ]]
    then
      START=$( grep -Fxn "# Start of function for ${1}." "${HOME}/.bashrc" | sed 's/:/ /g' | awk '{print $1 }' )
      if [[ "${START}" -gt 0 ]]
      then
        END=$( grep -Fxn "# End of function for ${1}." "${HOME}/.bashrc" | sed 's/:/ /g' | awk '{print $1 }' )
      fi
      if [[ "${END}" -gt 0 ]]
      then
        echo "Removing ${1} from .bashrc"
        sed -i "${START},${END}d" "${HOME}/.bashrc"
      fi
    fi

  )
  unset -f "${1}"
  # shellcheck source=/root/.bashrc
  source "${HOME:?}/.bashrc"

  elif [ "${ARG9}" == "reindexzerocoin" ]
  then
  (
    _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" stop >/dev/null 2>&1
    sleep 2

    echo "Rebuild local zerocoin database"
    if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
    then
      sudo su "${1}" -c "${DAEMON_BIN_LOC} --daemon --reindexzerocoin"
    else
      "${DAEMON_BIN_LOC}" "-datadir=${DATADIR}/" --reindex --forcestart --daemon --reindexzerocoin
    fi
    sleep 5

    echo
    echo "Restarting ${1}"
    _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" stop >/dev/null 2>&1
    sleep 5
    _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" start
  )

  elif [ "${ARG9}" == "reindex" ]
  then
  (
    HAS_ZERO_COIN=' --reindexzerocoin'
    if [[ $( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" getzerocoinbalance | grep -cF "not found") -gt 0 ]]
    then
      HAS_ZERO_COIN=''
    fi
    echo "Stopping ${1}"
    _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" stop >/dev/null 2>&1
    sleep 2
    echo "Remove local blockchain database"
    FILENAME=$( basename "${5}" )
    if [ "${ARG10}" == "remove_peers" ] || [ "${ARG10}" == "peers_remove" ] || [ "${ARG11}" == "remove_peers" ] || [ "${ARG11}" == "peers_remove" ]
    then
      find "${DIR}" -maxdepth 1 | tail -n +2 | grep -vE "backups|wallet.dat|${FILENAME}|debug.log" | xargs rm -r
    else
      find "${DIR}" -maxdepth 1 | tail -n +2 | grep -vE "backups|wallet.dat|${FILENAME}|peers.dat|debug.log" | xargs rm -r
    fi
    if [[ "${ARG10}" == "nuke" ]]
    then
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" connect_to_addnode
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" addnode_remove
      rm -r "${DIR}/peers.dat"
      rm -r "${DIR}/debug.log"
    fi

    if ([ "${ARG10}" == "remove_addnode" ] || [ "${ARG10}" == "addnode_remove" ] || [ "${ARG11}" == "remove_addnode" ] || [ "${ARG11}" == "addnode_remove" ]) && [ -r "${5}" ]
    then
      echo "${5}"
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" addnode_remove
    fi

    echo "Rebuild local blockchain database"
    if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
    then
      sudo su "${1}" -c "${DAEMON_BIN_LOC} --reindex --forcestart --daemon $HAS_ZERO_COIN"
    else
      "${DAEMON_BIN_LOC}" "-datadir=${DATADIR}/" --reindex --forcestart --daemon "$HAS_ZERO_COIN"
    fi

    if [[ "${ARG10}" == "nuke" ]]
    then
      return
    fi

    sleep 5
    echo
    echo "Restarting ${1}"
    _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" stop >/dev/null 2>&1
    sleep 5
    _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" start
  )

  elif [ "${ARG9}" == "system_log" ] || [ "${ARG9}" == "log_system" ]
  then
  (
    if [ "${ARG10}" == "grep" ]
    then
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" system_log | grep -aFi "${ARG11}"
    else
      journalctl -q -u "${1}"
    fi
  )

  elif [ "${ARG9}" == "daemon_log" ] || [ "${ARG9}" == "log_daemon" ]
  then
  (
    if [ "${ARG10}" == "location" ] || [ "${ARG10}" == "loc" ]
    then
      if [ -r "${DIR}/debug.log" ]
      then
        echo "${DIR}/debug.log"
      else
        if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
        then
          sudo find "${DIR}" -maxdepth 1 -name \*.log -not -empty
        else
          find "${DIR}" -maxdepth 1 -name \*.log -not -empty
        fi
      fi

    elif [ "${ARG10}" == "tac" ]
    then
      if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
      then
        sudo tac "${DIR}/debug.log"
      else
        tac "${DIR}/debug.log"
      fi

    elif [ "${ARG10}" == "tail" ]
    then
      N=50
      if [ ! -z "${ARG11}" ] && [[ ${ARG11} =~ ${RE} ]]
      then
        N="${ARG11}"
      fi

      if [ "${ARG12}" == 'watch' ]
      then
        if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
        then
          sudo watch -n 0.3 tail -n "${N}" "${DIR}/debug.log"
        else
          watch -n 0.3 tail -n "${N}" "${DIR}/debug.log"
        fi
      else
        if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
        then
          sudo tail -n "${N}" "${DIR}/debug.log"
        else
          tail -n "${N}" "${DIR}/debug.log" 2>/dev/null
        fi
      fi

    elif [ "${ARG10}" == "grep" ]
    then
      if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
      then
        sudo "grep" -aFi "${ARG11}" "${DIR}/debug.log"
      else
        grep -aFi "${ARG11}" "${DIR}/debug.log"
      fi

    elif [ "${ARG10}" == "starts" ]
    then
      TOTAL_LINES=$( wc -l < "${DIR}/debug.log" )
      STARTS=1
      if [[ ${ARG11} =~ ${RE} ]]
      then
        COUNTER=1
        while [[ "${COUNTER}" -lt "${ARG11}" ]]
        do
          COUNTER=$(( COUNTER + 1 ))
          STARTS="${STARTS} ${COUNTER}"
        done
      fi

      # Get 10 line behind and 30 lines ahead of start/stop spot
      LOOK_AHEAD=47
      LOOK_BEHIND=11

      if [[ ${ARG12} =~ ${RE} ]]
      then
        ADDITIONAL="${ARG12}"
        LOOK_AHEAD=$(( LOOK_AHEAD + ADDITIONAL ))
        LOOK_BEHIND=$(( LOOK_BEHIND + ADDITIONAL ))
      fi

      COUNTER=0
      TOTAL=$( echo "${STARTS}" | awk '{print $NF}' )
      OUTPUT=''
      while read -r LINE_NUMBER
      do
        START_NUMBER=$(( TOTAL - COUNTER ))
        COUNTER=$(( COUNTER + 1 ))
        if [[ $( echo "${STARTS}" | grep -c -e "${COUNTER}\b" -e "[[:space:]]${COUNTER}[[:space:]]" -e "^${COUNTER}$" ) -lt 1 ]]
        then
          continue
        fi
        START_OUTPUT=$(( TOTAL_LINES - LINE_NUMBER - LOOK_BEHIND ))
        START_OUTPUT=$( echo "${START_OUTPUT} 1 " | jq -s max )
        END_OUTPUT=$(( START_OUTPUT + LOOK_BEHIND + LOOK_AHEAD ))
        OUTPUT=$(
        echo
        echo "+++++ Start ${COUNTER}"
        echo
        sed -n "${START_OUTPUT}","${END_OUTPUT}"p "${DIR}/debug.log" | sed '/^$/N;/^\n$/D' | sed 's/^$/\n/'
        echo "${OUTPUT}"
        )

      done <<< "$( tac "${DIR}/debug.log" | pcregrep -n -o1 -M '\n\n\n' | sort -n | uniq -c | grep ' 1 .*' | awk 'NR == 1 || NR % 3 == 0' | tail -n +2 | awk '{ print $2 }' | tr -d ':' )"
      echo "${OUTPUT}"

    elif [ -r "${DIR}/debug.log" ]
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
  )

  elif [ "${ARG9}" == "peers_remove" ] || [ "${ARG9}" == "remove_peers" ]
  then
  (
    if [ -s "${DIR}/peers.dat" ]
    then
      TEMP_VAR_PID=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" pid )
      if [[ ! -z "${TEMP_VAR_PID}" ]]
      then
        _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" stop
      fi
      rm -f "${DIR}/peers.dat"
      if [[ ! -z "${TEMP_VAR_PID}" ]]
      then
        sleep 5
        _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" start
      fi
    fi
  )

  elif [ "${ARG9}" == "addnode_remove" ] || [ "${ARG9}" == "remove_addnode" ]
  then
  (
    if [[ ! -r "${5}" ]]
    then
      return
    fi

    TEMP_VAR_PID=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" pid )
    if [[ ! -z "${TEMP_VAR_PID}" ]]
    then
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" stop
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
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" start
    fi
  )

  elif [ "${ARG9}" == "addnode_to_connect" ] && [ -r "${5}" ]
  then
  (
    TEMP_VAR_PID=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" pid )
    if [[ ! -z "${TEMP_VAR_PID}" ]]
    then
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" stop
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
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" start
    fi
  )

  elif [ "${ARG9}" == "connect_to_addnode" ] && [ -r "${5}" ]
  then
  (
    TEMP_VAR_PID=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" pid )
    if [[ ! -z "${TEMP_VAR_PID}" ]]
    then
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" stop
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
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" start
    fi
  )

  elif [ "${ARG9}" == "conf" ] && [ -r "${5}" ]
  then
  (
    if [ "${ARG10}" == "location" ] || [ "${ARG10}" == "loc" ]
    then
      echo "${5}"
    elif [ "${ARG10}" == "nano" ]
    then
      nano "${5}"
    elif [ "${ARG10}" == "vim" ]
    then
      vim "${5}"
    elif [ "${ARG10}" == "edit" ] && [[ ! -z "${ARG11}" ]]
    then
      CONF_NOW=$( grep -m 1 -E "( |^)${ARG11}=" "${5}" | cut -d '=' -f2 )
      if [[ ! -z "${ARG12}" ]]
      then
        if [[ ! ${CAN_SUDO} =~ ${RE} ]] || [[ "${CAN_SUDO}" -le 2 ]]
        then
          echo
          echo "Need sudo in order to change conf file."
          echo
          return
        fi

        if [[ "${CONF_NOW}" == "${ARG12}" ]]
        then
          echo
          echo "${ARG11} already set to ${ARG12}."
          echo
          return
        fi

        sudo sed -i "/\(^\|\\s\)${VAR}\=/d" "${5}"
        if [[ $( echo "${ARG12}" | tr '[:upper:]' '[:lower:]' ) == 'null' ]]
        then
          echo
          echo "Removing ${ARG11}= from conf file."
          echo
        else
          echo
          echo "${ARG11}=${ARG12}" | sudo tee -a "${5}" >/dev/null
          echo "Setting ${ARG11}=${ARG12}."
          echo
        fi

        # Restarting node to make changes take effect.
        TEMP_VAR_PID=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" pid )
        if [[ ! -z "${TEMP_VAR_PID}" ]]
        then
          _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" restart
        fi

      elif [[ ! -z "${CONF_NOW}" ]]
      then
        echo
        echo "${ARG11} is currently set to ${CONF_NOW}"
        echo

      elif [[ -z "${CONF_NOW}" ]]
      then
        echo
        echo "${ARG11} is currently not set."
        echo
      fi
    else
      sudo cat "${5}"
    fi
  )

  elif [ "${ARG9}" == "port" ]
  then
  (
    if  [ ! -f "${5}" ]
    then
        echo
        echo "Conf file can not be found"
        echo "${5}"
        echo
        return
    fi
    if [ ! -z "${ARG10}" ] && [[ "${ARG10}" =~ ${RE} ]]
    then
      if [[ ! ${CAN_SUDO} =~ ${RE} ]] || [[ "${CAN_SUDO}" -le 2 ]]
      then
        echo
        echo "Need sudo in order to change port."
        echo
        return
      fi
      IP_EXTERNAL=$( grep -m 1 'externalip=' "${5}" | cut -d '=' -f2 | sed 's/:[0-9]*$//g' )
      IP_BIND=$( grep -m 1 'bind=' "${5}" | cut -d '=' -f2 | sed 's/:[0-9]*$//g' )
      PORT_EXTERNAL=$( grep -m 1 'bind=' "${5}" | cut -d '=' -f2 | grep -o ':[0-9]*$' | grep -o '[0-9]*$' )
      PORT_BIND=$( grep -m 1 'externalip=' "${5}" | cut -d '=' -f2 | grep -o ':[0-9]*$' | grep -o '[0-9]*$' )
      if [[ "${PORT_BIND}" == "${ARG10}" ]] && [[ "${PORT_EXTERNAL}" == "${ARG10}" ]]
      then
        echo
        echo "Port already set to ${ARG10}."
        echo
        return
      fi

      if [[ "$( sudo netstat -tulpnW | grep -cF "${IP_BIND}:${ARG10}" )" -gt 0 ]]
      then
        echo
        echo "Port already in use; netstat failure."
        sudo netstat -tulpnW | grep -F "${IP_BIND}:${ARG10}"
        echo
        return
      fi
      NETCAT_TEST=$( sudo timeout --signal=SIGKILL 0.2s netcat -p "${ARG10}" -l "${IP_BIND}" 2>&1 )
      NETCAT_PID=$!
      kill -9 "${NETCAT_PID}" >/dev/null 2>&1
      if [[ $( echo "${NETCAT_TEST}" | grep -ci 'in use' ) -gt 0 ]]
      then
        sudo -n ss -lpn 2>/dev/null  | grep ":${ARG10} "
        echo
        echo "Port can not be used; netcat failure."
        echo
        return
      fi

      # Remove externalip and bind.
      sudo sed -i "/externalip\=/d" "${5}"
      sudo sed -i "/bind\=/d" "${5}"
      # Add externalip and bind.
      echo "externalip=${IP_EXTERNAL}:${ARG10}" | sudo tee -a "${5}" >/dev/null
      echo "bind=${IP_BIND}:${ARG10}" | sudo tee -a "${5}" >/dev/null
      # Open up port.
      sudo ufw allow "${ARG10}" >/dev/null 2>&1

      # Restart node to change port settings.
      TEMP_VAR_PID=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" pid )
      if [[ ! -z "${TEMP_VAR_PID}" ]]
      then
        _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" restart
      fi
    fi

    PORT_EXTERNAL=$( grep -m 1 'externalip=' "${5}" | cut -d '=' -f2 | grep -o ':[0-9]*$' | grep -o '[0-9]*$' )
    PORT_BIND=$( grep -m 1 'bind=' "${5}" | cut -d '=' -f2 | grep -o ':[0-9]*$' | grep -o '[0-9]*$' )
    if [[ "${PORT_EXTERNAL}" == "${PORT_BIND}" ]]
    then
      echo
      echo "${PORT_EXTERNAL}"
      echo
    fi
  )

  elif [ "${ARG9}" == "mnlocal" ] || [ "${ARG9}" == "${_MASTERNODE_PREFIX}local" ]
  then
  (
    BALANCE=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" getbalance )
    if [[ $( echo "${BALANCE}>0" | bc 2>/dev/null ) -gt 0 ]]
    then
      MN_OUTPUTS=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "${_MASTERNODE_CALLER}"outputs )
      if [[ "${#MN_OUTPUTS}" -gt 10 ]]
      then
        echo "${MN_OUTPUTS}"
        MN_DEBUG=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "${_MASTERNODE_CALLER}"debug )
        if [[ "${#MN_DEBUG}" -gt 10 ]]
        then
          echo "${MN_DEBUG}"
        else
          _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "${_MASTERNODE_CALLER}"status
        fi
        _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "${_MASTERNODE_CONF}"
      else
        echo
        echo "${BALANCE}"
        MN1_ADDR=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" getaccountaddress mn1 )
        echo "${1}" sendtoaddress "${MN1_ADDR}"
        echo
      fi
    fi
  )

  elif [ "${ARG9}" == "masternode.conf" ] || [ "${ARG9}" == "${_MASTERNODE_CONF}" ]
  then
  (
    if [[ "${ARG10}" == 'loc' ]] || [[ "${ARG10}" == 'location' ]]
    then
      touch "${DATADIR}/${_MASTERNODE_CONF}"
      chown "${1}":"${1}" "${DATADIR}/${_MASTERNODE_CONF}"
      echo "${DATADIR}/${_MASTERNODE_CONF}"

    elif [[ "${ARG10}" == 'nano' ]]
    then
      nano "${DATADIR}/${_MASTERNODE_CONF}"
      chown "${1}":"${1}" "${DATADIR}/${_MASTERNODE_CONF}"

    elif [[ "${ARG10}" == 'vim' ]]
    then
      nano "${DATADIR}/${_MASTERNODE_CONF}"
      chown "${1}":"${1}" "${DATADIR}/${_MASTERNODE_CONF}"

    elif [[ "${ARG10}" == 'cat' ]]
    then
      touch "${DATADIR}/${_MASTERNODE_CONF}"
      chown "${1}":"${1}" "${DATADIR}/${_MASTERNODE_CONF}"
      cat "${DATADIR}/${_MASTERNODE_CONF}"

    elif  [ -r "${5}" ]
    then
      PART_A=$( hostname -s )
      PART_B1=$( grep -m 1 'externalip=' "${5}" | cut -d '=' -f2 )
      PART_B2=$( grep -m 1 'defaultport=' "${5}" | cut -d '=' -f2 )
      PART_C=$( grep -m 1 "${_MASTERNODE_PRIVKEY}=" "${5}" | cut -d '=' -f2 )
      PART_D=$( grep -m 1 'txhash=' "${5}" | cut -d '=' -f2 )
      PART_E=$( grep -m 1 'outputidx=' "${5}" | cut -d '=' -f2 )
      if [ ! -z "${PART_B2}" ]
      then
        # shellcheck disable=SC2001
        PART_B1=$( echo "${PART_B1}" | sed 's/:[0-9]*$//g' )
        PART_B1="${PART_B1}:${PART_B2}"
      fi
      if [[ -z "${PART_D}" ]] || [[ -z "${PART_E}" ]]
      then
        MASTERNODE_OUTPUTS=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "${_MASTERNODE_CALLER}"outputs )
        TXID=$( echo "${MASTERNODE_OUTPUTS}" | jq -r ".[0].txhash" 2>/dev/null | grep -o -w -E '[[:alnum:]]{64}' )
        OUTPUTIDX=$( echo "${MASTERNODE_OUTPUTS}" | jq -r ".[0].outputidx" 2>/dev/null )
        if [[ -z "${TXID}" ]] || [[ -z "${OUTPUTIDX}" ]]
        then
          TXID=$( echo "${MASTERNODE_OUTPUTS}" | grep -o -w -E -m 1 '[[:alnum:]]{64}' )
          OUTPUTIDX=$( echo "${MASTERNODE_OUTPUTS}" | grep -w -E -m 1 '[[:alnum:]]{64}' | grep -o ':.*' | grep -o '[0-9]*' )
        fi
        PART_D=${TXID}
        PART_E=${OUTPUTIDX}
      fi

      echo
      echo "${1}_${PART_A} ${PART_B1} ${PART_C} ${PART_D} ${PART_E} "
      echo

      if [[ "${ARG10}" == 'add' ]]
      then
        touch "${DATADIR}/${_MASTERNODE_CONF}"
        echo "${1}_${PART_A} ${PART_B1} ${PART_C} ${PART_D} ${PART_E}" >> "${DATADIR}/${_MASTERNODE_CONF}"
        chown "${1}":"${1}" "${DATADIR}/${_MASTERNODE_CONF}"
      fi
    fi
  )

  elif [ "${ARG9}" == "privkey" ] && [ -r "${5}" ]
  then
  (
    TEMP_VAR_A="${ARG10}"
    if [[ "${ARG10}" == "genkey" ]] || [[ "${ARG10}" == "keygen" ]]
    then

      TEMP_VAR_PID=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" pid )
      if [[ -z "${TEMP_VAR_PID}" ]]
      then
        echo "Starting ${1}"
        _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" start
      fi

      TEMP_VAR_A=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "${_MASTERNODE_GENKEY_COMMAND}" )
    fi

    if [ -z "${ARG10}" ]
    then
      grep -m 1 "${_MASTERNODE_PRIVKEY}=" "${5}" | cut -d '=' -f2

    elif [[ "${ARG10}" == "remove" ]]
    then
      if [[ $( grep -cF "${_MASTERNODE_NAME}=" "${5}" ) -ge 1 ]] || [[ $( grep -cF "/${_MASTERNODE_PRIVKEY}=" "${5}" ) -ge 1 ]]
      then
        TEMP_VAR_PIDD=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" pid )
        if [[ ! -z "${TEMP_VAR_PIDD}" ]]
        then
          echo "Stopping ${1}"
          _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" stop
        fi
        echo "Removing ${_MASTERNODE_NAME} configuration for ${1}"

        if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
        then
          sudo sed -i "/${_MASTERNODE_PRIVKEY}\=/d" "${5}"
          sudo sed -i "/${_MASTERNODE_NAME}\=/d" "${5}"
        else
          sed -i "/${_MASTERNODE_PRIVKEY}\=/d" "${5}"
          sed -i "/${_MASTERNODE_NAME}\=/d" "${5}"
        fi

        if [[ ! -z "${TEMP_VAR_PIDD}" ]]
        then
          echo "Starting ${1}"
          sleep 5
          _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" start
        fi
      fi

    elif [[ "${#TEMP_VAR_A}" -ne 51 ]] && [[ "${#TEMP_VAR_A}" -ne 50 ]]
    then
      echo
      echo "New ${_MASTERNODE_PRIVKEY} is not 50/51 char long and thus invalid."
      echo "${TEMP_VAR_A}"
      echo
      return 1 2>/dev/null

    else
      TEMP_VAR_PID=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" pid )
      if [[ ! -z "${TEMP_VAR_PID}" ]]
      then
        echo "Stopping ${1}"
        _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" stop
        sleep 0.5
      fi

      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" privkey remove
      echo "Reconfiguring ${1}"
      echo "${_MASTERNODE_NAME}=1" | sudo tee -a "${5}" >/dev/null
      echo "${_MASTERNODE_PRIVKEY}=${TEMP_VAR_A}" | sudo tee -a "${5}" >/dev/null

      if [[ ! -z "${TEMP_VAR_PID}" ]]
      then
        echo "Starting ${1}"
        sleep 3
        _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" start
      fi

      echo "privkey"
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" privkey
    fi
  )

  elif [ "${ARG9}" == "mnlistfull" ] || [ "${ARG9}" == "${_MASTERNODE_PREFIX}listfull" ]
  then
  (
    MN_LIST=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" masternode list )
    if [[ -z $( echo "${MN_LIST}" | jq '.[].rank' 2>/dev/null | tr -d '\040\011\012\015' ) ]]
    then
      if [[ -z "${ARG10}" ]]
      then
        ATTRIBUTES='rank
activeseconds
addr
address
lastseen
lastpaid
protocol
daemonversion
pubkey
status
payee
lastpaidblock
lastpaidtime
reward
votes
vin
active
sentinel
sentinelversion
sentinelstate
'
      else
        ATTRIBUTES=$( echo "${ARG10}" | tr " " "\n" )
      fi

      TEMP_FILE_NAME1=$( mktemp )
      TEMP_FILE_NAME2=$( mktemp )
      while read -r ATTRIBUTE
      do
        MN_LIST_INFO=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" masternode list "${ATTRIBUTE}" | jq '.' 2>/dev/null |  tr -d ' ' | sed '/^$/d' )
        if [[ -z "${MN_LIST_INFO}" ]]
        then
          continue
        fi
        MN_LIST_INFO=$( echo "${MN_LIST_INFO}" | sed -r '/^.{,3}$/d' )
        OUTPUT=''
        while read -r LINE
        do
          KEY=$( echo "${LINE}" | grep -o '.*":' | sed -E 's/:$//' | awk '{ print $1 }' )
          VALUE=$( echo "${LINE}" | grep -o '":.*' | sed -E 's/^"://' | sed -E 's/,$//' | tr -d '\040\011\012\015' )
          if [[ ${#KEY} -gt 10 ]]
          then
            OUTPUT="${OUTPUT}
${KEY}: {\"${ATTRIBUTE}\": ${VALUE} }"
          fi
        done <<< "${MN_LIST_INFO}"
        if [[ "${#OUTPUT}" -gt 10 ]]
        then
          TEMP_FILE="$( echo "${OUTPUT}" | sed '/^[[:space:]]*$/d' | sed '$!s/$/,/' )"
          echo "{
${TEMP_FILE}
}" | jq '.' > "${TEMP_FILE_NAME2}"
          if [[ ! -s "${TEMP_FILE_NAME1}" ]]
          then
            cp "${TEMP_FILE_NAME2}" "${TEMP_FILE_NAME1}"
          else
            TEMP_FILE="$( jq -s '.[0] * .[1]' "${TEMP_FILE_NAME1}" "${TEMP_FILE_NAME2}" )"
            echo "${TEMP_FILE}" > "${TEMP_FILE_NAME1}"
          fi
        fi
      done <<< "$( echo "${ATTRIBUTES}" |  tr -d ' ' | sed '/^$/d' )"
      jq '.' "${TEMP_FILE_NAME1}"
      rm "${TEMP_FILE_NAME1}"
      rm "${TEMP_FILE_NAME2}"
    else
      echo "${MN_LIST}" | jq '.'
    fi
  )

  elif [ "${ARG9}" == "masternodeping" ] || [ "${ARG9}" == "mnping" ] || [ "${ARG9}" == "${_MASTERNODE_NAME}ping" ] || [ "${ARG9}" == "${_MASTERNODE_PREFIX}ping" ]
  then
  (
    DATE_STRING=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" daemon_log tac | grep -ai -m1 "active.*${_MASTERNODE_NAME}ping" | awk '{print $1 " " $2}' )
    if [[ ! -z "${DATE_STRING}" ]]
    then
      UNIX_TIME_LAST=$( date -u --date="${DATE_STRING}" +%s )
      UNIX_TIME=$( date -u +%s )
      TIME_DIFF=$(( UNIX_TIME - UNIX_TIME_LAST ))
      echo "${TIME_DIFF}"
    fi
  )

  elif [ "${ARG9}" == "sentinel" ] && ([[ "${ARG10}" == "log" ]] || [[ "${ARG10}" == "run" ]] || [[ "${ARG10}" == "install" ]])
  then
  (
    if [[ "${ARG10}" == "log" ]]
    then
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" sentinel_log "${ARG11}" "${ARG12}" "${ARG13}" "${ARG14}"

    elif [[ "${ARG10}" == "run" ]]
    then
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" sentinel_run "${ARG11}"

    elif [[ "${ARG10}" == "install" ]]
    then
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" sentinel_install "${ARG11}"
    fi
  )

  elif [ "${ARG9}" == "sentinel_log" ] || [ "${ARG9}" == "log_sentinel" ]
  then
  (
    # shellcheck disable=SC2030,SC2031
    if [[ ! -f "${USR_HOME}/sentinel/sentinel-cron.log" ]]
    then
      return
    fi
    if [ "${ARG10}" == "location" ] || [ "${ARG10}" == "loc" ]
    then
      # shellcheck disable=SC2030,SC2031
      if [ -r "${USR_HOME}/sentinel/sentinel-cron.log" ]
      then
        echo "${USR_HOME}/sentinel/sentinel-cron.log"
      else
        if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
        then
          sudo find "${DIR}" -maxdepth 1 -name \*.log -not -empty
        else
          find "${DIR}" -maxdepth 1 -name \*.log -not -empty
        fi
      fi

    elif [ "${ARG10}" == "tac" ]
    then
      if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
      then
        # shellcheck disable=SC2030,SC2031
        sudo tac "${USR_HOME}/sentinel/sentinel-cron.log"
      else
        # shellcheck disable=SC2030,SC2031
        tac "${USR_HOME}/sentinel/sentinel-cron.log"
      fi

    elif [ "${ARG10}" == "tail" ]
    then
      N=10
      if [ ! -z "${ARG11}" ] && [[ ${ARG11} =~ ${RE} ]]
      then
        N="${ARG11}"
      fi

      if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
      then
        # shellcheck disable=SC2030,SC2031
        sudo tail -n "${N}" "${USR_HOME}/sentinel/sentinel-cron.log"
      else
        # shellcheck disable=SC2030,SC2031
        tail -n "${N}" "${USR_HOME}/sentinel/sentinel-cron.log" 2>/dev/null
      fi

    else
      if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
      then
        # shellcheck disable=SC2030,SC2031
        sudo cat "${USR_HOME}/sentinel/sentinel-cron.log"
      else
        # shellcheck disable=SC2030,SC2031
        cat "${USR_HOME}/sentinel/sentinel-cron.log"
      fi
    fi
  )

  elif [ "${ARG9}" == "sentinel_run" ]
  then
  (
    # shellcheck disable=SC2030,SC2031
    if [[ ! -d "${USR_HOME}/sentinel/" ]]
    then
      return
    fi
    # shellcheck disable=SC2030,SC2031
    sudo su "${1}" -c " cd ${USR_HOME}/sentinel/; ${USR_HOME}/sentinel/venv/bin/python ${USR_HOME}/sentinel/bin/sentinel.py "
  )

  elif [ "${ARG9}" == "sentinel_install" ]
  then
  (
    # shellcheck disable=SC2030,SC2031
    if [[ ! -d "${USR_HOME}/sentinel/" ]]
    then
      # shellcheck disable=SC2030,SC2031
      if [ -z "${GITHUB_REPO}" ]
      then
        # shellcheck disable=SC2030,SC2031
        GITHUB_REPO=$( grep -m 1 'github_repo=' "${5}" | cut -d '=' -f2 )
      fi

      _SPORK_FILE=$( wget -4qO- -o- "https://github.com/${GITHUB_REPO}/master/src/spork.cpp" )
      if [[ -z "${_CONFIGURE_AC}" ]]
      then
        _SPORK_FILE=$( wget -4qO- -o- "https://github.com/${GITHUB_REPO}/master/src/spork.cpp" )
      fi
      if [[ $( echo "${_SPORK_FILE}" | grep -ci 'sentinel' ) -eq 0 ]]
      then
        return
      fi
    fi

    AUTH_LIST=$( wget -4qO- -o- "https://raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/${4}.sh" )
    SENTINEL_GITHUB=$( echo "${AUTH_LIST}" | grep -m 1 'SENTINEL_GITHUB=' | cut -d '=' -f2 )

    if [[ -z "${SENTINEL_GITHUB}" ]]
    then
      AUTH_LIST=$( wget -4qO- -o- "https://raw.githubusercontent.com/mikeytown2/masternode/master/${4}.sh" )
      SENTINEL_GITHUB=$( echo "${AUTH_LIST}" | grep -m 1 'SENTINEL_GITHUB=' | cut -d '=' -f2 | tr -d "'" | tr -d '"' )
    fi

    if [[ -z "${SENTINEL_GITHUB}" ]]
    then
      return
    fi
    echo "${SENTINEL_GITHUB}"

    # shellcheck disable=SC2030,SC2031
    if [[ "${USR_HOME}/sentinel" == "$( pwd )" ]]
    then
      cd "${HOME}" || return
    fi

    # Use subshell to isolate the masternode setup script.
    (
    IS_EMPTY=$( type SENTINEL_GENERIC_SETUP 2>/dev/null )
    if [ -z "${IS_EMPTY}" ]
    then
      # shellcheck disable=SC2030,SC2031
      COUNTER=0
      rm -f /tmp/___mn.sh 2>/dev/null
      while [[ ! -f /tmp/___mn.sh ]] || [[ $( grep -Fxc "# End of masternode setup script." /tmp/___mn.sh ) -eq 0 ]]
      do
        rm -f /tmp/___mn.sh 2>/dev/null
        wget -4qo- gist.githubusercontent.com/mikeytown2/1637d98130ac7dfbfa4d24bac0598107/raw/mcarper.sh -O /tmp/___mn.sh
        chmod 666 /tmp/___mn.sh
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
        rm /tmp/___mn.sh 2>/dev/null
      ) & disown

      # shellcheck disable=SC1091
      . /tmp/___mn.sh
    fi

    sleep 1
    SENTINEL_GENERIC_SETUP "${1}" "${SENTINEL_GITHUB}"
    )
    if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
    then
      # shellcheck disable=SC2030,SC2031
      sudo chown -R "${1}:${1}" "${USR_HOME}/"
    else
      # shellcheck disable=SC2030,SC2031
      chown -R "${1}:${1}" "${USR_HOME}/"
    fi
  )

  elif [ "${ARG9}" == "daemon_in_good_state" ]
  then
  (
    :
    return
    if [[ $( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" system_log | grep -aFi ": error: couldn't connect to server" | tail -n 5 | sed '/^[[:space:]]*$/d' | wc -l ) -lt 5 ]]
    then
      return
    fi
    # Get the failure from 5 times ago
    DATE_STRING=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" system_log | grep -aFi ": error: couldn't connect to server" | tail -n 5 | head -n 1 | awk '{ print $1 " " $2 " " $3 }' )
    UNIX_TIME_PAST_FAILURE=$( date -u --date="${DATE_STRING}" +%s 2>/dev/null )
    # Get the last entry in the system log.
    DATE_STRING=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" system_log | tail -n 1 | awk '{ print $1 " " $2 " " $3 }' )
    UNIX_TIME_CURRENT_EVENT=$( date -u --date="${DATE_STRING}" +%s 2>/dev/null )
    UNIX_TIME=$( date -u +%s )
    if [[ ! -z "${UNIX_TIME_PAST_FAILURE}" ]] && [[ ! -z "${UNIX_TIME_CURRENT_EVENT}" ]]
    then
      TIME_DIFF_LAST_ENTRY=$(( UNIX_TIME - UNIX_TIME_CURRENT_EVENT ))
      TIME_DIFF_LAST_FAILURE=$(( UNIX_TIME_CURRENT_EVENT - UNIX_TIME_PAST_FAILURE ))
      if [[ "${TIME_DIFF_LAST_FAILURE}" -lt 2000 ]] && [[ "${TIME_DIFF_LAST_ENTRY}" -lt 300 ]]
      then
        if [[ $( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" system_log | tail -n 15 | grep -aFic ": Error: Unable to bind to " ) -gt 0 ]] || [[ $( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" system_log | tail -n 50 | grep -Fic "Error: Failed to listen on any port" ) -gt 0 ]]
        then
          echo "ERROR: Daemon can not be started by systemd (Port/IP issue)."
        else
          echo "ERROR: Daemon can not be started by systemd."
        fi
      fi
    fi
  )

  elif [ "${ARG9}" == "lastblock" ]
  then
  (
    COUNTER=10
    BLK_COUNT_LOG=''
    while [[ "${COUNTER}" -lt 100000 ]] && [[ -z "${BLK_COUNT_LOG}" ]]
    do
      COUNTER=$(( COUNTER * 10 ))
      LAST_BLOCK_A=$( tail -n "${COUNTER}" "${DIR}/debug.log" | tac | grep -aFi -m1  ": new best=" | grep -o -E -i '\sheight\=[0-9]*\s' | grep -o -E "[0-9]*" )
      LAST_BLOCK_C=$( tail -n "${COUNTER}" "${DIR}/debug.log" | tac | grep -o -E -ai -m1 "Valid at block [0-9]*" | grep -o -E "[0-9]*" )
      BLK_COUNT_LOG=$( echo "${LAST_BLOCK_A} ${LAST_BLOCK_C}" | jq -s max | tr -d '\040\011\012\015' | sed 's/null//g' )
    done
    echo "${BLK_COUNT_LOG}"
  )

  elif [ "${ARG9}" == "lastblock_time" ]
  then
  (
    COUNTER=10
    TIME_DIFF=-1
    while [[ "${COUNTER}" -lt 100000 ]] && [[ "${TIME_DIFF}" -eq -1 ]]
    do
      COUNTER=$(( COUNTER * 10 ))
      DATE_STRING=$( tail -n "${COUNTER}" "${DIR}/debug.log" | tac | grep -aFi -m1 "UpdateTip: new best=" | awk '{print $1 " " $2}' )
      if [[ ! -z "${DATE_STRING}" ]]
      then
        UNIX_TIME_LAST_BLOCK_A=$( date -u --date="${DATE_STRING}" +%s )
      fi
      DATE_STRING=$( tail -n "${COUNTER}" "${DIR}/debug.log" | tac | grep -aFi -m1 "ProcessNewBlock" | awk '{print $1 " " $2}' )
      if [[ ! -z "${DATE_STRING}" ]]
      then
        UNIX_TIME_LAST_BLOCK_B=$( date -u --date="${DATE_STRING}" +%s )
      fi
      DATE_STRING=$( tail -n "${COUNTER}" "${DIR}/debug.log" | tac | grep -aFi -m1 "Valid at block " | awk '{print $1 " " $2}' )
      if [[ ! -z "${DATE_STRING}" ]]
      then
        UNIX_TIME_LAST_BLOCK_C=$( date -u --date="${DATE_STRING}" +%s )
      fi
      DATE_STRING=$( tail -n "${COUNTER}" "${DIR}/debug.log" | tac | grep -aFi -m1 "ProcessBlock" | awk '{print $1 " " $2}' )
      if [[ ! -z "${DATE_STRING}" ]]
      then
        UNIX_TIME_LAST_BLOCK_D=$( date -u --date="${DATE_STRING}" +%s )
      fi
      DATE_STRING=$( tail -n "${COUNTER}" "${DIR}/debug.log" | tac | grep -aFi -m1 "block found" | awk '{print $1 " " $2}' )
      if [[ ! -z "${DATE_STRING}" ]]
      then
        UNIX_TIME_LAST_BLOCK_E=$( date -u --date="${DATE_STRING}" +%s )
      fi
      UNIX_TIME_LAST_BLOCK=$( echo "${UNIX_TIME_LAST_BLOCK_A} ${UNIX_TIME_LAST_BLOCK_B} ${UNIX_TIME_LAST_BLOCK_C} ${UNIX_TIME_LAST_BLOCK_D} ${UNIX_TIME_LAST_BLOCK_E}" | jq -s max | tr -d '\040\011\012\015' | sed 's/null//g' )

      UNIX_TIME=$( date -u +%s )
      TIME_DIFF=-1
      if [[ ! -z "${UNIX_TIME_LAST_BLOCK}" ]] && [[ ! -z "${UNIX_TIME}" ]] && [[ ${UNIX_TIME_LAST_BLOCK} =~ ${RE} ]]
      then
        TIME_DIFF=$(( UNIX_TIME - UNIX_TIME_LAST_BLOCK ))
      fi
    done
    echo "${TIME_DIFF}"
  )

  elif [ "${ARG9}" == "mnfix" ] || [ "${ARG9}" == "${_MASTERNODE_PREFIX}fix" ]
  then
  (
    dt=$( date -u '+%d/%m/%Y %H:%M:%S' )
    if [[ -f "${USER_HOME_DIR}/disabled" ]]
    then
      echo "${dt} Node disabled."
      return 1 2>/dev/null
    fi

    LOCKFILE="/var/multi-masternode-data/${1}-mnfix.lock"
    if [[ -s "${LOCKFILE}" ]] && kill -0 "$( cat "${LOCKFILE}" )"
    then
      PID_TO_KILL=$( cat "${LOCKFILE}" )
      echo "${dt} already running. PID ${PID_TO_KILL}"

      if [[ "$( ps -o etimes= -p "${PID_TO_KILL}" | awk '{ print $1}' )" -gt 100000 ]]
      then
        echo "${dt} Killing old mnfix call."
        kill "${PID_TO_KILL}"
        kill -9 "${PID_TO_KILL}"
      else
        return 1 2>/dev/null
      fi
    fi

    # Get last 2000 lines of the log file.
    LAST_2K_LOG_LINES_TAC=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" daemon_log tail 2000 | tac )

    # See if node is stalled via log files.
    if [[ $( echo "${LAST_2K_LOG_LINES_TAC}" | head -n 100 | grep -ic "work queue depth exceeded" ) -gt 3 ]]
    then
      dt=$( date -u '+%d/%m/%Y %H:%M:%S' )
      echo "${dt} Restarting ${1} as it is frozen."
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" stop
      sleep 2
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" stop
      sleep 2
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" restart
      sleep 10
      echo "${dt} ${1} process"
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" ps
      return
    fi

    # Make sure system is not overloaded.
    LOAD=$( uptime | grep -oE 'load average: [0-9]+([.][0-9]+)?' | grep -oE '[0-9]+([.][0-9]+)?' )
    CPU_COUNT=$( grep -c 'processor' /proc/cpuinfo )
    LOAD_PER_CPU="$( printf "%.3f\n" "$( bc -l <<< "${LOAD} / ${CPU_COUNT}" )" )"
    if [[ $( echo "${LOAD_PER_CPU} > 3" | bc ) -gt 0 ]]
    then
      echo "${dt} System overloaded; skipping mnfix."
      return 1 2>/dev/null
    fi

    # Remove lockfile when we exit.
    # shellcheck disable=SC2064
    trap "rm -f ${LOCKFILE}; return 1 2>/dev/null" INT TERM EXIT
    echo $$ > "${LOCKFILE}"
    chmod 666 "${LOCKFILE}"

    if [[ $( timeout --foreground --signal=SIGKILL 45s bash -ic "source /var/multi-masternode-data/.bashrc; ${1} getinfo 2>/dev/null | wc -l" 2>/dev/null ) -lt 5 ]]
    then
      dt=$( date -u '+%d/%m/%Y %H:%M:%S' )
      echo "${dt} Restarting ${1} as it is frozen."
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" stop
      sleep 2
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" stop
      sleep 2
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" restart
      sleep 10
      echo "${dt} ${1} process"
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" ps
    fi

    dt=$( date -u '+%d/%m/%Y %H:%M:%S' )
    if [[ -z $( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" pid ) ]]
    then
      echo "${dt} Starting ${1} as it is not running."
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" restart

      sleep 10
      echo "${dt} ${1} process"
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" ps
    fi

    MN_UPTIME=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" uptime | tr -d '[:space:]' )
    MN_STATUS=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "${_MASTERNODE_CALLER}"status )
    MN_SYSTEMD=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" checksystemd )
    if [[ "${MN_UPTIME}" -gt 1000 ]] && ([[ $( echo "${MN_STATUS}" | grep -ic 'successfully started' ) -ge 1 ]] || [[ $( echo "${MN_STATUS}" | grep -ic 'started remotely' ) -ge 1 ]])
    then
      if [[ $( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" getconnectioncount ) -lt 4 ]]
      then
        echo "${dt} Getting addnodes for ${1}"
        _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" dl_addnode
      fi

      if [[ $( echo "${MN_SYSTEMD}" | grep -c 'enabled active running' ) -lt 1 ]]
      then
        if [[ $( echo "${MN_SYSTEMD}" | grep -c 'enabled' ) -lt 1 ]]
        then
          echo "${dt} Enable ${1} systemd service on reboot."
          sudo -n systemctl enable "${_DAEMON_SYSTEMD_FILENAME}" 2>&1
        fi
        if [[ $( echo "${MN_SYSTEMD}" | grep -c 'running' ) -lt 1 ]]
        then
          echo "${dt} Restarting ${1} for systemd."
          _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" restart
        fi
        MN_SYSTEMD=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" checksystemd )
        echo "${dt} ${MN_SYSTEMD}"
      fi

      if [[ $( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "${_MASTERNODE_NAME}ping" ) -gt 1500 ]]
      then
        echo "${dt} Restarting ${1} because mn hasn't pinged the network in over 1500 seconds."
        _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" restart
        _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "${_MASTERNODE_NAME}ping"
      fi
    fi

    dt=$( date -u '+%d/%m/%Y %H:%M:%S' )
    if [[ $( echo "${MN_SYSTEMD}" | grep -c 'enabled active running' ) -lt 1 ]] && [[ $( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" daemon_in_good_state | grep -Fc "ERROR: Daemon can not be started by systemd." ) -gt 0 ]]
    then
      echo "${dt} Systemd can not start ${1}"
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" stop
      sleep 2

      DROPBOX_BLOCKS_N_CHAINS=$( grep -m 1 'blocks_n_chains=' "${5}" | cut -d '=' -f2 )
      DROPBOX_BOOTSTRAP=$( grep -m 1 'bootstrap=' "${5}" | cut -d '=' -f2 )
      if [[ ! -z "${DROPBOX_BLOCKS_N_CHAINS}" ]]
      then
        echo "${dt} Using blocks snapshot."
        _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" dl_blocks_n_chains force
      elif [ ! -z "${DROPBOX_BOOTSTRAP}" ]
      then
        echo "${dt} Using bootstrap file."
        _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" dl_bootstrap_reindex
      else
        echo "${dt} Using bootstrap file."
        _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" reindex
      fi

      sleep 2
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" start
    fi

    dt=$( date -u '+%d/%m/%Y %H:%M:%S' )
    LASTBLOCK_TIME=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" lastblock_time )
    if [[ "${LASTBLOCK_TIME}" -gt 500 ]]
    then
      WEB_BLK=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" explorer_blockcount )
      WEB_BLK_HIGH=$(( WEB_BLK + EXPLORER_BLOCKCOUNT_OFFSET ))
      WEB_BLK_LOW=$(( WEB_BLK - EXPLORER_BLOCKCOUNT_OFFSET ))
      LOCAL_BLK=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" getblockcount )
      BLKCOUNTL=$((LOCAL_BLK-2))
      BLKCOUNTH=$((LOCAL_BLK+2))

      if [[ $WEB_BLK =~ $RE ]]
      then
        if [[ "${WEB_BLK_HIGH}" -lt "${BLKCOUNTL}" ]] || [[ "${WEB_BLK_LOW}" -gt "${BLKCOUNTH}" ]]
        then
          echo "${dt} Blockcount has not moved in over ${LASTBLOCK_TIME} seconds and is not the same as the explorers."
          echo "Local: ${LOCAL_BLK} Remote: ${WEB_BLK}"
          echo "${WEB_BLK_HIGH} -lt ${BLKCOUNTL}"
          echo "${WEB_BLK_LOW} -gt ${BLKCOUNTH}"
          _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" uptime
          _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "${_MASTERNODE_CALLER}"status
          _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" getblockcount
          _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" stop
          sleep 2

          DROPBOX_BLOCKS_N_CHAINS=$( grep -m 1 'blocks_n_chains=' "${5}" | cut -d '=' -f2 )
          DROPBOX_BOOTSTRAP=$( grep -m 1 'bootstrap=' "${5}" | cut -d '=' -f2 )
          if [[ ! -z "${DROPBOX_BLOCKS_N_CHAINS}" ]]
          then
            _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" dl_blocks_n_chains force
          elif [ ! -z "${DROPBOX_BOOTSTRAP}" ]
          then
            _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" dl_bootstrap_reindex
          else
            _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" reindex
          fi

          _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" restart

          sleep 10
          _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" ps
          WEB_BLK=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" explorer_blockcount )
          LOCAL_BLK=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" getblockcount )
          echo "${dt} Local: ${LOCAL_BLK} Remote: ${WEB_BLK}"
          _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "${_MASTERNODE_CALLER}"status
        fi
      fi
    fi
    rm -f "${LOCKFILE}"
  )

  elif [ "${ARG9}" == "mncheck" ] || [ "${ARG9}" == "${_MASTERNODE_PREFIX}check" ]
  then
  (
    if [[ -z $( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" pid ) ]]
    then
      echo "ERROR: ${_MASTERNODE_NAME} ${1} is not running"
    fi

    MN_UPTIME=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" uptime | tr -d '[:space:]' )
    if [[ "${MN_UPTIME}" -gt 2 ]] && [[ "${MN_UPTIME}" -lt 1000 ]]
    then
      echo "INFO: ${_MASTERNODE_NAME} ${1} has just been started."
    fi

    if [[ $( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" conf | grep -c "${_MASTERNODE_NAME}=1" ) -lt 1 ]]
    then
      echo "ERROR: ${_MASTERNODE_NAME} ${1} is not conifgured to be a ${_MASTERNODE_NAME} (missing ${_MASTERNODE_NAME}=1)."
    fi

    if [[ $( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" conf | grep -c "${_MASTERNODE_PRIVKEY}=" ) -lt 1 ]]
    then
      echo "ERROR: ${_MASTERNODE_CALLER} ${1} is not conifgured to be a ${_MASTERNODE_CALLER} (missing ${_MASTERNODE_PRIVKEY}=)."
    fi

    MN_STATUS=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "${_MASTERNODE_CALLER}"status )
    if [[ $( echo "${MN_STATUS}" | grep -ic 'successfully started' ) -lt 1 ]] || [[ $( echo "${MN_STATUS}" | grep -ic 'started remotely' ) -lt 1 ]]
    then
      echo "ERROR: ${_MASTERNODE_NAME} ${1} has not started (${_MASTERNODE_NAME} status failed) ${MN_STATUS}."
    fi

    MN_PING_TIME=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "${_MASTERNODE_NAME}ping" )
    if [[ "${MN_PING_TIME}" -gt 1500 ]]
    then
      echo "ERROR: ${_MASTERNODE_NAME} ${1} has not pinged the network in over ${MN_PING_TIME} seconds (debug.log does not have a recent ping)."
    fi

    MN_CONNECTION_COUNT=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" getconnectioncount )
    if [[ ! "${MN_CONNECTION_COUNT}" =~ ${RE} ]] || [[ "${MN_CONNECTION_COUNT}" -lt 4 ]]
    then
      echo "WARNING: ${_MASTERNODE_NAME} ${1} connection count is low: ${MN_CONNECTION_COUNT}."
    fi

    MN_SYSTEMD=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" checksystemd )
    if [[ $( echo "${MN_SYSTEMD}" | grep -c 'enabled active running' ) -lt 1 ]]
    then
      echo "WARNING: ${_MASTERNODE_NAME} ${1} systemd is not in a good state (${MN_SYSTEMD})."
    fi

    if [[ $( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" blockcheck 2>/dev/null | sed '/^[[:space:]]*$/d' | wc -l ) -gt 1 ]]
    then
      LOCAL_BLK=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" getblockcount )
      PEER_BLK=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" getpeerblockcount )
      WEB_BLK=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" explorer_blockcount )
      WEB_BLK_HIGH=$(( WEB_BLK + EXPLORER_BLOCKCOUNT_OFFSET ))
      WEB_BLK_LOW=$(( WEB_BLK - EXPLORER_BLOCKCOUNT_OFFSET ))
      echo "WARNING: ${_MASTERNODE_NAME} ${1} blockcount is not correct. Local Count:${LOCAL_BLK}, Network Count:${PEER_BLK}."
      echo "Explorer Count:${WEB_BLK}; Explorer Count High:${WEB_BLK_HIGH} Explorer Count Low:${WEB_BLK_LOW}."
    fi

    LASTBLOCK=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" lastblock_time )
    if [[ "${LASTBLOCK}" -gt 1000 ]]
    then
      echo "ERROR: A new block has not been processed in over ${LASTBLOCK} seconds."
    fi

    _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" daemon_in_good_state

    _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" failure_after_start

    if [[ $( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "${_MASTERNODE_PREFIX}info" | grep -ci 'enabled' ) -lt 1 ]]
    then
      echo "ERROR: ${_MASTERNODE_NAME} ${1} is not registered on the network (missing from masternode list)."
    fi

    MN_SYNC=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "${_MASTERNODE_PREFIX}sync status" )
    if [[ $( echo "${MN_SYNC}" | grep -cE ':\s999|"IsBlockchainSynced": true' ) -lt 2 ]]
    then
      echo "WARNING: ${_MASTERNODE_NAME} ${1} mnsync not done (${MN_SYNC})."
    fi

    MN_WINNER=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "${_MASTERNODE_PREFIX}win" )
    if [[ ! -z "${MN_WINNER}" ]]
    then
      while read -r LINE
      do
        ADDRESS=$( echo "${LINE}" | awk '{print $1}' )
        BLOCK=$( echo "${LINE}" | awk '{print $2}' )
        echo "SUCCESS: ${_MASTERNODE_NAME} ${1} will send a reward to ${ADDRESS} on block ${BLOCK}."
      done <<< "$( echo "${MN_WINNER}" | sed '/^[[:space:]]*$/d' )"
    fi
  )

  elif [ "${ARG9}" == "rename" ]
  then
  (
    if [ -z "${ARG10}" ]
    then
      (>&2 echo "Please supply the new name after the command.")
      return 1 2>/dev/null
    fi
    if id "${ARG10}" >/dev/null 2>&1
    then
      (>&2 echo "Username ${ARG10} already exists.")
      return 1 2>/dev/null
    fi

    if [[ "${ARG10}" == 'root' ]] || [[ "${1}" == 'root' ]]
    then
      (>&2 echo "Username can not be root." )
      return 1 2>/dev/null
    fi

    echo "${1} will be transformed into ${ARG10}"
    sleep 3
    sudo systemctl disable "${_DAEMON_SYSTEMD_FILENAME}" -f --now
    _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" stop
    _NEW_CRONTAB=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}"  crontab -l | sed "s/${1} /${ARG10} /g" )

    # Rename contents of systemd service
    sudo sed -i "s/${1}/${ARG10}/g" /etc/systemd/system/"${1}".service
    # Rename contents of daemon conf file.
    sudo sed -i "s/${1}$/${ARG10}/g" "${5}"
    if [ -r "${USER_HOME_DIR}/sentinel/sentinel.conf" ]
    then
      # Rename contents of sentinel conf file.
      sudo sed -i "s/${1}\\//${ARG10}\\//g" "${USER_HOME_DIR}/sentinel/sentinel.conf"
    fi
    if [ -r "/etc/sudoers.d/${1}" ]
    then
      # Rename contents of sudoers file.
      sudo sed -i "s/${1}/${ARG10}/g" "/etc/sudoers.d/${1}"
      sudo sed -i "s/${1}$/${ARG10}/g" "/etc/sudoers.d/${1}"
      sudo sed -i "s/${1} /${ARG10} /g" "/etc/sudoers.d/${1}"
      sudo sed -i "s/${1}\./${ARG10}./g" "/etc/sudoers.d/${1}"
      sudo mv "/etc/sudoers.d/${1}" "/etc/sudoers.d/${ARG10}"
    fi

    sudo mv /etc/systemd/system/"${1}".service /etc/systemd/system/"${ARG10}".service
    sudo usermod --login "${ARG10}" --move-home --home /home/"${ARG10}" "${1}"
    sudo groupmod -n "${ARG10}" "${1}"
    sed -i "s/${1}\\//${ARG10}\\//g" "${HOME:?}/.bashrc"
    sed -i "s/\"${1}\"/\"${ARG10}\"/g" "${HOME:?}/.bashrc"
    sed -i "s/'${1}'/'${ARG10}'/g" "${HOME:?}/.bashrc"
    sed -i "s/${1} ()/${ARG10} ()/g" "${HOME:?}/.bashrc"
    sed -i "s/${1}\\./${ARG10}\\./g" "${HOME:?}/.bashrc"
    sed -i "s/${1}$/${ARG10}/g" "${HOME:?}/.bashrc"

    sudo systemctl daemon-reload 2>/dev/null
    if [ -s /etc/apparmor.d/multi-masternode-data ]
    then
      # Rename contents of apparmor conf file.
      sudo sed -i "s/\\/${1}\\//\\/${ARG10}\\//g" /etc/apparmor.d/multi-masternode-data
      sudo systemctl reload apparmor.service
    fi

    sudo systemctl enable "${ARG10}"

    # shellcheck source=/root/.bashrc
    source "${HOME:?}/.bashrc"
    sleep 1
    "${ARG10}" start
    # shellcheck disable=SC2030,SC2031
    if [[ ! -z "${_NEW_CRONTAB}" ]]
    then
      # shellcheck disable=SC2030,SC2031
      sudo su "${ARG10}" -c " echo \"${_NEW_CRONTAB}\" | crontab - "
    fi
    echo
  )
  unset -f "${1}"
  # shellcheck source=/root/.bashrc
  source "${HOME:?}/.bashrc"

  elif [ "${ARG9}" == "explorer" ]
  then
  (
    echo "${3}"
  )

  elif [ "${ARG9}" == "explorer_params" ]
  then
  (
    echo "${6}"
  )

  elif [ "${ARG9}" == "explorer_blockcount" ] || [ "${ARG9}" == "blockcount_explorer" ]
  then
  (
    EXPLORER_BLOCKCOUNT_PATH=$( grep -m 1 'explorer_blockcount_path=' "${5}" | grep -o '=.*' | cut -c2- )
    if [[ -z "${EXPLORER_BLOCKCOUNT_PATH}" ]]
    then
      EXPLORER_BLOCKCOUNT_PATH='api/getblockcount'
    fi

    if [[ ! -z "${3}" ]]
    then
      if [[ "${3}" == https://www.coinexplorer.net/api/v1/* ]]
      then
        WEB_BLK=$( timeout --signal=SIGKILL 15s wget -4qO- -T 15 -t 2 -o- "${3}block/latest" "${TEMP_VAR_C}" | jq -r '.result.height' | tr -d '[:space:]' 2>/dev/null )
      else
        WEB_BLK=$( timeout --signal=SIGKILL 15s wget -4qO- -T 15 -t 2 -o- "${3}${EXPLORER_BLOCKCOUNT_PATH}" "${TEMP_VAR_C}" )
      fi

      if [[ $( echo "${WEB_BLK}" | grep -c 'data' ) -gt 0 ]]
      then
        WEB_BLK=$( echo "${WEB_BLK}" | jq -r '.data' 2>/dev/null )
      fi

      sleep 1
      if [[ $( echo "${WEB_BLK}" | tr -d '[:space:]') =~ $RE ]]
      then
        echo "${WEB_BLK}" | tr -d '[:space:]'
      else
        echo "${WEB_BLK}"
      fi
    fi
  )

  elif [ "${ARG9}" == "explorer_peers" ]
  then
  (
    EXPLORER_PEERS=$( grep -m 1 'explorer_peers=' "${5}" | grep -o '=.*' | cut -c2- )
    if [[ -z "${EXPLORER_PEERS}" ]]
    then
      EXPLORER_PEERS='api/getpeerinfo'
    fi

    WEB_PEERS=$( wget -4qO- -T 15 -t 2 -o- "${3}${EXPLORER_PEERS}" "${TEMP_VAR_C}" | jq '.[].addr' | grep -v 'null' 2>/dev/null )
    if [[ -z "${WEB_PEERS}" ]]
    then
      WEB_PEERS=$( wget -4qO- -T 15 -t 2 -o- "${3}${EXPLORER_PEERS}" "${TEMP_VAR_C}" | jq -r '.[] | [.ip,.port] | "\(.[0]):\(.[1])"' )
      if [[ -z "${WEB_PEERS}" ]]
      then
        return
      fi
    fi
    if [[ "${ARG10}" == "add" ]]
    then
      while read -r IPADDR
      do
        echo "addnode ${IPADDR} add"
        _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" addnode "${IPADDR}" add
      done <<< "${WEB_PEERS}"
    elif [[ "${ARG10}" == "conf" ]]
    then
      while read -r IPADDR
      do
        echo "addnode=${IPADDR//\"}" | sudo tee -a "${5}" >/dev/null
        echo "addnode=${IPADDR//\"}"
      done <<< "${WEB_PEERS}"

      # Restart node if it's running.
      TEMP_VAR_PID=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" pid )
      if [[ ! -z "${TEMP_VAR_PID}" ]]
      then
        _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" restart
      fi
    else
      echo "${WEB_PEERS}" | awk '{print "addnode " $1 " add"}'
    fi
  )

  elif [ "${ARG9}" == "explorer_offset" ]
  then
  (
    echo "${EXPLORER_BLOCKCOUNT_OFFSET}"
  )

  elif [ "${ARG9}" == "chaincheck" ] || [ "${ARG9}" == "checkchain" ]
  then
  (
    if [[ -z "${3}" ]] || [[ "${3}" == https://www.coinexplorer.net/api/v1/* ]]
    then
      return
    fi
    WEBBCI=$( wget -4qO- -T 15 -t 2 -o- "${3}api/getblockchaininfo" "${TEMP_VAR_C}" | jq . |  grep -v "verificationprogress" )
    sleep 1

    BCI=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "getblockchaininfo" 2>&1 | grep -v "verificationprogress" )
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
  )

  elif [ "${ARG9}" == "blockcheck" ] || [ "${ARG9}" == "checkblock" ]
  then
  (
    if [[ ! -z "${3}" ]]
    then
      if [[ ! -z "${ARG10}" ]] && [[ ${ARG10} =~ $RE ]]
      then
        WEB_BLK=${ARG10}
      else
        WEB_BLK=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" explorer_blockcount )
      fi
    else
      WEB_BLK=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" getpeerblockcount )
    fi
    BC=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "getblockcount" 2>&1 )
    if ! [[ $WEB_BLK =~ $RE ]]
    then
      WEB_BLK=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" getpeerblockcount )
    fi

    if [[ ! $BC =~ $RE ]]
    then
      echo "Local block count can not be found"
      echo "${BC}"
      echo "Remote blockcount"
      echo "${WEB_BLK}"
      echo
      return
    fi

    WEB_BLK_HIGH=$(( WEB_BLK + EXPLORER_BLOCKCOUNT_OFFSET ))
    WEB_BLK_LOW=$(( WEB_BLK - EXPLORER_BLOCKCOUNT_OFFSET ))

    if [[ "${WEB_BLK_HIGH}" -lt "${BC}" ]] || [[ "${WEB_BLK_LOW}" -gt "${BC}" ]]
    then
      WEB_BLK=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" explorer_blockcount )
      if ! [[ $WEB_BLK =~ $RE ]]
      then
        WEB_BLK=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" getpeerblockcount )
      fi
      BC=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" getblockcount 2>&1 )

      WEB_BLK_HIGH=$(( WEB_BLK + EXPLORER_BLOCKCOUNT_OFFSET ))
      WEB_BLK_LOW=$(( WEB_BLK - EXPLORER_BLOCKCOUNT_OFFSET ))
      if [[ "${WEB_BLK_HIGH}" -lt "${BC}" ]] || [[ "${WEB_BLK_LOW}" -gt "${BC}" ]]
      then
        echo "Block counts do not match"
        echo "Local blockcount"
        echo "${BC}"
        echo "Remote blockcount"
        echo "${WEB_BLK} high:${WEB_BLK_HIGH} low:${WEB_BLK_LOW}"
        echo "${WEB_BLK_HIGH} -lt ${BC}"
        echo "${WEB_BLK_LOW} -gt ${BC}"
        echo
        echo "If the explorer count is correct and problem persists try"
        echo "${1} remove_peers"
        echo "${1} remove_addnode"
        echo "${1} dl_blocks_n_chains force"
        echo "And after 15 minutes if that does not fix it try"
        echo "${1} reindex"
        echo
        return
      fi
    fi

    if [[ $WEB_BLK =~ $RE ]]
    then
      echo "Block count looks good: ${BC} ${WEB_BLK}"
    fi
  )

  elif [ "${ARG9}" == "getpeerblockcount" ]
  then
  (
    PEER_INFO=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" getpeerinfo 2>/dev/null )
    _BLOCK_COUNT_A=$( echo "${PEER_INFO}" | jq '.[] | select( .banscore < 21 and .synced_headers > 0 ) | .synced_headers ' 2>/dev/null | sort -hr | uniq | head -1 | tr -d '[:space:]'  )
    if [[ ! "${_BLOCK_COUNT_A}" =~ ${RE} ]]
    then
      _BLOCK_COUNT_A=0
    fi
    _BLOCK_COUNT_B=$( echo "${PEER_INFO}" | jq '.[] | select( .banscore < 21 and .synced_headers > 0 ) | .startingheight ' 2>/dev/null | sort -hr | uniq | head -1 | tr -d '[:space:]' )
    if [[ ! "${_BLOCK_COUNT_B}" =~ ${RE} ]]
    then
      _BLOCK_COUNT_B=0
    fi
    _BLOCK_COUNT_C=$( echo "${PEER_INFO}" | jq '.[] | .synced_headers ' 2>/dev/null | sort -hr | uniq | head -1 | tr -d '[:space:]' )
    if [[ ! "${_BLOCK_COUNT_C}" =~ ${RE} ]]
    then
      _BLOCK_COUNT_C=0
    fi
    _BLOCK_COUNT_D=$( echo "${PEER_INFO}" | jq '.[] | .startingheight ' 2>/dev/null | sort -hr | uniq | head -1 | tr -d '[:space:]' )
    if [[ ! "${_BLOCK_COUNT_D}" =~ ${RE} ]]
    then
      _BLOCK_COUNT_D=0
    fi
    _BLOCK_COUNT_E=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" lastblock 2>/dev/null )
    if [[ ! -z "${_BLOCK_COUNT_E}" ]] && [[ "${_BLOCK_COUNT_E}" =~ ${RE} ]] && [[ "${_BLOCK_COUNT_E}" -gt 2000 ]]
    then
      _BLOCK_COUNT_E="$(( _BLOCK_COUNT_E - 1000))"
    fi
    echo "${_BLOCK_COUNT_A} ${_BLOCK_COUNT_B} ${_BLOCK_COUNT_C} ${_BLOCK_COUNT_D} ${_BLOCK_COUNT_E}" | jq -s max
  )

  elif [ "${ARG9}" == "getmasternodever" ] || [ "${9}" == "mnver" ] || [ "${9}" == "getmasternodeversion" ] || [ "${9}" == "masternodever" ] || [ "${9}" == "get${_MASTERNODE_NAME}ver" ] || [ "${9}" == "get${_MASTERNODE_NAME}version" ] || [ "${9}" == "${_MASTERNODE_NAME}ver" ] || [ "${9}" == "${_MASTERNODE_PREFIX}ver" ]
  then
  (
    _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "${_MASTERNODE_LIST}" |  jq '.[] | "\(.version)"' | sort -hr | uniq -c
  )

  elif [ "${ARG9}" == "getpeerver" ] || [ "${ARG9}" == "getpeerversion" ]
  then
  (
    _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" getpeerinfo | jq '.[] | "\(.version) \(.subver)"' | sort -hr | uniq -c
  )

  elif [ "${ARG9}" == "getpeerblockver" ] || [ "${ARG9}" == "checkpeers" ] || [ "${ARG9}" == "peercheck" ]
  then
  (
    _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" getpeerinfo | jq '.[] | "\(.synced_headers) \(.version) \(.subver)"' | sort -hr | uniq -c
  )

  elif [ "${ARG9}" == "dl_bootstrap" ] || [ "${ARG9}" == "dl_bootstrap_reindex" ]
  then
  (
    # shellcheck disable=SC2030,SC2031
    if [ -z "${DROPBOX_BOOTSTRAP}" ]
    then
      DROPBOX_BOOTSTRAP=$( grep -m 1 'bootstrap=' "${5}" | cut -d '=' -f2 )
    fi

    if [[ ! -z "${ARG10}" ]] && [[ "${ARG10}" == http* ]]
    then
      DROPBOX_BOOTSTRAP="${ARG10}"
    fi

    # shellcheck disable=SC2030,SC2031
    if [ -z "${GITHUB_REPO}" ]
    then
      # shellcheck disable=SC2030,SC2031
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
    # shellcheck disable=SC2030,SC2031
    PROJECT_DIR=$( echo "${GITHUB_REPO}" | tr '/' '_' )
    rm -rf "/var/multi-masternode-data/${PROJECT_DIR}/bootstrap"
    echo "Downloading bootstrap."

    if [[ "$( echo "${DROPBOX_BOOTSTRAP}" | grep -cE '^(http|https)://' )" -gt 0 ]]
    then
      BOOTSTRAP_URL="${DROPBOX_BOOTSTRAP}"
      BOOTSTRAP_DEST_FILENAME="$( basename "${DROPBOX_BOOTSTRAP}" | cut -d '?' -f1 )"
      BOOTSTRAP_DEST_FILENAME="${PROJECT_DIR}.${BOOTSTRAP_DEST_FILENAME}"
    else
      BOOTSTRAP_URL="https://www.dropbox.com/s/${DROPBOX_BOOTSTRAP}/bootstrap.dat.gz?dl=1"
      BOOTSTRAP_DEST_FILENAME="${PROJECT_DIR}.bootstrap.dat.gz"
    fi
    echo "${BOOTSTRAP_URL}"

    if [[ -x "$( command -v aria2c )" ]]
    then
      aria2c --console-log-level=warn -x 4 "${BOOTSTRAP_URL}" -d /tmp -o "${BOOTSTRAP_DEST_FILENAME}"
    else
      wget -4 "${BOOTSTRAP_URL}" -O "${BOOTSTRAP_DEST_FILENAME}" -q --show-progress --progress=bar:force 2>&1
    fi
    sleep 0.6
    echo

    mkdir -p "/var/multi-masternode-data/${PROJECT_DIR}/bootstrap"
    if [[ $( echo "${BOOTSTRAP_DEST_FILENAME}" | grep -c '.tar.gz$' ) -eq 1 ]] || [[ $( echo "${BOOTSTRAP_DEST_FILENAME}" | grep -c '.tgz$' ) -eq 1 ]]
    then
      echo "Decompressing gz archive."
      if [[ -x "$( command -v pv )" ]]
      then
        pv "/tmp/${BOOTSTRAP_DEST_FILENAME}" | tar -xz -C "/var/multi-masternode-data/${PROJECT_DIR}/bootstrap" 2>&1
      else
        tar -xzf "/tmp/${BOOTSTRAP_DEST_FILENAME}" -C "/var/multi-masternode-data/${PROJECT_DIR}/bootstrap"
      fi

    elif [[ $( echo "${BOOTSTRAP_DEST_FILENAME}" | grep -c '.tar.xz$' ) -eq 1 ]]
    then
      echo "Decompressing xz archive."
      if [[ -x "$( command -v pv )" ]]
      then
        pv "/tmp/${BOOTSTRAP_DEST_FILENAME}" | tar -xJ -C "/var/multi-masternode-data/${PROJECT_DIR}/bootstrap" 2>&1
      else
        tar -xJf "/tmp/${BOOTSTRAP_DEST_FILENAME}" -C "/var/multi-masternode-data/${PROJECT_DIR}/bootstrap"
      fi

    elif [[ $( echo "${BOOTSTRAP_DEST_FILENAME}" | grep -c '.zip$' ) -eq 1 ]]
    then
      echo "Unzipping file."
      unzip -o "/tmp/${BOOTSTRAP_DEST_FILENAME}" -d "/var/multi-masternode-data/${PROJECT_DIR}/bootstrap"

    elif [[ $( echo "${BOOTSTRAP_DEST_FILENAME}" | grep -c '.rar$' ) -eq 1 ]]
    then
      echo "Unraring file."
      unrar x "/tmp/${BOOTSTRAP_DEST_FILENAME}" "/var/multi-masternode-data/${PROJECT_DIR}/bootstrap"

    elif [[ $( echo "${BOOTSTRAP_DEST_FILENAME}" | grep -c '.gz$' ) -eq 1 ]]
    then
      gunzip -c "/tmp/${BOOTSTRAP_DEST_FILENAME}" > "/var/multi-masternode-data/${PROJECT_DIR}/bootstrap/bootstrap.dat"
    fi

    rm "/tmp/${BOOTSTRAP_DEST_FILENAME}"

    BOOTSTRAP_DAT_FILE="$( find "/var/multi-masternode-data/${PROJECT_DIR}/bootstrap" -type f -name 'bootstrap.dat' | head -n 1 )"
    if [[ -z "${BOOTSTRAP_DAT_FILE}" ]]
    then
      echo "Bootstrap not found in archive."
      rm -rf "/var/multi-masternode-data/${PROJECT_DIR}/bootstrap"
      return
    fi

    chmod 666 "${BOOTSTRAP_DAT_FILE}"
    stty sane 2>/dev/null

    TEMP_VAR_PID=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" pid )
    if [[ ! -z "${TEMP_VAR_PID}" ]]
    then
      echo "Stopping ${1}"
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" stop >/dev/null 2>&1
    fi

    USR_HOME="$( getent passwd "${1}" | cut -d: -f6 )"
    echo "Copy ${BOOTSTRAP_DAT_FILE} to ${DIR}/bootstrap.dat"
    if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
    then
      sudo cp "${BOOTSTRAP_DAT_FILE}" "${DIR}/bootstrap.dat"
      sudo chmod 666 "${DIR}/bootstrap.dat"
      sudo chown -R "${1}:${1}" "${USR_HOME}/"
    else
      cp "${BOOTSTRAP_DAT_FILE}" "${DIR}/bootstrap.dat"
      chmod 666 "${DIR}/bootstrap.dat"
      chown -R "${1}:${1}" "${USR_HOME}/"
    fi

    if [ "${ARG9}" == "dl_bootstrap_reindex" ]
    then
      sleep 5
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" reindex "${ARG10}" "${ARG11}"
    elif [[ ! -z "${TEMP_VAR_PID}" ]]
    then
      sleep 5
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" start
    fi
  )

  elif [ "${ARG9}" == "dl_blocks_n_chains" ]
  then
  (
    # shellcheck disable=SC2030,SC2031
    if [[ -z "${DROPBOX_BLOCKS_N_CHAINS}" ]]
    then
      DROPBOX_BLOCKS_N_CHAINS=$( grep -m 1 'blocks_n_chains=' "${5}" | cut -d '=' -f2 )
    fi
    # shellcheck disable=SC2030,SC2031
    if [[ -z "${GITHUB_REPO}" ]]
    then
      GITHUB_REPO=$( grep -m 1 'github_repo=' "${5}" | cut -d '=' -f2 )
    fi

    if [[ ! -z "${ARG10}" ]] && [[ "${ARG10}" == http* ]]
    then
      DROPBOX_BLOCKS_N_CHAINS="${ARG10}"
      # shellcheck disable=SC2030,SC2031
      rm -rf "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains"
    fi

    if [[ -z "${DROPBOX_BLOCKS_N_CHAINS}" ]]
    then
      echo
      echo "Blocks and chains source could not be found. Try dl_bootstrap."
      echo
      return 1 2>/dev/null
    fi

    PROJECT_DIR=$( echo "${GITHUB_REPO}" | tr '/' '_' )
    if [[ ! -z "${ARG10}" ]] && [[ "${ARG10}" == "force" ]]
    then
      rm -rf "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains"
    fi

    UNIX_TIME_LAST=1000
    DATE_STRING=$( find "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/" -type f -exec stat --format '%Y :%y %n' "{}" \; 2>/dev/null | sort -nr | cut -d: -f2- | head -n 1 | awk '{ print $1 " " $2 " " $3 }' )
    if [[ ! -z "${DATE_STRING}" ]]
    then
      UNIX_TIME_LAST=$( date -u --date="${DATE_STRING}" +%s )
    fi
    UNIX_TIME=$( date -u +%s )
    TIME_DIFF=$(( UNIX_TIME - UNIX_TIME_LAST ))

    if [[ "${TIME_DIFF}" -gt 259200 ]]
    then
      echo "Get new bootstrap code."
      rm -rf "/var/multi-masternode-data/${PROJECT_DIR:?}/blocks_n_chains/"
      mkdir -p "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains"

      if [[ "$( echo "${DROPBOX_BLOCKS_N_CHAINS}" | grep -cE '^(http|https)://' )" -gt 0 ]]
      then
        BLOCKS_N_CHAINS_URL="${DROPBOX_BLOCKS_N_CHAINS}"
        BLOCKS_N_CHAINS_DEST_FILENAME="$( basename "${BLOCKS_N_CHAINS_URL}" | cut -d '?' -f1 )"
        BLOCKS_N_CHAINS_DEST_FILENAME="${PROJECT_DIR}.${BLOCKS_N_CHAINS_DEST_FILENAME}"
      else
        BLOCKS_N_CHAINS_URL="https://www.dropbox.com/s/${DROPBOX_BLOCKS_N_CHAINS}/blocks_n_chains.tar.gz?dl=1"
        BLOCKS_N_CHAINS_DEST_FILENAME="${PROJECT_DIR}.blocks_n_chains.tar.gz"
      fi

      # shellcheck disable=SC2030,SC2031
      COUNTER=1
      while [[ $( find "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/" -type f | wc -l ) -lt 5 ]]
      do
        rm -rf "/var/multi-masternode-data/${PROJECT_DIR:?}/blocks_n_chains/"
        mkdir -p "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains"

        echo "Downloading blocks and chainstate."
        echo "${BLOCKS_N_CHAINS_URL}"
        if [[ -x "$( command -v aria2c )" ]]
        then
          aria2c --console-log-level=warn -x 4 "${BLOCKS_N_CHAINS_URL}" -d /tmp -o "${BLOCKS_N_CHAINS_DEST_FILENAME}"
        else
          wget -4 "${BLOCKS_N_CHAINS_URL}" -O "/tmp/${BLOCKS_N_CHAINS_DEST_FILENAME}" -q --show-progress --progress=bar:force 2>&1
        fi
        sleep 0.6
        echo

        if [[ $( echo "${BLOCKS_N_CHAINS_DEST_FILENAME}" | grep -c '.tar.gz$' ) -eq 1 ]] || [[ $( echo "${BLOCKS_N_CHAINS_DEST_FILENAME}" | grep -c '.tgz$' ) -eq 1 ]]
        then
          echo "Decompressing gz archive."
          if [[ -x "$( command -v pv )" ]]
          then
            pv "/tmp/${BLOCKS_N_CHAINS_DEST_FILENAME}" | tar -xz -C "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains" 2>&1
          else
            tar -xzf "/tmp/${PROJECT_DIR}.blocks_n_chains.tar.gz" -C "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains"
          fi

        elif [[ $( echo "${BLOCKS_N_CHAINS_DEST_FILENAME}" | grep -c '.tar.xz$' ) -eq 1 ]]
        then
          echo "Decompressing xz archive."
          if [[ -x "$( command -v pv )" ]]
          then
            pv "/tmp/${BLOCKS_N_CHAINS_DEST_FILENAME}" | tar -xJ -C "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains" 2>&1
          else
            tar -xJf "/tmp/${BLOCKS_N_CHAINS_DEST_FILENAME}" -C "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains"
          fi

        elif [[ $( echo "${BLOCKS_N_CHAINS_DEST_FILENAME}" | grep -c '.zip$' ) -eq 1 ]]
        then
          echo "Unzipping file."
          unzip -o "/tmp/${BLOCKS_N_CHAINS_DEST_FILENAME}" -d "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains"

        elif [[ $( echo "${BLOCKS_N_CHAINS_DEST_FILENAME}" | grep -c '.rar$' ) -eq 1 ]]
        then
          echo "Unraring file."
          unrar x "/tmp/${BLOCKS_N_CHAINS_DEST_FILENAME}" "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains"

        else
          echo "Decompression program for ${BLOCKS_N_CHAINS_DEST_FILENAME} couldn't be found."
        fi

        BASE_FOLDER="$( find "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains" -type d -name 'blocks' -exec dirname {} + | head -n 1 )"
        if [[ ! -z "${BASE_FOLDER}" ]] && [[ "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains" != "${BASE_FOLDER}" ]]
        then
          mv "${BASE_FOLDER:?}"/* "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains"
          rm -rf "${BASE_FOLDER:?}"
        fi

        rm "/tmp/${BLOCKS_N_CHAINS_DEST_FILENAME}"
        echo "Decompression done."
        echo
        echo -e "\\r\\c"
        echo

        COUNTER=$(( COUNTER+1 ))
        if [[ "${COUNTER}" -gt 3 ]]
        then
          break;
        fi
      done
    fi

    TEMP_VAR_PID=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" pid )
    if [[ ! -z "${TEMP_VAR_PID}" ]]
    then
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" stop
    fi

    TEMP_VAR_PID=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" pid )
    if [[ ! -z "${TEMP_VAR_PID}" ]]
    then
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" stop
    fi

    # Clear folder.
    FILENAME=$( basename "${5}" )
    if [[ -d "${DIR}" ]]
    then
      echo "Clear datadir folder ${DIR}."
      find "${DIR}" -maxdepth 1 | tail -n +2 | grep -vE "backups|wallet.dat|${FILENAME}|${_MASTERNODE_CONF}|peers.dat|debug.log" | xargs rm -rf
    fi

    MOVE_OR_COPY='cp'
    MOVE_OR_COPY_OPT='-r'
    MOVE_OR_COPY_TEXT='Copy'
    FREEPSPACE_PERCENT=$( df -P . | tail -1 | awk '{print $5}' | grep -oE '[0-9]*')
    FREEPSPACE_KBYTES=$( df -P . | tail -1 | awk '{print $4}' )
    if [[ "${FREEPSPACE_KBYTES}" -lt 10485760 ]] || [[ "${FREEPSPACE_PERCENT}" -gt 80 ]]
    then
      MOVE_OR_COPY='mv'
      MOVE_OR_COPY_OPT='-f'
      MOVE_OR_COPY_TEXT='Moving'
    fi

    USR_HOME="$( getent passwd "${1}" | cut -d: -f6 )"
    if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
    then
      echo "Set permissions in /var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains."
      sudo sh -c "find /var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/ -type f -exec chmod 666 {} \\;"
      sudo sh -c "find /var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/ -type d -exec chmod 777 {} \\;"
      sudo mkdir -p "${DIR}"/backups/

      if [[ -d "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/blocks/" ]]
      then
        echo "${MOVE_OR_COPY_TEXT} /var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/blocks/ to ${DIR}/blocks/"
        sudo mkdir -p "${DIR}/blocks/"
        sudo touch -m "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/blocks/"
        sudo "${MOVE_OR_COPY}" "${MOVE_OR_COPY_OPT}" "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/blocks/"* "${DIR}/blocks/" 2>/dev/null
      fi
      if [[ -d "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/chainstate/" ]]
      then
        sudo mkdir -p "${DIR}/chainstate/"
        sudo touch -m "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/chainstate/"
        sudo "${MOVE_OR_COPY}" "${MOVE_OR_COPY_OPT}" "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/chainstate/"* "${DIR}/chainstate/" 2>/dev/null
        echo "${MOVE_OR_COPY_TEXT} /var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/chainstate/ to ${DIR}/chainstate/"
      fi
      if [[ -d "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/sporks/" ]]
      then
        sudo mkdir -p "${DIR}/sporks/"
        sudo touch -m "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/sporks/"
        sudo "${MOVE_OR_COPY}" "${MOVE_OR_COPY_OPT}" "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/sporks/"* "${DIR}/sporks/" 2>/dev/null
        echo "${MOVE_OR_COPY_TEXT} /var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/sporks/ to ${DIR}/sporks/"
      fi
      if [[ -d "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/zerocoin/" ]]
      then
        sudo mkdir -p "${DIR}/zerocoin/"
        sudo touch -m "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/zerocoin/"
        sudo "${MOVE_OR_COPY}" "${MOVE_OR_COPY_OPT}" "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/zerocoin/"* "${DIR}/zerocoin/" 2>/dev/null
        echo "${MOVE_OR_COPY_TEXT} /var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/zerocoin/ to ${DIR}/zerocoin/"
      fi
      if [[ -d "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/database/" ]]
      then
        sudo mkdir -p "${DIR}/database/"
        sudo touch -m "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/database/"
        sudo "${MOVE_OR_COPY}" "${MOVE_OR_COPY_OPT}" "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/database/"* "${DIR}/database/" 2>/dev/null
        echo "${MOVE_OR_COPY_TEXT} /var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/database/ to ${DIR}/database/"
      fi
      if [[ -d "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/rewards/" ]]
      then
        sudo mkdir -p "${DIR}/rewards/"
        sudo touch -m "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/rewards/"
        sudo "${MOVE_OR_COPY}" "${MOVE_OR_COPY_OPT}" "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/rewards/"* "${DIR}/rewards/" 2>/dev/null
        echo "${MOVE_OR_COPY_TEXT} /var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/rewards/ to ${DIR}/rewards/"
      fi
      if [[ -d "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/txleveldb/" ]]
      then
        sudo mkdir -p "${DIR}/txleveldb/"
        sudo touch -m "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/txleveldb/"
        sudo "${MOVE_OR_COPY}" "${MOVE_OR_COPY_OPT}" "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/txleveldb/"* "${DIR}/txleveldb/" 2>/dev/null
        echo "${MOVE_OR_COPY_TEXT} /var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/txleveldb/ to ${DIR}/txleveldb/"
      fi

      if [[ -r "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/mncache.dat" ]] ; then
        sudo "${MOVE_OR_COPY}" "${MOVE_OR_COPY_OPT}" "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/mncache.dat" "${DIR}/"
        echo "${MOVE_OR_COPY_TEXT} /var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/mncache.dat to ${DIR}/"
      fi
      if [[ -r "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/fee_estimates.dat" ]] ; then
        sudo "${MOVE_OR_COPY}" "${MOVE_OR_COPY_OPT}" "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/fee_estimates.dat" "${DIR}/"
        echo "${MOVE_OR_COPY_TEXT} /var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/fee_estimates.dat to ${DIR}/"
      fi
      if [[ -r "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/db.log" ]] ; then
        sudo "${MOVE_OR_COPY}" "${MOVE_OR_COPY_OPT}" "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/db.log" "${DIR}/"
        echo "${MOVE_OR_COPY_TEXT} /var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/db.log to ${DIR}/"
      fi
      if [[ -r "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/mnpayments.dat" ]] ; then
        sudo "${MOVE_OR_COPY}" "${MOVE_OR_COPY_OPT}" "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/mnpayments.dat" "${DIR}/"
        echo "${MOVE_OR_COPY_TEXT} /var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/mnpayments.dat to ${DIR}/"
      fi
      if [[ -r "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/snpayments.dat" ]] ; then
        sudo "${MOVE_OR_COPY}" "${MOVE_OR_COPY_OPT}" "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/snpayments.dat" "${DIR}/"
        echo "${MOVE_OR_COPY_TEXT} /var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/snpayments.dat to ${DIR}/"
      fi
      if [[ -r "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/budget.dat" ]] ; then
        sudo "${MOVE_OR_COPY}" "${MOVE_OR_COPY_OPT}" "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/budget.dat" "${DIR}/"
        echo "${MOVE_OR_COPY_TEXT} /var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/budget.dat to ${DIR}/"
      fi
      if [[ -r "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/netfulfilled.dat" ]] ; then
        sudo "${MOVE_OR_COPY}" "${MOVE_OR_COPY_OPT}" "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/netfulfilled.dat" "${DIR}/"
        echo "${MOVE_OR_COPY_TEXT} /var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/netfulfilled.dat to ${DIR}/"
      fi
      if [[ -r "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/version.dat" ]] ; then
        sudo "${MOVE_OR_COPY}" "${MOVE_OR_COPY_OPT}" "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/version.dat" "${DIR}/"
        echo "${MOVE_OR_COPY_TEXT} /var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/version.dat to ${DIR}/"
      fi
      if [[ -r "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/blk0001.dat" ]] ; then
        sudo "${MOVE_OR_COPY}" "${MOVE_OR_COPY_OPT}" "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/blk0001.dat" "${DIR}/"
        echo "${MOVE_OR_COPY_TEXT} /var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/blk0001.dat to ${DIR}/"
      fi
      if [[ -r "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/governance.dat" ]] ; then
        sudo "${MOVE_OR_COPY}" "${MOVE_OR_COPY_OPT}" "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/governance.dat" "${DIR}/"
        echo "${MOVE_OR_COPY_TEXT} /var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/governance.dat to ${DIR}/"
      fi
      if [[ -r "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/mempool.dat" ]] ; then
        sudo "${MOVE_OR_COPY}" "${MOVE_OR_COPY_OPT}" "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/mempool.dat" "${DIR}/"
        echo "${MOVE_OR_COPY_TEXT} /var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/mempool.dat to ${DIR}/"
      fi

      sudo chown -R "${1}:${1}" "${USR_HOME}/"
    else
      echo "Set permissions in /var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains."
      find "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/" -type f -exec chmod 666 {} \;
      find "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/" -type d -exec chmod 777 {} \;
      mkdir -p "${DIR}"/backups/

      if [[ -d "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/blocks/" ]]
      then
        echo "${MOVE_OR_COPY_TEXT} /var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/blocks/ to ${DIR}/blocks/"
        mkdir -p "${DIR}/blocks/"
        touch -m "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/blocks/"
        "${MOVE_OR_COPY}" "${MOVE_OR_COPY_OPT}" "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/blocks/"* "${DIR}/blocks/" 2>/dev/null
      fi
      if [[ -d "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/chainstate/" ]]
      then
        mkdir -p "${DIR}/chainstate/"
        touch -m "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/chainstate/"
        "${MOVE_OR_COPY}" "${MOVE_OR_COPY_OPT}" "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/chainstate/"* "${DIR}/chainstate/" 2>/dev/null
        echo "${MOVE_OR_COPY_TEXT} /var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/chainstate/ to ${DIR}/chainstate/"
      fi
      if [[ -d "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/sporks/" ]]
      then
        mkdir -p "${DIR}/sporks/"
        touch -m "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/sporks/"
        "${MOVE_OR_COPY}" "${MOVE_OR_COPY_OPT}" "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/sporks/"* "${DIR}/sporks/" 2>/dev/null
        echo "${MOVE_OR_COPY_TEXT} /var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/sporks/ to ${DIR}/sporks/"
      fi
      if [[ -d "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/zerocoin/" ]]
      then
        mkdir -p "${DIR}/zerocoin/"
        touch -m "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/zerocoin/"
        "${MOVE_OR_COPY}" "${MOVE_OR_COPY_OPT}" "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/zerocoin/"* "${DIR}/zerocoin/" 2>/dev/null
        echo "${MOVE_OR_COPY_TEXT} /var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/zerocoin/ to ${DIR}/zerocoin/"
      fi
      if [[ -d "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/database/" ]]
      then
        mkdir -p "${DIR}/database/"
        touch -m "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/database/"
        "${MOVE_OR_COPY}" "${MOVE_OR_COPY_OPT}" "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/database/"* "${DIR}/database/" 2>/dev/null
        echo "${MOVE_OR_COPY_TEXT} /var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/database/ to ${DIR}/database/"
      fi
      if [[ -d "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/rewards/" ]]
      then
        mkdir -p "${DIR}/rewards/"
        touch -m "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/rewards/"
        "${MOVE_OR_COPY}" "${MOVE_OR_COPY_OPT}" "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/rewards/"* "${DIR}/rewards/" 2>/dev/null
        echo "${MOVE_OR_COPY_TEXT} /var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/rewards/ to ${DIR}/rewards/"
      fi
      if [[ -d "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/txleveldb/" ]]
      then
        mkdir -p "${DIR}/txleveldb/"
        touch -m "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/txleveldb/"
        "${MOVE_OR_COPY}" "${MOVE_OR_COPY_OPT}" "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/txleveldb/"* "${DIR}/txleveldb/" 2>/dev/null
        echo "${MOVE_OR_COPY_TEXT} /var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/txleveldb/ to ${DIR}/txleveldb/"
      fi

      if [[ -r "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/mncache.dat" ]] ; then
        "${MOVE_OR_COPY}" "${MOVE_OR_COPY_OPT}" "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/mncache.dat" "${DIR}/"
        echo "${MOVE_OR_COPY_TEXT} /var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/mncache.dat to ${DIR}/"
      fi
      if [[ -r "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/fee_estimates.dat" ]] ; then
        "${MOVE_OR_COPY}" "${MOVE_OR_COPY_OPT}" "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/fee_estimates.dat" "${DIR}/"
        echo "${MOVE_OR_COPY_TEXT} /var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/fee_estimates.dat to ${DIR}/"
      fi
      if [[ -r "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/db.log" ]] ; then
        "${MOVE_OR_COPY}" "${MOVE_OR_COPY_OPT}" "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/db.log" "${DIR}/"
        echo "${MOVE_OR_COPY_TEXT} /var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/db.log to ${DIR}/"
      fi
      if [[ -r "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/mnpayments.dat" ]] ; then
        "${MOVE_OR_COPY}" "${MOVE_OR_COPY_OPT}" "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/mnpayments.dat" "${DIR}/"
        echo "${MOVE_OR_COPY_TEXT} /var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/mnpayments.dat to ${DIR}/"
      fi
      if [[ -r "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/snpayments.dat" ]] ; then
        "${MOVE_OR_COPY}" "${MOVE_OR_COPY_OPT}" "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/snpayments.dat" "${DIR}/"
        echo "${MOVE_OR_COPY_TEXT} /var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/snpayments.dat to ${DIR}/"
      fi
      if [[ -r "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/budget.dat" ]] ; then
        "${MOVE_OR_COPY}" "${MOVE_OR_COPY_OPT}" "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/budget.dat" "${DIR}/"
        echo "${MOVE_OR_COPY_TEXT} /var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/budget.dat to ${DIR}/"
      fi
      if [[ -r "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/netfulfilled.dat" ]] ; then
        "${MOVE_OR_COPY}" "${MOVE_OR_COPY_OPT}" "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/netfulfilled.dat" "${DIR}/"
        echo "${MOVE_OR_COPY_TEXT} /var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/netfulfilled.dat to ${DIR}/"
      fi
      if [[ -r "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/version.dat" ]] ; then
        "${MOVE_OR_COPY}" "${MOVE_OR_COPY_OPT}" "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/version.dat" "${DIR}/"
        echo "${MOVE_OR_COPY_TEXT} /var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/version.dat to ${DIR}/"
      fi
      if [[ -r "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/blk0001.dat" ]] ; then
        "${MOVE_OR_COPY}" "${MOVE_OR_COPY_OPT}" "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/blk0001.dat" "${DIR}/"
        echo "${MOVE_OR_COPY_TEXT} /var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/blk0001.dat to ${DIR}/"
      fi
      if [[ -r "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/governance.dat" ]] ; then
        "${MOVE_OR_COPY}" "${MOVE_OR_COPY_OPT}" "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/governance.dat" "${DIR}/"
        echo "${MOVE_OR_COPY_TEXT} /var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/governance.dat to ${DIR}/"
      fi
      if [[ -r "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/mempool.dat" ]] ; then
        "${MOVE_OR_COPY}" "${MOVE_OR_COPY_OPT}" "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/mempool.dat" "${DIR}/"
        echo "${MOVE_OR_COPY_TEXT} /var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/mempool.dat to ${DIR}/"
      fi
      chown -R "${1}:${1}" "${USR_HOME}/"
    fi

    if [[ ! -z "${TEMP_VAR_PID}" ]]
    then
      _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" start
    fi
  )

  elif [ "${ARG9}" == "dl_addnode" ]
  then
  (
    DROPBOX_ADDNODES=$( grep -m 1 'nodelist=' "${5}" | cut -d '=' -f2 )
    if [ ! -z "${DROPBOX_ADDNODES}" ]
    then
      echo "Downloading addnode list."
      ADDNODES=$( wget -4qO- -o- https://www.dropbox.com/s/"${DROPBOX_ADDNODES}"/peers_1.txt?dl=1 | grep 'addnode=' | shuf )
      TEMP_VAR_PID=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" pid )
      if [[ ! -z "${TEMP_VAR_PID}" ]]
      then
        _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" stop
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
        _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" start
      fi
    fi
  )

  elif [ "${ARG9}" == "addnode_list" ] || [ "${ARG9}" == "list_addnode" ]
  then
  (
    # Get the port.
    EXTERNAL_IP=$( grep -m 1 'externalip=' "${5}" | cut -d '=' -f2 )
    DEFAULT_PORT=$( grep -m 1 'defaultport=' "${5}" | cut -d '=' -f2 )
    if [ -z "${DEFAULT_PORT}" ]
    then
      DEFAULT_PORT=$(echo "${EXTERNAL_IP}" | cut -d ':' -f2)
    fi

    LASTBLOCK=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" getblockcount 2>/dev/null)
    if [[ -z "${ARG11}" ]] && [[ ! -z "${3}" ]]
    then
      if [[ ! -z "${ARG10}" ]] && [[ ${ARG10} =~ $RE ]]
      then
        WEB_BLK=${ARG10}
      else
        WEB_BLK=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" explorer_blockcount )
      fi

      if [[ ! $WEB_BLK =~ $RE ]]
      then
        echo "Explorer is down."
        echo "Can not generate addnode list."
        return
      fi

      WEB_BLK_HIGH=$(( WEB_BLK + EXPLORER_BLOCKCOUNT_OFFSET ))
      WEB_BLK_LOW=$(( WEB_BLK - EXPLORER_BLOCKCOUNT_OFFSET ))
      if [[ "${WEB_BLK_HIGH}" -lt "${LASTBLOCK}" ]] || [[ "${WEB_BLK_LOW}" -gt "${LASTBLOCK}" ]]
      then
        echo "Local blockcount ${LASTBLOCK} and Remote blockcount ${WEB_BLK} do not match."
        echo "${WEB_BLK_HIGH} -lt ${LASTBLOCK}"
        echo "${WEB_BLK_LOW} -gt ${LASTBLOCK}"
        echo "Can not generate addnode list."
        return
      fi
    fi

    ADDNODE_LIST=''
    # shellcheck disable=SC2030,SC2031
    COUNTER=0
    GETPEERINFO=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" getpeerinfo )
    while [[ "${#ADDNODE_LIST}" -lt 10 ]]
    do
      COUNTER=$(( COUNTER + 1 ))
      BLKCOUNTL=$(( LASTBLOCK - COUNTER ))
      BLKCOUNTH=$(( LASTBLOCK + COUNTER ))
      ADDNODE_LIST=$( echo "${GETPEERINFO}" | jq -r ".[] | select( .synced_headers >= ${BLKCOUNTL} and .synced_headers <= ${BLKCOUNTH} and .banscore < 60 ) | .addr " | sed "s/\:${DEFAULT_PORT}//g" | awk '{print "addnode="$1}' )
      if [[ "${#ADDNODE_LIST}" -lt 10 ]]
      then
        ADDNODE_LIST=$( echo "${GETPEERINFO}" | jq -r ".[] | select( .startingheight >= ${BLKCOUNTL} and .startingheight <= ${BLKCOUNTH} ) | .addr " | sed "s/\:${DEFAULT_PORT}//g" | awk '{print "addnode="$1}' )
      fi
      if [[ "${#ADDNODE_LIST}" -lt 10 ]]
      then
        ADDNODE_LIST=$( echo "${GETPEERINFO}" | jq -r '.[] | select( .banscore == 0 and .inbound == false and .pingtime < 1.5 and .pingtime > 0) | .addr' | sed "s/\:${DEFAULT_PORT}//g" | awk '{print "addnode="$1}' )
      fi
      if [[ "${COUNTER}" -gt 20 ]]
      then
        break
      fi
    done

    if [ "${ARG10}" == "ipv4" ]
    then
      echo "${ADDNODE_LIST}" | grep -v '\=\['
    elif [ "${ARG10}" == "ipv6" ]
    then
      echo "${ADDNODE_LIST}" | grep '\=\[' | cat
    else
      echo "${ADDNODE_LIST}"
    fi
  )

  elif [ "${ARG9}" == "addnode_console" ] || [ "${ARG9}" == "console_addnode" ]
  then
  (
    # Get the port.
    EXTERNAL_IP=$( grep -m 1 'externalip=' "${5}" | cut -d '=' -f2 )
    DEFAULT_PORT=$( grep -m 1 'defaultport=' "${5}" | cut -d '=' -f2 )
    if [ -z "${DEFAULT_PORT}" ]
    then
      DEFAULT_PORT=$(echo "${EXTERNAL_IP}" | cut -d ':' -f2)
    fi

    LASTBLOCK=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" getblockcount 2>/dev/null)
    if [[ -z "${ARG11}" ]] && [[ ! -z "${3}" ]]
    then
      if [[ ! -z "${ARG10}" ]] && [[ ${ARG10} =~ $RE ]]
      then
        WEB_BLK=${ARG10}
      else
        WEB_BLK=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" explorer_blockcount )
      fi

      if ! [[ $WEB_BLK =~ $RE ]]
      then
        echo "Explorer is down."
        echo "Can not generate addnode console list."
        return
      fi

      WEB_BLK_HIGH=$(( WEB_BLK + EXPLORER_BLOCKCOUNT_OFFSET ))
      WEB_BLK_LOW=$(( WEB_BLK - EXPLORER_BLOCKCOUNT_OFFSET ))
      if [[ "${WEB_BLK_HIGH}" -lt "${LASTBLOCK}" ]] || [[ "${WEB_BLK_LOW}" -gt "${LASTBLOCK}" ]]
      then
        echo "Local blockcount ${LASTBLOCK} and Remote blockcount ${WEB_BLK} do not match."
        echo "${WEB_BLK_HIGH} -lt ${LASTBLOCK}"
        echo "${WEB_BLK_LOW} -gt ${LASTBLOCK}"
        echo "Can not generate addnode console list."
        return
      fi
    fi

    ADDNODE_LIST=''
    # shellcheck disable=SC2030,SC2031
    COUNTER=0
    GETPEERINFO=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" getpeerinfo )
    while [[ "${#ADDNODE_LIST}" -lt 10 ]]
    do
      COUNTER=$(( COUNTER + 1 ))
      BLKCOUNTL=$(( LASTBLOCK - COUNTER ))
      BLKCOUNTH=$(( LASTBLOCK + COUNTER ))
      ADDNODE_LIST=$( echo "${GETPEERINFO}" | jq -r ".[] | select( .synced_headers >= ${BLKCOUNTL} and .synced_headers <= ${BLKCOUNTH} and .banscore < 60 ) | .addr " | sed "s/\:${DEFAULT_PORT}//g" | awk '{print "addnode " $1 " add"}' )
      if [[ "${#ADDNODE_LIST}" -lt 10 ]]
      then
        ADDNODE_LIST=$( echo "${GETPEERINFO}" | jq -r ".[] | select( .startingheight >= ${BLKCOUNTL} and .startingheight <= ${BLKCOUNTH} ) | .addr " | sed "s/\:${DEFAULT_PORT}//g" | awk '{print "addnode " $1 " add"}' )
      fi
      if [[ "${#ADDNODE_LIST}" -lt 10 ]]
      then
        ADDNODE_LIST=$( echo "${GETPEERINFO}" | jq -r '.[] | select( .banscore == 0 and .inbound == false and .pingtime < 1.5 and .pingtime > 0) | .addr' | sed "s/\:${DEFAULT_PORT}//g" | awk '{print "addnode " $1 " add"}' )
      fi
      if [[ "${COUNTER}" -gt 20 ]]
      then
        break
      fi
    done

    if [ "${ARG10}" == "ipv4" ]
    then
      echo "${ADDNODE_LIST}" | grep -v '\s\[.*\sadd'
    elif [ "${ARG10}" == "ipv6" ]
    then
      echo "${ADDNODE_LIST}" | grep '\s\[.*\sadd' | cat
    else
      echo "${ADDNODE_LIST}"
    fi
  )

  elif [ "${ARG9}" == "mnbal" ] || [ "${ARG9}" == "${_MASTERNODE_PREFIX}bal" ]
  then
  (
    # Get txid and output index.
    MN_WALLET_ADDR=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" mnaddr )
    if [[ -z "${MN_WALLET_ADDR}" ]]
    then
      return 1
    fi
    WEB_BLK=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" explorer_blockcount )
    if ! [[ $WEB_BLK =~ $RE ]]
    then
      return 1
    fi

    MASTERNODE_STATUS=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "${_MASTERNODE_CALLER}"status )
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
    if [[ -z "${OUTPUTIDX}" ]]
    then
      return 1
    fi

    # Get info from explorer
    if [[ "${3}" == https://www.coinexplorer.net/api/v1/* ]]
    then
      OUTPUTIDX_RAW=$( wget -4qO- -T 15 -t 2 -o- "${3}transaction?txid=${TXID}" "${TEMP_VAR_C}" | jq '.result' 2>/dev/null )
      sleep 1
      MN_WALLET_BALANCE=$( wget -4qO- -T 15 -t 2 -o- "${3}address/balance?address=${MN_WALLET_ADDR}" "${TEMP_VAR_C}" | jq -r ".result[]" 2>/dev/null )
      sleep 1
    else

      EXPLORER_RAWTRANSACTION_PATH=$( grep -m 1 'explorer_rawtransaction_path=' "${5}" | grep -o '=.*' | cut -c2- )
      if [[ -z "${EXPLORER_RAWTRANSACTION_PATH}" ]]
      then
        EXPLORER_RAWTRANSACTION_PATH='api/getrawtransaction?txid='
      fi
      EXPLORER_RAWTRANSACTION_PATH=$( echo "${EXPLORER_RAWTRANSACTION_PATH}" | tr -d '\040\011\012\015' )

      EXPLORER_GETADDRESS_PATH=$( grep -m 1 'explorer_getaddress_path=' "${5}" | grep -o '=.*' | cut -c2- )
      if [[ -z "${EXPLORER_GETADDRESS_PATH}" ]]
      then
        EXPLORER_GETADDRESS_PATH='ext/getaddress/'
      fi
      EXPLORER_GETADDRESS_PATH=$( echo "${EXPLORER_GETADDRESS_PATH}" | tr -d '\040\011\012\015' )

      EXPLORER_RAWTRANSACTION_PATH_SUFFIX=$( grep -m 1 'explorer_rawtransaction_path_suffix=' "${5}" | grep -o '=.*' | cut -c2- )
      if [[ -z "${EXPLORER_RAWTRANSACTION_PATH_SUFFIX}" ]]
      then
        EXPLORER_RAWTRANSACTION_PATH_SUFFIX='&decrypt=1'
      fi
      EXPLORER_RAWTRANSACTION_PATH_SUFFIX=$( echo "${EXPLORER_RAWTRANSACTION_PATH_SUFFIX}" | tr -d '\040\011\012\015' )

      EXPLORER_AMOUNT_ADJUST=$( grep -m 1 'explorer_amount_adjust=' "${5}" | grep -o '=.*' | cut -c2- )
      if [[ -z "${EXPLORER_AMOUNT_ADJUST}" ]]
      then
        EXPLORER_AMOUNT_ADJUST=1
      fi

      URL=$( echo "${3}${EXPLORER_RAWTRANSACTION_PATH}${TXID}${EXPLORER_RAWTRANSACTION_PATH_SUFFIX}" | tr -d '[:space:]' )
      OUTPUTIDX_RAW=$( wget -4qO- -T 15 -t 2 -o- "${URL}" "${TEMP_VAR_C}"  )
      sleep 1

      OUTPUTIDX_RAW_ALT=$( echo "$OUTPUTIDX_RAW" | jq ".data" )
      if [[ $( echo "${OUTPUTIDX_RAW_ALT}" | grep -c 'vin' ) -gt 0 ]]
      then
        OUTPUTIDX_RAW=${OUTPUTIDX_RAW_ALT}
      fi

      OUTPUTIDX_RAW_ALT=$( echo "$OUTPUTIDX_RAW" | jq ".tx" )
      if [[ $( echo "${OUTPUTIDX_RAW_ALT}" | grep -c 'vin' ) -gt 0 ]]
      then
        OUTPUTIDX_RAW=${OUTPUTIDX_RAW_ALT}
      fi

      MN_WALLET_ADDR_DETAILS=$( wget -4qO- -T 15 -t 2 -o- "${3}${EXPLORER_GETADDRESS_PATH}${MN_WALLET_ADDR}" "${TEMP_VAR_C}" )
      MN_WALLET_BALANCE=$( echo "${MN_WALLET_ADDR_DETAILS}" | jq -r ".balance" 2>/dev/null )
      if [[ ! "${MN_WALLET_BALANCE}" =~ ^[0-9]+([.][0-9]+)?$ ]]
      then
        MN_WALLET_BALANCE=$( echo "${MN_WALLET_ADDR_DETAILS}" | jq -r ".data" 2>/dev/null )
      fi
      if [[ ! "${MN_WALLET_BALANCE}" =~ ^[0-9]+([.][0-9]+)?$ ]]
      then
        MN_WALLET_BALANCE=${MN_WALLET_ADDR_DETAILS}
      fi
      MN_WALLET_BALANCE=$( echo "${MN_WALLET_BALANCE} / ${EXPLORER_AMOUNT_ADJUST}" | bc )
      sleep 1
    fi
    MN_WALLET_TX_COLLATERAL=$( echo "${OUTPUTIDX_RAW}" | tr '[:upper:]' '[:lower:]' | jq ".vout[] | select( (.n)|tonumber == ${OUTPUTIDX} ) | .value " )
    UNLOCKED=$( echo "${MN_WALLET_BALANCE} - ${MN_WALLET_TX_COLLATERAL}" | bc )
    echo "Balance:${MN_WALLET_BALANCE} Locked:${MN_WALLET_TX_COLLATERAL} Unlocked:${UNLOCKED}"
  )

  elif [ "${ARG9}" == "getlockedbalance" ] || ([ "${ARG9}" == "getbalance" ] && [ "${ARG10}" == "locked" ])
  then
  (
    LOCKED_COINS=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" listlockunspent )
    HASHES_LOCKED=''
    if [[ "${#LOCKED_COINS}" -gt 63 ]]
    then
      HASHES_LOCKED=$( echo "${LOCKED_COINS}" | jq -r '.[] | [.txhash,.outputidx] | "\(.[0]) \(.[1])"' 2>/dev/null )
      if [[ "${#HASHES_LOCKED}" -lt 63 ]]
      then
        HASHES_LOCKED=$( echo "${LOCKED_COINS}" | jq -r '.[] | [.txid,.vout] | "\(.[0]) \(.[1])"' 2>/dev/null )
      fi
      if [[ "${#HASHES_LOCKED}" -lt 63 ]]
      then
        HASHES_LOCKED=''
        while read -r LINE
        do
          TXID=$( echo "${LINE}" | grep -o -w -E -m 1 '[[:alnum:]]{64}' )
          OUTPUTIDX=$( echo "${LINE}" | grep -w -E -m 1 '[[:alnum:]]{64}' | grep -o ':.*' | grep -o '[0-9]*' )
          HASHES_LOCKED="${HASHES_LOCKED}
            ${TXID} ${OUTPUTIDX}"
        done <<< "${LOCKED_COINS}"
        HASHES_LOCKED=$( echo "${HASHES_LOCKED}" | grep -E '[[:alnum:]]{64}' )
      fi
    fi

    HASHES_MASTERNODE=''
    MN_COLLATERAL=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "${_MASTERNODE_CALLER}"outputs )
    if [[ "${#MN_COLLATERAL}" -gt 63 ]]
    then
      HASHES_MASTERNODE=$( echo "${MN_COLLATERAL}" | jq -r '.[] | [.txhash,.outputidx] | "\(.[0]) \(.[1])"' 2>/dev/null )
      if [[ "${#HASHES_MASTERNODE}" -lt 63 ]]
      then
        HASHES_MASTERNODE=$( echo "${MN_COLLATERAL}" | jq -r '.[] | [.txid,.vout] | "\(.[0]) \(.[1])"' 2>/dev/null )
      fi
      if [[ "${#HASHES_MASTERNODE}" -lt 63 ]]
      then
        HASHES_MASTERNODE=''
        while read -r LINE
        do
          TXID=$( echo "${LINE}" | grep -o -w -E -m 1 '[[:alnum:]]{64}' )
          OUTPUTIDX=$( echo "${LINE}" | grep -w -E -m 1 '[[:alnum:]]{64}' | grep -o ':.*' | grep -o '[0-9]*' )
          HASHES_MASTERNODE="${HASHES_MASTERNODE}
            ${TXID} ${OUTPUTIDX}"
        done <<< "${MN_COLLATERAL}"
        HASHES_MASTERNODE=$( echo "${HASHES_MASTERNODE}" | grep -E '[[:alnum:]]{64}' )
      fi
    fi

    HASHES=$( echo -e "${HASHES_MASTERNODE}\\n${HASHES_LOCKED}" | awk '{print $1 " " $2}' | sort -u )
    SUM=0
    while read -r TXID OUTPUTIDX
    do
      if [[ "${#TXID}" -lt 63 ]]
      then
        continue
      fi
      LOCKED_VALUE=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" getrawtransaction "${TXID}" 1  | jq ".vout | .[] | select( .n == ${OUTPUTIDX} ) | .value" )

      SUM=$(( LOCKED_VALUE + SUM ))
    done <<< "${HASHES}"
    echo "${SUM}"
  )

  elif [ "${ARG9}" == "getunlockedbalance" ] || ([ "${ARG9}" == "getbalance" ] && [ "${ARG10}" == "unlocked" ])
  then
  (
    BALANCE=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" getbalance )
    if [[ $(echo "${BALANCE} > 0" | bc -l ) -eq 0 ]]
    then
      return 0
    fi
    LOCKED_BALANCE=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" getlockedbalance )
    UNLOCKED_BALANCE=$( echo "${BALANCE} - ${LOCKED_BALANCE}" | bc -l )
    echo "${UNLOCKED_BALANCE}"
  )

  elif [ "${ARG9}" == "getstakeinputsbalance" ] || ([ "${ARG9}" == "liststakeinputs" ] && [ "${ARG10}" == "balance" ])
  then
  (
    STAKING_BALANCE=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" liststakeinputs | jq '.[].amount' | awk '{s+=$1} END {print s}' )
    echo "${STAKING_BALANCE}"
  )

  elif [ "${ARG9}" == "mnlock" ] || [ "${ARG9}" == "${_MASTERNODE_PREFIX}lock" ]
  then
  (
    MN_OUTPUTS=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "${_MASTERNODE_CALLER}"outputs )
    if [[ "${#MN_OUTPUTS}" -lt 63 ]]
    then
      return
    fi

    HASHES=$( echo "${MN_OUTPUTS}" |  jq -r '.[] | [.txhash,.outputidx] | "\(.[0]) \(.[1])"' 2>/dev/null )
    if [[ "${#HASHES}" -lt 63 ]]
    then
      HASHES=''
      while read -r LINE
      do
        TXID=$( echo "${LINE}" | grep -o -w -E -m 1 '[[:alnum:]]{64}' )
        OUTPUTIDX=$( echo "${LINE}" | grep -w -E -m 1 '[[:alnum:]]{64}' | grep -o ':.*' | grep -o '[0-9]*' )
        HASHES="${HASHES}
${TXID} ${OUTPUTIDX}"
      done <<< "${MN_OUTPUTS}"
      HASHES=$( echo "${HASHES}" | grep -E '[[:alnum:]]{64}' )
    fi

    echo "${HASHES}"
    # Create a json string for lockunspent.
    JSON='['
    LINES=$( echo "${HASHES}" | wc -l )
    while read -r TXID OUTPUTIDX
    do
      LINES=$(( LINES-1 ))
      EXTRA=''
      if [[ "${LINES}" -gt 0 ]]
      then
        EXTRA=','
      fi
      JSON="${JSON}{\"\\\"txid\\\"\":\"\\\"${TXID}\\\"\"\\,\"\\\"vout\\\"\":\"${OUTPUTIDX}\"}${EXTRA}"
    done <<< "${HASHES}"
    JSON="${JSON}]"
    _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" lockunspent false "${JSON}"
  )

  elif [ "${ARG9}" == "mnstatus" ] || [ "${ARG9}" == "${_MASTERNODE_PREFIX}status" ]
  then
  (
    MASTERNODE_STATUS=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "${_MASTERNODE_CALLER}"status )
    if [[ $( echo "${MASTERNODE_STATUS}" | grep -ic "method not found" ) -gt 0 ]]
    then
      MASTERNODE_STATUS=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "${_MASTERNODE_CALLER}"debug )
    fi
    JSON_ERROR=$( echo "${MASTERNODE_STATUS}" | jq . 2>&1 >/dev/null )
    if [ -z "${JSON_ERROR}" ]
    then
      echo "${MASTERNODE_STATUS}" | jq .
    else
      echo "${MASTERNODE_STATUS}"
    fi
  )

  elif [ "${ARG9}" == "mninfo" ] || [ "${ARG9}" == "${_MASTERNODE_PREFIX}info" ]
  then
  (
    if [[ ! -z "${ARG10}" ]] && [[ ! -z "${ARG11}" ]]
    then
      TXID="${ARG10}"
      OUTPUTIDX="${ARG11}"
    else
      sleep 0.1
      MASTERNODE_STATUS=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "${_MASTERNODE_CALLER}"status )
      if [[ $( echo "${MASTERNODE_STATUS}" | grep -ic "${_MASTERNODE_NAME} successfully started" ) -ge 1 ]] || [[ $( echo "${MASTERNODE_STATUS}" | grep -ic "${_MASTERNODE_NAME} started remotely" ) -ge 1 ]]
      then
        # Get collateral info.
        TXID=$( echo "${MASTERNODE_STATUS}" | jq -r .[] 2>/dev/null | head -n 1 | grep -o -w -E '[[:alnum:]]{64}' )
        OUTPUTIDX=$( echo "${MASTERNODE_STATUS}" | jq '.outputidx' 2>/dev/null | grep -v 'null' )
        if [[ -z "${OUTPUTIDX}" ]]
        then
          OUTPUTIDX=$( echo "${MASTERNODE_STATUS}" | jq -r .[] 2>/dev/null | head -n 1 | grep -o -w -E '[[:alnum:]]{64}-[0-9]{1,2}' | cut -d '-' -f2 )
        fi
        if [[ -z "${OUTPUTIDX}" ]]
        then
          OUTPUTIDX=$( echo "${MASTERNODE_STATUS}" | jq -r .[] 2>/dev/null | head -n 1 | grep -o -w -E '[[:alnum:]]{64},\s[0-9]{1,2}' | awk '{print $2}' )
        fi
      else
        TXID=$( grep -m 1 'txhash=' "${5}" | cut -d '=' -f2 )
        OUTPUTIDX=$( grep -m 1 'outputidx=' "${5}" | cut -d '=' -f2 )
      fi

      if [[ -z "${TXID}" ]] || [[ -z "${OUTPUTIDX}" ]]
      then
        sleep 0.2
        MASTERNODE_OUTPUTS=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "${_MASTERNODE_CALLER}"outputs )
        TXID=$( echo "${MASTERNODE_OUTPUTS}" | jq -r ".[0].txhash" 2>/dev/null | grep -o -w -E '[[:alnum:]]{64}' )
        OUTPUTIDX=$( echo "${MASTERNODE_OUTPUTS}" | jq -r ".[0].outputidx" 2>/dev/null )
        if [[ -z "${TXID}" ]] || [[ -z "${OUTPUTIDX}" ]]
        then
          TXID=$( echo "${MASTERNODE_OUTPUTS}" | grep -o -w -E -m 1 '[[:alnum:]]{64}' )
          OUTPUTIDX=$( echo "${MASTERNODE_OUTPUTS}" | grep -w -E -m 1 '[[:alnum:]]{64}' | grep -o ':.*' | grep -o '[0-9]*' )
        fi
      fi
    fi

    if [[ ! -z "${TXID}" ]] && [[ ! -z "${OUTPUTIDX}" ]]
    then
      # Get masternode list info.
      sleep 0.3
      MASTERNODE_LIST=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "${_MASTERNODE_LIST}" )
      LIST_STATUS=$( echo "${MASTERNODE_LIST}" | jq ".[] | select( .txhash == \"$TXID\" and .outidx == $OUTPUTIDX )" 2>/dev/null )
      if [[ -z "${LIST_STATUS}" ]]
      then
        LIST_STATUS=$( echo "${MASTERNODE_LIST}" | jq ".[] | select( .txhash == \"$TXID\" )" 2>/dev/null )
      fi
      if [[ -z "${LIST_STATUS}" ]]
      then
        sleep 0.4
        if [[ $( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "${_MASTERNODE_LIST}" help | grep -ic 'json' ) -gt 0 ]]
        then
          sleep 0.5
          MASTERNODE_LIST_JSON=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "${_MASTERNODE_LIST}" json )
          LIST_STATUS=$( echo "${MASTERNODE_LIST_JSON}" | jq ".[\"${TXID}-${OUTPUTIDX}\"]" 2>/dev/null )
        fi
      fi
      if [[ -z "${LIST_STATUS}" ]]
      then
        LIST_STATUS=$( echo "$MASTERNODE_LIST_JSON}" | jq ".[keys[] | select(contains(\"${TXID}\"))]" 2>/dev/null )
      fi
      if [[ -z "${LIST_STATUS}" ]]
      then
        sleep 0.6
        MASTERNODE_LIST_ALL=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "${_MASTERNODE_LIST}" full )
        LIST_STATUS=$( echo "${MASTERNODE_LIST_ALL}" | grep "${TXID}-${OUTPUTIDX}"  2>/dev/null )
        if [[ -z "${LIST_STATUS}" ]]
        then
          LIST_STATUS=$( echo "${MASTERNODE_LIST}" | grep "${TXID}-${OUTPUTIDX}"  2>/dev/null )
        fi
      fi
      if [[ -z "${LIST_STATUS}" ]]
      then
        LIST_STATUS=$( echo "${MASTERNODE_LIST_ALL}" | grep "${TXID}, ${OUTPUTIDX}"  2>/dev/null )
        if [[ -z "${LIST_STATUS}" ]]
        then
          LIST_STATUS=$( echo "${MASTERNODE_LIST}" | grep "${TXID}, ${OUTPUTIDX}"  2>/dev/null )
        fi
      fi
      if [[ -z "${LIST_STATUS}" ]]
      then
        LIST_STATUS=$( echo "${MASTERNODE_LIST_ALL}" | grep "${TXID}"  2>/dev/null )
        if [[ -z "${LIST_STATUS}" ]]
        then
          LIST_STATUS=$( echo "${MASTERNODE_LIST}" | grep "${TXID}"  2>/dev/null )
        fi
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
  )

  elif [ "${ARG9}" == "mnaddr" ] || [ "${ARG9}" == "${_MASTERNODE_PREFIX}addr" ]
  then
  (
    MASTERNODE_STATUS=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "${_MASTERNODE_CALLER}"status )
    if [[ $( echo "${MASTERNODE_STATUS}" | grep -ic "${_MASTERNODE_NAME} successfully started" ) -ge 1 ]] || [[ $( echo "${MASTERNODE_STATUS}" | grep -ic "${_MASTERNODE_NAME} started remotely" ) -ge 1 ]]
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
  )

  elif [ "${ARG9}" == "mnwin" ] || [ "${ARG9}" == "${_MASTERNODE_PREFIX}win" ]
  then
  (
    # Get masternode address.
    if [[ -z "${ARG10}" ]]
    then
      MN_ADDR=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "${_MASTERNODE_PREFIX}addr" )
    else
      MN_ADDR=${ARG10}
    fi

    # Return if no masternode address.
    if [[ -z "${MN_ADDR}" ]]
    then
      return
    fi

    # Return if no masternode winners does not contain masternode address.
    MASTERNODE_WINNERS=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "${_MASTERNODE_CALLER}"winners | sed 's/: " /: "/g' )
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
        OUTPUT=$( echo -e "${OUTPUT}\\n${MN_ADDR} ${BLK}" )
        continue
      fi
      if [[ $( echo "${BLK_WINNERS}" | jq '.winner' 2>/dev/null | grep -c "${MN_ADDR}" ) -gt 0 ]]
      then
        OUTPUT=$( echo -e "${OUTPUT}\\n${MN_ADDR} ${BLK}" )
      fi
    done <<< "$( echo "${MN_WINNER}" | jq ".nHeight" 2>/dev/null  )"

    # Dash syntax.
    if [[ -z "${OUTPUT}" ]] || [[ ! ${OUTPUT} =~ ${RE} ]]
    then
      while read -r BLK
      do
        if [[ $( echo "${MASTERNODE_WINNERS}" | grep "${BLK}" | tr -d -c ',' | wc -c ) -eq 1 ]]
        then
          OUTPUT=$( echo -e "${OUTPUT}\\n${MN_ADDR} ${BLK}" )
        else
          if [[ $( echo "${MASTERNODE_WINNERS}" | grep "${BLK}" | awk '{first = $1; $1 = ""; print $0}' | tr ',' '\n' | tr -d '"' | tr ':' ' ' | awk '{print $2 " " $1}' | sort -hr | head -n 1 | grep -c "${MN_ADDR}" ) -gt 0 ]]
          then
            OUTPUT=$( echo -e "${OUTPUT}\\n${MN_ADDR} ${BLK}" )
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
          OUTPUT=$( echo -e "${OUTPUT}\\n${MN_ADDR} ${BLK}" )
        fi
      done <<< "$( echo "$MN_WINNER }}" | jq -r 'keys[]' 2>/dev/null )"
    fi
    echo "${OUTPUT}" | sed '/^[[:space:]]*$/d'
  )

  elif [ "${ARG9}" == "sync" ]
  then
  (
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
    local BLOCKCOUNT_FALLBACK_VALUE
    BLOCKCOUNT_FALLBACK_VALUE="${ARG10}"
    i=1
    BIG_COUNTER=0
    START_COUNTER=0

    if ! [[ ${BLOCKCOUNT_FALLBACK_VALUE} =~ ${RE} ]] || [[ -z "${BLOCKCOUNT_FALLBACK_VALUE}" ]]
    then
      echo "Getting the block count from the network"
      BLOCKCOUNT_FALLBACK_VALUE=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" getpeerblockcount )
      if [[ "${#BLOCKCOUNT_FALLBACK_VALUE}" -gt 1 ]]
      then
        echo "${BLOCKCOUNT_FALLBACK_VALUE}"
      fi
    fi
    # shellcheck disable=SC2030,SC2031
    if [[ -z "${DAEMON_CONNECTIONS}" ]]
    then
      DAEMON_CONNECTIONS=4
    fi

    # Get block count from the explorer.
    echo "Getting the block count from the explorer."
    WEBBLOCK=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" explorer_blockcount )
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

    TEMP_VAR_PID=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" pid )
    if [[ ! -z "${TEMP_VAR_PID}" ]]
    then
      sudo -n renice 10 -p "${TEMP_VAR_PID}"
    fi

    echo "You can watch the log to see the exact details of the sync by"
    echo "running this in another terminal:"
    echo "${1} daemon_log loc | xargs watch -n 0.3 tail -n 15"
    echo "Explorer Count: ${WEBBLOCK}"
    echo "Waiting for at least ${DAEMON_CONNECTIONS} connections."
    echo
    echo "Initializing blocks, the faster the CPU that faster this goes."
    echo

    DAEMON_LOG=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" daemon_log loc )
    if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
    then
      CONNECTIONCOUNT=$( sudo ss -nptu -o state established 2>/dev/null | grep -c "pid=${TEMP_VAR_PID}" | tr -d '\040\011\012\015' )
    else
      PORT_FOR_DAEMON=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" port | grep -o '[0-9]*' )
      CONNECTIONCOUNT=$( ss -nptu -o state established 2>/dev/null | awk '{print $5}' | grep -c ":${PORT_FOR_DAEMON}" | tr -d '\040\011\012\015' )
    fi
    # If connectioncount is not a number set it to 0.
    if ! [[ $CONNECTIONCOUNT =~ $RE ]]
    then
      CONNECTIONCOUNT=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" getconnectioncount 2>/dev/null )
      if ! [[ $CONNECTIONCOUNT =~ $RE ]]
      then
        CONNECTIONCOUNT=0;
      fi
    fi

    LASTBLOCK=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" daemon_log tail 200 | tac | grep -m1 -o 'height=[[:digit:]]*' | cut -d '=' -f2 | head -n 1 | tr -d '\040\011\012\015' )
    # If blockcount is not a number set it to 0.
    if [[ ! ${LASTBLOCK} =~ ${RE} ]] || [[ -z ${LASTBLOCK} ]]
    then
      LASTBLOCK=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" getblockcount 2>/dev/null )
      if ! [[ ${LASTBLOCK} =~ ${RE} ]]
      then
        LASTBLOCK=0
      fi
    fi

    if [ "${ARG11}" == "y" ]
    then
      echo "Waiting for the blockcount to get to ${WEBBLOCK}"
    else
      echo -e "\\r${SP:i++%${#SP}:1} Connection Count: ${CONNECTIONCOUNT}/${DAEMON_CONNECTIONS} \tBlockcount: ${LASTBLOCK} \\n"
      echo
      echo
      echo "Contents of ${DAEMON_LOG}"
      echo
      echo
      echo
      echo
      echo
      UP=$( tput cuu1 )
    fi

    stty sane 2>/dev/null

    sleep 3
    while :
    do
      # Auto restart if daemon dies.
      TEMP_VAR_PID=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" pid )
      if [[ -z "${TEMP_VAR_PID}" ]]
      then
        if [[ "${START_COUNTER}" -eq 2 ]]
        then
          START_COUNTER=$(( START_COUNTER + 1 ))
          echo "Starting the daemon with -reindex."
          _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" reindex
        else
          START_COUNTER=$(( START_COUNTER + 1 ))
          echo "Starting the daemon again."
          _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" start
          sleep 15
          TEMP_VAR_PID=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" pid )
          if [[ ! -z "${TEMP_VAR_PID}" ]]
          then
            sudo -n renice 10 -p "${TEMP_VAR_PID}" >/dev/null 2>&1
          fi
        fi
      fi

      if [[ -z ${DAEMON_LOG} ]]
      then
        DAEMON_LOG=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" daemon_log loc )
      fi

      if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
      then
        CONNECTIONCOUNT=$( sudo ss -nptu -o state established 2>/dev/null | grep -c "pid=${TEMP_VAR_PID}" | tr -d '\040\011\012\015' )
      else
        PORT_FOR_DAEMON=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" port | grep -o '[0-9]*' )
        CONNECTIONCOUNT=$( ss -nptu -o state established 2>/dev/null | awk '{print $5}' | grep -c ":${PORT_FOR_DAEMON}" | tr -d '\040\011\012\015' )
      fi
      # If connectioncount is not a number set it to 0.
      if ! [[ $CONNECTIONCOUNT =~ $RE ]]
      then
        CONNECTIONCOUNT=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" getconnectioncount 2>/dev/null )
        if ! [[ $CONNECTIONCOUNT =~ $RE ]]
        then
          CONNECTIONCOUNT=0;
        fi
      fi

      LASTBLOCK=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" daemon_log tail 200 | tac | grep -m1 -o 'height=[[:digit:]]*' | cut -d '=' -f2 | head -n 1 | tr -d '\040\011\012\015' )
      # If blockcount is not a number set it to 0.
      if [[ ! ${LASTBLOCK} =~ ${RE} ]] || [[ -z ${LASTBLOCK} ]]
      then
        LASTBLOCK=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" getblockcount 2>/dev/null )
        if ! [[ ${LASTBLOCK} =~ ${RE} ]]
        then
          LASTBLOCK=0
        fi
      fi

      if [[ "${WEBBLOCK}" -eq 0 ]] && [[ "${CONNECTIONCOUNT}" -gt 1 ]]
      then
        PEER_BLOCK_COUNT=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" getpeerblockcount )
        if [[ ${PEER_BLOCK_COUNT} =~ ${RE} ]]
        then
          WEBBLOCK=${PEER_BLOCK_COUNT}
        fi
      fi

      # Update console 34 times in 10 seconds before doing a check.
      END=34
      stty sane 2>/dev/null
      while [ ${END} -gt 0 ];
      do
        END=$(( END - 1 ))
        CURRENTBLOCK=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" daemon_log tail 200 | tac | grep -m1 -o 'height=[[:digit:]]*' | cut -d '=' -f2 | head -n 1 | tr -d '\040\011\012\015' )
        # If blockcount is not a number set it to 0.
        if [[ ! ${CURRENTBLOCK} =~ ${RE} ]] || [[ -z ${CURRENTBLOCK} ]]
        then
          CURRENTBLOCK=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" getblockcount 2>/dev/null )
          if ! [[ ${CURRENTBLOCK} =~ ${RE} ]]
          then
            CURRENTBLOCK=0
          fi
        fi

        if [ "${ARG11}" == "y" ]
        then
          printf "."
        else
          # Generate header text.
          i=$((i+1))
          HEADER="$( echo -e "${SP:i%${#SP}:1} Connection Count: ${CONNECTIONCOUNT}/${DAEMON_CONNECTIONS} Blockcount: ${CURRENTBLOCK}/${WEBBLOCK}" )"

          # Generate process info line.

          if [[ -z "${TEMP_VAR_PID}" ]]
          then
            TEMP_VAR_PID=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" pid )
          fi
          PS_LINES=$( echo -e "\\n No Process Info ${TEMP_VAR_PID} \\n \\n" )
          if [[ "${#TEMP_VAR_PID}" -gt 1 ]]
          then
            PS_LINES=''
            PS_LINES="$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" ps-short )"
          fi

          # Generate lines
          LOG_LINES="$( echo -e " \\n \\n \\n \\n \\n" )"
          if [[ -r "${DAEMON_LOG}" ]]
          then
            LOG_LINES="$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" daemon_log tail 5 | awk '{ printf substr($2,7,2); $1=$2=""; print $0}' | sed 's/ \+ / /g' | sed 's/best\=.\{65\}//g' | tr -cd "[:print:]\n" )"
          fi

          # Generate the full output line.
          LOOP_LINES="${HEADER}

${PS_LINES}
Contents of ${DAEMON_LOG}
${LOG_LINES}"

          # Move up.
          while read -r LOG_LINE
          do
            echo -e "${UP}\\c"
          done <<< "${LOOP_LINES}"

          # Output lines.
          MIN_WIDTH=20
          TERM_WIDTH=$( tput cols )
          TERM_WIDTH=$(( TERM_WIDTH > MIN_WIDTH ? TERM_WIDTH : MIN_WIDTH ))
          TERM_WIDTH=$(( TERM_WIDTH - 1 ))
          while read -r LOG_LINE
          do
            printf "%-${TERM_WIDTH}s\n" "${LOG_LINE:0:${TERM_WIDTH}}"
          done <<< "${LOOP_LINES}"
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
        PEER_BLOCK_COUNT=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" getpeerblockcount )
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
        # Swap addnodes if blockcount is stuck.
        if [[ "${START_COUNTER}" -lt 2 ]]
        then
          if [[ $( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" conf | grep -c '^addnode=' ) -gt 2 ]]
          then
            _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" remove_addnode
          else
            _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" dl_addnode
          fi

        # Reindex daemon if blockcount is stuck 3 times in a row.
        elif [[ "${START_COUNTER}" -eq 3 ]]
        then
          echo "Starting the daemon with -reindex."
          _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" reindex

        else
          _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" restart
          sleep 15
          echo
          echo
          echo
          echo
          echo
          echo
          echo
        fi
        BIG_COUNTER=0
        START_COUNTER=$(( START_COUNTER + 1 ))
      fi
      TEMP_VAR_PID=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" pid )
      if [[ ! -z "${TEMP_VAR_PID}" ]]
      then
        sudo -n renice 10 -p "${TEMP_VAR_PID}" >/dev/null 2>&1
      fi
    done
    stty sane 2>/dev/null
    echo

    TEMP_VAR_PID=$( _masternode_dameon_2 "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" pid )
    if [[ ! -z "${TEMP_VAR_PID}" ]]
    then
      sudo -n renice 0 -p "${TEMP_VAR_PID}"
    fi
    )

  elif [ ! -z "${USER_HOME_DIR}" ]
  then
  (
    if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
    then
      JSON_STRING=$( sudo su "${1}" -c "${CLI_BIN_LOC} -datadir=${DATADIR}/ ${ARG9} ${ARG10} ${ARG11} ${ARG12} ${ARG13} ${ARG14} ${ARG15} ${ARG16} ${ARG17} " 2>&1 )
    else
      # shellcheck disable=SC2086
      JSON_STRING=$( "${CLI_BIN_LOC}" "-datadir=${DATADIR}/" "${ARG9}" ${ARG10} ${ARG11} ${ARG12} ${ARG13} ${ARG14} ${ARG15} ${ARG16} ${ARG17} 2>&1 )
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
  )
  fi

}
# End of function for _masternode_dameon_2.
MN_DAEMON_MASTER_FUNCD
)
sleep 0.1

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
#   LEVEL1_ALT=" $( _masternode_dameon_2 '' '' '' '' '' '' '' '' 'help-bashrc' ) "
  LEVEL1_ALT=' addnode_console addnode_list addnode_remove addnode_to_connect blockcheck blockcheck_fix blockcheck_reindex blockcount_explorer chaincheck checkblock checkchain checkpeers checksystemd cli conf connect_to_addnode console_addnode crontab daemon daemon_in_good_state daemon_log daemon_remove daemon_update dl_addnode dl_blocks_n_chains dl_bootstrap dl_bootstrap_reindex explorer explorer_blockcount explorer_peers failure_after_start forcestart getmasternodever getmasternodeversion getpeerblockcount getpeerblockver getpeerver getpeerversion githubrepo lastblock lastblock_time list_addnode log_daemon log_system peercheck peers_remove pid port privkey ps ps-short reindex reindexzerocoin remove_addnode remove_daemon remove_peers rename restart start start-nosystemd status stop sync systemdcheck system_log update_daemon uptime '

  if [[ $( echo "${LEVEL1}" | grep -c "smartnode" ) -ge 1 ]]
  then
    LEVEL1_ALT="${LEVEL1_ALT} smartnode.conf  snaddr snbal sncheck snfix sninfo snlocal snping snver snwin "
  else
    LEVEL1_ALT="${LEVEL1_ALT} masternode.conf mnaddr mnbal mncheck mnfix mninfo mnlocal mnping mnver mnwin "
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
  local DAEMONS_RAN
  local THIS_DAEMON
  while read -r USR_HOME_DIR
  do
    if [[ "${#USR_HOME_DIR}" -lt 3 ]] || [[ ${USR_HOME_DIR} == /var/run/* ]] || [[ ${USR_HOME_DIR} == '/proc' ]]
    then
      continue
    fi

    MN_USRNAME=$( basename "${USR_HOME_DIR}" )
    if [ "$( type "${MN_USRNAME}" 2>/dev/null | grep -c '_masternode_dameon_2' )" -gt 0 ]
    then
      if [[ "$1" == 'DAEMON_NAME' ]]
      then
        if [[ $( "${MN_USRNAME}" daemon ) == "$2" ]]
        then
          echo "${MN_USRNAME}"
          ${MN_USRNAME} "$3" "$4" "$5" "$6" "$7" "$8" "$9" "${10}" "${11}"
          echo
        fi
      elif [[ "$1" == 'ONE_DAEMON' ]]
      then
        THIS_DAEMON=$( "${MN_USRNAME}" daemon )
        if [[ $( echo "${DAEMONS_RAN}" |  grep -c "${THIS_DAEMON}" ) -eq 0 ]]
        then
          DAEMONS_RAN="${DAEMONS_RAN} ${THIS_DAEMON}"
          echo "${MN_USRNAME}"
          ${MN_USRNAME} "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "${10}" "${11}"
          echo
        fi
      else
        echo "${MN_USRNAME}"
        ${MN_USRNAME} "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"
        echo
      fi
    fi
  done <<< "$( cut -d: -f1 /etc/passwd | getent passwd | cut -d: -f6 | sort -h )"
}
# End of function for all_mn_run.
ALL_MN_RUN
)

# Create function that will run the same command on all masternodes.
_DAEMON_MN_RUN=$( cat << "DAEMON_MN_RUN"
# Start of function for _daemon_mn_run.
_daemon_mn_run () {
  CONF=${1}
  CONTROLLER_BIN=${2}
  DAEMON_BIN=${3}
  EXPLORER_URL=${4}
  EXPLORER_EXTRA_PARAM=${5}

  CONF_N_USRNAMES=''
  COUNTER=0
  # shellcheck disable=SC2034
  while read -r USRNAME DEL_1 DEL_2 DEL_3 DEL_4 DEL_5 DEL_6 DEL_7 DEL_8 USR_HOME_DIR USR_HOME_DIR_ALT DEL_9
  do
    if [[ "${USR_HOME_DIR}" == 'X' ]]
    then
      USR_HOME_DIR=${USR_HOME_DIR_ALT}
    fi

    if [[ "${#USR_HOME_DIR}" -lt 3 ]] || [[ ${USR_HOME_DIR} == /var/run/* ]] || [[ ${USR_HOME_DIR} == '/proc' ]]
    then
      continue
    fi

    CONF_LOCATIONS=$( find "${USR_HOME_DIR}" -name "${CONF}" 2>/dev/null )
    if [[ -z "${CONF_LOCATIONS}" ]]
    then
      continue
    fi

    MN_USRNAME=$( basename "${USR_HOME_DIR}" )
    if [ "$( type "${MN_USRNAME}" 2>/dev/null | grep -c '_masternode_dameon_2' )" -gt 0 ]
    then
      if [[ $( "${MN_USRNAME}" cli ) == "${CONTROLLER_BIN}" ]]
      then
        CONF_LOCATIONS=$( "${MN_USRNAME}" conf loc )
      else
        CONF_LOCATIONS=''
      fi
    fi

    while read -r CONF_LOCATION
    do
      if [[ $( echo "${CONF_LOCATION}" | grep -c '/contrib/' ) -eq 0 ]]
      then
        CONF_N_USRNAMES="${CONF_N_USRNAMES}
${USRNAME} ${CONF_LOCATION}"
      fi
    done <<< "${CONF_LOCATIONS}"
  done <<< "$( cut -d: -f1 /etc/passwd | getent passwd | sed 's/:/ X /g' | sort -h )"

  CONF_N_USRNAMES=$( echo "${CONF_N_USRNAMES}" | sed '/^[[:space:]]*$/d' )
  ROOT_ENTRY=$( echo "${CONF_N_USRNAMES}" | grep -E '^root .*' )
  CONF_N_USRNAMES=$( echo "${CONF_N_USRNAMES}" | sed '/^root .*/d' )
  CONF_N_USRNAMES="${CONF_N_USRNAMES}
${ROOT_ENTRY}"
  CONF_N_USRNAMES=$( echo "${CONF_N_USRNAMES}" | sed '/^[[:space:]]*$/d' )

  CONF_N_USRNAMES_NEXT=''
  while read -r USRNAME CONF_LOCATION
  do
    if [[ -z ${USRNAME} ]]
    then
      continue
    fi
    COUNTER=$(( COUNTER + 1 ))
    CONF_N_USRNAMES_NEXT="${CONF_N_USRNAMES_NEXT}
${COUNTER} ${USRNAME} ${CONF_LOCATION}"
  done <<< "${CONF_N_USRNAMES}"
  CONF_N_USRNAMES=$( echo "${CONF_N_USRNAMES_NEXT}" | sed '/^[[:space:]]*$/d' )

  REPLY=''
  if [[ "${6}" == 'help' ]] || [[ $( echo "${CONF_N_USRNAMES}" | wc -l ) -lt 2 ]]
  then
    REPLY='1'
  fi

  while [[ -z "${REPLY}" ]]
  do
    if [[ $( echo "${CONF_N_USRNAMES}" | wc -l ) -gt 1 ]]
    then
      echo "0  Run on all"
      echo "${CONF_N_USRNAMES}" | column -t
      REPLY=''
      read -r -p $'What number to run this command on? ' -e -i "${REPLY}" input 2>&1
      REPLY="${input:-$REPLY}"
      if [[ -z "${REPLY}" ]]
      then
        REPLY=0
      fi
      REPLY=$( echo "${REPLY}" | grep -o '[0-9]*' )
      if [[ "$( echo "${CONF_N_USRNAMES}" | grep -cE "^${REPLY} " )" -eq 0 ]] && [[ "${REPLY}" -gt 0 ]]
      then
        REPLY=''
      fi
    fi
  done

  if [[ "${REPLY}" -gt 0 ]]
  then
    CONF_N_USRNAMES=$( echo "${CONF_N_USRNAMES}" | grep -E "^${REPLY} " )
  fi

  while read -r COUNTER USRNAME CONF_LOCATION
  do
    if [[ "${REPLY}" -eq 0 ]]
    then
      echo
      echo "${USRNAME} ${CONF_LOCATION}"
    fi
    _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" "${EXPLORER_URL}" "${DAEMON_BIN}" "${CONF_LOCATION}" "${EXPLORER_EXTRA_PARAM}" '-1' '-1' "${6}" "${7}" "${8}" "${9}" "${10}" "${11}" "${12}" "${13}" "${14}"
  done <<< "${CONF_N_USRNAMES}"
}
# End of function for _daemon_mn_run.
DAEMON_MN_RUN
)

COMPILE_DAEMON() {
  local GITHUB_REPO
  GITHUB_REPO="${1}"
  DAEMON_BIN="${2}"
  CONTROLLER_BIN="${3}"
  COUNTER=0

  WAIT_FOR_APT_GET
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq \
    build-essential \
    libtool \
    autotools-dev \
    automake \
    pkg-config \
    libevent-dev \
    bsdmainutils \
    software-properties-common \
    git

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

  # Add in bitcoin repo.
  # shellcheck disable=SC2941
  if [[ $( grep -r '/etc/apt' -e 'bitcoin' | wc -l ) -eq 0 ]]
  then
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

  WAIT_FOR_APT_GET
  sudo DEBIAN_FRONTEND=noninteractive apt-get -f install -yq
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
    libminiupnpc10 \
    miniupnpc\
    libzmq5 \
    libdb4.8-dev \
    libdb4.8++-dev \
    libleveldb-dev \
    libminiupnpc-dev \
    libcrypto++-dev \
    libqrencode-dev \
    libboost-all-dev \
    libboost-system-dev \
    libboost-filesystem-dev \
    libboost-program-options-dev \
    libboost-thread-dev \
    libzmq3-dev \
    libssl1.0-dev \
    libqt5gui5 \
    libqt5core5a \
    libqt5webkit5-dev \
    libqt5dbus5 \
    qttools5-dev \
    qttools5-dev-tools \
    libprotobuf-dev \
    protobuf-compiler \
    libgmp3-dev

  GITHUB_REPO_URL="${GITHUB_REPO}"
  if [[ ! "${GITHUB_REPO_URL}" == http* ]]
  then
    GITHUB_REPO_URL=$( echo "github.com/${GITHUB_REPO_URL}" | sed 's,//,/,g' )
    GITHUB_REPO_URL="https://${GITHUB_REPO_URL}"
  fi

  TMP_FOLDER=$( mktemp -d )
  echo
  echo
  echo "Getting ${GITHUB_REPO_URL}."
  git clone "${GITHUB_REPO_URL}" "${TMP_FOLDER}"
  git -C "${TMP_FOLDER}" clean -x -f -d
  git -C "${TMP_FOLDER}" reset --hard

  # Only trust bitcoin shell scripts.
  if [[ -f "${TMP_FOLDER}/share/genbuild.sh" ]]
  then
    rm "${TMP_FOLDER}/share/genbuild.sh"
    wget -4q https://raw.githubusercontent.com/bitcoin/bitcoin/master/share/genbuild.sh -O "${TMP_FOLDER}/share/genbuild.sh"
    chmod +x "${TMP_FOLDER}/share/genbuild.sh"
  fi
  if [[ -f "${TMP_FOLDER}/src/leveldb/build_detect_platform" ]]
  then
    rm "${TMP_FOLDER}/src/leveldb/build_detect_platform"
    wget -4q https://raw.githubusercontent.com/bitcoin/bitcoin/master/src/leveldb/build_detect_platform -O "${TMP_FOLDER}/src/leveldb/build_detect_platform"
    chmod +x "${TMP_FOLDER}/src/leveldb/build_detect_platform"
  fi
  if [[ -f "${TMP_FOLDER}/autogen.sh" ]]
  then
    rm "${TMP_FOLDER}/autogen.sh"
    wget wget -4q https://raw.githubusercontent.com/bitcoin/bitcoin/master/autogen.sh -O "${TMP_FOLDER}/autogen.sh"
    chmod +x "${TMP_FOLDER}/autogen.sh"
    "${TMP_FOLDER}/autogen.sh"
  fi

  if [[ -f "${TMP_FOLDER}/configure" ]]
  then
    bash -c "
    cd \"${TMP_FOLDER}\"
    \"${TMP_FOLDER}/configure\"
    "
  fi

  if [[ -f "${TMP_FOLDER}/src/makefile.unix" ]]
  then
    chmod +x "${TMP_FOLDER}/src/leveldb/build_detect_platform"
    make -C "${TMP_FOLDER}/src/leveldb" libleveldb.a libmemenv.a

    make -C "${TMP_FOLDER}/src" -f makefile.unix USE_UPNP=
  else
    make -C "${TMP_FOLDER}"
  fi

  PROJECT_DIR=$( echo "${GITHUB_REPO}" | tr '/' '_' )
  mkdir -p "/var/multi-masternode-data/${PROJECT_DIR}/src"
  if [[ -f "${TMP_FOLDER}/src/${DAEMON_BIN}" ]]
  then
    cp "${TMP_FOLDER}/src/${DAEMON_BIN}" "/var/multi-masternode-data/${PROJECT_DIR}/src/${DAEMON_BIN}"
  fi
  if [[ -f "${TMP_FOLDER}/src/${CONTROLLER_BIN}" ]]
  then
    cp "${TMP_FOLDER}/src/${CONTROLLER_BIN}" "/var/multi-masternode-data/${PROJECT_DIR}/src/${CONTROLLER_BIN}"
  fi
}

USER_FUNCTION_FOR_ALL_MASTERNODES () {
  echo "Updating .bashrc file."
  UPDATE_USER_FILE "${_MN_DAEMON_MASTER_FUNC}" "_masternode_dameon_2" "${HOME}/.bashrc" "/var/multi-masternode-data/___temp.sh"
  UPDATE_USER_FILE "${_MN_DAEMON_COMP}" "_masternode_dameon_2_completions" "${HOME}/.bashrc" "/var/multi-masternode-data/___temp.sh"
  UPDATE_USER_FILE "${_ALL_MN_RUN}" "all_mn_run" "${HOME}/.bashrc" "/var/multi-masternode-data/___temp.sh"
  UPDATE_USER_FILE "${_DAEMON_MN_RUN}" "_daemon_mn_run" "${HOME}/.bashrc" "/var/multi-masternode-data/___temp.sh"
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
  DAEMON_DOWNLOAD=$( echo "${DAEMON_DOWNLOAD}" | tr "\n" " " )
  DATA_DIRECTORY=${5}
  CONF_DROPBOX_ADDNODES=${6}
  CONF_DROPBOX_BOOTSTRAP=${7}
  CONF_DROPBOX_BLOCKS_N_CHAINS=${8}
  RELEASE_INFO_OR_FORCE=${9}

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

  if [[ $( grep -c '_masternode_dameon_2' "${HOME}/.bashrc" ) -gt 1 ]]
  then
    USER_FUNCTION_FOR_ALL_MASTERNODES
  fi
  # shellcheck source=/root/.bashrc
  source ~/.bashrc
  if [[ -f /var/multi-masternode-data/.bashrc ]]
  then
    # shellcheck disable=SC1091
    source /var/multi-masternode-data/.bashrc
  fi
  if [[ -f /var/multi-masternode-data/___temp.sh ]]
  then
    # shellcheck disable=SC1091
    source /var/multi-masternode-data/___temp.sh
  fi

  PROJECT_DIR_UPDATE=$( echo "${GITHUB_REPO}" | tr '/' '_' )
  # Download the latest binaries.
  if [[ "${RELEASE_INFO_OR_FORCE}" == 'force_skip_download' ]]
  then
    DAEMON_DOWNLOAD_SUPER "${GITHUB_REPO}" "${BIN_BASE}" "${DAEMON_DOWNLOAD}" force
  else
    DAEMON_DOWNLOAD_SUPER "${GITHUB_REPO}" "${BIN_BASE}" "${DAEMON_DOWNLOAD}" "${RELEASE_INFO_OR_FORCE}"
  fi
  if [[ $( ldd /var/multi-masternode-data/"${PROJECT_DIR_UPDATE}"/src/"${DAEMON_BIN}" | grep -cF 'not found' ) -ne 0 ]] || [[ $( ldd /var/multi-masternode-data/"${PROJECT_DIR_UPDATE}"/src/"${CONTROLLER_BIN}" | grep -cF 'not found' ) -ne 0 ]]
  then
    INITIAL_PROGRAMS
  fi

  echo
  echo
  while read -r USR_HOME_DIR
  do
    if [[ "${#USR_HOME_DIR}" -lt 3 ]]
    then
      continue
    fi

    MN_USRNAME=$( basename "${USR_HOME_DIR}" )
    if [ "$( type "${MN_USRNAME}" 2>/dev/null | grep -c '_masternode_dameon_2' )" -eq 0 ] || [[ $( "${MN_USRNAME}" daemon ) != "${DAEMON_BIN}" ]]
    then
      continue
    fi
    echo "Working on ${MN_USRNAME}"
    USR_HOME="$( getent passwd "${MN_USRNAME}" | cut -d: -f6 )"
    CONF_FILE=$( "${MN_USRNAME}" conf loc )
    if [[ -z "${CONF_FILE}" ]]
    then
      CONF_FILE="${USR_HOME}/${DATA_DIRECTORY}/${CONF_FILE_TOP}"
    fi
    echo "Target configuation file ${CONF_FILE}"

    if [[ $( grep -c 'github_repo' < "${CONF_FILE}" ) -eq 0 ]]
    then
      echo "Adding github_repo=${GITHUB_REPO}"
      echo -e "\\n# github_repo=${GITHUB_REPO}" >> "${CONF_FILE}"
    fi
    if [[ $( grep -c 'bin_base' < "${CONF_FILE}" ) -eq 0 ]]
    then
      echo "Adding bin_base=${BIN_BASE}"
      echo -e "\\n# bin_base=${BIN_BASE}"  >> "${CONF_FILE}"
    fi
    if [[ $( grep -c 'daemon_download' < "${CONF_FILE}" ) -eq 0 ]]
    then
      echo "Adding daemon_download=${DAEMON_DOWNLOAD}"
      echo -e "\\n# daemon_download=${DAEMON_DOWNLOAD}"  >> "${CONF_FILE}"
    fi
    if [[ $( grep -c 'nodelist' < "${CONF_FILE}" ) -eq 0 ]]
    then
      echo "Adding nodelist=${CONF_DROPBOX_ADDNODES}"
      echo -e "\\n# nodelist=${CONF_DROPBOX_ADDNODES}"  >> "${CONF_FILE}"
    fi
    if [[ $( grep -c 'bootstrap' < "${CONF_FILE}" ) -eq 0 ]]
    then
      echo "Adding bootstrap=${CONF_DROPBOX_BOOTSTRAP}"
      echo -e "\\n# bootstrap=${CONF_DROPBOX_BOOTSTRAP}"  >> "${CONF_FILE}"
    fi
    if [[ $( grep -c 'blocks_n_chains' < "${CONF_FILE}" ) -eq 0 ]]
    then
      echo "Adding blocks_n_chains=${CONF_DROPBOX_BLOCKS_N_CHAINS}"
      echo -e "\\n# blocks_n_chains=${CONF_DROPBOX_BLOCKS_N_CHAINS}"  >> "${CONF_FILE}"
    fi

    if [[ $( sudo su "${MN_USRNAME}" -c 'crontab -l' 2>/dev/null | grep -cF "${MN_USRNAME} update_daemon 2>&1" ) -eq 0  ]]
    then
      echo 'Setting up crontab for auto updating in the future.'
      MINUTES=$((RANDOM % 60))
      sudo su "${MN_USRNAME}" -c " ( crontab -l 2>/dev/null ; echo \"${MINUTES} */6 * * * bash -ic 'source /var/multi-masternode-data/.bashrc; ${MN_USRNAME} update_daemon 2>&1' 2>/dev/null\" ) | crontab - "
    fi

    if [[ $( sudo su "${MN_USRNAME}" -c 'crontab -l' | grep -cF "${MN_USRNAME} mnfix 2>&1" ) -eq 0  ]]
    then
      echo 'Setting up crontab to auto fix the daemon.'
      MINUTES=$(( RANDOM % 19 ))
      MINUTES_A=$(( MINUTES + 20 ))
      MINUTES_B=$(( MINUTES + 40 ))
      rm -f "${USR_HOME}/mnfix.log"
      sudo su "${MN_USRNAME}" -c "touch \"${USR_HOME}/mnfix.log\""
      sudo su "${MN_USRNAME}" -c " ( crontab -l ; echo \"${MINUTES},${MINUTES_A},${MINUTES_B} * * * * bash -ic 'source /var/multi-masternode-data/.bashrc; ${MN_USRNAME} mnfix 2>&1' 2>&1 >> ${USR_HOME}/mnfix.log \" ) | crontab - "
    fi
    sudo sh -c "find /var/multi-masternode-data/${PROJECT_DIR_UPDATE}/blocks_n_chains/ -type f -exec chmod 666 {} \\;"
    sudo sh -c "find /var/multi-masternode-data/${PROJECT_DIR_UPDATE}/blocks_n_chains/ -type d -exec chmod 777 {} \\;"

    if [[ ! -z "${EXPLORER_URL}" ]]
    then
      USER_FUNCTION_FOR_MASTERNODE "${MN_USRNAME}" "${HOME}/.bashrc" "/var/multi-masternode-data/___temp.sh"
    fi
    USER_FUNCTION_FOR_MN_CLI "${CONF}" "${CONTROLLER_BIN}" "${DAEMON_BIN}" "${EXPLORER_URL}" "${BAD_SSL_HACK}" "${HOME}/.bashrc" "/var/multi-masternode-data/___temp.sh"

    # Add libs if missing.
    if [[ $( ldd /var/multi-masternode-data/"${PROJECT_DIR_UPDATE}"/src/"${DAEMON_BIN}" | grep -cF 'not found' ) -ne 0 ]] || [[ $( ldd /var/multi-masternode-data/"${PROJECT_DIR_UPDATE}"/src/"${CONTROLLER_BIN}" | grep -cF 'not found' ) -ne 0 ]]
    then
      INITIAL_PROGRAMS
    fi

    "${MN_USRNAME}" update_daemon "${RELEASE_INFO_OR_FORCE}"

    PID_MN=$( "${MN_USRNAME}" pid )
    if [[  -z "${PID_MN}" ]]
    then
      continue
    fi

    "${MN_USRNAME}" wait_for_loaded "${ARG6}"
    "${MN_USRNAME}" blockcheck
    if [[ $( "${MN_USRNAME}" blockcheck 2>/dev/null | sed '/^[[:space:]]*$/d' | wc -l ) -gt 1 ]]
    then
      stty sane 2>/dev/null
      REPLY=y
      read -r -p $'Blockcheck looks bad, reindex? \e[7m(y/n)\e[0m? ' -e -i "${REPLY}" input 2>&1
      REPLY="${input:-$REPLY}"

      if [[ $REPLY =~ ^[Yy] ]]
      then
        "${MN_USRNAME}" stop
        "${MN_USRNAME}" remove_addnode
        "${MN_USRNAME}" reindex
        "${MN_USRNAME}" start "${ARG6}"
        "${MN_USRNAME}" sync "" "${ARG6}"
      fi
    fi

  done <<< "$( cut -d: -f1 /etc/passwd | getent passwd | cut -d: -f6 | sort -h )"

  echo
  echo
  echo "Getting MD5 of ${DAEMON_BIN} and ${CONTROLLER_BIN}."
  DAEMON_MD5=$( md5sum "/var/multi-masternode-data/${PROJECT_DIR_UPDATE}/src/${DAEMON_BIN}" | awk '{print $1}' )
  CONTROLLER_MD5=$( md5sum "/var/multi-masternode-data/${PROJECT_DIR_UPDATE}/src/${CONTROLLER_BIN}" | awk '{print $1}' )

  # Get running processes.
  RUNNING_DAEMON_USERS=$( sudo ps axo etimes,pid,user:32,command | grep "[${DAEMON_BIN:0:1}]${DAEMON_BIN:1}" | grep -v "bash" | grep -v "watch" )

  # Get real path for pid.
  RUNNING_DAEMON_USERS_NEW=''
  while read -r TIME PID_RUNNING USER_RUNNING A B C D E F G H I J K
  do
    PID_PATH=$( sudo readlink -f "/proc/${PID_RUNNING}/exe" )
    if [[ "${#PID_PATH}" -gt 4 ]]
    then
      RUNNING_DAEMON_USERS_NEW="${RUNNING_DAEMON_USERS_NEW}
${TIME} ${PID_RUNNING} ${USER_RUNNING} ${PID_PATH} ${B} ${C} ${D} ${E} ${F} ${G} ${H} ${I} ${J} ${K}"
    else
      RUNNING_DAEMON_USERS_NEW="${RUNNING_DAEMON_USERS_NEW}
${TIME} ${PID_RUNNING} ${USER_RUNNING} ${A} ${B} ${C} ${D} ${E} ${F} ${G} ${H} ${I} ${J} ${K}"
    fi
  done <<< "${RUNNING_DAEMON_USERS}"
  RUNNING_DAEMON_USERS_NEW=$( echo "${RUNNING_DAEMON_USERS_NEW}" | column -t )

  echo
  echo "Searching for ${CONTROLLER_BIN} on the filesystem."
  sudo find / -xdev -executable -name "${CONTROLLER_BIN}" 2>/dev/null | while read -r FILENAME
  do
    echo "Checking ${FILENAME}"
    VERSION_LOCAL=$( timeout --signal=SIGKILL 9s "${FILENAME}" --help 2>/dev/null | head -n 1 | sed 's/[^0-9.]*\([0-9.]*\).*/\1/' )
    if [[ -z "${VERSION_LOCAL}" ]]
    then
      VERSION_LOCAL=$( timeout --signal=SIGKILL 9s "${FILENAME}" -version 2>/dev/null | sed 's/[^0-9.]*\([0-9.]*\).*/\1/' )
    fi

    CONTROLLER_MD5_OLD=$( md5sum "${FILENAME}" | awk '{print $1}' )
    if [[ "${CONTROLLER_MD5}" != "${CONTROLLER_MD5_OLD}" ]]
    then
      echo "${FILENAME} needs to be updated: ${VERSION_LOCAL}"

      cp "/var/multi-masternode-data/${PROJECT_DIR_UPDATE}/src/${CONTROLLER_BIN}" "${FILENAME}"
      VERSION_LOCAL=$( timeout --signal=SIGKILL 9s "${FILENAME}" --help 2>/dev/null | head -n 1 | sed 's/[^0-9.]*\([0-9.]*\).*/\1/' )
      if [[ -z "${VERSION_LOCAL}" ]]
      then
        VERSION_LOCAL=$( timeout --signal=SIGKILL 9s "${FILENAME}" -version 2>/dev/null | sed 's/[^0-9.]*\([0-9.]*\).*/\1/' )
      fi
      echo "${FILENAME} should be updated now: ${VERSION_LOCAL}"
    else
      echo "is the correct version: ${VERSION_LOCAL}"
    fi
  done

  echo
  echo "Searching for ${DAEMON_BIN} on the filesystem."
  sudo find / -xdev -executable -name "${DAEMON_BIN}" 2>/dev/null | while read -r FILENAME
  do
    echo "Checking ${FILENAME}"
    VERSION_LOCAL=$( timeout --signal=SIGKILL 9s "${FILENAME}" --help 2>/dev/null | head -n 1 | sed 's/[^0-9.]*\([0-9.]*\).*/\1/' )
    if [[ -z "${VERSION_LOCAL}" ]]
    then
      VERSION_LOCAL=$( timeout --signal=SIGKILL 9s "${FILENAME}" -version 2>/dev/null | sed 's/[^0-9.]*\([0-9.]*\).*/\1/' )
    fi

    DAEMON_MD5_OLD=$( md5sum "${FILENAME}" | awk '{print $1}' )
    if [[ "${DAEMON_MD5}" != "${DAEMON_MD5_OLD}" ]]
    then
      echo "${FILENAME} needs to be updated: ${VERSION_LOCAL}"

      BIN_FOLDER=$( dirname "${FILENAME}" )
      CONTROLLER_BIN_LOC="${BIN_FOLDER}/${CONTROLLER_BIN}"

      if [[ $( echo "${RUNNING_DAEMON_USERS_NEW}" | grep -c "[[:space:]]${FILENAME}" ) -eq 0 ]]
      then
        cp "/var/multi-masternode-data/${PROJECT_DIR_UPDATE}/src/${DAEMON_BIN}" "${FILENAME}"
      else
        # Get extra parameters.
        EXTRA_PARAMETERS=$( echo "${RUNNING_DAEMON_USERS_NEW}" | grep "[[:space:]]${FILENAME}" | grep -o "/${DAEMON_BIN}.*" | sed "s/^\/${DAEMON_BIN}//g" | sed "s/\s\(-\)\{0,2\}daemon//g"  | sed "s/\s\(-\)\{0,2\}reindex//g" | sed "s/\s\(-\)\{0,2\}rescan//g" | sed "s/\s\(-\)\{0,2\}reindexzerocoin//g" | sed "s/\s\(-\)\{0,2\}zapwallettxes\=1//g" | sed "s/\s\(-\)\{0,2\}zapwallettxes\=2//g" )
        # Get pid of daemon.
        PID_TO_KILL=$( echo "${RUNNING_DAEMON_USERS_NEW}" | grep "[[:space:]]${FILENAME}" | awk '{print $2}' )
        USR_OF_PROCESS=$( echo "${RUNNING_DAEMON_USERS_NEW}" | grep "[[:space:]]${FILENAME}" | awk '{print $3}' )
        ps "${PID_TO_KILL}"

        # Stop daemon.
        echo "Stopping ${CONTROLLER_BIN_LOC}"
        if [[ "${USR_OF_PROCESS}" != 'root' ]]
        then
          sudo su "${USR_OF_PROCESS}" -c "${CONTROLLER_BIN_LOC} ${EXTRA_PARAMETERS} stop"
        fi
        # shellcheck disable=SC2086
        "${CONTROLLER_BIN_LOC}" ${EXTRA_PARAMETERS} stop

        # Use systemctl if it exists.
        SYSTEMD_FULLFILE=$( grep -lrE "ExecStart=${FILENAME}.*-daemon" /etc/systemd/system/ | head -n 1 )
        if [[ ! -z "${SYSTEMD_FULLFILE}" ]]
        then
          SYSTEMD_FILE=$( basename "${SYSTEMD_FULLFILE}" )
        fi
        if [[ ! -z "${SYSTEMD_FILE}" ]]
        then
          systemctl stop "${SYSTEMD_FILE}"
        fi

        # Wait for pid to be done.
        COUNTER=0
        if [[ ${ARG6} == 'y' ]]
        then
          echo "Waiting for ${FILENAME} to shutdown (pid ${PID_TO_KILL})"
        fi
        while [[ $( ps "${PID_TO_KILL}" | tail -n +2 | wc -c ) -gt 10 ]]
        do
          if [[ ${ARG6} == 'y' ]]
          then
            printf "."
          else
            echo -e "\\r${SP:i++%${#SP}:1} Waiting for ${FILENAME} to shutdown (pid ${PID_TO_KILL}) \\c"
          fi
          COUNTER=$((COUNTER+1))
          kill "${PID_TO_KILL}"
          if [[ "${COUNTER}" -gt 99 ]]
          then
            kill -9 "${PID_TO_KILL}" >/dev/null 2>&1
          fi
          if [[ ${CAN_SUDO} =~ ${RE} ]] && [[ "${CAN_SUDO}" -gt 2 ]]
          then
            sudo kill "${PID_TO_KILL}" >/dev/null 2>&1
            if [[ "${COUNTER}" -gt 99 ]]
            then
              sudo kill -9 "${PID_TO_KILL}" >/dev/null 2>&1
            fi
          fi
          if [[ "${COUNTER}" -gt 111 ]]
          then
            break
          fi
          sleep 0.5
        done
        echo

        # Copy new version.
        sleep 1
        echo "Copying files"
        cp "/var/multi-masternode-data/${PROJECT_DIR_UPDATE}/src/${DAEMON_BIN}" "${FILENAME}"

        # Start daemon up again.
        echo "${FILENAME} --daemon ${EXTRA_PARAMETERS}"
        sleep 1

        # Use systemctl if it exists.
        if [[ ! -z "${SYSTEMD_FILE}" ]]
        then
          systemctl start "${SYSTEMD_FILE}"
        fi

        if [[ "${USR_OF_PROCESS}" != 'root' ]]
        then
          sudo su "${USR_OF_PROCESS}" -c "${FILENAME} --daemon ${EXTRA_PARAMETERS}"
        else
          # shellcheck disable=SC2086
          "${FILENAME}" --daemon ${EXTRA_PARAMETERS}
        fi
      fi

      VERSION_LOCAL=$( timeout --signal=SIGKILL 9s "${FILENAME}" --help 2>/dev/null | head -n 1 | sed 's/[^0-9.]*\([0-9.]*\).*/\1/' )
      if [[ -z "${VERSION_LOCAL}" ]]
      then
        VERSION_LOCAL=$( timeout --signal=SIGKILL 9s "${FILENAME}" -version 2>/dev/null | sed 's/[^0-9.]*\([0-9.]*\).*/\1/' )
      fi
      echo "${FILENAME} should be updated now: ${VERSION_LOCAL}"
    else
      echo "is the correct version: ${VERSION_LOCAL}"
    fi
  done

}
sleep 0.1

DAEMON_SETUP_THREAD () {
CHECK_SYSTEM
if [ $? == "1" ]
then
  return 1 2>/dev/null || exit 1
fi

# Install JQ if not installed
if [ ! -x "$( command -v jq )" ]
then
  # Start sub process to install jq.
  sudo su -c 'bash -c "
    WAIT_FOR_APT_GET () {
      while [[ $( sudo lslocks -n -o COMMAND,PATH | grep -c \"apt-get\|dpkg\|unattended-upgrades\" ) -ne 0 ]]; do sleep 0.5; done
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

rm -f /var/multi-masternode-data/___temp.sh
# m c a r p e r
UPDATE_USER_FILE "${_DENYHOSTS_UNBLOCK}" "denyhosts_unblock" "${HOME}/.bashrc" "/var/multi-masternode-data/___temp.sh"
USER_FUNCTION_FOR_ALL_MASTERNODES

if [ ! -x "$( command -v netcat )" ] || [ ! -x "$( command -v bc )" ] || [ ! -x "$( command -v netstat )" ]
then
  WAIT_FOR_APT_GET
  timeout 30s sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq \
      bc \
      netcat \
      net-tools
  if [ ! -x "$( command -v netcat )" ] || [ ! -x "$( command -v bc )" ] || [ ! -x "$( command -v netstat )" ]
  then
    WAIT_FOR_APT_GET
    timeout 30s sudo DEBIAN_FRONTEND=noninteractive add-apt-repository universe
    WAIT_FOR_APT_GET
    timeout 60s sudo DEBIAN_FRONTEND=noninteractive apt-get update -yq
    WAIT_FOR_APT_GET
    timeout 30s sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq \
      bc \
      netcat \
      net-tools
  fi
fi

stty sane 2>/dev/null
ASCII_ART

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

if [[ "${NO_MN}" -eq 1 ]]
then
  MULTI_IP_MODE=0
  SKIP_CONFIRM='y'
  SENTINEL_GITHUB=''
  SENTINEL_CONF_START=''
  MNSYNC_WAIT_FOR=''
  DAEMON_CONNECTIONS=3
  DAEMON_PREFIX=$( echo "${DAEMON_PREFIX}" | cut -f1 -d "_")
  DAEMON_PREFIX="${DAEMON_PREFIX}_n"
  DAEMON_CYCLE=0
fi

# Set Defaults
PORTB=''
INET=''
PUBIPADDRESS=''
PRIVIPADDRESS=''
echo "Using wget to get public IP..."
PUB_PRIV_IPS=$( FIND_OPEN_PORT_IPV46 "${DEFAULT_PORT}" "${IPV4}" "${IPV6}" "${TOR}" "${MULTI_IP_MODE}" "${DAEMON_BIN}" )
if [[ -z "${PUB_PRIV_IPS}" ]]
then
    FIND_OPEN_PORT_IPV46 "${DEFAULT_PORT}" "${IPV4}" "${IPV6}" "${TOR}" "${MULTI_IP_MODE}" "${DAEMON_BIN}" 1
    echo "${DEFAULT_PORT}" "${IPV4}" "${IPV6}" "${TOR}" "${MULTI_IP_MODE}" "${DAEMON_BIN}"
    echo
    echo "Port already used by another service."
    echo "Please add another IP Address."
    echo "Or open up port ${DEFAULT_PORT} for ${DAEMON_NAME}."
    echo
    echo "Process using port ${DEFAULT_PORT}:"
    USED_PORT=$( sudo -n ss -lpn 2>/dev/null  | grep ":${DEFAULT_PORT} " )
    PIDS=$( echo "${USED_PORT}" | grep -oE "pid=[0-9]+" | cut -d '=' -f2 )
    while read -r PID
    do
      ps -up "${PID}"
    done <<< "${PIDS}"
    echo "${USED_PORT}"
    echo
    echo "If you just added a new IPv4 address,"
    echo "you might need to reboot the box and try running the script again."
    echo
    return 1 2>/dev/null
fi

INET="$( echo "${PUB_PRIV_IPS}" | awk '{print $1}' )"
PUBIPADDRESS="$( echo "${PUB_PRIV_IPS}" | awk '{print $2}' )"
PRIVIPADDRESS="$( echo "${PUB_PRIV_IPS}" | awk '{print $3}' )"
PORTB="$( echo "${PUB_PRIV_IPS}" | awk '{print $4}' )"

IPV6USED=''
if [[ "${INET}" == "6" ]]
then
  IPV6USED=1
fi

# Set alias as the hostname.
MNALIAS="$( hostname )"

if [ -x "$( command -v ufw )" ]
then
  # Open up port.
  sudo ufw allow "${DEFAULT_PORT}" >/dev/null 2>&1
fi

# Find open port.
echo "Searching for an unused port for rpc"
PORTA=$( FIND_FREE_PORT "${PRIVIPADDRESS}" | tail -n 1 )


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
if [[ ${#ARG4} -eq 51 ]] || [[ ${#ARG4} -eq 50 ]]
then
  MNKEY=${ARG4}
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
  if [[ ${ARG2} =~ $RE ]] && [[ ${#ARG2} -lt 3 ]]
  then
    OUTPUTIDX=${ARG2}
    ARG2=''
  fi
fi
if [[ ${#ARG2} -eq 64 ]]
then
  TXHASH=${ARG2}
  ARG2=''
  if [[ ${ARG3} =~ $RE ]] && [[ ${#ARG3} -lt 3 ]]
  then
    OUTPUTIDX=${ARG3}
    ARG3=''
  fi
fi
if [[ ${#ARG3} -eq 64 ]]
then
  TXHASH=${ARG3}
  ARG3=''
  if [[ ${ARG4} =~ $RE ]] && [[ ${#ARG4} -lt 3 ]]
  then
    OUTPUTIDX=${ARG4}
    ARG4=''
  fi
fi
if [[ ${#ARG4} -eq 64 ]]
then
  TXHASH=${ARG4}
  ARG4=''
  if [[ ${ARG5} =~ $RE ]] && [[ ${#ARG5} -lt 3 ]]
  then
    OUTPUTIDX=${ARG5}
    ARG5=''
  fi
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

if [[ "${NO_MN}" -eq 0 ]]
then
  echo "${DAEMON_NAME} daemon ${MASTERNODE_NAME} setup script"
  echo
fi

WEBBLOCK=''

stty sane 2>/dev/null
# Ask for txhash.
if [ "${ARG2}" != "0" ] && [ -z "${SKIP_CONFIRM}" ]
then
  while :
  do
    echo "Collateral required: "
    echo "${COLLATERAL}"
    echo
    echo "In your wallet, go to tools -> debug -> console and type:"
    echo "${MASTERNODE_CALLER}outputs"
    echo "Paste the info for this ${MASTERNODE_NAME}; or leave it blank to skip and do it later."
    if [ -z "${TXHASH}" ]
    then
      stty sane 2>/dev/null
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
        WEBBLOCK=$( timeout --signal=SIGKILL 15s wget -4qO- -T 15 -t 2 -o- "${EXPLORER_URL}block/latest" "${BAD_SSL_HACK}" | jq -r '.result.height' | tr -d '[:space:]' 2>/dev/null )
      else
        WEBBLOCK=$( timeout --signal=SIGKILL 15s wget -4qO- -T 15 -t 2 -o- "${EXPLORER_URL}${EXPLORER_BLOCKCOUNT_PATH}" "${BAD_SSL_HACK}" | tr -d '[:space:]' )
      fi

      if [[ $( echo "${WEBBLOCK}" | grep -c 'data' ) -gt 0 ]]
      then
        WEBBLOCK=$( echo "${WEBBLOCK}" | jq -r '.data' 2>/dev/null )
      fi

      if [[ $( echo "${WEBBLOCK}" | tr -d '[:space:]') =~ $RE ]]
      then
        WEBBLOCK=$( echo "${WEBBLOCK} ${EXPLORER_BLOCKCOUNT_OFFSET}" | bc )
      fi
      sleep "${EXPLORER_SLEEP}"
    fi
    if ! [[ ${WEBBLOCK} =~ ${RE} ]] || [[ -z "${EXPLORER_RAWTRANSACTION_PATH}" ]]
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
          stty sane 2>/dev/null
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

    echo "Current blockcount ${WEBBLOCK}"
    echo "Downloading transaction from the explorer."

    if [[ "${EXPLORER_URL}" == https://www.coinexplorer.net/api/v1/* ]]
    then
      echo "${EXPLORER_URL}transaction?txid=${TXHASH}"
      OUTPUTIDX_RAW=$( wget -4qO- -T 15 -t 2 -o- "${EXPLORER_URL}transaction?txid=${TXHASH}" "${BAD_SSL_HACK}" | jq '.result' 2>/dev/null )
      sleep "${EXPLORER_SLEEP}"
    else
      URL=$( echo "${EXPLORER_URL}${EXPLORER_RAWTRANSACTION_PATH}${TXHASH}${EXPLORER_RAWTRANSACTION_PATH_SUFFIX}" | tr -d '[:space:]' )
      echo "${URL}"
      OUTPUTIDX_RAW=$( wget -4qO- -T 15 -t 2 -o- "${URL}" "${BAD_SSL_HACK}" )
      sleep "${EXPLORER_SLEEP}"

      OUTPUTIDX_RAW_ALT=$( echo "$OUTPUTIDX_RAW" | jq ".data" 2>/dev/null )
      if [[ $( echo "${OUTPUTIDX_RAW_ALT}" | grep -c 'vin' ) -gt 0 ]]
      then
        OUTPUTIDX_RAW=${OUTPUTIDX_RAW_ALT}
      fi

      OUTPUTIDX_RAW_ALT=$( echo "${OUTPUTIDX_RAW}" | jq '.tx' 2>/dev/null )
      if [[ $( echo "${OUTPUTIDX_RAW_ALT}" | grep -c 'vin' ) -gt 0 ]]
      then
        OUTPUTIDX_RAW=${OUTPUTIDX_RAW_ALT}
      fi

      OUTPUTIDX_RAW_ALT=$( echo "${OUTPUTIDX_RAW}" | jq '.tx' 2>/dev/null )
      if [[ $( echo "${OUTPUTIDX_RAW_ALT}" | grep -c 'vin' ) -gt 0 ]]
      then
        OUTPUTIDX_RAW=${OUTPUTIDX_RAW_ALT}
      fi
    fi
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
    COLLATERAL_FOUND=0
    while read -r COLLATERAL_LEVEL
    do
      COLLATERAL_ADJUSTED=$( echo "${COLLATERAL_LEVEL} * ${EXPLORER_AMOUNT_ADJUST}" | bc )
      OUTPUTIDX_WEB=$( echo "${OUTPUTIDX_RAW}" | tr '[:upper:]' '[:lower:]' | jq ".vout[] | select( (.value)|tonumber == ${COLLATERAL_ADJUSTED} ) | .n" 2>/dev/null )
      OUTPUTIDX_COUNT=$( echo "${OUTPUTIDX_WEB}" | sed '/^[[:space:]]*$/d' | wc -l )
      if [[ ! -z "${OUTPUTIDX_COUNT}" ]] && [[ ! -z "${OUTPUTIDX_WEB}" ]]
      then
        COLLATERAL_FOUND=1
        break
      fi
      OUTPUTIDX_WEB=$( echo "${OUTPUTIDX_RAW}" | tr '[:upper:]' '[:lower:]' | jq ".outputs | to_entries[] | select( (.value.amount)|tonumber == ${COLLATERAL_ADJUSTED} ) | .key" 2>/dev/null )
      OUTPUTIDX_COUNT=$( echo "${OUTPUTIDX_WEB}" | sed '/^[[:space:]]*$/d' | wc -l )
      if [[ ! -z "${OUTPUTIDX_COUNT}" ]] && [[ ! -z "${OUTPUTIDX_WEB}" ]]
      then
        COLLATERAL_FOUND=1
        break
      fi

    done <<< "${COLLATERAL}"

    if [[ "${COLLATERAL_FOUND}" -eq 0 ]]
    then
      echo
      echo "txhash does not contain the collateral: ${TXHASH}."
      echo
      TXHASH=''
      continue
    fi

    # Check the address.
    OUTPUT_INDEXES=''
    while read -r OUTPUTIDX_ALT
    do
      TEMP_FILE=$( mktemp )
      OUTPUTIDX_ALT=$( echo "${OUTPUTIDX_ALT}" | sed '/^[[:space:]]*$/d' )
      STILL_GOOD=$( CHECK_COLLATERAL_INDEX "${OUTPUTIDX_RAW}" "${TXHASH}" "${OUTPUTIDX_ALT}" "${COLLATERAL}" "${BAD_SSL_HACK}" "${TEMP_FILE}" )
      STILL_GOOD=$( echo "${STILL_GOOD}" | sed '/^[[:space:]]*$/d' )
      if [[ "${STILL_GOOD}" == "${OUTPUTIDX_ALT}" ]]
      then
        OUTPUT_INDEXES=$( echo -e "${OUTPUT_INDEXES}\\n${OUTPUTIDX_ALT}" )
      fi
    done <<< "${OUTPUTIDX_WEB}"
    OUTPUTIDX_WEB=$( echo "${OUTPUT_INDEXES}" | sed '/^[[:space:]]*$/d' )
    OUTPUTIDX_COUNT=$( echo "${OUTPUTIDX_WEB}" | sed '/^[[:space:]]*$/d' | wc -l )

    if [[ "${OUTPUTIDX_COUNT}" -eq 0 ]]
    then
      echo
      echo "txhash no longer contains the collateral: ${TXHASH}."
      echo
      TXHASH=''
      continue
    fi

    if [[ "${OUTPUTIDX_COUNT}" -eq 1 ]]
    then
      OUTPUTIDX=$( echo "${OUTPUTIDX_WEB}" | sed '/^[[:space:]]*$/d' )
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
          stty sane 2>/dev/null
          read -r -e -i "${OUTPUTIDX}" -p "outputidx: " input 2>&1
        else
          echo "outputidx: ${OUTPUTIDX}"
          sleep 0.5
        fi
        OUTPUTIDX_ALT="${input:-$OUTPUTIDX_ALT}"
        OUTPUTIDX_ALT="$( echo -e "${OUTPUTIDX_ALT}" | tr -d '[:space:]' | sed 's/\://g' | sed 's/\"//g' | sed 's/outputidx//g' | sed 's/outidx//g' | sed 's/,//g' )"
        if [[ $( echo "${OUTPUTIDX_WEB}" | grep -c "^${OUTPUTIDX_ALT}$" ) -gt 0 ]]
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

    # Make sure it didn't get staked.
    if [[ -s "${TEMP_FILE}.${OUTPUTIDX}" ]] && [[ -z "${MN_WALLET_ADDR_DETAILS}" ]]
    then
      MN_WALLET_ADDR_DETAILS="$( cat "${TEMP_FILE}.${OUTPUTIDX}" )"
    fi

    TXIDS_FOR_ADDR=$( echo "${MN_WALLET_ADDR_DETAILS}" | jq -r ".last_txs[][] " 2>/dev/null | grep -o -w -E '[[:alnum:]]{64}' | grep -vE "vin|vout" )
    if [[ $( echo "${TXIDS_FOR_ADDR}" | grep -c "${TXHASH}" ) -gt 0 ]]
    then
      TXIDS_AFTER_COLLATERAL=$( echo "${TXIDS_FOR_ADDR}" | sed -n -e "/${TXHASH}/,\$p" | grep -v "${TXHASH}" )
    else
      TXIDS_AFTER_COLLATERAL="${TXIDS_FOR_ADDR}"
    fi
    if [ -z "${TXIDS_AFTER_COLLATERAL}" ]
    then
      echo "${TXHASH} is good"
      break
    fi

    echo
    echo "Check each tx after the given tx to see if it was used as an input."
    COUNTER=0
    while read -r OTHERTXIDS
    do
      COUNTER=$(( COUNTER+1 ))
      echo "Downloading transaction from the explorer."
      URL=$( echo "${EXPLORER_URL}${EXPLORER_RAWTRANSACTION_PATH}${OTHERTXIDS}${EXPLORER_RAWTRANSACTION_PATH_SUFFIX}" | tr -d '[:space:]' )
      echo "${URL}"
      OUTPUTIDX_RAW=$( wget -4qO- -T 15 -t 2 -o- "${URL}" "${BAD_SSL_HACK}" | tr '[:upper:]' '[:lower:]' )
      sleep "${EXPLORER_SLEEP}"

      OUTPUTIDX_RAW_ALT=$( echo "$OUTPUTIDX_RAW" | jq ".data" 2>/dev/null )
      if [[ $( echo "${OUTPUTIDX_RAW_ALT}" | grep -c 'vin' ) -gt 0 ]]
      then
        OUTPUTIDX_RAW=${OUTPUTIDX_RAW_ALT}
      fi

      OUTPUTIDX_RAW_ALT=$( echo "$OUTPUTIDX_RAW" | jq ".tx" 2>/dev/null )
      if [[ $( echo "${OUTPUTIDX_RAW_ALT}" | grep -c 'vin' ) -gt 0 ]]
      then
        OUTPUTIDX_RAW=${OUTPUTIDX_RAW_ALT}
      fi
      TX_HAS_BEEN_FOUNT=$( echo "$OUTPUTIDX_RAW" | jq ".vin[] | select( .txid == \"${TXHASH}\" )" )
      if [[ "${#TX_HAS_BEEN_FOUNT}" -gt 10 ]]
      then
        VOUT_TX=$( echo "${TX_HAS_BEEN_FOUNT}" | jq '.vout' )
        if [[ "${VOUT_TX}" -gt 0 ]] || [[ "${VOUT_TX}" == null ]]
        then
          echo
          echo "txid no longer holds the collateral; staked or split up: ${TXHASH}."
          echo "txid that broke up the collateral"
          echo "${OTHERTXIDS}"
          echo "${URL}"
          echo
          TXHASH=''
          break
        fi
      fi
      if [[ "${COUNTER}" -gt 10 ]]
      then
        echo
        echo "More than 10 transactions checked; assuming it's good."
        echo
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

if [ ! -z "${SKIP_CONFIRM}" ] && [ ! -z "${TXHASH}" ] && [ -z "${OUTPUTIDX}" ]
then
  echo "Collateral required: "
  echo "${COLLATERAL}"
  echo

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
  else
    if [[ ! -z "${EXPLORER_URL}" ]]
    then
      echo "Getting the block count from the explorer."
      if [[ "${EXPLORER_URL}" == https://www.coinexplorer.net/api/v1/* ]]
      then
        WEBBLOCK=$( timeout --signal=SIGKILL 15s wget -4qO- -T 15 -t 2 -o- "${EXPLORER_URL}block/latest" "${BAD_SSL_HACK}" | jq -r '.result.height' | tr -d '[:space:]' 2>/dev/null )
      else
        WEBBLOCK=$( timeout --signal=SIGKILL 15s wget -4qO- -T 15 -t 2 -o- "${EXPLORER_URL}${EXPLORER_BLOCKCOUNT_PATH}" "${BAD_SSL_HACK}" | tr -d '[:space:]' )
      fi

      if [[ $( echo "${WEBBLOCK}" | grep -c 'data' ) -gt 0 ]]
      then
        WEBBLOCK=$( echo "${WEBBLOCK}" | jq -r '.data' 2>/dev/null )
      fi

      if [[ $( echo "${WEBBLOCK}" | tr -d '[:space:]') =~ $RE ]]
      then
        WEBBLOCK=$( echo "${WEBBLOCK} ${EXPLORER_BLOCKCOUNT_OFFSET}" | bc )
      fi
      sleep "${EXPLORER_SLEEP}"
    fi

    if ! [[ ${WEBBLOCK} =~ ${RE} ]] || [[ -z "${EXPLORER_RAWTRANSACTION_PATH}" ]]
    then
      echo "Explorers output is not good: ${WEBBLOCK}"
      echo
      TXHASH=''
    else
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
        TXHASH=''
      else
        echo "Current blockcount ${WEBBLOCK}"
        echo "Downloading transaction from the explorer."
        if [[ "${EXPLORER_URL}" == https://www.coinexplorer.net/api/v1/* ]]
        then
          echo "${EXPLORER_URL}transaction?txid=${TXHASH}"
          OUTPUTIDX_RAW=$( wget -4qO- -T 15 -t 2 -o- "${EXPLORER_URL}transaction?txid=${TXHASH}" "${BAD_SSL_HACK}" | jq '.result' 2>/dev/null )
          sleep "${EXPLORER_SLEEP}"
        else
          URL=$( echo "${EXPLORER_URL}${EXPLORER_RAWTRANSACTION_PATH}${TXHASH}${EXPLORER_RAWTRANSACTION_PATH_SUFFIX}" | tr -d '[:space:]' )
          echo "${URL}"
          OUTPUTIDX_RAW=$( wget -4qO- -T 15 -t 2 -o- "${URL}" "${BAD_SSL_HACK}" )
          sleep "${EXPLORER_SLEEP}"

          OUTPUTIDX_RAW_ALT=$( echo "$OUTPUTIDX_RAW" | jq ".data" 2>/dev/null )
          if [[ $( echo "${OUTPUTIDX_RAW_ALT}" | grep -c 'vin' ) -gt 0 ]]
          then
            OUTPUTIDX_RAW=${OUTPUTIDX_RAW_ALT}
          fi

          OUTPUTIDX_RAW_ALT=$( echo "${OUTPUTIDX_RAW}" | jq '.tx' 2>/dev/null )
          if [[ $( echo "${OUTPUTIDX_RAW_ALT}" | grep -c 'vin' ) -gt 0 ]]
          then
            OUTPUTIDX_RAW=${OUTPUTIDX_RAW_ALT}
          fi

          OUTPUTIDX_RAW_ALT=$( echo "${OUTPUTIDX_RAW}" | jq '.tx' 2>/dev/null )
          if [[ $( echo "${OUTPUTIDX_RAW_ALT}" | grep -c 'vin' ) -gt 0 ]]
          then
            OUTPUTIDX_RAW=${OUTPUTIDX_RAW_ALT}
          fi
        fi
        JSON_ERROR=$( echo "${OUTPUTIDX_RAW}" | jq . 2>&1 >/dev/null )

        # Make sure txid is valid.
        if [ ! -z "${JSON_ERROR}" ] || [ -z "${OUTPUTIDX_RAW}" ]
        then
          echo
          echo "txhash is not a valid transaction id: ${TXHASH}."
          echo
          TXHASH=''
        else
          # Get the output index.
          COLLATERAL_FOUND=0
          while read -r COLLATERAL_LEVEL
          do
            COLLATERAL_ADJUSTED=$( echo "${COLLATERAL_LEVEL} * ${EXPLORER_AMOUNT_ADJUST}" | bc )
            OUTPUTIDX_WEB=$( echo "${OUTPUTIDX_RAW}" | tr '[:upper:]' '[:lower:]' | jq ".vout[] | select( (.value)|tonumber == ${COLLATERAL_ADJUSTED} ) | .n" 2>/dev/null )
            OUTPUTIDX_COUNT=$( echo "${OUTPUTIDX_WEB}" | sed '/^[[:space:]]*$/d' | wc -l )
            if [[ ! -z "${OUTPUTIDX_COUNT}" ]] && [[ ! -z "${OUTPUTIDX_WEB}" ]]
            then
              COLLATERAL_FOUND=1
              break
            fi
            OUTPUTIDX_WEB=$( echo "${OUTPUTIDX_RAW}" | tr '[:upper:]' '[:lower:]' | jq ".outputs | to_entries[] | select( (.value.amount)|tonumber == ${COLLATERAL_ADJUSTED} ) | .key" 2>/dev/null )
            OUTPUTIDX_COUNT=$( echo "${OUTPUTIDX_WEB}" | sed '/^[[:space:]]*$/d' | wc -l )
            if [[ ! -z "${OUTPUTIDX_COUNT}" ]] && [[ ! -z "${OUTPUTIDX_WEB}" ]]
            then
              COLLATERAL_FOUND=1
              break
            fi
          done <<< "${COLLATERAL}"

          if [[ "${COLLATERAL_FOUND}" -eq 0 ]]
          then
            echo
            echo "txhash does not contain the collateral: ${TXHASH}."
            echo
            TXHASH=''
          else
            # Check the address.
            OUTPUT_INDEXES=''
            while read -r OUTPUTIDX_ALT
            do
              TEMP_FILE=$( mktemp )
              OUTPUTIDX_ALT=$( echo "${OUTPUTIDX_ALT}" | sed '/^[[:space:]]*$/d' )
              STILL_GOOD=$( CHECK_COLLATERAL_INDEX "${OUTPUTIDX_RAW}" "${TXHASH}" "${OUTPUTIDX_ALT}" "${COLLATERAL}" "${BAD_SSL_HACK}" "${TEMP_FILE}" )
              STILL_GOOD=$( echo "${STILL_GOOD}" | sed '/^[[:space:]]*$/d' )
              if [[ "${STILL_GOOD}" == "${OUTPUTIDX_ALT}" ]]
              then
                OUTPUT_INDEXES=$( echo -e "${OUTPUT_INDEXES}\\n${OUTPUTIDX_ALT}" )
              fi
            done <<< "${OUTPUTIDX_WEB}"
            OUTPUTIDX_WEB=$( echo "${OUTPUT_INDEXES}" | sed '/^[[:space:]]*$/d' )
            OUTPUTIDX_COUNT=$( echo "${OUTPUTIDX_WEB}" | sed '/^[[:space:]]*$/d' | wc -l )

            if [[ "${OUTPUTIDX_COUNT}" -eq 0 ]]
            then
              echo
              echo "txhash no longer contains the collateral: ${TXHASH}."
              echo
              TXHASH=''
            fi

            if [[ "${OUTPUTIDX_COUNT}" -eq 1 ]]
            then
              OUTPUTIDX=$( echo "${OUTPUTIDX_WEB}" | sed '/^[[:space:]]*$/d' )
            fi

            if [[ "${OUTPUTIDX_COUNT}" -gt 1 ]]
            then
              echo
              echo "Too many possible transaction outputs to fully automate."
              echo
              TXHASH=''
            fi
          fi
        fi
      fi
    fi
  fi
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

stty sane 2>/dev/null
echo
echo -e "Username to run ${DAEMON_NAME} as: \\e[1;4m${USRNAME}\\e[0m"
# Get public and private ip addresses.
if [ "${PUBIPADDRESS}" != "${PRIVIPADDRESS}" ] && [ "${PRIVIPADDRESS}" == "0" ]
then
  PRIVIPADDRESS="${PUBIPADDRESS}"
fi
if [ "${PUBIPADDRESS}" != "${PRIVIPADDRESS}" ]
then
  echo -e "Public Address:       \\e[1;4m${PUBIPADDRESS}\\e[0m"
  echo -e "Private Address:      \\e[1;4m${PRIVIPADDRESS}\\e[0m"
else
  echo -e "Address:              \\e[1;4m${PUBIPADDRESS}\\e[0m"
fi
echo -e "Port:                 \\e[1;4m${PORTB}\\e[0m"
if [[ "${NO_MN}" -eq 0 ]]
then
  if [ -z "${MNKEY}" ]
  then
    echo -e "${MASTERNODE_PRIVKEY}:    \\e[2m(auto generate one)\\e[0m"
  else
    echo -e "${MASTERNODE_PRIVKEY}:    \\e[1;4m${MNKEY}\\e[0m"
  fi
  echo -e "txhash:               \\e[1;4m${TXHASH}\\e[0m"
  echo -e "outputidx:            \\e[1;4m${OUTPUTIDX}\\e[0m"
  echo -e "alias:                \\e[1;4m${USRNAME}_${MNALIAS}\\e[0m"
  echo

  REPLY='y'
  echo "The full string to paste into the ${MASTERNODE_CONF} file"
  echo "will be shown at the end of the setup script."
  echo -e "\\e[4mPress Enter to continue\\e[0m"
  stty sane 2>/dev/null
  if [ -z "${SKIP_CONFIRM}" ]
  then
    read -r -p $'Use given defaults \e[7m(y/n)\e[0m? ' -e -i "${REPLY}" input 2>&1
  else
    echo -e "Use given defaults \\e[7m(y/n)\\e[0m? ${REPLY}"
  fi
  REPLY="${input:-$REPLY}"
fi
sudo true >/dev/null 2>&1

if [[ $REPLY =~ ^[Nn] ]]
then
  # Create new user for daemon.
  echo
  echo "If you are unsure about what to type in, press enter to select the default."
  echo

  stty sane 2>/dev/null
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

  # Get private key if user want's to supply one.
  echo
  echo "Recommend you leave this blank to have script automatically generate one"
  read -r -e -i "${MNKEY}" -p "${MASTERNODE_PRIVKEY}: " input 2>&1
  MNKEY="${input:-$MNKEY}"

  # Get IP public address.
  read -r -e -i "${PUBIPADDRESS}" -p "Public IPv4 Address: " input 2>&1
  PUBIPADDRESS="${input:-$PUBIPADDRESS}"
  # Get IP private address.
  read -r -e -i "${PRIVIPADDRESS}" -p "Private IPv4 Address: " input 2>&1
  PRIVIPADDRESS="${input:-$PRIVIPADDRESS}"

else
  echo "Using the above default values."
fi

echo
echo "Starting the ${DAEMON_NAME} install process; please wait for this to finish."
if [[ "${NO_MN}" -eq 0 ]]
then
  echo "The script ends when you see the big string to add to the ${MASTERNODE_CONF} file."
fi
echo "Let the script run and keep your terminal open."
echo
stty sane 2>/dev/null
read -r -t 10 -p "Hit ENTER to continue or wait 10 seconds" 2>&1
echo
sudo true >/dev/null 2>&1

# Find running daemons to copy from for faster sync.
# shellcheck disable=SC2009
RUNNING_DAEMON_USERS=$( sudo ps axo etimes,user:32,command | grep "${DAEMON_GREP}" | grep -v "bash" | grep -v "watch" | awk '$1 > 10' | awk '{ print $2 }' )
ALL_DAEMON_USERS=''

stty sane 2>/dev/null
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
while read -r USR_HOME_DIR
do
  if [[ "${#USR_HOME_DIR}" -lt 3 ]]
  then
    continue
  fi

  MN_USRNAME=$( basename "${USR_HOME_DIR}" )
  if [ "$( type "${MN_USRNAME}" 2>/dev/null | grep -c '_masternode_dameon_2' )" -gt 0 ]
  then
    if [[ -z "${ALL_DAEMON_USERS}" ]]
    then
      ALL_DAEMON_USERS="${MN_USRNAME}"
    else
      ALL_DAEMON_USERS=$( printf "%s\\n%s" "${ALL_DAEMON_USERS}" "${MN_USRNAME}" )
    fi
  fi
done <<< "$( cut -d: -f1 /etc/passwd | getent passwd | cut -d: -f6 | sort -h )"

# Find running damons with matching bash functions
RUNNING_DAEMON_USERS=$( echo "${RUNNING_DAEMON_USERS}" | sort )
ALL_DAEMON_USERS=$( echo "${ALL_DAEMON_USERS}" | sort )
BOTH_LISTS=$( sort <( echo "${RUNNING_DAEMON_USERS}" | tr " " '\n' ) <( echo "${ALL_DAEMON_USERS}" | tr " " '\n' )| uniq -d | grep -Ev "^$" )

# Make sure daemon has the correct block count.
while read -r GOOD_MN_USRNAME
do
  if [[ -z "${GOOD_MN_USRNAME}" ]] || [[ "${GOOD_MN_USRNAME}" == 'root' ]]
  then
    break
  fi
  echo -n "Checking ${GOOD_MN_USRNAME}."
  if [[ $( "${GOOD_MN_USRNAME}" blockcheck 2>/dev/null | sed '/^[[:space:]]*$/d' | wc -l ) -eq 1 ]]
  then
    echo " It is good!"
    if [[ "${FAST_SYNC}" -eq 1 ]]
    then
      continue
    fi
    # Generate key and stop master node.
    if [ -z "${MNKEY}" ] && [[ "${NO_MN}" -eq 0 ]]
    then
      echo "Generate ${MASTERNODE_GENKEY_COMMAND} on ${GOOD_MN_USRNAME}"
      MNKEY=$( "${GOOD_MN_USRNAME}" "${MASTERNODE_GENKEY_COMMAND}" )
    fi

    # If daemon is not slow OR we do not have BLOCKS_N_CHAINS then stop n copy.
    if [[ "${SLOW_DAEMON_START}" -eq 0 ]] || [[ -z "${DROPBOX_BLOCKS_N_CHAINS}" ]]
    then
      # Copy this Daemon.
      echo "Stopping ${GOOD_MN_USRNAME}"
      "${GOOD_MN_USRNAME}" disable >/dev/null 2>&1

      if [[ ${ARG6} == 'y' ]]
      then
        echo "Waiting for ${GOOD_MN_USRNAME} to shutdown"
      fi
      while [[ $( sudo lslocks -n -o COMMAND,PATH | grep -cF "${GOOD_MN_USRNAME}/${DIRECTORY}" ) -ne 0 ]]
      do
        if [[ ${ARG6} == 'y' ]]
        then
          printf "."
        else
          echo -e "\\r${SP:i++%${#SP}:1} Waiting for ${GOOD_MN_USRNAME} to shutdown \\c"
        fi
        sleep 0.5
      done
      echo

      echo "Coping /home/${GOOD_MN_USRNAME} to /home/${USRNAME} for faster sync."
      sudo rm -rf /home/"${USRNAME:?}"
      sudo cp -r /home/"${GOOD_MN_USRNAME}" "/home/${USRNAME}"
      sleep 0.1
      rm -rf "/home/${USRNAME}/disabled"
      if [[ ! -z $( "${GOOD_MN_USRNAME}" pid ) ]]
      then
        sudo rm -rf /home/"${USRNAME:?}"
        sudo mkdir /home/"${USRNAME:?}"
        sudo chown -R "${USRNAME}":"${USRNAME}" "/home/${USRNAME}"
        continue
      fi

      echo "Starting ${GOOD_MN_USRNAME}"
      "${GOOD_MN_USRNAME}" enable >/dev/null 2>&1
      sleep 0.2

      FAST_SYNC=1
      if [ ! -z "${SKIP_CONFIRM}" ]
      then
        break
      fi
    fi

  elif [ -z "${SKIP_CONFIRM}" ]
  then
    echo
    echo "System Might be overloaded."
    "${GOOD_MN_USRNAME}" blockcheck
    echo "This linux box may not have enough resources to run another ${MASTERNODE_NAME} daemon."
    echo "ctrl-c to exit this script and fix the broken mn before installing more."
    echo
    stty sane 2>/dev/null
    read -r -t 10 -p "Hit ENTER to continue or wait 10 seconds" 2>&1
  fi
done <<< "${BOTH_LISTS}"

if [[ "${#PROJECT_DIR}" -lt 4 ]]
then
  PROJECT_DIR=$( echo "${GITHUB_REPO}" | tr '/' '_' )
fi

sudo true >/dev/null 2>&1
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
  while [[ $( ldd "/var/multi-masternode-data/${PROJECT_DIR}/src/${DAEMON_BIN}" | grep -cF 'not found' ) -ne 0 ]] || [[ $( ldd "/var/multi-masternode-data/${PROJECT_DIR}/src/${CONTROLLER_BIN}" | grep -cF 'not found' ) -ne 0 ]]
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
      ldd "/var/multi-masternode-data/${PROJECT_DIR}/src/${DAEMON_BIN}" | grep -F 'not found'
      echo "The following shared objects are missing for ${CONTROLLER_BIN}"
      ldd "/var/multi-masternode-data/${PROJECT_DIR}/src/${CONTROLLER_BIN}" | grep -F 'not found'
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

if [ ! -f "/var/multi-masternode-data/${PROJECT_DIR}/src/${DAEMON_BIN}" ] || [ ! -f "/var/multi-masternode-data/${PROJECT_DIR}/src/${CONTROLLER_BIN}" ]
then
  echo
  echo "Daemon download and install failed. "
  echo "/var/multi-masternode-data/${PROJECT_DIR}/src/${DAEMON_BIN}"
  echo "/var/multi-masternode-data/${PROJECT_DIR}/src/${CONTROLLER_BIN}"
  echo "Do not exist."
  echo
  return 1 2>/dev/null || exit 1
fi

# Set new user password to a big string.
sudo true >/dev/null 2>&1
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
USR_HOME="$( getent passwd "${USRNAME}" | cut -d: -f6 )"
sudo cp -r /etc/skel/. "${USR_HOME}"
sudo usermod -a -G systemd-journal "${USRNAME}"

if [[ -r "/var/spool/cron/crontabs/${USRNAME}" ]]
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
# shellcheck disable=SC2063
if ! grep -Fxq "* hard nofile 32768" /etc/security/limits.conf
then
  echo "* hard nofile 32768" | sudo tee -a /etc/security/limits.conf >/dev/null
fi
# shellcheck disable=SC2063
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
USER_FUNCTION_FOR_MN_CLI "${CONF}" "${CONTROLLER_BIN}" "${DAEMON_BIN}" "${EXPLORER_URL}" "${BAD_SSL_HACK}" "${HOME}/.bashrc" "/var/multi-masternode-data/___temp.sh"

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

if [[ "$( type "${USRNAME}" 2>/dev/null | grep -c '_masternode_dameon_2' )" -eq 0 ]]
then
  # shellcheck disable=SC1091
  . /var/multi-masternode-data/___temp.sh
fi

# Copy daemon code to new users home dir.
USR_HOME="$( getent passwd "${USRNAME}" | cut -d: -f6 )"
echo "Copy daemon code to ${USR_HOME}/.local/bin"
sudo mkdir -p "${USR_HOME}/.local/bin"
sudo cp "/var/multi-masternode-data/${PROJECT_DIR}/src/${DAEMON_BIN}" "${USR_HOME}/.local/bin/"
sudo chmod +x "${USR_HOME}/.local/bin/${DAEMON_BIN}"
sudo cp "/var/multi-masternode-data/${PROJECT_DIR}/src/${CONTROLLER_BIN}" "${USR_HOME}/.local/bin/"
sudo chmod +x "${USR_HOME}/.local/bin/${CONTROLLER_BIN}"

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

if [ -d "${USR_HOME}/${DIRECTORY}/" ]
then
  sudo chown -R "${USRNAME}":"${USRNAME}" "${USR_HOME}/"
  sleep 0.2
  if [[ ! -f "${USR_HOME}/.profile" ]]
  then
    sudo su - "${USRNAME}" -c "${USR_HOME}/.profile"
  fi
  if [[ $( grep -cF "PATH=\"\$HOME/.local/bin:\$PATH\"" "${USR_HOME}/.profile" ) -ne 1 ]]
  then
    echo "Adding"
    echo "${PROFILE_FIX}" | sudo tee -a "${USR_HOME}/.profile" >/dev/null
  fi
fi

# Copy key if it exists into the new users home dir.
if [[ -s ~/masternode.mcarper.key ]]
then
  cp ~/masternode.mcarper.key "${USR_HOME}/masternode.mcarper.key"

elif [[ -s ~/masternode.myce.key ]]
then
  cp ~/masternode.myce.key "${USR_HOME}/masternode.myce.key"

elif [[ -s ~/masternode.abacus.key ]]
then
  cp ~/masternode.abacus.key "${USR_HOME}/masternode.abacus.key"

fi

# Make sure daemon data folder exists
sudo su "${USRNAME}" -c "mkdir -p ${USR_HOME}/${DIRECTORY}/"
sudo chown -R "${USRNAME}":"${USRNAME}" "${USR_HOME}/"
# Remove old conf and create new conf
sudo rm -f "${USR_HOME}/${DIRECTORY}/${CONF}"
sudo su "${USRNAME}" -c "touch ${USR_HOME}/${DIRECTORY}/${CONF}"

# Setup systemd to start masternode on restart.
TIMEOUT='70s'
STARTLIMITINTERVAL='600s'
if [[ "${SLOW_DAEMON_START}" -eq 1 ]]
then
  TIMEOUT='240s'
  STARTLIMITINTERVAL='1200s'
fi

OOM_SCORE_ADJUST=$( sudo cat /etc/passwd | wc -l )
CPU_SHARES=$(( 1024 - OOM_SCORE_ADJUST ))
STARTUP_CPU_SHARES=$(( 768 - OOM_SCORE_ADJUST  ))
echo "Creating systemd ${MASTERNODE_NAME} service for ${DAEMON_NAME}"

MN_TEXT="Creating systemd shutdown service for all masternode daemons."
MN_TEXT1="Shutdown service for all masternode daemons"
if [[ "${NO_MN}" -eq 1 ]]
then
  MN_TEXT="Creating systemd shutdown service for all coin daemons."
  MN_TEXT1="Shutdown service for all coin daemons"
fi

cat << SYSTEMD_CONF | sudo tee /etc/systemd/system/"${USRNAME}".service >/dev/null
[Unit]
Description=${DAEMON_NAME} ${MASTERNODE_NAME} for user ${USRNAME}
After=network.target

[Service]
Type=forking
User=${USRNAME}
WorkingDirectory=${USR_HOME}
#PIDFile=${USR_HOME}/${DIRECTORY}/${DAEMON_BIN}.pid
ExecStart=${USR_HOME}/.local/bin/${DAEMON_BIN} --daemon
ExecStartPost=/bin/sleep 1
ExecStop=${USR_HOME}/.local/bin/${CONTROLLER_BIN} stop
Restart=always
RestartSec=${TIMEOUT}
TimeoutStartSec=${TIMEOUT}
TimeoutStopSec=240s
StartLimitInterval=${STARTLIMITINTERVAL}
StartLimitBurst=3
OOMScoreAdjust=${OOM_SCORE_ADJUST}
CPUShares=${CPU_SHARES}
StartupCPUShares=${STARTUP_CPU_SHARES}

[Install]
WantedBy=multi-user.target
SYSTEMD_CONF

echo "${MN_TEXT}"
cat << SYSTEMD_CONF | sudo tee /etc/systemd/system/multi-masternode-data-shutdown.service >/dev/null
[Unit]
Description=${MN_TEXT1}
Requires=network.target
RequiresMountsFor=/
DefaultDependencies=no
Before=shutdown.target reboot.target halt.target kexec.target

[Service]
Type=oneshot
User=root
WorkingDirectory=/root/
RemainAfterExit=true
ExecStart=/bin/true
ExecStop=/bin/bash -ic 'source /var/multi-masternode-data/.bashrc; all_mn_run stop'

[Install]
WantedBy=multi-user.target
SYSTEMD_CONF

sudo systemctl daemon-reload
sudo systemctl enable multi-masternode-data-shutdown.service --now

if [[ -z "${IPV6USED}" ]] || [[ "${IPV6USED}" -eq 0 ]]
then
  BIND="${PRIVIPADDRESS}:${PORTB}"
else
  BIND="[${PRIVIPADDRESS}]:${PORTB}"
fi

# Make sure ports are still open.
if [[ $( IS_PORT_OPEN "${PRIVIPADDRESS}" "${PORTB}" | tail -n 1 ) -eq 0 ]]
then
  echo
  echo "Restart the script. Port is now taken."
  echo "${PRIVIPADDRESS}:${PORTB}"
  echo "${BIND}"
  IS_PORT_OPEN "${PRIVIPADDRESS}" "${PORTB}" "" 1
  cat /tmp/ipv46-verbose.log
  sudo ss -lpn 2>/dev/null | grep -F ":${PORTB} "
  sudo ss -lpn 2>/dev/null | grep -F "${BIND} "
  echo "${NETCAT_TEST}"
  echo
  return 1 2>/dev/null
fi

if [[ $( IS_PORT_OPEN "${PRIVIPADDRESS}" "${PORTA}" | tail -n 1 ) -eq 0 ]] || \
  [[ $( IS_PORT_OPEN "127.0.0.1" "${PORTA}" | tail -n 1 ) -eq 0 ]] || \
  [[ $( IS_PORT_OPEN "0.0.0.0" "${PORTA}" | tail -n 1 ) -eq 0 ]] || \
  [[ $( IS_PORT_OPEN "::" "${PORTA}" "\[::.*\]:${PORTA}" | tail -n 1 ) -eq 0 ]]
then
  echo "Searching for an unused port for rpc"
  PORTA=$( FIND_FREE_PORT "${PRIVIPADDRESS}" | tail -n 1 )
fi

if [[ "$( sudo ufw status | grep -v '(v6)' | awk '{print $1}' | grep -c "^${PORTB}$" )" -eq 0 ]]
then
  sudo ufw allow "${PORTB}"
fi
echo "y" | sudo ufw enable >/dev/null 2>&1
sudo ufw reload

if [[ -z "${IPV6USED}" ]] || [[ "${IPV6USED}" -eq 0 ]]
then
  EXTERNALIP="${PUBIPADDRESS}:${PORTB}"
  BIND="${PRIVIPADDRESS}:${PORTB}"
else
  EXTERNALIP="[${PUBIPADDRESS}]:${PORTB}"
  BIND="[${PRIVIPADDRESS}]:${PORTB}"
fi

# Create conf file.
DAEMON_DOWNLOAD=$( echo "${DAEMON_DOWNLOAD}" | tr "\n" " " )
cat << COIN_CONF | sudo tee "${USR_HOME}/${DIRECTORY}/${CONF}" >/dev/null
rpcuser=${RPC_USERNAME}_rpc_${USRNAME}
rpcpassword=${PWA}
rpcbind=127.0.0.1
rpcallowip=127.0.0.1
rpcport=${PORTA}
server=1
daemon=1
logtimestamps=1
listen=1
staking=1
externalip=${EXTERNALIP}
bind=${BIND}
${EXTRA_CONFIG}
# nodelist=${DROPBOX_ADDNODES}
# bootstrap=${DROPBOX_BOOTSTRAP}
# blocks_n_chains=${DROPBOX_BLOCKS_N_CHAINS}
# github_repo=${GITHUB_REPO}
# bin_base=${BIN_BASE}
# daemon_download=${DAEMON_DOWNLOAD}
# defaultport=${DEFAULT_PORT}
# masternode_caller=${MASTERNODE_CALLER}
# masternode_name=${MASTERNODE_NAME}
# masternode_prefix=${MASTERNODE_PREFIX}
# masternode_genkey_command=${MASTERNODE_GENKEY_COMMAND}
# masternode_privkey=${MASTERNODE_PRIVKEY}
# masternode_conf=${MASTERNODE_CONF}
# masternode_list=${MASTERNODE_LIST}
# explorer_blockcount_path=${EXPLORER_BLOCKCOUNT_PATH}
# explorer_blockcount_offset=${EXPLORER_BLOCKCOUNT_OFFSET}
# explorer_rawtransaction_path=${EXPLORER_RAWTRANSACTION_PATH}
# explorer_rawtransaction_path_suffix=${EXPLORER_RAWTRANSACTION_PATH_SUFFIX}
# explorer_getaddress_path=${EXPLORER_GETADDRESS_PATH}
# explorer_amount_adjust=${EXPLORER_AMOUNT_ADJUST}
# explorer_peers=${EXPLORER_PEERS}
COIN_CONF

if [ ! -z "${TXHASH}" ]
then
  echo "# txhash=${TXHASH}" | sudo tee -a "${USR_HOME}/${DIRECTORY}/${CONF}" >/dev/null
fi
if [ ! -z "${OUTPUTIDX}" ]
then
  echo "# outputidx=${OUTPUTIDX}" | sudo tee -a "${USR_HOME}/${DIRECTORY}/${CONF}" >/dev/null
fi

if [[ "${FAST_SYNC}" -ne 1 ]]
then
  if [[ ! -z "${DROPBOX_BLOCKS_N_CHAINS}" ]] && [[ "${USE_DROPBOX_BLOCKS_N_CHAINS}" -eq 1 ]]
  then
    echo "Download snapshot."
    "${USRNAME}" dl_blocks_n_chains
  fi

  if [[ $( find "/var/multi-masternode-data/${PROJECT_DIR}/blocks_n_chains/" -type f | wc -l ) -lt 5 ]] && [[ ! -z "${DROPBOX_BOOTSTRAP}" ]] && [[ "${USE_DROPBOX_BOOTSTRAP}" -eq 1 ]]
  then
    if [[ ! -d "${USR_HOME}/${DIRECTORY}/blocks" ]]
    then
      echo "Download Bootstrap."
      "${USRNAME}" dl_bootstrap
    fi
  fi

  # Get addnode section for the config file.
  if [[ "${USE_DROPBOX_ADDNODES}" -eq 1 ]]
  then
    echo "Addnodes."
    "${USRNAME}" dl_addnode
  fi
fi
sudo chown -R "${USRNAME}:${USRNAME}" "${USR_HOME}/${DIRECTORY}/"

# Get addnodes from explorer if possible.
"${USRNAME}" explorer_peers conf

# m c a r p e r
if [ ! -z "${MNKEY}" ]
then
  # Add private key to config and make masternode.
  echo "Setting privkey."
  "${USRNAME}" privkey "${MNKEY}"
else
  # Use connect for sync that doesn't drop out.
  if [[ $( "${USRNAME}" conf | grep -c 'addnode' ) -gt "${DAEMON_CONNECTIONS}" ]] && [[ "${NO_MN}" -eq 0 ]] && [[ "${USE_CONNECT}" -eq 1 ]]
  then
    echo "Changing addnode to connect for faster sync."
    "${USRNAME}" addnode_to_connect
  fi
fi

# Rename existing wallet.dat files if they exist.
if [[ -r "${USR_HOME}/${DIRECTORY}/wallet.dat" ]]
then
  mv "${USR_HOME}/${DIRECTORY}/wallet.dat" "${USR_HOME}/${DIRECTORY}/wallet.dat.old"
fi

# Add apparmor.
echo "Adding apparmor configuation."
ADD_APPARMOR_CONF "${USRNAME}" "${DIRECTORY}" "${CONF}" "${USR_HOME}/.local/bin/${DAEMON_BIN}" "${USR_HOME}/.local/bin/${CONTROLLER_BIN}"

# Create sudoers conf file.
echo "Allow for ${USRNAME} to run systemctl for its daemon."
cat << SUDOERS_CONF | sudo tee "/etc/sudoers.d/${USRNAME}" >/dev/null
${USRNAME} ALL=(ALL) NOPASSWD:/bin/systemctl start ${USRNAME}.service
${USRNAME} ALL=(ALL) NOPASSWD:/bin/systemctl stop ${USRNAME}.service
${USRNAME} ALL=(ALL) NOPASSWD:/bin/systemctl restart ${USRNAME}.service
${USRNAME} ALL=(ALL) NOPASSWD:/bin/systemctl enable ${USRNAME}.service
${USRNAME} ALL=(ALL) NOPASSWD:/bin/systemctl reset-failed ${USRNAME}.service

${USRNAME} ALL=(ALL) NOPASSWD:/bin/systemctl start ${USRNAME}
${USRNAME} ALL=(ALL) NOPASSWD:/bin/systemctl stop ${USRNAME}
${USRNAME} ALL=(ALL) NOPASSWD:/bin/systemctl restart ${USRNAME}
${USRNAME} ALL=(ALL) NOPASSWD:/bin/systemctl enable ${USRNAME}
${USRNAME} ALL=(ALL) NOPASSWD:/bin/systemctl reset-failed ${USRNAME}
SUDOERS_CONF
sudo chmod 440 "/etc/sudoers.d/${USRNAME}"

IS_EMPTY=$( type "DAEMON_PRE_RUN" 2>/dev/null )
if [ ! -z "${IS_EMPTY}" ]
then
  DAEMON_PRE_RUN "${USRNAME}"
fi

# Run daemon as the user mn1 and update block-chain.
echo
echo -e "\\r\\c"
stty sane 2>/dev/null
sudo true >/dev/null 2>&1
echo "Starting the daemon."
"${USRNAME}" start "${ARG6}"
sudo true >/dev/null 2>&1
"${USRNAME}" sync "${BLOCKCOUNT_FALLBACK_VALUE}" "${ARG6}"
sudo true >/dev/null 2>&1
stty sane 2>/dev/null

if [[ "${FIRST_SYNC}"  -eq 1 ]]
then
  BIN_BASE_LOWER=$( echo "${BIN_BASE}" | tr '[:upper:]' '[:lower:]' )
  "${USRNAME}" up_dbox -1 now
  echo
  echo "bash -i /root/${BIN_BASE_LOWER}d.sh '' '' '' '' 'y'"

  # shellcheck disable=SC2941
  if [[ $( grep 'DROPBOX_BLOCKS_N_CHAINS' "/root/${BIN_BASE_LOWER}d.sh" | wc -c ) -gt 32 ]]
  then
    echo "Dropbox worked"
    "${USRNAME}" remove_daemon
    bash -i "/root/${BIN_BASE_LOWER}d.sh" '' '' '' '' 'y'

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

    if [[ "$( type "${USRNAME}" 2>/dev/null | grep -c '_masternode_dameon_2' )" -eq 0 ]]
    then
      # shellcheck disable=SC1091
      source /var/multi-masternode-data/___temp.sh
    fi

    echo "${USRNAME} up_gdrive"
    "${USRNAME}" up_gdrive
  fi

  echo "Testing if coin is limited to 1 IPv4"
  "${USRNAME}" port | tr -d '\040\011\012\015'
  PORT_RIGHT_NOW=$( "${USRNAME}" port | tr -d '\040\011\012\015' )
  echo "${USRNAME} is running on port ${PORT_RIGHT_NOW}"
  PORT_TO_TEST=$( FIND_FREE_PORT "${PRIVIPADDRESS}" | tail -n 1 )
  echo "Changing port ${PORT_RIGHT_NOW} to ${PORT_TO_TEST}"
  "${USRNAME}" port "${PORT_TO_TEST}"
  "${USRNAME}" wait_for_loaded "${ARG6}"
  echo "Waiting 20 seconds."
  sleep 20

  MN_STATUS=$( "${USRNAME}" "${MASTERNODE_CALLER}status" )
  MN_DEBUG=$( "${USRNAME}" "${MASTERNODE_CALLER}debug" )
  if [[ $( echo "${MN_STATUS}" | grep -ciF 'invalid port' ) -gt 0 ]]
  then
    echo "Coin is limited to 1 IPv4"
    sed -i 's/MULTI_IP_MODE.*/MULTI_IP_MODE=3/g' "/root/${BIN_BASE_LOWER}d.sh"
  elif [[ $( echo "${MN_DEBUG}" | grep -ciF 'invalid port' ) -gt 0 ]]
  then
    echo "Coin is limited to 1 IPv4"
    sed -i 's/MULTI_IP_MODE.*/MULTI_IP_MODE=3/g' "/root/${BIN_BASE_LOWER}d.sh"
  else
    echo "Coin is not limited to 1 IPv4"
  fi
  "${USRNAME}" port "${PORT_RIGHT_NOW}"

  echo "Need to test ipv6 here."
  echo
  stty sane 2>/dev/null
  read -n 1 -s -r -p "Press any key to continue"
  return
fi

# Get privkey from conf.
MNKEY=$( "${USRNAME}" privkey )

# Generate key and stop master node.
if [ -z "${MNKEY}" ] && [[ "${NO_MN}" -eq 0 ]]
then
  echo "Generate ${MASTERNODE_GENKEY_COMMAND} on ${USRNAME}"
  sleep 1
  MNKEY=$( "${USRNAME}" "${MASTERNODE_GENKEY_COMMAND}" )
  sleep 1
  echo "Stopping ${USRNAME}"
  "${USRNAME}" stop >/dev/null 2>&1
  sleep 1
  echo "Adding ${MASTERNODE_NAME} key to ${USRNAME} configuration"
  "${USRNAME}" privkey "${MNKEY}" >/dev/null 2>&1
  sleep 1

  if [[ "${DAEMON_CYCLE}" -eq 1 ]]
  then
    echo "Cycling the daemon on and off."
    "${USRNAME}" stop >/dev/null 2>&1
    sleep 1
    "${USRNAME}" start >/dev/null 2>&1
    sleep 1
    "${USRNAME}" stop >/dev/null 2>&1
  fi

  # Start daemon.
  "${USRNAME}" connect_to_addnode
  "${USRNAME}" addnode_remove
  echo "Starting the daemon."
  "${USRNAME}" start "${ARG6}"

else
  "${USRNAME}" addnode_remove
fi
# Enable masternode to run on system start.
sudo systemctl enable "${USRNAME}" 2>&1
stty sane 2>/dev/null

# Output firewall info.
echo
sudo ufw status
sleep 1
stty sane 2>/dev/null

if [[ ! -z "${MNSYNC_WAIT_FOR}" ]]
then
  sudo true >/dev/null 2>&1
  echo "Waiting for ${MASTERNODE_PREFIX}sync status to be ${MNSYNC_WAIT_FOR}"
  echo "This can sometimes take up to 5-10 minutes; please wait for ${MASTERNODE_PREFIX}sync."
  while [[ $( "${USRNAME}" "${MASTERNODE_PREFIX}sync" status | grep -cF "${MNSYNC_WAIT_FOR}" ) -eq 0 ]]
  do
    if [[ ${ARG6} == 'y' ]]
    then
      printf "."
    else
      PERCENT_DONE=$( "${USRNAME}" daemon_log tail 10000 | tac | grep -m 1 -o 'nSyncProgress.*' | awk -v SF=100 '{printf($2*SF )}' )
      echo -e "\\r${SP:i++%${#SP}:1} Percent Done: %${PERCENT_DONE}      \\c"
    fi
    sleep 0.5
  done
  echo
  sudo true >/dev/null 2>&1
fi

if [[ "${NO_MN}" -eq 0 ]]
then
  # Output masternode info.
  sleep 1
  "${USRNAME}" wait_for_loaded "${ARG6}"

  "${USRNAME}" "${MASTERNODE_CALLER}status"
  "${USRNAME}" "${MASTERNODE_CALLER}debug"
  sleep 1
  IS_EMPTY=$( type "SENTINEL_SETUP" 2>/dev/null )
  if [ ! -z "${IS_EMPTY}" ]
  then
    sudo true >/dev/null 2>&1
    SENTINEL_SETUP "${USRNAME}"

    # Add apparmor.
    ADD_APPARMOR_CONF "${USRNAME}" "${DIRECTORY}" "${CONF}" "${USR_HOME}/.local/bin/${DAEMON_BIN}" "${USR_HOME}/.local/bin/${CONTROLLER_BIN}" "${USR_HOME}/sentinel/venv/bin/python2"
  fi
fi

if [[ ! -z "${SENTINEL_GITHUB}" ]] && [[ ! -z "${SENTINEL_CONF_START}" ]]
then
  SENTINEL_GENERIC_SETUP "${USRNAME}" "${SENTINEL_GITHUB}" "${SENTINEL_CONF_START}" "${DIRECTORY}/${CONF}"
fi

# Use logrotate.
cat << LOG_ROTATE | sudo tee "/etc/logrotate.d/${USRNAME}" >/dev/null
${DIRECTORY}/debug.log {
  su ${USRNAME} ${USRNAME}
  rotate 3
  minsize 100M
  copytruncate
  compress
  missingok
}

${USR_HOME}/mnfix.log {
  su ${USRNAME} ${USRNAME}
  rotate 3
  minsize 25M
  copytruncate
  compress
  missingok
}

${USR_HOME}/update.log {
  su ${USRNAME} ${USRNAME}
  rotate 3
  minsize 25M
  copytruncate
  compress
  missingok
}

LOG_ROTATE

cat << LOG_ROTATE | sudo tee -a "/etc/logrotate.d/${USRNAME}" >/dev/null

${USR_HOME}/sentinel/sentinel-cron.log {
  su ${USRNAME} ${USRNAME}
  rotate 3
  daily
  copytruncate
  compress
  missingok
}

LOG_ROTATE


if [[ ! -z "${TXHASH}" ]] && [[ ! -z "${EXPLORER_URL}" ]] && [[ ! "${EXPLORER_URL}" == https://www.coinexplorer.net/api/v1/* ]]
then
  echo "Downloading transaction from the explorer."
  URL=$( echo "${EXPLORER_URL}${EXPLORER_RAWTRANSACTION_PATH}${TXHASH}${EXPLORER_RAWTRANSACTION_PATH_SUFFIX}" | tr -d '[:space:]' )
  echo "${URL}"
  OUTPUTIDX_RAW=$( wget -4qO- -T 15 -t 2 -o- "${URL}" "${BAD_SSL_HACK}" | tr '[:upper:]' '[:lower:]' )
  sleep "${EXPLORER_SLEEP}"

  OUTPUTIDX_RAW_ALT=$( echo "$OUTPUTIDX_RAW" | jq ".data" )
  if [[ $( echo "${OUTPUTIDX_RAW_ALT}" | grep -c 'vin' ) -gt 0 ]]
  then
    OUTPUTIDX_RAW=${OUTPUTIDX_RAW_ALT}
  fi

  TXID_CONFIRMATIONS=$( echo "${OUTPUTIDX_RAW}" | jq ".confirmations" )
  if [[ -z "${TXID_CONFIRMATIONS}" ]]
  then
    TXID_CONFIRMATIONS=1
  fi
  if [[ ! ${TXID_CONFIRMATIONS} =~ ${RE} ]]
  then
    TXID_CONFIRMATIONS=17
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

if [[ $( sudo su "${USRNAME}" -c 'crontab -l' | grep -cF "${USRNAME} update_daemon 2>&1" ) -eq 0  ]]
then
  echo 'Setting up crontab for auto update'
  MINUTES=$((RANDOM % 60))
  sudo su "${USRNAME}" -c " ( crontab -l ; echo \"${MINUTES} */6 * * * bash -ic 'source /var/multi-masternode-data/.bashrc; ${USRNAME} update_daemon 2>&1' 2>/dev/null\" ) | crontab - "
fi

if [[ $( sudo su "${USRNAME}" -c 'crontab -l' | grep -cF "${USRNAME} mnfix 2>&1" ) -eq 0  ]]
then
  echo 'Setting up crontab to auto fix the daemon'
  MINUTES=$(( RANDOM % 19 ))
  MINUTES_A=$(( MINUTES + 20 ))
  MINUTES_B=$(( MINUTES + 40 ))
  rm -f "${USR_HOME}/mnfix.log"
  touch "${USR_HOME}/mnfix.log"
  sudo su "${USRNAME}" -c " ( crontab -l ; echo \"${MINUTES},${MINUTES_A},${MINUTES_B} * * * * bash -ic 'source /var/multi-masternode-data/.bashrc; ${USRNAME} mnfix 2>&1' 2>&1 >> ${USR_HOME}/mnfix.log \" ) | crontab - "
fi

# Show crontab contents.
sudo su "${USRNAME}" -c 'crontab -l'
touch "${DAEMON_SETUP_INFO}"

IS_EMPTY=$( type "DAEMON_POST_RUN" 2>/dev/null )
if [ ! -z "${IS_EMPTY}" ]
then
  DAEMON_POST_RUN "${USRNAME}"
fi

# Get port that are being used by a program holding a lock.
PORTS_IN_USE=$( sudo -n ss -lpn 2>/dev/null )
RUNNING_DAEMON_PORTS=$( sudo lslocks -n -r -o PID | sort -un | awk '{print "pid=" $1}' )
# shellcheck disable=SC2063
RUNNING_PORTS=$( while read -r PID; do echo "${PORTS_IN_USE}" | grep "${PID}" | grep -vF '*:*' | awk '{print $5}' | grep -oE ':[0-9]+$' | tr -d ':' ; done <<< "${RUNNING_DAEMON_PORTS}" )
RUNNING_PORTS=$( echo "${RUNNING_PORTS}" | sort -V | uniq -u )

# Get ports open on the firewall.
OPEN_PORTS=$( sudo ufw status | grep -v '(v6)' | tail -n +5 | awk '{print $1}' | sort -V | uniq -u | sed '/^[[:space:]]*$/d' )
# Merge the lists.
BOTH_LISTS=$( sort <( echo "$RUNNING_PORTS" | tr " " '\n' ) <( echo "$OPEN_PORTS" | tr " " '\n' ) | uniq -d )
#Find missing rules.
MISSING_FIREWALL_RULES=$( sort <( echo "$RUNNING_PORTS" | tr " " '\n' ) <( echo "$BOTH_LISTS" | tr " " '\n' ) | uniq -u )
if [[ $( echo "${MISSING_FIREWALL_RULES}" | wc -w ) -ne 0 ]]
then
  _UFW_OUTPUT=''
  if [[ ${ARG6} == 'y' ]]
  then
    echo "Getting firewall rules"
  fi
  while read -r PID_LOCK
  do
    MISSING_FIREWALL_RULE=$( sudo netstat -tulpnW | grep "${PID_LOCK}" | grep -v -E 'tcp6|:25\s' | grep ":${MISSING_FIREWALL_RULES}" | awk '{print $4 "\t\t" $7}' )
    if [ ! -z "${MISSING_FIREWALL_RULE}" ]
    then
      MISSING_PORT=$( echo "${MISSING_FIREWALL_RULE}" | awk '{print $1}' | cut -d ':' -f2 )
      OUTPUT="sudo ufw allow ${MISSING_PORT}"
      _UFW_OUTPUT=$( echo -e "${_UFW_OUTPUT}\\n${OUTPUT}" )
      if [[ ${ARG6} == 'y' ]]
      then
        printf "."
      else
        echo -e "\\r${SP:i++%${#SP}:1} Getting firewall rules ${MISSING_PORT}      \\c"
      fi
    fi
  done <<< "$( sudo lslocks -n -r -o PID | sort -un | awk '{print $1 "/"}' )"
  echo
  echo "NOTICE: If you are running another masternode on the vps make sure to open any ports needed with this command:"
  echo "${_UFW_OUTPUT}" | sort -V
  echo
fi

sudo rm -f "${USR_HOME}/update.log"
sudo su "${USRNAME}" -c "touch \"${USR_HOME}/update.log\""

stty sane 2>/dev/null

# Output more info.
echo
echo "Commands to control the daemon"
echo "${USRNAME} status"
echo "${USRNAME} start"
echo "${USRNAME} restart"
echo "${USRNAME} stop"
echo

stty sane 2>/dev/null
echo "Alternative ways to issue commands via ${CONTROLLER_BIN}"
echo "${USR_HOME}/.local/bin/${CONTROLLER_BIN} -datadir=${USR_HOME}/${DIRECTORY}/"
echo "sudo su - ${USRNAME} -c '${CONTROLLER_BIN} '"
echo
if [[ ! -z "${TIPS}" ]]
then
  echo "# Send a tip in ${TICKER} to mc for making this script"
  echo "${TIPS}"
  echo
fi
if [[ "${NO_MN}" -eq 1 ]]
then
  stty sane 2>/dev/null
  rm -f /var/multi-masternode-data/___temp.sh
  return
fi

echo "Check if master node started remotely"
echo "${USRNAME} ${MASTERNODE_CALLER}debug"
echo "${USRNAME} ${MASTERNODE_CALLER}status"
echo
echo "Keep this terminal open until you have started the ${MASTERNODE_NAME} from your wallet. "
echo "If ${MASTERNODE_PREFIX} start was successful you should see this message displayed in this shell: "
echo "'${MASTERNODE_NAME} ${USRNAME} started remotely'. "
echo "If you do not see that message, then start it again from your wallet."
echo "IP and port daemon is using"
echo "${EXTERNALIP}"
echo
echo "${MASTERNODE_PRIVKEY}"
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
echo "file in order to start the ${MASTERNODE_NAME}"
REMOTE_IP=$( who | tr '()' ' ' | awk '{print $5}' | sed '/^[[:space:]]*$/d' | head -n1 )
stty sane 2>/dev/null
echo "externalip=${REMOTE_IP}"
echo
echo "Command to start the ${MASTERNODE_NAME} from the "
echo "desktop/hot/control wallet's debug console:"
if [[ $( "${USRNAME}" help | awk '{print $1}' | grep -c "start${MASTERNODE_NAME}" ) -gt 0 ]]
then
  echo -e "\\e[1mstart${MASTERNODE_NAME} alias false ${USRNAME}_${MNALIAS}\\e[0m"
else
  echo -e "\\e[1m${MASTERNODE_CALLER}start-alias ${USRNAME}_${MNALIAS}\\e[0m"
fi
echo
# Print masternode.conf string.
echo "The line that goes into ${MASTERNODE_CONF} will have 4 spaces total."
echo "You will need to restart the desktop wallet for the ${MASTERNODE_NAME} to appear."
if [ ! -z "${TXHASH}" ]
then
  echo "Full string to paste into ${MASTERNODE_CONF} (all on one line)."
  echo
  if [[ -z "${IPV6USED}" ]] || [[ "${IPV6USED}" -eq 0 ]]
  then
    echo -e "\\e[1;7m${USRNAME}_${MNALIAS} ${PUBIPADDRESS}:${DEFAULT_PORT} ${MNKEY} ${TXHASH} ${OUTPUTIDX}\\e[0m"
    echo "${USRNAME}_${MNALIAS} ${PUBIPADDRESS}:${DEFAULT_PORT} ${MNKEY} ${TXHASH} ${OUTPUTIDX}" >> "${DAEMON_SETUP_INFO}"
  else
    echo -e "\\e[1;7m${USRNAME}_${MNALIAS} [${PUBIPADDRESS}]:${DEFAULT_PORT} ${MNKEY} ${TXHASH} ${OUTPUTIDX}\\e[0m"
    echo "${USRNAME}_${MNALIAS} [${PUBIPADDRESS}]:${DEFAULT_PORT} ${MNKEY} ${TXHASH} ${OUTPUTIDX}" >> "${DAEMON_SETUP_INFO}"
  fi
else
  echo "There is almost a full string to paste into the ${MASTERNODE_CONF} file."
  echo -e "Run \\e[7m${MASTERNODE_CALLER}outputs\\e[0m and add the txhash and outputidx to the line below."
  echo "The values when done will be all on one line with 4 spaces total."
  echo
  if [[ -z "${IPV6USED}" ]] || [[ "${IPV6USED}" -eq 0 ]]
  then
    echo -e "\\e[1;7m${USRNAME}_${MNALIAS} ${PUBIPADDRESS}:${DEFAULT_PORT} ${MNKEY}\\e[0m"
    echo "${USRNAME}_${MNALIAS} ${PUBIPADDRESS}:${DEFAULT_PORT} ${MNKEY} " >> "${DAEMON_SETUP_INFO}"
  else
    echo -e "\\e[1;7m${USRNAME}_${MNALIAS} [${PUBIPADDRESS}]:${DEFAULT_PORT} ${MNKEY}\\e[0m"
    echo "${USRNAME}_${MNALIAS} [${PUBIPADDRESS}]:${DEFAULT_PORT} ${MNKEY} " >> "${DAEMON_SETUP_INFO}"
  fi
fi
echo

# Start sub process mini monitor that will exit once masternode has started.
if [ -z "${SKIP_CONFIRM}" ]
then
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

  if [[ "$( type "${USRNAME}" 2>/dev/null | grep -c '_masternode_dameon_2' )" -eq 0 ]]
  then
    # shellcheck disable=SC1091
    . /var/multi-masternode-data/___temp.sh
  fi

  sleep 60
  COUNTER=0
  RESTART_COUNTER=0
  START=$( date -u +%s )
  while :
  do
    # Break out of loop if daemon gets deleted.
    if [ ! -f "${USR_HOME}/.local/bin/${DAEMON_BIN}" ]
    then
#       echo "${USR_HOME}/.local/bin/${DAEMON_BIN} Deleted."
      break
    fi

    # Break out of loop if privkey gets deleted.
    if [[ $( "${USRNAME}" privkey 2>/dev/null | sed '/^[[:space:]]*$/d' | wc -l ) -eq 0 ]]
    then
#       echo "${USRNAME} privkey Deleted."
      break
    fi

    # Break out of loop if daemon has been restarted 4+ times.
    if [[ ${RESTART_COUNTER} =~ ${RE} ]] && [[ "${RESTART_COUNTER}" -gt 4 ]]
    then
#       echo "${USRNAME} restarted."
      break
    fi

    USER_HOME_DIR=$( "${USRNAME}" home_folder )
    if [[ -f "${USER_HOME_DIR}/disabled" ]]
    then
      :
#       echo "${USRNAME} disabled"
#       break
    fi

    # Stop after 2 hours
    if [ $(( $(date -u +%s) - 7200 )) -gt "$START" ]
    then
#       echo "${USRNAME} past 2 hours"
      break
    fi

    PID_MN=$( "${USRNAME}" pid )
    if [[ -z "${PID_MN}" ]] || [[ "${#PID_MN}" -lt 3 ]]
    then
      sleep 60
      continue
    fi

    MN_UPTIME=$( "${USRNAME}" uptime 2>/dev/null | tr -d '[:space:]' )
    if [[ "${MN_UPTIME}" -lt 60 ]]
    then
      sleep 60
      continue
    fi

    MN_SYNC=$( "${USRNAME}" "${MASTERNODE_PREFIX}sync status" )
    if [[ $( echo "${MN_SYNC}" | grep -cE ':\s999|"IsBlockchainSynced": true' ) -lt 2 ]]
    then
      sleep 60
      continue
    fi

    if [ -z "${SKIP_CONFIRM}" ] && [[ "${MINI_MONITOR_RUN}" -ne 0 ]]
    then
      # Additional checks if the txhash and output index are here.
      if [[ ! -z "${TXHASH}" ]] && [[ ! -z "${OUTPUTIDX}" ]] && [[ ! -z "${EXPLORER_URL}" ]] && [[ ! "${EXPLORER_URL}" == https://www.coinexplorer.net/api/v1/* ]]
      then
        # Check the collateral once every 2 minutes.
        COUNTER=$(( COUNTER + 1 ))
        if [[ ${COUNTER} =~ ${RE} ]] && [[ "${COUNTER}" -eq 24 ]]
        then
          COUNTER=0
          URL=$( echo "${EXPLORER_URL}${EXPLORER_RAWTRANSACTION_PATH}${TXHASH}${EXPLORER_RAWTRANSACTION_PATH_SUFFIX}" | tr -d '[:space:]' )
          echo "${URL}"
          OUTPUTIDX_RAW=$( wget -4qO- -T 15 -t 2 -o- "${URL}" "${BAD_SSL_HACK}" )
          sleep "${EXPLORER_SLEEP}"

          OUTPUTIDX_RAW_ALT=$( echo "$OUTPUTIDX_RAW" | jq ".data" )
          if [[ $( echo "${OUTPUTIDX_RAW_ALT}" | grep -c 'vin' ) -gt 0 ]]
          then
            OUTPUTIDX_RAW=${OUTPUTIDX_RAW_ALT}
          fi

          OUTPUTIDX_RAW_ALT=$( echo "$OUTPUTIDX_RAW" | jq ".tx" )
          if [[ $( echo "${OUTPUTIDX_RAW_ALT}" | grep -c 'vin' ) -gt 0 ]]
          then
            OUTPUTIDX_RAW=${OUTPUTIDX_RAW_ALT}
          fi

          # Make sure collateral is still valid.
          MN_WALLET_ADDR=$( echo "${OUTPUTIDX_RAW}" | tr '[:upper:]' '[:lower:]' | jq -r ".vout[] | select( (.n)|tonumber == ${OUTPUTIDX} )" 2>/dev/null )
          MN_WALLET_ADDR_ALT=$( echo "${MN_WALLET_ADDR}" | jq -r '.scriptpubkey.addresses | .[]' 2>/dev/null )
          if [[ -z "${MN_WALLET_ADDR_ALT}" ]]
          then
            MN_WALLET_ADDR_ALT=$( echo "${MN_WALLET_ADDR}" | jq -r '.address' )
          fi
          MN_WALLET_ADDR="${MN_WALLET_ADDR_ALT}"
          # Get correct upper/lower case for the address.
          MN_WALLET_ADDR=$( echo "${OUTPUTIDX_RAW}" | jq '.' | grep -io -m 1 "${MN_WALLET_ADDR}" )

          MN_WALLET_ADDR_DETAILS=$( wget -4qO- -T 15 -t 2 -o- "${EXPLORER_URL}${EXPLORER_GETADDRESS_PATH}${MN_WALLET_ADDR}" "${BAD_SSL_HACK}" | tr '[:upper:]' '[:lower:]' )
          sleep "${EXPLORER_SLEEP}"
          MN_WALLET_ADDR_BALANCE=$( echo "${MN_WALLET_ADDR_DETAILS}" | jq -r ".balance" 2>/dev/null )
          if [[ ! "${MN_WALLET_ADDR_BALANCE}" =~ $RE ]]
          then
            MN_WALLET_ADDR_BALANCE=$( echo "${MN_WALLET_ADDR_DETAILS}" | jq -r ".data" 2>/dev/null )
          fi
          if [[ ! "${MN_WALLET_ADDR_BALANCE}" =~ $RE ]]
          then
            MN_WALLET_ADDR_BALANCE=${MN_WALLET_ADDR_DETAILS}
          fi
          MN_WALLET_ADDR_BALANCE=$( echo "${MN_WALLET_ADDR_BALANCE} / ${EXPLORER_AMOUNT_ADJUST}" | bc )

          COLLATERAL_FOUND=0
          while read -r COLLATERAL_LEVEL
          do
            if [[ $( echo "${MN_WALLET_ADDR_BALANCE}>=${COLLATERAL_LEVEL}" | bc ) -eq 1 ]]
            then
              COLLATERAL_FOUND=1
              break
            fi
          done <<< "${COLLATERAL}"

          if [[ "${COLLATERAL_FOUND}" -eq 0 ]]
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
              URL=$( echo "${EXPLORER_URL}${EXPLORER_RAWTRANSACTION_PATH}${OTHERTXIDS}${EXPLORER_RAWTRANSACTION_PATH_SUFFIX}" | tr -d '[:space:]' )
              echo "${URL}"
              OUTPUTIDX_RAW=$( wget -4qO- -T 15 -t 2 -o- "${URL}" "${BAD_SSL_HACK}" | tr '[:upper:]' '[:lower:]' )
              sleep "${EXPLORER_SLEEP}"

              OUTPUTIDX_RAW_ALT=$( echo "$OUTPUTIDX_RAW" | jq ".data" )
              if [[ $( echo "${OUTPUTIDX_RAW_ALT}" | grep -c 'vin' ) -gt 0 ]]
              then
                OUTPUTIDX_RAW=${OUTPUTIDX_RAW_ALT}
              fi

              OUTPUTIDX_RAW_ALT=$( echo "$OUTPUTIDX_RAW" | jq ".tx" )
              if [[ $( echo "${OUTPUTIDX_RAW_ALT}" | grep -c 'vin' ) -gt 0 ]]
              then
                OUTPUTIDX_RAW=${OUTPUTIDX_RAW_ALT}
              fi

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
      fi
    fi

    PID_MN=$( "${USRNAME}" pid )
    if [[ -z "${PID_MN}" ]] || [[ "${#PID_MN}" -lt 3 ]]
    then
      sleep 60
      continue
    fi

    # Check status number.
    MNINFO=$( "${USRNAME}" "${MASTERNODE_PREFIX}info" 2>/dev/null )
    sleep 5

    PID_MN=$( "${USRNAME}" pid )
    if [[ -z "${PID_MN}" ]] || [[ "${#PID_MN}" -lt 3 ]]
    then
      sleep 60
      continue
    fi

    MNDEBUG=$( "${USRNAME}" "${MASTERNODE_CALLER}debug" 2>/dev/null )
    sleep 5
    if [ ! -z "${MNDEBUG}" ]
    then
      if [[ $( echo "${MNDEBUG}" | grep -ic 'successfully started' ) -gt 0 ]] || [[ $( echo "${MNDEBUG}" | grep -ic 'started remotely' ) -gt 0 ]]
      then
        MNCOUNT=$( "${USRNAME}" "${MASTERNODE_CALLER}count" 2>/dev/null )
        sleep 0.5
        if [[ $( echo "${MNCOUNT}" | grep -c 'total' ) -gt 0 ]]
        then
          MNCOUNT=$( echo "${MNCOUNT}" | jq -r '.total' 2>/dev/null )
        fi
        if [ -z "${SKIP_CONFIRM}" ] && [[ "${MINI_MONITOR_RUN}" -ne 0 ]]
        then
          echo
          "${USRNAME}" "${MASTERNODE_PREFIX}info" status
          sleep 0.5
          "${USRNAME}" "${MASTERNODE_CALLER}status"
          sleep 0.5
          "${USRNAME}" "${MASTERNODE_CALLER}debug"
          echo
          echo -e "\\e[1;4m ${MASTERNODE_NAME} ${USRNAME} successfully started! \\e[0m"
          echo "This is ${MASTERNODE_NAME} number ${MNCOUNT} in the network."
          if [[ "${MINI_MONITOR_MN_QUEUE}" -eq 1 ]]
          then
            MNHOURS=$( echo "${MNCOUNT} * ${BLOCKTIME} / 1200" | bc -l )
            printf "First payout will be in approximately %.*f hours\\n" 1 "${MNHOURS}"
          fi
          echo
          echo "Press Enter to continue"
          echo
        fi
        break
      elif [[ "${#MNINFO}" -gt 60 ]]
      then
        if [[ ${RESTART_COUNTER} =~ ${RE} ]] && [[ "${RESTART_COUNTER}" -eq 0 ]]
        then
          "${USRNAME}" stop >/dev/null 2>&1
          "${USRNAME}" start >/dev/null 2>&1
          RESTART_COUNTER=$(( RESTART_COUNTER + 1 ))
          sleep 60
        else
          if [ -z "${SKIP_CONFIRM}" ] && [[ "${MINI_MONITOR_RUN}" -ne 0 ]]
          then
            echo "${USRNAME}_${MNALIAS}"
            echo "Start ${MASTERNODE_NAME} again from desktop wallet."
            echo "Please wait for your transaction to be older than 16 blocks and try again."
            echo "You might need to restart the daemon by running this on the vps"
            echo
            echo "${USRNAME} restart"
            echo
            echo "Also verify that the genkey on the VPS matches "
            echo "what is in the desktop wallets masternode.conf"
            ${USRNAME} privkey
            echo
            sleep 180
          fi
        fi
      fi
    fi

    PID_MN=$( "${USRNAME}" pid )
    if [[ -z "${PID_MN}" ]] || [[ "${#PID_MN}" -lt 3 ]]
    then
      sleep 60
      continue
    fi

    # Restart masternode if not out of loop after 16 blocks.
    MN_UPTIME=$( "${USRNAME}" uptime 2>/dev/null | tr -d '[:space:]' )
    BLOCKS_16=$( echo "16 * ${BLOCKTIME}" | bc )
    if [[ "${MN_UPTIME}" =~ $RE ]] && [ "${MN_UPTIME}" -gt "${BLOCKS_16}" ]
    then
      "${USRNAME}" stop >/dev/null 2>&1
      "${USRNAME}" start >/dev/null 2>&1
      RESTART_COUNTER=$(( RESTART_COUNTER + 1 ))
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

if [[ "${ARG1}" == 'FIND_FREE_PORT' ]]
then
  FIND_FREE_PORT "${ARG2}"
  return 1 2>/dev/null || exit 1
fi

if [[ "${ARG1}" == 'UPDATE_BASHRC' ]]
then
  USER_FUNCTION_FOR_ALL_MASTERNODES
  return 1 2>/dev/null || exit 1
fi

if [[ "${ARG1}" == 'GENERATE_SCRIPT' ]]
then
  echo "GENERATE_SCRIPT"
  GENERATE_SCRIPT

  USRNAME="${DAEMON_PREFIX}1"
  BIN_BASE_LOWER=$( echo "${BIN_BASE}" | tr '[:upper:]' '[:lower:]' )
  echo
  echo "bash -i /root/${BIN_BASE_LOWER}d.sh 'FIRST_SYNC' '' '' '' 'y' ; source ~/.bashrc"
  echo
  echo "screen -d -m bash -i /root/${BIN_BASE_LOWER}d.sh 'FIRST_SYNC' '' '' '' 'y' ; source ~/.bashrc"
  echo
  return 1 2>/dev/null || exit 1
fi

if [[ "${ARG1}" == 'COMPILE_DAEMON' ]]
then
  echo "COMPILE_DAEMON"
  GITHUB_REPO="${2}"
  GET_MISSING_COIN_PARAMS
  echo "${GITHUB_REPO}" "${DAEMON_BIN}" "${CONTROLLER_BIN}"
  sleep 5
  COMPILE_DAEMON "${GITHUB_REPO}" "${DAEMON_BIN}" "${CONTROLLER_BIN}"

  return 1 2>/dev/null || exit 1
fi


stty sane 2>/dev/null
echo "Script Loaded."
echo
sleep 0.1
# End of masternode setup script.
