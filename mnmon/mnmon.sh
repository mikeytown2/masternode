#!/bin/bash

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
stty sane 2>/dev/null

arg1="${1}"
arg2="${2}"
arg3="${3}"

RE='^[0-9]+$'

WEBHOOK_USERNAME_DEFAULT='Masternode Monitor'
WEBHOOK_AVATAR_DEFAULT='https://i.imgur.com/8WHSSa7s.jpg'

# Daemon_bin_name URL_to_logo Bot_name
DAEMON_BIN_LUT="
energid https://s2.coinmarketcap.com/static/img/coins/128x128/3218.png Energi Monitor
dogecashd https://s2.coinmarketcap.com/static/img/coins/128x128/3672.png DogeCash Monitor
ungrid http://explorer.unigrid.org/images/logo.png UniGrid Monitor
"

# Daemon_bin_name minimum_balance_to_stake staking_reward mn_reward confirmations cooloff_seconds networkhashps_multiplier ticker_name blocktime_seconds
DAEMON_BALANCE_LUT="
energid 1 2.28 9.14 101 3600 0.000001 NRG 60
dogecashd 1 2.16 8.64 101 3600 0.000001 DOGEC 60
"

DEBUG_OUTPUT=0
if [[ "${arg1}" == 'debug' ]]
then
  DEBUG_OUTPUT=1
fi
if [[ "${arg2}" == 'debug' ]]
then
  DEBUG_OUTPUT=1
fi
if [[ "${arg3}" == 'debug' ]]
then
  DEBUG_OUTPUT=1
fi

# Get sqlite.
if ! [ -x "$(command -v sqlite3 )" ]
then
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq sqlite3
fi
# Get jq.
if ! [ -x "$(command -v jq)" ]
then
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq jq
fi

SQL_QUERY () {
  if [[ ! -d /var/multi-masternode-data/mnbot ]]
  then
    mkdir -p /var/multi-masternode-data/mnbot
  fi
  sqlite3 -batch /var/multi-masternode-data/mnbot/mnmon.sqlite3.db "${1}"
}

# Create tables if they do not exist.
SQL_QUERY "CREATE TABLE IF NOT EXISTS variables (
 key TEXT PRIMARY KEY,
 value TEXT NOT NULL
);"

SQL_QUERY "CREATE TABLE IF NOT EXISTS login_data (
  time INTEGER,
  message TEXT,
  PRIMARY KEY (time, message)
);"

SQL_QUERY "CREATE TABLE IF NOT EXISTS system_log (
  name TEXT PRIMARY KEY,
  start_time INTEGER ,
  last_ping_time INTEGER ,
  message TEXT
);"

SQL_QUERY "CREATE TABLE IF NOT EXISTS node_log (
  conf_loc TEXT,
  type TEXT,
  start_time INTEGER ,
  last_ping_time INTEGER ,
  message TEXT,
  PRIMARY KEY (conf_loc, type)
);"

DISPLAYTIME () {
  # Round up the time.
  local T=0
  T=$( printf '%.*f\n' 0 "${1}" )
  local D=$((T/60/60/24))
  local H=$((T/60/60%24))
  local M=$((T/60%60))
  local S=$((T%60))
  (( D > 0 )) && printf '%d days ' "${D}"
  (( H > 0 )) && printf '%d hours ' "${H}"
  (( M > 0 )) && printf '%d minutes ' "${M}"
  (( S > 0 )) && printf '%d seconds ' "${S}"
}

INSTALL_MN_MON_SERVICE () {
  if [[ -f "${HOME}/masternode/mnmon/mnmon.sh" ]]
  then
    cp "${HOME}/masternode/mnmon/mnmon.sh" /var/multi-masternode-data/mnbot/mnmon.sh
  else
    wget -q4o- https://raw.githubusercontent.com/mikeytown2/masternode/master/mnmon/mnmon.sh -O /var/multi-masternode-data/mnbot/mnmon.sh
  fi

  cat << SYSTEMD_CONF | sudo tee /etc/systemd/system/mnmon.service >/dev/null
[Unit]
Description=Node Monitor
After=syslog.target network.target

[Service]
SyslogIdentifier=cftimer-test-energi-sentinel
Type=oneshot
Restart=no
RestartSec=5
UMask=0027
ExecStart=/bin/bash -i /var/multi-masternode-data/mnbot/mnmon.sh cron

[Install]
WantedBy=multi-user.target
SYSTEMD_CONF

  cat << SYSTEMD_CONF | sudo tee /etc/systemd/system/mnmon.timer >/dev/null
[Unit]
Description=Run Node Monitor Every Minute
Requires=mnmon.service

[Timer]
Unit=mnmon.service
OnBootSec=60
OnUnitActiveSec=60

[Install]
WantedBy=timers.target
SYSTEMD_CONF

  cat << SYSTEMD_CONF | sudo tee /etc/systemd/system/mnmon.slice >/dev/null
[Unit]
Description=Limited resources Slice
DefaultDependencies=no
Before=slices.target

[Slice]
CPUQuota=50%
MemoryLimit=1.0G
SYSTEMD_CONF

  echo "Reload"
  sudo systemctl daemon-reload
  echo "Enable"
  sudo systemctl enable mnmon.timer --now
}

WEBHOOK_SEND () {
(
  local URL="${1}"
  local DESCRIPTION="${2}"
  local TITLE="${3}"
  local WEBHOOK_USERNAME="${4}"
  if [[ -z "${WEBHOOK_USERNAME}" ]]
  then
    WEBHOOK_USERNAME="${WEBHOOK_USERNAME_DEFAULT}"
  fi
  WEBHOOK_AVATAR="${5}"
  if [[ -z "${WEBHOOK_AVATAR}" ]]
  then
    WEBHOOK_AVATAR="${WEBHOOK_AVATAR_DEFAULT}"
  fi
  WEBHOOK_COLOR="${6}"

  # Show Date.
  SERVER_INFO=$( date -Ru )

  # Show Server Alias.
  SERVER_ALIAS=$( SQL_QUERY "SELECT value FROM variables WHERE key = 'server_alias';" )
  if [[ -z "${SERVER_ALIAS}" ]]
  then
    SERVER_ALIAS=$( hostname )
  fi
  if [[ ! -z "${SERVER_ALIAS}" ]]
  then
    SERVER_INFO="${SERVER_INFO}
- ${SERVER_ALIAS}"
  fi

  # Show IP Address.
  SHOW_IP=$( SQL_QUERY "SELECT value FROM variables WHERE key = 'show_ip';" )
  IP_ADDRESS=''
  if [[ "${SHOW_IP}" -gt 0 ]]
  then
    IP_ADDRESS=$( hostname -i )
  fi
  if [[ ! -z "${IP_ADDRESS}" ]]
  then
    SERVER_INFO="${SERVER_INFO}
- ${IP_ADDRESS}"
  fi

  # Allow footer Override.
  if [[ ! -z "${7}" ]]
  then
    SERVER_INFO="${7}"
  fi

  # Replace new line with \n
  DESCRIPTION=$( echo "${DESCRIPTION}" | awk '{printf "%s\\n", $0}' )
  SERVER_INFO=$( echo "${SERVER_INFO}" | awk '{printf "%s\\n", $0}' )
  TITLE=$( echo "${TITLE}" | awk '{printf "%s\\n", $0}' )

  # Build HTTP POST.
  _PAYLOAD=$( cat << PAYLOAD
{
  "username": "${WEBHOOK_USERNAME} - ${SERVER_ALIAS}",
  "avatar_url": "${WEBHOOK_AVATAR}",
  "content": "**${TITLE}**",
  "embeds": [{
    "color": ${WEBHOOK_COLOR},
    "title": "${DESCRIPTION}",
    "description": "${SERVER_INFO}"
  }]
}
PAYLOAD
)

  # Do the post.
  OUTPUT=$( curl -H "Content-Type: application/json" -s -X POST "${URL}" -d "${_PAYLOAD}" | sed '/^[[:space:]]*$/d' )
  if [[ ! -z "${OUTPUT}" ]]
  then
    MS_WAIT=$( echo "${OUTPUT}" | jq -r '.retry_after' 2>/dev/null )
    if [[ ! -z "${MS_WAIT}" ]]
    then
      SECONDS_WAIT=$( printf "%.1f\n" "$( echo "scale=3;${MS_WAIT}/1000" | bc -l )" )
      SECONDS_WAIT=$( echo "${SECONDS_WAIT} + 0.1" | bc -l )
      sleep "${SECONDS_WAIT}"
      OUTPUT=$( curl -H "Content-Type: application/json" -s -X POST "${URL}" -d "${_PAYLOAD}" | sed '/^[[:space:]]*$/d' )
    fi
  fi
  if [[ ! -z "${OUTPUT}" ]]
  then
    echo "Discord Error"
    echo "curl -H Content-Type: application/json -s -X POST ${URL} -d '${_PAYLOAD}'"
    echo "${OUTPUT}" | jq '.'
    echo "Payload:"
    echo "${_PAYLOAD}"
    echo "-"
  fi
)
}

TELEGRAM_SEND () {
(
  TOKEN="${1}"
  CHAT_ID="${2}"
  TITLE="${3}"
  MESSAGE="${4}"

  # https://apps.timwhitlock.info/emoji/tables/unicode
  # http://www.unicode.org/emoji/charts/full-emoji-list.html
  # https://onlineutf8tools.com/convert-utf8-to-bytes
  MESSAGE=$( echo "${MESSAGE}" | \
    sed 's/:exclamation:/\xE2\x9D\x97/g' | \
    sed 's/:unlock:/\xF0\x9F\x94\x93/g' | \
    sed 's/:warning:/\xE2\x9A\xA0/g' | \
    sed 's/:blue_book:/\xF0\x9F\x93\x98/g' | \
    sed 's/:money_mouth:/\xF0\x9F\xA4\x91/g' | \
    sed 's/:moneybag:/\xF0\x9F\x92\xB0/g' | \
    sed 's/:floppy_disk:/\xF0\x9F\x92\xBE/g' | \
    sed 's/:desktop:/\xF0\x9F\x96\xA5/g' | \
    sed 's/:wrench:/\xF0\x9F\x94\xA7/g' | \
    sed 's/:fire:/\xF0\x9F\x94\xA5/g' )

  TITLE=$( echo "${TITLE}" | \
    sed 's/:exclamation:/\xE2\x9D\x97/g' | \
    sed 's/:unlock:/\xF0\x9F\x94\x93/g' | \
    sed 's/:warning:/\xE2\x9A\xA0/g' | \
    sed 's/:blue_book:/\xF0\x9F\x93\x98/g' | \
    sed 's/:money_mouth:/\xF0\x9F\xA4\x91/g' | \
    sed 's/:moneybag:/\xF0\x9F\x92\xB0/g' | \
    sed 's/:floppy_disk:/\xF0\x9F\x92\xBE/g' | \
    sed 's/:desktop:/\xF0\x9F\x96\xA5/g' | \
    sed 's/:wrench:/\xF0\x9F\x94\xA7/g' | \
    sed 's/:fire:/\xF0\x9F\x94\xA5/g' )

  SERVER_INFO=$( date -Ru )

  SHOW_IP=$( SQL_QUERY "SELECT value FROM variables WHERE key = 'show_ip';" )
  if [[ "${SHOW_IP}" -gt 0 ]]
  then
    # shellcheck disable=SC2028
    SERVER_INFO=$( echo -ne "${SERVER_INFO}\n - " ; hostname -i )
  fi

  SERVER_ALIAS=$( SQL_QUERY "SELECT value FROM variables WHERE key = 'server_alias';" )
  if [[ -z "${SERVER_ALIAS}" ]]
  then
    # shellcheck disable=SC2028
    SERVER_INFO=$( echo -ne "${SERVER_INFO}\n - " ; hostname )
  else
    SERVER_INFO=$( echo -ne "${SERVER_INFO}\n - ${SERVER_ALIAS}" )
  fi
  if [[ ! -z "${5}" ]]
  then
    SERVER_INFO="${5}"
  fi

  _PAYLOAD="text=<b>${TITLE}</b>
<i>${SERVER_INFO}</i>
${MESSAGE}"

  URL="https://api.telegram.org/bot$TOKEN/sendMessage"
  TELEGRAM_MSG=$( curl -s -X POST "${URL}" -d "chat_id=${CHAT_ID}&parse_mode=html" -d "${_PAYLOAD}" | sed '/^[[:space:]]*$/d' )
  IS_OK=$( echo "${TELEGRAM_MSG}" | jq '.ok' )

  if [[ "${IS_OK}" != 'true' ]]
  then
    echo "Telegram Error"
    echo "${TELEGRAM_MSG}" | jq '.'
    echo "Payload:"
    echo "${_PAYLOAD}"
    echo "-"
  fi
  sleep 0.3
)
}

TELEGRAM_SETUP () {
  TOKEN=$( SQL_QUERY "SELECT value FROM variables WHERE key = 'telegram_token';" )
  echo "Message the @botfather https://web.telegram.org/#/im?p=@BotFather"
  echo "with the following text: "
  echo "/start"
  echo "/newbot"
  echo "Then paste in the token below"
  read -r -e -i "${TOKEN}" -p "Telegram Token: "
  if [[ ! -z "${REPLY}" ]]
  then
    TOKEN="${REPLY}"
  fi

  CHAT_ID=$( SQL_QUERY "SELECT value FROM variables WHERE key = 'telegram_chatid';" )
  if [[ -z "${CHAT_ID}" ]] || [[ "${CHAT_ID}" == 'null' ]]
  then
    while :
    do
      GET_UPDATES=$( curl -s "https://api.telegram.org/bot${TOKEN}/getUpdates" )
      IS_OK=$( echo "${GET_UPDATES}" | jq '.ok' )
      if [[ "${IS_OK}" != 'true' ]]
      then
        echo "Please message the bot."
        read -p "When done press enter or q to quit." -r
        REPLY=${REPLY,,} # tolower
        if [[ "${REPLY}" == q ]]
        then
          return 1 2>/dev/null
        fi
        sleep 1
      else
        break
      fi
    done

    while :
    do
      GET_UPDATES=$( curl -s "https://api.telegram.org/bot${TOKEN}/getUpdates" )
      CHAT_ID=$( echo "${GET_UPDATES}" | jq '.result[0].message.chat.id' 2>/dev/null )
      if [[ -z "${CHAT_ID}" ]]
      then
        echo "Please message the bot."
      else
        SQL_QUERY "REPLACE INTO variables (key,value) VALUES ('telegram_token','${TOKEN}');"
        SQL_QUERY "REPLACE INTO variables (key,value) VALUES ('telegram_chatid','${CHAT_ID}');"
        break
      fi
    done
  fi

  TITLE="Test Title"
  MESSAGE="Bot Works!"
  TELEGRAM_SEND "${TOKEN}" "${CHAT_ID}" "${TITLE}" "<pre>${MESSAGE}</pre>"
}

SEND_ERROR () {
  URL=$( SQL_QUERY "SELECT value FROM variables WHERE key = 'discord_webhook_url_error';" )
  TOKEN=$( SQL_QUERY "SELECT value FROM variables WHERE key = 'telegram_token';" )
  CHAT_ID=$( SQL_QUERY "SELECT value FROM variables WHERE key = 'telegram_chatid';" )

  DESCRIPTION="${1}"
  if [[ -z "${DESCRIPTION}" ]]
  then
    DESCRIPTION="Default Error Message!"
  fi
  TITLE="${2}"
  if [[ -z "${TITLE}" ]]
  then
    TITLE=":exclamation: Error :exclamation:"
  fi
  WEBHOOK_COLOR="${5}"
  if [[ -z "${WEBHOOK_COLOR}" ]]
  then
    WEBHOOK_COLOR=16711680
  fi
  if [[ ! -z "${6}" ]]
  then
    URL="${6}"
  fi

  SENT=0
  if [[ ! -z "${URL}" ]]
  then
    SENT=1
    WEBHOOK_SEND "${URL}" "${DESCRIPTION}" "${TITLE}" "${3}" "${4}" "${WEBHOOK_COLOR}"
  fi
  if [[ ! -z "${TOKEN}" ]] && [[ ! -z "${CHAT_ID}" ]]
  then
    SENT=1
    TELEGRAM_SEND "${TOKEN}" "${CHAT_ID}" "${TITLE}" "<code>${DESCRIPTION}</code>"
  fi
  if [[ "${SENT}" -eq 0 ]] || [[ "${DEBUG_OUTPUT}" -eq 1 ]]
  then
    echo "${TITLE}"
    echo "${DESCRIPTION}"
    echo "-"
  fi
}

SEND_WARNING () {
  URL=$( SQL_QUERY "SELECT value FROM variables WHERE key = 'discord_webhook_url_warning';" )
  TOKEN=$( SQL_QUERY "SELECT value FROM variables WHERE key = 'telegram_token';" )
  CHAT_ID=$( SQL_QUERY "SELECT value FROM variables WHERE key = 'telegram_chatid';" )

  DESCRIPTION="${1}"
  if [[ -z "${DESCRIPTION}" ]]
  then
    DESCRIPTION="Default Warning Message."
  fi
  TITLE="${2}"
  if [[ -z "${TITLE}" ]]
  then
    TITLE=":warning: Warning :warning:"
  fi
  WEBHOOK_COLOR="${5}"
  if [[ -z "${WEBHOOK_COLOR}" ]]
  then
    WEBHOOK_COLOR=16776960
  fi
  if [[ ! -z "${6}" ]]
  then
    URL="${6}"
  fi

  SENT=0
  if [[ ! -z "${URL}" ]]
  then
    SENT=1
    WEBHOOK_SEND "${URL}" "${DESCRIPTION}" "${TITLE}" "${3}" "${4}" "${WEBHOOK_COLOR}"
  fi
  if [[ ! -z "${TOKEN}" ]] && [[ ! -z "${CHAT_ID}" ]]
  then
    SENT=1
    TELEGRAM_SEND "${TOKEN}" "${CHAT_ID}" "${TITLE}" "<pre>${DESCRIPTION}</pre>"
  fi
  if [[ "${SENT}" -eq 0 ]] || [[ "${DEBUG_OUTPUT}" -eq 1 ]]
  then
    echo "${TITLE}"
    echo "${DESCRIPTION}"
    echo "-"
  fi
}

SEND_INFO () {
  URL=$( SQL_QUERY "SELECT value FROM variables WHERE key = 'discord_webhook_url_information';" )
  TOKEN=$( SQL_QUERY "SELECT value FROM variables WHERE key = 'telegram_token';" )
  CHAT_ID=$( SQL_QUERY "SELECT value FROM variables WHERE key = 'telegram_chatid';" )

  DESCRIPTION="${1}"
  if [[ -z "${DESCRIPTION}" ]]
  then
    DESCRIPTION="Default Information Message."
  fi
  TITLE="${2}"
  if [[ -z "${TITLE}" ]]
  then
    TITLE=":blue_book: Information :blue_book:"
  fi
  WEBHOOK_COLOR="${5}"
  if [[ -z "${WEBHOOK_COLOR}" ]]
  then
    WEBHOOK_COLOR=65535
  fi
  if [[ ! -z "${6}" ]]
  then
    URL="${6}"
  fi

  SENT=0
  if [[ ! -z "${URL}" ]]
  then
    SENT=1
    WEBHOOK_SEND "${URL}" "${DESCRIPTION}" "${TITLE}" "${3}" "${4}" "${WEBHOOK_COLOR}"
  fi
  if [[ ! -z "${TOKEN}" ]] && [[ ! -z "${CHAT_ID}" ]]
  then
    SENT=1
    TELEGRAM_SEND "${TOKEN}" "${CHAT_ID}" "${TITLE}" "<pre>${DESCRIPTION}</pre>"
  fi
  if [[ "${SENT}" -eq 0 ]] || [[ "${DEBUG_OUTPUT}" -eq 1 ]]
  then
    echo "${TITLE}"
    echo "${DESCRIPTION}"
    echo "-"
  fi
}

SEND_SUCCESS () {
  URL=$( SQL_QUERY "SELECT value FROM variables WHERE key = 'discord_webhook_url_success';" )
  TOKEN=$( SQL_QUERY "SELECT value FROM variables WHERE key = 'telegram_token';" )
  CHAT_ID=$( SQL_QUERY "SELECT value FROM variables WHERE key = 'telegram_chatid';" )

  DESCRIPTION="${1}"
  if [[ -z "${DESCRIPTION}" ]]
  then
    DESCRIPTION="Default Success Message!"
  fi
  TITLE="${2}"
  if [[ -z "${TITLE}" ]]
  then
    TITLE=":moneybag: Success :money_mouth:"
  fi
  WEBHOOK_COLOR="${5}"
  if [[ -z "${WEBHOOK_COLOR}" ]]
  then
    WEBHOOK_COLOR=65535
  fi
  if [[ ! -z "${6}" ]]
  then
    URL="${6}"
  fi

  SENT=0
  if [[ ! -z "${URL}" ]]
  then
    SENT=1
    WEBHOOK_SEND "${URL}" "${DESCRIPTION}" "${TITLE}" "${3}" "${4}" "${WEBHOOK_COLOR}"
  fi
  if [[ ! -z "${TOKEN}" ]] && [[ ! -z "${CHAT_ID}" ]]
  then
    SENT=1
    TELEGRAM_SEND "${TOKEN}" "${CHAT_ID}" "${TITLE}" "<pre>${DESCRIPTION}</pre>"
  fi
  if [[ "${SENT}" -eq 0 ]] || [[ "${DEBUG_OUTPUT}" -eq 1 ]]
  then
    echo "${TITLE}"
    echo "${DESCRIPTION}"
    echo "-"
  fi
}

WEBHOOK_URL_PROMPT () {
  TEXT_A="${1}"
  WEBHOOKURL="${2}"
  while :
  do
    echo
    read -r -e -i "${WEBHOOKURL}" -p "${TEXT_A}s webhook url: " input
    WEBHOOKURL="${input:-${WEBHOOKURL}}"
    if [[ ! -z "${WEBHOOKURL}" ]]
    then
      TOKEN=$( wget -qO- -o- "${WEBHOOKURL}" | jq -r '.token' )
      if [[ -z "${TOKEN}" ]]
      then
        echo "Given URL is not a webhook."
        echo
        echo -n 'Get Webhook URL: Your personal server (press plus on left if you do not have one)'
        echo -n ' -> Right click on your server -> Server Settings -> Webhooks'
        echo -n ' -> Create Webhook -> Copy webhook url -> save'
        echo
        WEBHOOKURL=''
      else
        echo "${TOKEN}"
        break
      fi
    fi
  done
  SQL_QUERY "REPLACE INTO variables (key,value) VALUES ('discord_webhook_url_${TEXT_A}','${WEBHOOKURL}');"
}

GET_DISCORD_WEBHOOKS () {
  WEBHOOKURL=$( SQL_QUERY "SELECT value FROM variables WHERE key = 'discord_webhook_url_error';" )
  if [[ -z "${WEBHOOKURL}" ]] || [[ "${REPLY}" == y ]]
  then
    # Get webhook url.
    echo
    echo -n 'Get Webhook URL: Your personal server (press plus on left if you do not have one)'
    echo -n ' -> text channels, general, click gear to "edit channel" -> Left side SELECT Webhooks'
    echo -n ' -> Create Webhook -> Copy webhook url -> save'
    echo
    echo "This webhook will be used for ${TEXT_A} Messages."
    echo 'You can reuse the same webhook url if you want all alerts and information'
    echo 'pings in the same channel.'

    WEBHOOK_URL_PROMPT "error" "${WEBHOOKURL}"
    SEND_ERROR "Test"
  fi
  WEBHOOKURL=$( SQL_QUERY "SELECT value FROM variables WHERE key = 'discord_webhook_url_warning';" )
  if [[ -z "${WEBHOOKURL}" ]] || [[ "${REPLY}" == y ]]
  then
    WEBHOOK_URL_PROMPT "warning" "${WEBHOOKURL}"
    SEND_WARNING "Test"
  fi
  WEBHOOKURL=$( SQL_QUERY "SELECT value FROM variables WHERE key = 'discord_webhook_url_information';" )
  if [[ -z "${WEBHOOKURL}" ]] || [[ "${REPLY}" == y ]]
  then
    WEBHOOK_URL_PROMPT "information" "${WEBHOOKURL}"
    SEND_INFO "Test"
  fi
  WEBHOOKURL=$( SQL_QUERY "SELECT value FROM variables WHERE key = 'discord_webhook_url_success';" )
  if [[ -z "${WEBHOOKURL}" ]] || [[ "${REPLY}" == y ]]
  then
    WEBHOOK_URL_PROMPT "success" "${WEBHOOKURL}"
    SEND_SUCCESS "Test"
  fi
}

if [[ "${arg1}" != 'cron' ]]
then
  echo
  SERVER_ALIAS=$( SQL_QUERY "SELECT value FROM variables WHERE key = 'server_alias';" )
  if [[ -z "${SERVER_ALIAS}" ]]
  then
    SERVER_ALIAS=$( hostname )
  fi
  read -e -p "Current alias for this server: " -i "${SERVER_ALIAS}" -r
  SQL_QUERY "REPLACE INTO variables (key,value) VALUES ('server_alias','${REPLY}');"

  echo
  echo -ne "IP Address: "; hostname -i
  SHOW_IP=$( SQL_QUERY "SELECT value FROM variables WHERE key = 'show_ip';" )
  if [[ -z "${SHOW_IP}" ]] || [[ "${SHOW_IP}" == '1' ]]
  then
    SHOW_IP='y'
  else
    SHOW_IP='n'
  fi
  read -e -p "Display IP in logs (y/n)? " -i "${SHOW_IP}" -r
  REPLY=${REPLY,,} # tolower
  if [[ "${REPLY}" == y ]]
  then
    SQL_QUERY "REPLACE INTO variables (key,value) VALUES ('show_ip','1');"
  else
    SQL_QUERY "REPLACE INTO variables (key,value) VALUES ('show_ip','0');"
  fi

  echo
  PREFIX='Setup'
  REPLY='y'
  WEBHOOKURL=$( SQL_QUERY "SELECT value FROM variables WHERE key = 'discord_webhook_url_error';" )
  if [[ ! -z "${WEBHOOKURL}" ]]
  then
    REPLY='n'
    PREFIX='Redo'
  fi
  read -e -p "${PREFIX} Discord Bot webhook URLs (y/n)? " -i "${REPLY}" -r
  REPLY=${REPLY,,} # tolower
  if [[ "${REPLY}" == y ]]
  then
    GET_DISCORD_WEBHOOKS
    echo "Discord Done"
  fi

  echo
  PREFIX='Setup'
  REPLY='y'
  WEBHOOKURL=$( SQL_QUERY "SELECT value FROM variables WHERE key = 'discord_webhook_url_error';" )
  CHAT_ID=$( SQL_QUERY "SELECT value FROM variables WHERE key = 'telegram_chatid';" )
  if [[ ! -z "${WEBHOOKURL}" ]]
  then
    REPLY='n'
  fi
  if [[ ! -z "${CHAT_ID}" ]]
  then
    REPLY='n'
    PREFIX='Redo'
  fi
  read -e -p "${PREFIX} Telegram Bot token (y/n)? " -i "${REPLY}" -r
  REPLY=${REPLY,,} # tolower
  if [[ "${REPLY}" == y ]]
  then
    TELEGRAM_SETUP
    echo "Telegram Done"
  fi

  echo
  echo "Installing as a systemd service."
  sleep 1
  INSTALL_MN_MON_SERVICE
  echo "Service Install Done"
  return 1 2>/dev/null || exit 1

fi

PROCESS_MESSAGES () {
  local NAME=${1}
  local MESSAGE_ERROR=${2}
  local MESSAGE_WARNING=${3}
  local MESSAGE_INFO=${4}
  local MESSAGE_SUCCESS=${5}
  local RECOVERED_MESSAGE_SUCCESS=${6}
  local RECOVERED_TITLE_SUCCESS=${7}
  local WEBHOOK_USERNAME=${8}
  local WEBHOOK_AVATAR=${9}

  # Get past events.
  UNIX_TIME=$( date -u +%s )
  MESSAGE_PAST=$( SQL_QUERY "SELECT start_time,last_ping_time,message FROM system_log WHERE name == '${NAME}'; " )
  START_TIME=$( echo "${MESSAGE_PAST}" | cut -d \| -f1 )
  if [[ ! ${START_TIME} =~ ${RE} ]]
  then
    START_TIME="${UNIX_TIME}"
  fi
  LAST_PING_TIME=$( echo "${MESSAGE_PAST}" | cut -d \| -f2 )
  if [[ ! ${LAST_PING_TIME} =~ ${RE} ]]
  then
    LAST_PING_TIME='0'
  fi
  MESSAGE_PAST=$( echo "${MESSAGE_PAST}" | cut -d \| -f3 )

  # Send recovery message.
  if [[ -z "${MESSAGE_ERROR}" ]] && [[ -z "${MESSAGE_WARNING}" ]] && [[ ! -z "${MESSAGE_PAST}" ]] && [[ ! -z "${RECOVERED_MESSAGE_SUCCESS}" ]]
  then
    ERRORS=$( SEND_SUCCESS "${RECOVERED_MESSAGE_SUCCESS}" ":wrench: ${RECOVERED_TITLE_SUCCESS} :wrench:" )
    if [[ ! -z "${ERRORS}" ]]
    then
      echo "ERROR: ${ERRORS}"
    else
      SQL_QUERY "DELETE FROM system_log WHERE name == '${NAME}'; "
    fi
  fi

  # Send message out.
  ERRORS=''
  MESSAGE=''
  if [[ ! -z "${MESSAGE_ERROR}" ]] && [[ "${SECONDS_SINCE_PING}" -gt 300 ]]
  then
    ERRORS=$( SEND_ERROR "${MESSAGE_ERROR}" "" "${WEBHOOK_USERNAME}" "${WEBHOOK_AVATAR}" )
    MESSAGE="${MESSAGE_ERROR}"
  elif [[ ! -z "${MESSAGE_WARNING}" ]] && [[ "${SECONDS_SINCE_PING}" -gt 900 ]]
  then
    ERRORS=$( SEND_WARNING "${MESSAGE_WARNING}" "" "${WEBHOOK_USERNAME}" "${WEBHOOK_AVATAR}" )
    MESSAGE="${MESSAGE_WARNING}"
  elif [[ ! -z "${MESSAGE_INFO}" ]] && [[ "${SECONDS_SINCE_PING}" -gt 3600 ]]
  then
    ERRORS=$( SEND_INFO "${MESSAGE_INFO}" "" "${WEBHOOK_USERNAME}" "${WEBHOOK_AVATAR}" )
    MESSAGE="${MESSAGE_INFO}"
  elif [[ ! -z "${MESSAGE_SUCCESS}" ]]
  then
    ERRORS=$( SEND_SUCCESS "${MESSAGE_SUCCESS}" "" "${WEBHOOK_USERNAME}" "${WEBHOOK_AVATAR}" )
    MESSAGE="${MESSAGE_SUCCESS}"
  fi

  # Write to the database.
  if [[ ! -z "${ERRORS}" ]]
  then
    echo "${ERRORS}" >/dev/tty
  elif [[ "${arg1}" != 'test' ]] && [[ ! -z "${MESSAGE}" ]]
  then
    SQL_QUERY "REPLACE INTO system_log (start_time,last_ping_time,name,message) VALUES ('${START_TIME}','${UNIX_TIME}','${NAME}','${MESSAGE}');"
  fi
}

GET_LATEST_LOGINS () {
  while read -r DATE_1 DATE_2 DATE_3 LINE
  do
#     echo "GET_LATEST_LOGINS ${LINE}" >/dev/tty
    INFO=$( echo "${LINE}" | grep -oE '\]\: .*' | cut -c 4- )

    if [[ -z "${INFO}" ]]
    then
      continue
    fi

    UNIX_TIME_LOG=$( date -u --date="${DATE_1} ${DATE_2} ${DATE_3}" +%s )
    # Logins are one time; not continual issues.
    MESSAGE=$( SQL_QUERY "SELECT message FROM login_data WHERE time == ${UNIX_TIME_LOG} " )
    if [[ ! -z "${MESSAGE}" ]] && [[ "${arg1}" != 'test' ]]
    then
      if [[ "${DEBUG_OUTPUT}" -eq 1 ]]
      then
        echo "Skipping GET_LATEST_LOGINS ${DATE_1} ${DATE_2} ${DATE_3} ${UNIX_TIME_LOG} ${MESSAGE}" | awk '{printf "%s ", $0}'
        echo
      fi
      continue
    fi

    ERRORS=$( SEND_INFO "${INFO}" ":unlock: User logged in" )
    if [[ ! -z "${ERRORS}" ]]
    then
      echo "ERROR: ${ERRORS}"
    elif [[ "${arg1}" != 'test' ]]
    then
      SQL_QUERY "INSERT INTO login_data (time,message) VALUES ('${UNIX_TIME_LOG}','${INFO}');"
    fi
  done <<< "$( grep -B 20 ' systemd-logind' /var/log/auth.log | grep -B 20 'New' | grep -C10 'sshd' | grep port | grep -v 'CRON\|preauth\|Invalid user\|user unknown\|Failed[[:space:]]password\|authentication[[:space:]]failure\|refused[[:space:]]connect\|ignoring[[:space:]]max\|not[[:space:]]receive[[:space:]]identification\|[[:space:]]sudo\|[[:space:]]su\|Bad[[:space:]]protocol' )"
}
GET_LATEST_LOGINS

CHECK_DISK () {
  NAME='disk_space'
  MESSAGE_ERROR=''
  MESSAGE_WARNING=''
  MESSAGE_INFO=''
  MESSAGE_SUCCESS=''

  FREEPSPACE_ALL=$( df -P . | tail -1 | awk '{print $4}' )
  FREEPSPACE_BOOT=$( df -P /boot | tail -1 | awk '{print $4}' )
  if [[ "${FREEPSPACE_ALL}" -lt 524288 ]] || [[ "${arg1}" == 'test' ]]
  then
    FREEPSPACE_ALL=$( echo "${FREEPSPACE_ALL} / 1024" | bc )
    MESSAGE_ERROR="${MESSAGE_ERROR} Less than 512 MB of free space is left on the drive. ${FREEPSPACE_ALL} MB left."
  fi
  if [[ "${FREEPSPACE_BOOT}" -lt 65536 ]] || [[ "${arg1}" == 'test' ]]
  then
    FREEPSPACE_BOOT=$( echo "${FREEPSPACE_BOOT} / 1024" | bc )
    MESSAGE_ERROR="${MESSAGE_ERROR} Less than 64 MB of free space is left in the boot folder. ${FREEPSPACE_BOOT} MB left."
  fi

  if [[ -z "${MESSAGE_ERROR}" ]]
  then
    if [[ "${FREEPSPACE_ALL}" -lt 1572864 ]] || [[ "${arg1}" == 'test' ]]
    then
      FREEPSPACE_ALL=$( echo "${FREEPSPACE_ALL} / 1024" | bc )
      MESSAGE_WARNING="${MESSAGE_WARNING} Less than 1.5 GB of free space is left on the drive. ${FREEPSPACE_ALL} MB left."
    fi
    if [[ "${FREEPSPACE_BOOT}" -lt 131072 ]] || [[ "${arg1}" == 'test' ]]
    then
      FREEPSPACE_BOOT=$( echo "${FREEPSPACE_BOOT} / 1024" | bc )
      MESSAGE_WARNING="${MESSAGE_WARNING} Less than 128 MB of free space is left in the boot folder. ${FREEPSPACE_BOOT} MB left."
    fi
  fi

  if [[ ! -z "${MESSAGE_ERROR}" ]]
  then
    MESSAGE_ERROR=":floppy_disk: :fire: ${MESSAGE_ERROR} :fire: :floppy_disk:"
  fi
  if [[ ! -z "${MESSAGE_WARNING}" ]]
  then
    MESSAGE_WARNING=":floppy_disk: ${MESSAGE_WARNING} :floppy_disk:"
  fi

  RECOVERED_MESSAGE_SUCCESS="Hard drive has ${FREEPSPACE_ALL} MB Free; boot folder has ${FREEPSPACE_BOOT} MB Free."
  RECOVERED_TITLE_SUCCESS="Low diskspace issue has been resolved."
  PROCESS_MESSAGES "${NAME}" "${MESSAGE_ERROR}" "${MESSAGE_WARNING}" "${MESSAGE_INFO}" "${MESSAGE_SUCCESS}" "${RECOVERED_MESSAGE_SUCCESS}" "${RECOVERED_TITLE_SUCCESS}" "${WEBHOOK_USERNAME_DEFAULT}" "${WEBHOOK_AVATAR_DEFAULT}"
}
CHECK_DISK

CHECK_CPU_LOAD () {
  NAME='cpu_usage'
  MESSAGE_ERROR=''
  MESSAGE_WARNING=''
  MESSAGE_INFO=''
  MESSAGE_SUCCESS=''

  LOAD=$( uptime | grep -oE 'load average: [0-9]+([.][0-9]+)?' | grep -oE '[0-9]+([.][0-9]+)?' )
  CPU_COUNT=$( grep -c 'processor' /proc/cpuinfo )
  LOAD_PER_CPU="$( printf "%.3f\n" "$( bc -l <<< "${LOAD} / ${CPU_COUNT}" )" )"

  if [[ "$( echo "${LOAD_PER_CPU} > 4" | bc )" -gt 0 ]] || [[ "${arg1}" == 'test' ]]
  then
    MESSAGE_ERROR=" :desktop: :fire:  CPU LOAD is over 4: ${LOAD_PER_CPU} :fire: :desktop: "
  elif [[ "$( echo "${LOAD_PER_CPU} > 2" | bc )" -gt 0 ]] || [[ "${arg1}" == 'test' ]]
  then
    MESSAGE_WARNING=" :desktop: CPU LOAD is over 2: ${LOAD_PER_CPU} :desktop: "
  fi

  RECOVERED_MESSAGE_SUCCESS="Load per CPU is ${LOAD_PER_CPU}."
  RECOVERED_TITLE_SUCCESS="CPU Load is back to normal."
  PROCESS_MESSAGES "${NAME}" "${MESSAGE_ERROR}" "${MESSAGE_WARNING}" "${MESSAGE_INFO}" "${MESSAGE_SUCCESS}" "${RECOVERED_MESSAGE_SUCCESS}" "${RECOVERED_TITLE_SUCCESS}" "${WEBHOOK_USERNAME_DEFAULT}" "${WEBHOOK_AVATAR_DEFAULT}"
}
CHECK_CPU_LOAD

CHECK_SWAP () {
  NAME='swap_free'
  MESSAGE_ERROR=''
  MESSAGE_WARNING=''
  MESSAGE_INFO=''
  MESSAGE_SUCCESS=''

  SWAP_FREE_MB=$( free -wm | grep -i 'Swap:' | awk '{print $4}' )
  if [[ $( echo "${SWAP_FREE_MB} < 512" | bc ) -gt 0 ]] || [[ "${arg1}" == 'test' ]]
  then
    MESSAGE_ERROR=":desktop: :fire: Swap is under 512 MB: ${SWAP_FREE_MB} MB :fire: :desktop: "
  fi
  if ([[ $( echo "${SWAP_FREE_MB} >= 512" | bc ) -gt 0 ]] && [[ $( echo "${SWAP_FREE_MB} < 1024" | bc ) -gt 0 ]]) || [[ "${arg1}" == 'test' ]]
  then
    MESSAGE_WARNING=":desktop: Swap is under 1024 MB: ${SWAP_FREE_MB} MB :desktop: "
  fi

  RECOVERED_MESSAGE_SUCCESS="Free Swap space is ${SWAP_FREE_MB} MB."
  RECOVERED_TITLE_SUCCESS="Free sawp space is back to normal."
  PROCESS_MESSAGES "${NAME}" "${MESSAGE_ERROR}" "${MESSAGE_WARNING}" "${MESSAGE_INFO}" "${MESSAGE_SUCCESS}" "${RECOVERED_MESSAGE_SUCCESS}" "${RECOVERED_TITLE_SUCCESS}" "${WEBHOOK_USERNAME_DEFAULT}" "${WEBHOOK_AVATAR_DEFAULT}"
}
CHECK_SWAP

CHECK_RAM () {
  NAME='ram_free'
  MESSAGE_ERROR=''
  MESSAGE_WARNING=''
  MESSAGE_INFO=''
  MESSAGE_SUCCESS=''

  MEM_AVAILABLE=$( sudo cat /proc/meminfo | grep -i 'MemAvailable:\|MemFree:' | awk '{print $2}' | tail -n 1 )
  MEM_AVAILABLE_MB=$( echo "${MEM_AVAILABLE} / 1024" | bc )

  if [[ $( echo "${MEM_AVAILABLE_MB} < 256" | bc ) -gt 0 ]] || [[ "${arg1}" == 'test' ]]
  then
    MESSAGE_ERROR=":desktop: :fire: Free RAM is under 256 MB: ${MEM_AVAILABLE_MB} MB :fire: :desktop: "
  fi
  if ([[ $( echo "${MEM_AVAILABLE_MB} >= 256" | bc ) -gt 0 ]] && [[ $( echo "${MEM_AVAILABLE_MB} < 512" | bc ) -gt 0 ]]) || [[ "${arg1}" == 'test' ]]
  then
    MESSAGE_WARNING=":desktop: Free RAM is under 512 MB: ${MEM_AVAILABLE_MB} MB :desktop: "
  fi

  RECOVERED_MESSAGE_SUCCESS="Free RAM is now at ${MEM_AVAILABLE_MB} MB."
  RECOVERED_TITLE_SUCCESS="Free RAM is back to normal."
  PROCESS_MESSAGES "${NAME}" "${MESSAGE_ERROR}" "${MESSAGE_WARNING}" "${MESSAGE_INFO}" "${MESSAGE_SUCCESS}" "${RECOVERED_MESSAGE_SUCCESS}" "${RECOVERED_TITLE_SUCCESS}" "${WEBHOOK_USERNAME_DEFAULT}" "${WEBHOOK_AVATAR_DEFAULT}"
}
CHECK_RAM

PROCESS_NODE_MESSAGES () {
  CONF_LOCATION=''
  TYPE=''
  MESSAGE_ERROR=''
  MESSAGE_WARNING=''
  MESSAGE_INFO=''
  MESSAGE_SUCCESS=''
  RECOVERED_MESSAGE_SUCCESS=''
  RECOVERED_TITLE_SUCCESS=''

  CONF_LOCATION=${1}
  TYPE=${2}
  MESSAGE_ERROR=${3}
  MESSAGE_WARNING=${4}
  MESSAGE_INFO=${5}
  MESSAGE_SUCCESS=${6}
  RECOVERED_MESSAGE_SUCCESS=${7}
  RECOVERED_TITLE_SUCCESS=${8}
  WEBHOOK_USERNAME=${9}
  WEBHOOK_AVATAR=${10}


  # Get past events.
  UNIX_TIME=$( date -u +%s )
  MESSAGE_PAST=$( SQL_QUERY "SELECT start_time,last_ping_time,message FROM node_log WHERE conf_loc == '${CONF_LOCATION}' AND type == '${TYPE}'; " )
  START_TIME=$( echo "${MESSAGE_PAST}" | head -n1 | cut -d \| -f1 )
  if [[ ! ${START_TIME} =~ ${RE} ]]
  then
    START_TIME="${UNIX_TIME}"
  fi
  LAST_PING_TIME=$( echo "${MESSAGE_PAST}" | head -n1 | cut -d \| -f2 )
  if [[ ! ${LAST_PING_TIME} =~ ${RE} ]]
  then
    LAST_PING_TIME='0'
  fi
  MESSAGE_PAST=$( echo "${MESSAGE_PAST}" | cut -d \| -f3 )

  # Send recovery message.
  if [[ -z "${MESSAGE_ERROR}" ]] && [[ -z "${MESSAGE_WARNING}" ]] && [[ ! -z "${MESSAGE_PAST}" ]] && [[ ! -z "${RECOVERED_MESSAGE_SUCCESS}" ]]
  then
    ERRORS=$( SEND_SUCCESS "${RECOVERED_MESSAGE_SUCCESS}" ":wrench: ${RECOVERED_TITLE_SUCCESS} :wrench:" "${WEBHOOK_USERNAME}" "${WEBHOOK_AVATAR}" )
    if [[ ! -z "${ERRORS}" ]]
    then
      echo "ERROR: ${ERRORS}"
    else
      SQL_QUERY "DELETE FROM node_log WHERE conf_loc == '${CONF_LOCATION}' AND type == '${TYPE}'; "
    fi
  fi

  SECONDS_SINCE_PING="$( echo "${UNIX_TIME} - ${LAST_PING_TIME}" | bc -l )"


  # Send message out.
  ERRORS=''
  MESSAGE=''
  if [[ ! -z "${MESSAGE_ERROR}" ]] && [[ "${SECONDS_SINCE_PING}" -gt 300 ]]
  then
    ERRORS=$( SEND_ERROR "${MESSAGE_ERROR}" "" "${WEBHOOK_USERNAME}" "${WEBHOOK_AVATAR}" )
    MESSAGE="${MESSAGE_ERROR}"
  elif [[ ! -z "${MESSAGE_WARNING}" ]] && [[ "${SECONDS_SINCE_PING}" -gt 900 ]]
  then
    ERRORS=$( SEND_WARNING "${MESSAGE_WARNING}" "" "${WEBHOOK_USERNAME}" "${WEBHOOK_AVATAR}" )
    MESSAGE="${MESSAGE_WARNING}"
  elif [[ ! -z "${MESSAGE_INFO}" ]] && [[ "${SECONDS_SINCE_PING}" -gt 3600 ]]
  then
#     echo "${SECONDS_SINCE_PING} ${START_TIME} ${LAST_PING_TIME} ${MESSAGE_PAST}"
    ERRORS=$( SEND_INFO "${MESSAGE_INFO}" "" "${WEBHOOK_USERNAME}" "${WEBHOOK_AVATAR}" )
    MESSAGE="${MESSAGE_INFO}"
  elif [[ ! -z "${MESSAGE_SUCCESS}" ]] && [[ "${SECONDS_SINCE_PING}" -gt 7200 ]]
  then
    ERRORS=$( SEND_SUCCESS "${MESSAGE_SUCCESS}" "" "${WEBHOOK_USERNAME}" "${WEBHOOK_AVATAR}" )
    MESSAGE="${MESSAGE_SUCCESS}"
  fi

  # Write to the database.
  if [[ ! -z "${ERRORS}" ]]
  then
    echo "${ERRORS}" >/dev/tty
  elif [[ "${arg1}" != 'test' ]] && [[ ! -z "${MESSAGE}" ]]
  then
    SQL_QUERY "REPLACE INTO node_log (start_time,last_ping_time,conf_loc,type,message) VALUES ('${START_TIME}','${UNIX_TIME}','${CONF_LOCATION}','${TYPE}','${MESSAGE}');"
  fi
}

REPORT_INFO_ABOUT_NODE () {
  USRNAME=$( echo "${1}" | tr -d \" )
  DAEMON_BIN=$( echo "${2}" | tr -d \" )
  CONTROLLER_BIN=$( echo "${3}" | tr -d \" )
  CONF_FOLDER=$( echo "${4}" | tr -d \" )
  CONF_LOCATION=$( echo "${5}" | tr -d \" )
  MASTERNODE=$( echo "${6}" | tr -d \" )
  MNINFO=$( echo "${7}" | tr -d \" )
  GETBALANCE=$( echo "${8}" | tr -d \" )
  GETTOTALBALANCE=$( echo "${9}" | tr -d \" )
  STAKING=$( echo "${10}" | tr -d \" )
  GETCONNECTIONCOUNT=$( echo "${11}" | tr -d \" )
  GETBLOCKCOUNT=$( echo "${12}" | tr -d \" )
  UPTIME=$( echo "${13}" | tr -d \" )
  DAEMON_PID=$( echo "${14}" | tr -d \" )
  NETWORKHASHPS=$( echo "${15}" | tr -d \" )
  MNWIN=$( echo "${16}" | tr -d \" )

  if [[ -z "${USRNAME}" ]]
  then
    return
  fi

  if [[ ! ${MASTERNODE} =~ ${RE} ]]
  then
    return
  fi

  WEBHOOK_AVATAR=''
  WEBHOOK_USERNAME=''
  EXTRA_INFO=$( echo "${DAEMON_BIN_LUT}" | grep -E "^${DAEMON_BIN} " )
  if [[ ! -z "${EXTRA_INFO}" ]]
  then
    WEBHOOK_AVATAR=$( echo "${EXTRA_INFO}" | cut -d ' ' -f2 )
    WEBHOOK_USERNAME=$( echo "${EXTRA_INFO}" | cut -d ' ' -f3- )
  fi

  if [[ "${MASTERNODE}" == '-1' ]]
  then
    PROCESS_NODE_MESSAGES "${USRNAME}" "not_running" "__${USRNAME} ${DAEMON_BIN} ${CONF_LOCATION}__
${MNINFO}" "" "" "" "" "" "${WEBHOOK_USERNAME}" "${WEBHOOK_AVATAR}"
    return
  fi

  if [[ "${MASTERNODE}" == '-2' ]]
  then
    PROCESS_NODE_MESSAGES "${USRNAME}" "frozen" "__${USRNAME} ${DAEMON_BIN} ${CONF_LOCATION}__
${MNINFO}" "" "" "" "" "" "${WEBHOOK_USERNAME}" "${WEBHOOK_AVATAR}"
    return
  fi

  MIN_STAKE=0
  STAKE_REWARD=0
  MASTERNODE_REWARD=0
#     BLOCKS_WAIT=0
#     SECONDS_WAIT=0
  NET_HASH_FACTOR=0
  TICKER_NAME='COIN'
  STAKE_REWARD_UPPER=0
  BLOCKTIME_SECONDS=60

  EXTRA_INFO=$( echo "${DAEMON_BALANCE_LUT}" | grep -E "^${DAEMON_BIN} " )
  if [[ ! -z "${EXTRA_INFO}" ]]
  then
    MIN_STAKE=$( echo "${EXTRA_INFO}" | cut -d ' ' -f2 )
    STAKE_REWARD=$( echo "${EXTRA_INFO}" | cut -d ' ' -f3 )
    MASTERNODE_REWARD=$( echo "${EXTRA_INFO}" | cut -d ' ' -f4 )
#       BLOCKS_WAIT=$( echo "${EXTRA_INFO}" | cut -d ' ' -f5 )
#       SECONDS_WAIT=$( echo "${EXTRA_INFO}" | cut -d ' ' -f6 )
    NET_HASH_FACTOR=$( echo "${EXTRA_INFO}" | cut -d ' ' -f7 )
    TICKER_NAME=$( echo "${EXTRA_INFO}" | cut -d ' ' -f8 )
    BLOCKTIME_SECONDS=$( echo "${EXTRA_INFO}" | cut -d ' ' -f9 )
    STAKE_REWARD_UPPER=$( echo "${STAKE_REWARD} + 0.3" | bc -l )
  fi

  # Masternode Status.
  if [[ ${MASTERNODE} -eq 1 ]]
  then
    if [[ ${MNINFO} -eq 1 ]]
    then
      PROCESS_NODE_MESSAGES "${CONF_LOCATION}" "masternode_status" "" "" "__${USRNAME} ${DAEMON_BIN}__
Masternode should be starting up soon." "" "" "" "${WEBHOOK_USERNAME}" "${WEBHOOK_AVATAR}"
    elif [[ ${MNINFO} -eq 2 ]]
    then
      PROCESS_NODE_MESSAGES "${CONF_LOCATION}" "masternode_status" "" "__${USRNAME} ${DAEMON_BIN}__
Masternode list shows the masternode as active bug masternode status doesn't. Hopefully this changes soon." "" "" "" "" "${WEBHOOK_USERNAME}" "${WEBHOOK_AVATAR}"
    else
      PROCESS_NODE_MESSAGES "${CONF_LOCATION}" "masternode_status" "__${USRNAME} ${DAEMON_BIN}__
Masternode is not currently running." "" "" "" "" "" "${WEBHOOK_USERNAME}" "${WEBHOOK_AVATAR}"
    fi
  elif [[ ${MASTERNODE} -eq 2 ]]
  then
    if [[ ${MNINFO} -eq 2 ]]
    then
      PROCESS_NODE_MESSAGES "${CONF_LOCATION}" "masternode_status" "" "" "" "" "__${USRNAME} ${DAEMON_BIN}__
Masternode status and masternode list are good!" "Masternode Running" "${WEBHOOK_USERNAME}" "${WEBHOOK_AVATAR}"
    elif [[ ${MNINFO} -eq 0 ]]
    then
      PROCESS_NODE_MESSAGES "${CONF_LOCATION}" "masternode_status" "" "" "" "" "__${USRNAME} ${DAEMON_BIN}__
Masternode status is good!" "Masternode Running" "${WEBHOOK_USERNAME}" "${WEBHOOK_AVATAR}"
    fi
  fi

  # Update & report on balance.
  PAST_BALANCE=$( SQL_QUERY "SELECT value FROM variables WHERE key = '${CONF_LOCATION}:balance';" )
  if [[ -z "${PAST_BALANCE}" ]]
  then
    PAST_BALANCE=0
    SQL_QUERY "REPLACE INTO variables (key,value) VALUES ('${CONF_LOCATION}:balance','${GETTOTALBALANCE}');"
  else
    SQL_QUERY "REPLACE INTO variables (key,value) VALUES ('${CONF_LOCATION}:balance','${GETTOTALBALANCE}');"
  fi
  BALANCE_DIFF=$( echo "${GETTOTALBALANCE} - ${PAST_BALANCE}" | bc -l )

  # Empty Wallet.
  if [[ $(echo "${BALANCE_DIFF} != 0 " | bc -l ) -eq 0 ]]
  then
    : # Do nothing.

  # Wallet has been drained.
  elif [[ -z "${GETTOTALBALANCE}" ]] || [[ $(echo "${GETTOTALBALANCE} == 0" | bc -l ) -eq 1 ]]
  then
    SEND_ERROR "__${USRNAME} ${DAEMON_BIN}__
Balance is now zero ${TICKER_NAME}!
Before: ${PAST_BALANCE}
After: ${GETTOTALBALANCE} " "" "${WEBHOOK_USERNAME}" "${WEBHOOK_AVATAR}"

  # Larger amount has been moved off this wallet.
  elif [[ $( echo "${BALANCE_DIFF} < -1" | bc -l ) -gt 0 ]]
  then
    SEND_WARNING "__${USRNAME} ${DAEMON_BIN}__
Balance has decreased by over 1 ${TICKER_NAME} Difference: ${BALANCE_DIFF}.
New Balance: ${GETTOTALBALANCE}" "" "${WEBHOOK_USERNAME}" "${WEBHOOK_AVATAR}"

  # Small amount has been moved.
  elif [[ $( echo "${BALANCE_DIFF} < 1" | bc -l ) -gt 0 ]]
  then
    SEND_INFO "__${USRNAME} ${DAEMON_BIN}__
Small amout of ${TICKER_NAME} has been transfered Difference: ${BALANCE_DIFF}.
New Balance: ${GETTOTALBALANCE}" "" "${WEBHOOK_USERNAME}" "${WEBHOOK_AVATAR}"

  # More than 1 Coin has been added.
  elif [[ $( echo "${BALANCE_DIFF} >= 1" | bc -l ) -gt 0 ]]
  then
    if [[ $( echo "${BALANCE_DIFF} == ${MASTERNODE_REWARD}" | bc -l ) -eq 1 ]]
    then
      SEND_SUCCESS "__${USRNAME} ${DAEMON_BIN}__
Masternode reward amout of ${BALANCE_DIFF} ${TICKER_NAME}.
New Balance: ${GETTOTALBALANCE}" "" "${WEBHOOK_USERNAME}" "${WEBHOOK_AVATAR}"
    elif [[ $( echo "${BALANCE_DIFF} >= ${STAKE_REWARD}" | bc -l ) -gt 0 ]] && [[ $( echo "${BALANCE_DIFF} < ${STAKE_REWARD_UPPER}" | bc -l ) -gt 0 ]]
    then
      SEND_SUCCESS "__${USRNAME} ${DAEMON_BIN}__
Staking reward amout of ${BALANCE_DIFF} ${TICKER_NAME}.
New Balance: ${GETTOTALBALANCE}" "" "${WEBHOOK_USERNAME}" "${WEBHOOK_AVATAR}"
    else
      SEND_SUCCESS "__${USRNAME} ${DAEMON_BIN}__
Larger amout of ${TICKER_NAME} has been transfered Difference: ${BALANCE_DIFF}.
New Balance: ${GETTOTALBALANCE}" "" "${WEBHOOK_USERNAME}" "${WEBHOOK_AVATAR}"
    fi
  fi

  # Report on staking.
  TIME_TO_STAKE=''
  if [[ ! -z "${GETBALANCE}" ]] && [[ "$( echo "${GETBALANCE} > 0.0" | bc -l )" -gt 0 ]]
  then
    COINS_STAKED_TOTAL_NETWORK=$( echo "${NETWORKHASHPS} * ${NET_HASH_FACTOR}" | bc -l )
    if [[ ! -z "${COINS_STAKED_TOTAL_NETWORK}" ]] && [[ $( echo "${COINS_STAKED_TOTAL_NETWORK} != 0" | bc -l ) -eq 1 ]]
    then
      SECONDS_TO_AVERAGE_STAKE=$( echo "${COINS_STAKED_TOTAL_NETWORK} / ${GETBALANCE} * ${BLOCKTIME_SECONDS}" | bc -l )
      TIME_TO_STAKE=$( DISPLAYTIME "${SECONDS_TO_AVERAGE_STAKE}" )
    fi

    if [[ "$( echo "${MIN_STAKE} > ${GETBALANCE}" | bc -l )" -gt 0 ]]
    then
      PROCESS_NODE_MESSAGES "${CONF_LOCATION}" "staking_balance" "" "__${USRNAME} ${DAEMON_BIN}__
Balance (${GETBALANCE}) is below the minimum staking threshold (${MIN_STAKE}).
${MIN_STAKE} > ${GETBALANCE}" "" "" "" "" "${WEBHOOK_USERNAME}" "${WEBHOOK_AVATAR}"
    else
      PROCESS_NODE_MESSAGES "${CONF_LOCATION}" "staking_balance" "" "" "" "" "__${USRNAME} ${DAEMON_BIN}__
Has enough coins to stake now!" "Balance is above the minimum" "${WEBHOOK_USERNAME}" "${WEBHOOK_AVATAR}"
      if [[ "${STAKING}" -eq 0 ]]
      then
        GETSTAKINGSTATUS=$( su "${USRNAME}" -c "\"${CONTROLLER_BIN}\" \"-datadir=${CONF_FOLDER}\" getstakingstatus" 2>&1 | jq . | grep 'false' | tr -d \" )
        PROCESS_NODE_MESSAGES "${CONF_LOCATION}" "staking_status" "" "__${USRNAME} ${DAEMON_BIN}__
${GETSTAKINGSTATUS}" "" "" "" "" "${WEBHOOK_USERNAME}" "${WEBHOOK_AVATAR}"
      fi
      if [[ "${STAKING}" -eq 1 ]]
      then
        PROCESS_NODE_MESSAGES "${CONF_LOCATION}" "staking_status" "" "" "" "" "__${USRNAME} ${DAEMON_BIN}__
Staking status is now TRUE!" "Staking is enabled" "${WEBHOOK_USERNAME}" "${WEBHOOK_AVATAR}"
      fi
    fi
  fi

  # Report on connection count.
  if [[ ${GETCONNECTIONCOUNT} =~ ${RE} ]]
  then
    if [[ "${GETCONNECTIONCOUNT}" -lt 2 ]]
    then
      PROCESS_NODE_MESSAGES "${CONF_LOCATION}" "connection_count" "__${USRNAME} ${DAEMON_BIN}__
  Connection Count (${GETCONNECTIONCOUNT}) is very low!" "" "" "" "" "" "${WEBHOOK_USERNAME}" "${WEBHOOK_AVATAR}"
    elif [[ "${GETCONNECTIONCOUNT}" -lt 5 ]]
    then
      PROCESS_NODE_MESSAGES "${CONF_LOCATION}" "connection_count" "" "__${USRNAME} ${DAEMON_BIN}__
  Connection Count (${GETCONNECTIONCOUNT}) is low!" "" "" "" "" "${WEBHOOK_USERNAME}" "${WEBHOOK_AVATAR}"
    else
      PROCESS_NODE_MESSAGES "${CONF_LOCATION}" "connection_count" "" "" "" "" "__${USRNAME} ${DAEMON_BIN}__
  Connection count has been restored" "Connection Count Normal" "${WEBHOOK_USERNAME}" "${WEBHOOK_AVATAR}"
    fi
  fi

  # Report on masternode winner
  if [[ "${MNWIN}" == 0 ]]
  then
    :
  else
    MN_ADDRESS_WIN=$( echo "${MNWIN}" | cut -d ' ' -f1 )
    BLOCK_WIN=$( echo "${MNWIN}" | cut -d ' ' -f2 )
    MN_REWARD_IN_BLOCKS=$( echo "${BLOCK_WIN} - ${GETBLOCKCOUNT}" | bc -l )
    MN_REWARD_IN_SECONDS=$( echo "${MN_REWARD_IN_BLOCKS} * ${BLOCKTIME_SECONDS}" | bc -l )
    MN_REWARD_IN_TIME=$( DISPLAYTIME "${MN_REWARD_IN_SECONDS}" )
    PROCESS_NODE_MESSAGES "${CONF_LOCATION}" "mnwin:${BLOCK_WIN}" "" "" "" "__${USRNAME} ${DAEMON_BIN}__
Masternode on ${MN_ADDRESS_WIN} will get paid
on block ${BLOCK_WIN}
in approximately ${MN_REWARD_IN_TIME}." "" "" "${WEBHOOK_USERNAME}" "${WEBHOOK_AVATAR}"
  fi

  # Report on daemon info.
  UPTIME_HUMAN=$( DISPLAYTIME "${UPTIME}" )
  STAKING_TEXT='Disabled'
  if [[ "${STAKING}" -eq 1 ]]
  then
    STAKING_TEXT='Enabled'
  fi
  MASTERNODE_TEXT='Disabled'
  if [[ ${MASTERNODE} -eq 2 ]]
  then
    MASTERNODE_TEXT='Enabled but not enabled in masternode list'
    if [[ ${MNINFO} -eq 2 ]]
    then
      MASTERNODE_TEXT='Enabled'
    fi
  fi
  PROCESS_NODE_MESSAGES "${CONF_LOCATION}" "node_info" "" "" "__${USRNAME} ${DAEMON_BIN}__
BlockCount: ${GETBLOCKCOUNT}
PID: ${DAEMON_PID}
Uptime: ${UPTIME} seconds (${UPTIME_HUMAN})
Staking Status: ${STAKING_TEXT}
Masternode Status: ${MASTERNODE_TEXT}
Balance: ${GETBALANCE}
Total Balance: ${GETTOTALBALANCE}
Staking Average ETA: ${TIME_TO_STAKE}" "" "" "" "${WEBHOOK_USERNAME}" "${WEBHOOK_AVATAR}"
}

GET_INFO_ON_THIS_NODE () {
  HAS_FUNCTION=${1}
  USRNAME=${2}
  CONTROLLER_BIN=${3}
  DAEMON_BIN=${4}
  CONF_LOCATION=${5}
  DAEMON_PID=${6}
  UPTIME=${7}

  GETBALANCE=0
  GETTOTALBALANCE=0
  # is the daemon running.
  if [[ -z "${DAEMON_PID}" ]]
  then
    REPORT_INFO_ABOUT_NODE "${USRNAME}" "${DAEMON_BIN}" "${CONF_LOCATION}" "-1" "This node is not running."
    return
  fi

  # setup vars.
  CONF_FOLDER=$( dirname "${CONF_LOCATION}" )

  GETBLOCKCOUNT=$( su "${USRNAME}" -c "timeout 5 \"${CONTROLLER_BIN}\" \"-datadir=${CONF_FOLDER}\" getblockcount" 2>&1 | grep -o '[0-9].*' )
  GETCONNECTIONCOUNT=$( su "${USRNAME}" -c "timeout 5 \"${CONTROLLER_BIN}\" \"-datadir=${CONF_FOLDER}\" getconnectioncount" 2>&1 | grep -o '[0-9].*' )

  if [[ -z "${GETBLOCKCOUNT}" ]] && [[ -z "${GETCONNECTIONCOUNT}" ]]
  then
    REPORT_INFO_ABOUT_NODE "${USRNAME}" "${DAEMON_BIN}" "${CONF_LOCATION}" "-2" "This node is frozen. PID: ${DAEMON_PID}"
    return
  fi

  # is a masternode?
  MASTERNODE=0
  if [[ $( grep 'privkey=' "${CONF_LOCATION}" | grep -vE -c '^#' ) -gt 0 ]]
  then
    MASTERNODE=1
    MASTERNODE_STATUS=$( su "${USRNAME}" -c "\"${CONTROLLER_BIN}\" \"-datadir=${CONF_FOLDER}\" masternode status" 2>&1 )
    if [[ $( echo "${MASTERNODE_STATUS}" | grep -ic "method not found" ) -gt 0 ]]
    then
      MASTERNODE_STATUS=$( su "${USRNAME}" -c "\"${CONTROLLER_BIN}\" \"-datadir=${CONF_FOLDER}\" masternode debug" 2>&1 )
    fi
    if [[ $( echo "${MASTERNODE_STATUS}" | grep -ic "method not found" ) -gt 0 ]] && [[ "${HAS_FUNCTION}" -gt 0 ]]
    then
      MASTERNODE_STATUS=$( bash -ic "source /var/multi-masternode-data/.bashrc; ${USRNAME} mnstatus" )
    fi

    if [[ $( echo "${MASTERNODE_STATUS}" | grep -ic " successfully started" ) -eq 1 ]] || [[ $( echo "${MASTERNODE_STATUS}" | grep -ic " started remotely" ) -eq 1 ]]
    then
      MASTERNODE=2
    fi
  fi

  # check mninfo.
  MNINFO=0
  if [[ "${MASTERNODE}" -ge 2 ]]
  then
    if [[ "${HAS_FUNCTION}" -gt 0 ]]
    then
      MNINFO_OUTPUT=$( bash -ic "source /var/multi-masternode-data/.bashrc; ${USRNAME} mninfo" )
      if [[ "${#MNINFO_OUTPUT}" -gt 1 ]]
      then
        MNINFO=1
        if [[ $( echo "${MNINFO_OUTPUT}" | grep -iEc 'status.*ENABLED' ) -gt 0 ]]
        then
          MNINFO=2
        fi
      fi
    fi
  fi

  MNWIN=''
  if [[ "${MNINFO}" -eq 2 ]] && [[ "${HAS_FUNCTION}" -gt 0 ]]
  then
    MNWIN=$( bash -ic "source /var/multi-masternode-data/.bashrc; ${USRNAME} mnwin" )
  fi
  if [[ -z "${MNWIN}" ]]
  then
    MNWIN='0'
  fi

  WALLETINFO=$( su "${USRNAME}" -c "\"${CONTROLLER_BIN}\" \"-datadir=${CONF_FOLDER}\" getwalletinfo" 2>&1 )
  if [[ ! -z "${WALLETINFO}" ]] && [[ $( echo "${WALLETINFO}" | grep -ic 'balance' ) -gt 0 ]]
  then
    GETBALANCE=$( echo "${WALLETINFO}" | jq -r '.balance' )
    GETTOTALBALANCE=$( echo "${WALLETINFO}" | jq -r '.balance, .unconfirmed_balance, .immature_balance' | awk '{sum += $0} END {printf "%.8f", sum}' )
  else
    WALLETINFO=$( su "${USRNAME}" -c "\"${CONTROLLER_BIN}\" \"-datadir=${CONF_FOLDER}\" getbalance" 2>&1 )
  fi


  # check staking status.
  STAKING=0
  GETSTAKINGSTATUS=''
  if [[ $( echo "${GETBALANCE} > 0" | bc -l ) -gt 0 ]]
  then
    GETSTAKINGSTATUS=$( su "${USRNAME}" -c "\"${CONTROLLER_BIN}\" \"-datadir=${CONF_FOLDER}\" getstakingstatus" 2>&1 )
    if [[ $( echo "${GETSTAKINGSTATUS}" | grep -c 'false' ) -eq 0 ]]
    then
      STAKING=1
    fi
  fi

  # check networkhashps
  GETNETHASHRATE=$( su "${USRNAME}" -c "\"${CONTROLLER_BIN}\" \"-datadir=${CONF_FOLDER}\" getnetworkhashps" 2>&1 | grep -Eo '[+-]?[0-9]+([.][0-9]+)?' 2>/dev/null )
  if [[ -z "${GETNETHASHRATE}" ]]
  then
    GETNETHASHRATE=0
  fi

  # output info.
  DAEMON_BIN=$( basename "${DAEMON_BIN}" )
  CONF_LOCATION=$( dirname "${CONF_LOCATION}" )
  REPORT_INFO_ABOUT_NODE "${USRNAME}" "${DAEMON_BIN}" "${CONTROLLER_BIN}" "${CONF_FOLDER}" "${CONF_LOCATION}" "${MASTERNODE}" "${MNINFO}" "${GETBALANCE}" "${GETTOTALBALANCE}" "${STAKING}" "${GETCONNECTIONCOUNT}" "${GETBLOCKCOUNT}" "${UPTIME}" "${DAEMON_PID}" "${GETNETHASHRATE}" "${MNWIN}"
}

GET_ALL_NODES () {
  FILENAME_WITH_FUNCTIONS=''
  if [[ -r /var/multi-masternode-data/.bashrc ]]
  then
    # shellcheck disable=SC1091
    FILENAME_WITH_FUNCTIONS='/var/multi-masternode-data/.bashrc'
  elif [[ -r /root/.bashrc ]]
  then
    # shellcheck disable=SC1091
    FILENAME_WITH_FUNCTIONS='/root/.bashrc'
  elif [[ -r /home/ubuntu/.bashrc ]]
  then
    # shellcheck disable=SC1091
    FILENAME_WITH_FUNCTIONS='/home/ubuntu/.bashrc'
  fi

  LSLOCKS=$( lslocks -n -o COMMAND,PID,PATH )
  PS_LIST=$( ps --no-headers -axo user:32,pid,etimes,command )
  # shellcheck disable=SC2034
  while read -r USRNAME DEL_1 DEL_2 DEL_3 DEL_4 DEL_5 DEL_6 DEL_7 DEL_8 USR_HOME_DIR USR_HOME_DIR_ALT DEL_9
  do
#     echo "GET_ALL_NODES ${USRNAME}" >/dev/tty
    if [[ "${USR_HOME_DIR}" == 'X' ]]
    then
      USR_HOME_DIR=${USR_HOME_DIR_ALT}
    fi

    if [[ "${#USR_HOME_DIR}" -lt 3 ]] || [[ ${USR_HOME_DIR} == /var/* ]] || [[ ${USR_HOME_DIR} == '/proc' ]] || [[ ${USR_HOME_DIR} == '/dev' ]] || [[ ${USR_HOME_DIR} == /run/* ]] || [[ ${USR_HOME_DIR} == '/nonexistent' ]]
    then
      continue
    fi

    if [[ ! -d "${USR_HOME_DIR}" ]]
    then
      continue
    fi

    MN_USRNAME=$( basename "${USR_HOME_DIR}" )

    DAEMON_BIN=''
    CONTROLLER_BIN=''

    CONF_LOCATIONS=$( find "${USR_HOME_DIR}" -name "peers.dat" 2>/dev/null )
    if [[ -z "${CONF_LOCATIONS}" ]]
    then
      continue
    fi
    CONF_FOLDER=$( dirname "${CONF_LOCATIONS}" )
    CONF_LOCATIONS=$( grep --include=\*.conf -rl "rpc" "${CONF_FOLDER}" )

    if [[ -z "${CONF_LOCATIONS}" ]] && [[ "$( grep -c "_masternode_dameon_2 \"${MN_USRNAME}\"" "${FILENAME_WITH_FUNCTIONS}" )" -gt 0 ]]
    then
      CONF_LOCATIONS=$( "${MN_USRNAME}" conf loc )
    fi

    HAS_FUNCTION=0
    if [[ "$( grep -c "_masternode_dameon_2 \"${MN_USRNAME}\"" "${FILENAME_WITH_FUNCTIONS}" )" -gt 0 ]]
    then
      HAS_FUNCTION=1
    fi

    while read -r CONF_LOCATION
    do
      CONF_FOLDER=$( dirname "${CONF_LOCATION}" )
      DAEMON_BIN=$( echo "${LSLOCKS}" | grep -m 1 "${CONF_FOLDER}" | awk '{print $1}' )
      CONTROLLER_BIN="${DAEMON_BIN}"
      DAEMON_PID=$( echo "${LSLOCKS}" | grep -m 1 "${CONF_FOLDER}" | awk '{print $2}' )
      if [[ ! -z "${DAEMON_PID}" ]]
      then
        DAEMON_BIN=$( echo "${PS_LIST}" | cut -c 32- | grep " ${DAEMON_PID} " | awk '{print $3}' )
        CONTROLLER_BIN="${DAEMON_BIN}"
        COMMAND_FOLDER=$( dirname "${DAEMON_BIN}" )
        CONTROLLER_BIN_FOLDER=$( find "${COMMAND_FOLDER}" -executable -type f | grep -v "${DAEMON_BIN}" | grep -i "${DAEMON_BIN::-1}" )
        if [[ ! -z "${CONTROLLER_BIN_FOLDER}" ]]
        then
          CONTROLLER_BIN="${CONTROLLER_BIN_FOLDER}"
        fi
      fi

      if [[ "${HAS_FUNCTION}" -gt 0 ]]
      then
        FUNCTION_PARAMS=$( grep "_masternode_dameon_2 \"${MN_USRNAME}\"" /var/multi-masternode-data/.bashrc )
        if [[ -z "${DAEMON_BIN}" ]]
        then
          DAEMON_BIN=$( echo "${FUNCTION_PARAMS}" | awk '{print $5}' | tr -d \" )
          if [[ -z "${DAEMON_BIN}" ]]
          then
            DAEMON_BIN=$( bash -ic "source /var/multi-masternode-data/.bashrc; ${MN_USRNAME} daemon loc" )
          fi
        fi
        if [[ -z "${CONTROLLER_BIN}" ]]
        then
          CONTROLLER_BIN=$( echo "${FUNCTION_PARAMS}" | awk '{print $3}' | tr -d \" )
          if [[ -z "${CONTROLLER_BIN}" ]]
          then
            CONTROLLER_BIN=$( bash -ic "source /var/multi-masternode-data/.bashrc; ${MN_USRNAME} cli loc" )
          fi
        fi
      fi

      UPTIME=0
      if [[ ! -z "${DAEMON_PID}" ]]
      then
        UPTIME=$( echo "${PS_LIST}" | cut -c 32- | grep " ${DAEMON_PID} " | awk '{print $2}' | head -n 1 | awk '{print $1}' | grep -o '[0-9].*' )
      fi

      GET_INFO_ON_THIS_NODE "${HAS_FUNCTION}" "${USRNAME}" "${CONTROLLER_BIN}" "${DAEMON_BIN}" "${CONF_LOCATION}" "${DAEMON_PID}" "${UPTIME}"
    done <<< "${CONF_LOCATIONS}"
  done <<< "$( cut -d: -f1 /etc/passwd | getent passwd | sed 's/:/ X /g' | sort -h )"
}
GET_ALL_NODES
