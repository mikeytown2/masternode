#!/bin/bash

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# shellcheck disable=SC2016
: '
# Run this file

```
  bash -ic "$( wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/mnmon/mnmon.sh )" ; source ~/.bashrc
```

'

# Simple guide
# https://imgur.com/a/B8RMhHV

# Define simple variables.
 stty sane 2>/dev/null
 arg1="${1}"
 arg2="${2}"
 arg3="${3}"
 RE='^[0-9]+$'
 DISCORD_WEBHOOK_USERNAME_DEFAULT='Masternode Monitor'
 DISCORD_WEBHOOK_AVATAR_DEFAULT='https://i.imgur.com/8WHSSa7s.jpg'
 DISCORD_TITLE_LIMIT=266

# debug arg.
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

# test arg.
 TEST_OUTPUT=0
 if [[ "${arg1}" == 'test' ]]
then
  TEST_OUTPUT=1
fi
 if [[ "${arg2}" == 'test' ]]
then
  TEST_OUTPUT=1
fi
 if [[ "${arg3}" == 'test' ]]
then
  TEST_OUTPUT=1
fi

# Get sqlite.
 if ! [ -x "$( command -v sqlite3 )" ]
then
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq sqlite3
fi
# Get jq.
 if ! [ -x "$( command -v jq)" ]
then
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq jq
fi
# Get ntpdate.
 if [ ! -x "$( command -v ntpdate )" ]
then
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq ntpdate
fi

# Run a sqlite query.
 SQL_QUERY () {
  if [[ ! -d /var/multi-masternode-data/mnbot ]]
  then
    sudo mkdir -p /var/multi-masternode-data/mnbot
  fi
  sudo sqlite3 -batch /var/multi-masternode-data/mnbot/mnmon.sqlite3.db "${1}"
}

# Create tables if they do not exist.
# Key Value table.
 SQL_QUERY "CREATE TABLE IF NOT EXISTS variables (
 key TEXT PRIMARY KEY,
 value TEXT NOT NULL
);"

# User login.
 SQL_QUERY "CREATE TABLE IF NOT EXISTS login_data (
  time INTEGER,
  message TEXT,
  PRIMARY KEY (time, message)
);"

# System logs.
 SQL_QUERY "CREATE TABLE IF NOT EXISTS system_log (
  name TEXT PRIMARY KEY,
  start_time INTEGER ,
  last_ping_time INTEGER ,
  message TEXT
);"

# Daemon logs.
 SQL_QUERY "CREATE TABLE IF NOT EXISTS node_log (
  conf_loc TEXT,
  type TEXT,
  start_time INTEGER ,
  last_ping_time INTEGER ,
  message TEXT,
  PRIMARY KEY (conf_loc, type)
);"

 if [[ -f /var/multi-masternode-data/.bashrc ]] && [[ $( sudo grep -c mnstatus /var/multi-masternode-data/.bashrc ) -eq 0 ]]
then
  if [[ "${DEBUG_OUTPUT}" -eq 1 ]]
  then
    echo "Updating bashrc"
  fi

  COUNTER=0
  rm -f ~/___mn.sh
  while [[ ! -f ~/___mn.sh ]] || [[ $( grep -Fxc "# End of masternode setup script." ~/___mn.sh ) -eq 0 ]]
  do
    rm -f ~/___mn.sh
    echo "Downloading Masternode Setup Script."
    wget -4qo- gist.githack.com/mikeytown2/1637d98130ac7dfbfa4d24bac0598107/raw/mcarper.sh -O ~/___mn.sh
    COUNTER=$((COUNTER+1))
    if [[ "${COUNTER}" -gt 3 ]]
    then
      echo
      echo "Download of masternode setup script failed."
      echo
    fi
  done

  echo "DAEMON_BIN='energid'
  $( cat ~/___mn.sh )" > ~/___mn.sh
  bash ~/___mn.sh UPDATE_BASHRC
  sudo rm ~/___mn.sh
  sudo cp "${HOME}/.bashrc" /var/multi-masternode-data/.bashrc
fi

# Daemon_bin_name URL_to_logo Bot_name
 DAEMON_BIN_LUT="
energid https://s2.coinmarketcap.com/static/img/coins/128x128/3218.png Energi Monitor
dogecashd https://s2.coinmarketcap.com/static/img/coins/128x128/3672.png DogeCash Monitor
unigridd https://assets.coingecko.com/coins/images/8937/large/unigrid-logo-round.png UniGrid Monitor
millenniumd https://pbs.twimg.com/profile_images/1096902939342503937/uo3aeRep.png Millennium Club Monitor
galileld https://s2.coinmarketcap.com/static/img/coins/128x128/3793.png Galilel Monitor
gossipd https://s2.coinmarketcap.com/static/img/coins/128x128/3332.png Gossip Monitor
catocoind https://cmc.io/img/coin_icons/128x128/catocoin.png CatoCoin Monitor
"

# Daemon_bin_name minimum_balance_to_stake staking_reward mn_reward confirmations cooloff_seconds networkhashps_multiplier ticker_name blocktime_seconds
 DAEMON_BALANCE_LUT="
energid 1 2.28 9.14 101 3600 0.000001 NRG 60
dogecashd 1 2.16 8.64 101 3600 0.000001 DOGEC 60
"

# Convert seconds to days, hours, minutes, seconds.
 DISPLAYTIME () {
  # Round up the time.
  local T=0
  T=$( printf '%.*f\n' 0 "${1}" )
  local D=$(( T/60/60/24 ))
  local H=$(( T/60/60%24 ))
  local M=$(( T/60%60 ))
  local S=$(( T%60 ))
  (( D > 0 )) && printf '%d days ' "${D}"
  (( H > 0 )) && printf '%d hours ' "${H}"
  (( M > 0 )) && printf '%d minutes ' "${M}"
  (( S > 0 )) && printf '%d seconds ' "${S}"
}

# Create a service that runs every minute.
 INSTALL_MN_MON_SERVICE () {
  if [[ -f "${HOME}/masternode/mnmon/mnmon.sh" ]]
  then
    sudo cp "${HOME}/masternode/mnmon/mnmon.sh" /var/multi-masternode-data/mnbot/mnmon.sh
  else
    COUNTER=0
    sudo rm -f /var/multi-masternode-data/mnbot/mnmon.sh
    while [[ ! -f /var/multi-masternode-data/mnbot/mnmon.sh ]] || [[ $( sudo grep -Fxc "# End of the masternode monitor script." /var/multi-masternode-data/mnbot/mnmon.sh ) -eq 0 ]]
    do
      sudo rm -f /var/multi-masternode-data/mnbot/mnmon.sh
      echo "Downloading Masternode Setup Script."
      sudo wget -q4o- https://raw.githubusercontent.com/mikeytown2/masternode/master/mnmon/mnmon.sh -O /var/multi-masternode-data/mnbot/mnmon.sh
      COUNTER=$(( COUNTER+1 ))
      if [[ "${COUNTER}" -gt 3 ]]
      then
        echo
        echo "Download of masternode monitor script failed."
        echo
        exit 1
      fi
    done
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

# Send the data to discord via webhook.
 DISCORD_WEBHOOK_SEND () {
(
  local SERVER_ALIAS
  local SHOW_IP
  local _PAYLOAD
  local IP_ADDRESS=''

  local URL="${1}"
  local DESCRIPTION="${2}"
  local TITLE="${3}"
  local DISCORD_WEBHOOK_USERNAME="${4}"
  local DISCORD_WEBHOOK_AVATAR="${5}"
  local DISCORD_WEBHOOK_COLOR="${6}"
  local SERVER_INFO="${7}"

  # Username to show.
  if [[ -z "${DISCORD_WEBHOOK_USERNAME}" ]]
  then
    DISCORD_WEBHOOK_USERNAME="${DISCORD_WEBHOOK_USERNAME_DEFAULT}"
  fi
  # Avatar to show.
  if [[ -z "${DISCORD_WEBHOOK_AVATAR}" ]]
  then
    DISCORD_WEBHOOK_AVATAR="${DISCORD_WEBHOOK_AVATAR_DEFAULT}"
  fi

  if [[ -z "${SERVER_INFO}" ]]
  then
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
    if [[ "${SHOW_IP}" -gt 0 ]]
    then
      IP_ADDRESS=$( hostname -i )
    fi
    if [[ ! -z "${IP_ADDRESS}" ]]
    then
      SERVER_INFO="${SERVER_INFO}
- ${IP_ADDRESS}"
    fi
  fi

  # Replace new line with \n
#   DESCRIPTION=$( echo "${DESCRIPTION}" | awk '{printf "%s\\n", $0}' )
  SERVER_INFO=$( echo "${SERVER_INFO}" | awk '{printf "%s\\n", $0}' )
  TITLE=$( echo "${TITLE}" | tr '\n' ' ' )

  ALT_DESC=''
  while read -r LINE
  do
    CURRENT_CHAR_COUNT=$( echo "${ALT_DESC}" | tail -n 1 | wc -c )
    # shellcheck disable=SC2028
    NEW_LINE_CHAR_COUNT=$( echo "${LINE}\n " | wc -c )
    NEW_TOTAL=$(( CURRENT_CHAR_COUNT + NEW_LINE_CHAR_COUNT ))
    if [[ "${NEW_TOTAL}" -lt "${DISCORD_TITLE_LIMIT}" ]]
    then
      ALT_DESC="${ALT_DESC}${LINE}\n"
    else
      ALT_DESC="${ALT_DESC}
${LINE}\n"
    fi
  done <<< "${DESCRIPTION}"

  # Split up the description into mutiple embeds.
  LINE_COUNT=$( echo "${ALT_DESC}" | wc -l )
  COUNTER=0
  EMBEDS='['
  while read -r LINE
  do
    COUNTER=$(( COUNTER + 1 ))
    if [[ ! -z "${LINE}" ]]
    then
      EMBEDS="${EMBEDS}{
      \"color\": ${DISCORD_WEBHOOK_COLOR},
      \"title\": \"${LINE}\""
    fi
    if [[ "${COUNTER}" -lt "${LINE_COUNT}" ]]
    then
      EMBEDS="${EMBEDS}
      },
"
    else
      EMBEDS="${EMBEDS},
      \"description\": \"${SERVER_INFO}\"
      }"
    fi
  done <<< "${ALT_DESC}"
  EMBEDS="${EMBEDS}]"

  # Build HTTP POST.
  _PAYLOAD=$( cat << PAYLOAD
{
  "username": "${DISCORD_WEBHOOK_USERNAME} - ${SERVER_ALIAS}",
  "avatar_url": "${DISCORD_WEBHOOK_AVATAR}",
  "content": "**${TITLE}**",
  "embeds": ${EMBEDS}
}
PAYLOAD
)

  # Do the post.
  OUTPUT=$( curl -H "Content-Type: application/json" -s -X POST "${URL}" -d "${_PAYLOAD}" | sed '/^[[:space:]]*$/d' )
  if [[ ! -z "${OUTPUT}" ]]
  then
    # Wait if we got throttled.
    MS_WAIT=$( echo "${OUTPUT}" | jq -r '.retry_after' 2>/dev/null )
    if [[ ! -z "${MS_WAIT}" ]]
    then
      SECONDS_WAIT=$( printf "%.1f\n" "$( echo "scale=3;${MS_WAIT}/1000" | bc -l )" )
      SECONDS_WAIT=$( echo "${SECONDS_WAIT} + 0.1" | bc -l )
      sleep "${SECONDS_WAIT}"
      OUTPUT=$( curl -H "Content-Type: application/json" -s -X POST "${URL}" -d "${_PAYLOAD}" | sed '/^[[:space:]]*$/d' )
    fi
  fi
  # If only errors get a return value.
  if [[ ! -z "${OUTPUT}" ]]
  then
    echo "Discord Error"
    _PAYLOAD=$( echo "${_PAYLOAD}" | tr -d \' )
    echo "curl -H \"Content-Type: application/json\" -v ${URL} -d '${_PAYLOAD}'"
    echo "Output:"
    echo "${OUTPUT}" | jq '.'
    echo "Payload:"
    echo "${_PAYLOAD}"
    echo "-"
  fi
)
}

# Get the webhook url and test to make sure it works.
 DISCORD_WEBHOOK_URL_PROMPT () {
  # Title of this webhook.
  TEXT_A="${1}"
  # Url of the existing webhook.
  DISCORD_WEBHOOK_URL="${2}"
  while :
  do
    echo
    read -r -e -i "${DISCORD_WEBHOOK_URL}" -p "${TEXT_A}s webhook url: " input
    DISCORD_WEBHOOK_URL="${input:-${DISCORD_WEBHOOK_URL}}"
    if [[ ! -z "${DISCORD_WEBHOOK_URL}" ]]
    then
      TOKEN=$( wget -qO- -o- "${DISCORD_WEBHOOK_URL}" | jq -r '.token' )
      if [[ -z "${TOKEN}" ]]
      then
        echo "Given URL is not a webhook."
        echo
        echo -n 'Get Webhook URL: Your personal server (press plus on left if you do not have one)'
        echo -n ' -> Right click on your server -> Server Settings -> Webhooks'
        echo -n ' -> Create Webhook -> Copy webhook url -> save'
        echo
        DISCORD_WEBHOOK_URL=''
      else
        echo "${TOKEN}"
        break
      fi
    fi
  done
  SQL_QUERY "REPLACE INTO variables (key,value) VALUES ('discord_webhook_url_${TEXT_A}','${DISCORD_WEBHOOK_URL}');"
}

# Prompt for all webhooks that we need.
 GET_DISCORD_WEBHOOKS () {
  # Get webhook url from discord.
  echo
  echo -n 'Get Webhook URL: Your personal server (press plus on left if you do not have one)'
  echo -n ' -> text channels, general, click gear to "edit channel" -> Left side SELECT Webhooks'
  echo -n ' -> Create Webhook -> Copy webhook url -> save'
  echo
  echo "This webhook will be used for ${TEXT_A} Messages."
  echo 'You can reuse the same webhook url if you want all alerts and information'
  echo 'pings in the same channel.'

  # Errors.
  DISCORD_WEBHOOK_URL=$( SQL_QUERY "SELECT value FROM variables WHERE key = 'discord_webhook_url_error';" )
  DISCORD_WEBHOOK_URL_PROMPT "error" "${DISCORD_WEBHOOK_URL}"
  SEND_ERROR "Test Error"

  # Warnings.
  DISCORD_WEBHOOK_URL=$( SQL_QUERY "SELECT value FROM variables WHERE key = 'discord_webhook_url_warning';" )
  DISCORD_WEBHOOK_URL_PROMPT "warning" "${DISCORD_WEBHOOK_URL}"
  SEND_WARNING "Test Warning"

  # Info.
  DISCORD_WEBHOOK_URL=$( SQL_QUERY "SELECT value FROM variables WHERE key = 'discord_webhook_url_information';" )
  DISCORD_WEBHOOK_URL_PROMPT "information" "${DISCORD_WEBHOOK_URL}"
  SEND_INFO "Test Info"

  # Success.
  DISCORD_WEBHOOK_URL=$( SQL_QUERY "SELECT value FROM variables WHERE key = 'discord_webhook_url_success';" )
  DISCORD_WEBHOOK_URL_PROMPT "success" "${DISCORD_WEBHOOK_URL}"
  SEND_SUCCESS "Test Success"
}

# Send the data to telegram via bot.
 TELEGRAM_SEND () {
(
  local SERVER_INFO
  local SHOW_IP
  local SERVER_ALIAS
  local _PAYLOAD

  local TOKEN="${1}"
  local CHAT_ID="${2}"
  local TITLE="${3}"
  local MESSAGE="${4}"
  local SERVER_INFO="${5}"

  # Translate discord emojis to telegram.
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
    sed 's/:watch:/\xE2\x8C\x9A/g' | \
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
    sed 's/:watch:/\xE2\x8C\x9A/g' | \
    sed 's/:fire:/\xF0\x9F\x94\xA5/g' )

  if [[ -z "${SERVER_INFO}" ]]
  then
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
  # Rate limit this function.
  sleep 0.3
)
}

# Install telegram bot.
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

# Send an error messsage to discord and telegram.
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
  DISCORD_WEBHOOK_COLOR="${5}"
  if [[ -z "${DISCORD_WEBHOOK_COLOR}" ]]
  then
    DISCORD_WEBHOOK_COLOR=16711680
  fi
  if [[ ! -z "${6}" ]]
  then
    URL="${6}"
  fi

  SENT=0
  if [[ ! -z "${URL}" ]]
  then
    SENT=1
    DISCORD_WEBHOOK_SEND "${URL}" "${DESCRIPTION}" "${TITLE}" "${3}" "${4}" "${DISCORD_WEBHOOK_COLOR}"
  fi
  if [[ ! -z "${TOKEN}" ]] && [[ ! -z "${CHAT_ID}" ]]
  then
    SENT=1
    TELEGRAM_SEND "${TOKEN}" "${CHAT_ID}" "${TITLE}" "<code>${DESCRIPTION}</code>"
  fi
  if [[ "${SENT}" -eq 0 ]] || [[ "${DEBUG_OUTPUT}" -eq 1 ]]
  then
    echo "${TITLE}" >/dev/tty
    echo "${DESCRIPTION}" >/dev/tty
    echo "-" >/dev/tty
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
  DISCORD_WEBHOOK_COLOR="${5}"
  if [[ -z "${DISCORD_WEBHOOK_COLOR}" ]]
  then
    DISCORD_WEBHOOK_COLOR=16776960
  fi
  if [[ ! -z "${6}" ]]
  then
    URL="${6}"
  fi

  SENT=0
  if [[ ! -z "${URL}" ]]
  then
    SENT=1
    DISCORD_WEBHOOK_SEND "${URL}" "${DESCRIPTION}" "${TITLE}" "${3}" "${4}" "${DISCORD_WEBHOOK_COLOR}"
  fi
  if [[ ! -z "${TOKEN}" ]] && [[ ! -z "${CHAT_ID}" ]]
  then
    SENT=1
    TELEGRAM_SEND "${TOKEN}" "${CHAT_ID}" "${TITLE}" "<pre>${DESCRIPTION}</pre>"
  fi
  if [[ "${SENT}" -eq 0 ]] || [[ "${DEBUG_OUTPUT}" -eq 1 ]]
  then
    echo "${TITLE}" >/dev/tty
    echo "${DESCRIPTION}" >/dev/tty
    echo "-" >/dev/tty
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
  DISCORD_WEBHOOK_COLOR="${5}"
  if [[ -z "${DISCORD_WEBHOOK_COLOR}" ]]
  then
    DISCORD_WEBHOOK_COLOR=65535
  fi
  if [[ ! -z "${6}" ]]
  then
    URL="${6}"
  fi

  SENT=0
  if [[ ! -z "${URL}" ]]
  then
    SENT=1
    DISCORD_WEBHOOK_SEND "${URL}" "${DESCRIPTION}" "${TITLE}" "${3}" "${4}" "${DISCORD_WEBHOOK_COLOR}"
  fi
  if [[ ! -z "${TOKEN}" ]] && [[ ! -z "${CHAT_ID}" ]]
  then
    SENT=1
    TELEGRAM_SEND "${TOKEN}" "${CHAT_ID}" "${TITLE}" "<pre>${DESCRIPTION}</pre>"
  fi
  if [[ "${SENT}" -eq 0 ]] || [[ "${DEBUG_OUTPUT}" -eq 1 ]]
  then
    echo "${TITLE}" >/dev/tty
    echo "${DESCRIPTION}" >/dev/tty
    echo "-" >/dev/tty
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
  DISCORD_WEBHOOK_COLOR="${5}"
  if [[ -z "${DISCORD_WEBHOOK_COLOR}" ]]
  then
    DISCORD_WEBHOOK_COLOR=65535
  fi
  if [[ ! -z "${6}" ]]
  then
    URL="${6}"
  fi

  SENT=0
  if [[ ! -z "${URL}" ]]
  then
    SENT=1
    DISCORD_WEBHOOK_SEND "${URL}" "${DESCRIPTION}" "${TITLE}" "${3}" "${4}" "${DISCORD_WEBHOOK_COLOR}"
  fi
  if [[ ! -z "${TOKEN}" ]] && [[ ! -z "${CHAT_ID}" ]]
  then
    SENT=1
    TELEGRAM_SEND "${TOKEN}" "${CHAT_ID}" "${TITLE}" "<pre>${DESCRIPTION}</pre>"
  fi
  if [[ "${SENT}" -eq 0 ]] || [[ "${DEBUG_OUTPUT}" -eq 1 ]]
  then
    echo "${TITLE}" >/dev/tty
    echo "${DESCRIPTION}">/dev/tty
    echo "-" >/dev/tty
  fi
}

 PROCESS_MESSAGES () {
  local ERRORS=''
  local MESSAGE=''
  local NAME=${1}
  local MESSAGE_ERROR=${2}
  local MESSAGE_WARNING=${3}
  local MESSAGE_INFO=${4}
  local MESSAGE_SUCCESS=${5}
  local RECOVERED_MESSAGE_SUCCESS=${6}
  local RECOVERED_TITLE_SUCCESS=${7}
  local DISCORD_WEBHOOK_USERNAME=${8}
  local DISCORD_WEBHOOK_AVATAR=${9}


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
  SECONDS_SINCE_PING="$( echo "${UNIX_TIME} - ${LAST_PING_TIME}" | bc -l )"

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
    ERRORS=$( SEND_ERROR "${MESSAGE_ERROR}" "" "${DISCORD_WEBHOOK_USERNAME}" "${DISCORD_WEBHOOK_AVATAR}" )
    MESSAGE="${MESSAGE_ERROR}"
  elif [[ ! -z "${MESSAGE_WARNING}" ]] && [[ "${SECONDS_SINCE_PING}" -gt 900 ]]
  then
    ERRORS=$( SEND_WARNING "${MESSAGE_WARNING}" "" "${DISCORD_WEBHOOK_USERNAME}" "${DISCORD_WEBHOOK_AVATAR}" )
    MESSAGE="${MESSAGE_WARNING}"
  elif [[ ! -z "${MESSAGE_INFO}" ]] && [[ "${SECONDS_SINCE_PING}" -gt 3600 ]]
  then
    ERRORS=$( SEND_INFO "${MESSAGE_INFO}" "" "${DISCORD_WEBHOOK_USERNAME}" "${DISCORD_WEBHOOK_AVATAR}" )
    MESSAGE="${MESSAGE_INFO}"
  elif [[ ! -z "${MESSAGE_SUCCESS}" ]]
  then
    ERRORS=$( SEND_SUCCESS "${MESSAGE_SUCCESS}" "" "${DISCORD_WEBHOOK_USERNAME}" "${DISCORD_WEBHOOK_AVATAR}" )
    MESSAGE="${MESSAGE_SUCCESS}"
  fi

  if [[ "${DEBUG_OUTPUT}" -eq 1 ]]
  then
    echo "system_log name ${NAME}"
    echo "Last ping: ${SECONDS_SINCE_PING}"
    if [[ ! -z "${MESSAGE_ERROR}" ]]
    then
      echo "Error: ${MESSAGE_ERROR}"
    fi
    if [[ ! -z "${MESSAGE_WARNING}" ]]
    then
      echo "Warning: ${MESSAGE_WARNING}"
    fi
    if [[ ! -z "${MESSAGE_INFO}" ]]
    then
      echo "Info: ${MESSAGE_INFO}"
    fi
    if [[ ! -z "${MESSAGE_SUCCESS}" ]]
    then
      echo "Success: ${MESSAGE_SUCCESS}"
    fi
    if [[ ! -z "${MESSAGE}" ]]
    then
      echo "Message: ${MESSAGE}"
    fi
    if [[ ! -z "${ERRORS}" ]]
    then
      echo "Errors: ${ERRORS}"
    fi
    echo
  fi

  # Write to the database.
  if [[ ! -z "${ERRORS}" ]]
  then
    echo "${ERRORS}" >/dev/tty
  elif [[ "${TEST_OUTPUT}" -eq 1 ]] && [[ ! -z "${MESSAGE}" ]]
  then
    SQL_QUERY "REPLACE INTO system_log (start_time,last_ping_time,name,message) VALUES ('${START_TIME}','${UNIX_TIME}','${NAME}','${MESSAGE}');"
  fi
}

 PROCESS_NODE_MESSAGES () {
  local ERRORS=''
  local MESSAGE=''
  local CONF_LOCATION=${1}
  local TYPE=${2}
  local MESSAGE_ERROR=${3}
  local MESSAGE_WARNING=${4}
  local MESSAGE_INFO=${5}
  local MESSAGE_SUCCESS=${6}
  local RECOVERED_MESSAGE_SUCCESS=${7}
  local RECOVERED_TITLE_SUCCESS=${8}
  local DISCORD_WEBHOOK_USERNAME=${9}
  local DISCORD_WEBHOOK_AVATAR=${10}

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
  SECONDS_SINCE_PING="$( echo "${UNIX_TIME} - ${LAST_PING_TIME}" | bc -l )"

  # Send recovery message.
  if [[ -z "${MESSAGE_ERROR}" ]] && [[ -z "${MESSAGE_WARNING}" ]] && [[ ! -z "${MESSAGE_PAST}" ]] && [[ ! -z "${RECOVERED_MESSAGE_SUCCESS}" ]]
  then
    ERRORS=$( SEND_SUCCESS "${RECOVERED_MESSAGE_SUCCESS}" ":wrench: ${RECOVERED_TITLE_SUCCESS} :wrench:" "${DISCORD_WEBHOOK_USERNAME}" "${DISCORD_WEBHOOK_AVATAR}" )
    if [[ ! -z "${ERRORS}" ]]
    then
      echo "ERROR: ${ERRORS}"
    else
      SQL_QUERY "DELETE FROM node_log WHERE conf_loc == '${CONF_LOCATION}' AND type == '${TYPE}'; "
    fi
  fi

  # Send message out.
  ERRORS=''
  MESSAGE=''
  if [[ ! -z "${MESSAGE_ERROR}" ]] && [[ "${SECONDS_SINCE_PING}" -gt 300 ]]
  then
    ERRORS=$( SEND_ERROR "${MESSAGE_ERROR}" "" "${DISCORD_WEBHOOK_USERNAME}" "${DISCORD_WEBHOOK_AVATAR}" )
    MESSAGE="${MESSAGE_ERROR}"
  elif [[ ! -z "${MESSAGE_WARNING}" ]] && [[ "${SECONDS_SINCE_PING}" -gt 900 ]]
  then
    ERRORS=$( SEND_WARNING "${MESSAGE_WARNING}" "" "${DISCORD_WEBHOOK_USERNAME}" "${DISCORD_WEBHOOK_AVATAR}" )
    MESSAGE="${MESSAGE_WARNING}"
  elif [[ ! -z "${MESSAGE_INFO}" ]] && [[ "${SECONDS_SINCE_PING}" -gt 3600 ]]
  then
    ERRORS=$( SEND_INFO "${MESSAGE_INFO}" "" "${DISCORD_WEBHOOK_USERNAME}" "${DISCORD_WEBHOOK_AVATAR}" )
    MESSAGE="${MESSAGE_INFO}"
  elif [[ ! -z "${MESSAGE_SUCCESS}" ]] && [[ "${SECONDS_SINCE_PING}" -gt 7200 ]]
  then
    ERRORS=$( SEND_SUCCESS "${MESSAGE_SUCCESS}" "" "${DISCORD_WEBHOOK_USERNAME}" "${DISCORD_WEBHOOK_AVATAR}" )
    MESSAGE="${MESSAGE_SUCCESS}"
  fi

  if [[ "${DEBUG_OUTPUT}" -eq 1 ]]
  then
    echo "node_log conf ${CONF_LOCATION} type ${TYPE}"
    echo "Last ping: ${SECONDS_SINCE_PING}"
    if [[ ! -z "${MESSAGE_ERROR}" ]]
    then
      echo "Error: ${MESSAGE_ERROR}"
    fi
    if [[ ! -z "${MESSAGE_WARNING}" ]]
    then
      echo "Warning: ${MESSAGE_WARNING}"
    fi
    if [[ ! -z "${MESSAGE_INFO}" ]]
    then
      echo "Info: ${MESSAGE_INFO}"
    fi
    if [[ ! -z "${MESSAGE_SUCCESS}" ]]
    then
      echo "Success: ${MESSAGE_SUCCESS}"
    fi
    if [[ ! -z "${MESSAGE}" ]]
    then
      echo "Message: ${MESSAGE}"
    fi
    if [[ ! -z "${ERRORS}" ]]
    then
      echo "Errors: ${ERRORS}"
    fi
    echo
  fi

  # Write to the database.
  if [[ ! -z "${ERRORS}" ]]
  then
    echo "${ERRORS}" >/dev/tty
  elif [[ "${TEST_OUTPUT}" -eq 1 ]] && [[ ! -z "${MESSAGE}" ]]
  then
    SQL_QUERY "REPLACE INTO node_log (start_time,last_ping_time,conf_loc,type,message) VALUES ('${START_TIME}','${UNIX_TIME}','${CONF_LOCATION}','${TYPE}','${MESSAGE}');"
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
    if [[ ! -z "${MESSAGE}" ]] && [[ "${TEST_OUTPUT}" -eq 1 ]]
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
    elif [[ "${TEST_OUTPUT}" -eq 1 ]]
    then
      SQL_QUERY "INSERT INTO login_data (time,message) VALUES ('${UNIX_TIME_LOG}','${INFO}');"
    fi
  done <<< "$( grep -B 20 ' systemd-logind' /var/log/auth.log | grep -B 20 'New' | grep -C10 'sshd' | grep port | grep -v 'CRON\|preauth\|Invalid user\|user unknown\|Failed[[:space:]]password\|authentication[[:space:]]failure\|refused[[:space:]]connect\|ignoring[[:space:]]max\|not[[:space:]]receive[[:space:]]identification\|[[:space:]]sudo\|[[:space:]]su\|Bad[[:space:]]protocol' )"
}

 CHECK_DISK () {
  NAME='disk_space'
  MESSAGE_ERROR=''
  MESSAGE_WARNING=''
  MESSAGE_INFO=''
  MESSAGE_SUCCESS=''

  FREEPSPACE_ALL=$( df -P . | tail -1 | awk '{print $4}' )
  FREEPSPACE_BOOT=$( df -P /boot | tail -1 | awk '{print $4}' )
  if [[ "${FREEPSPACE_ALL}" -lt 524288 ]] || [[ "${TEST_OUTPUT}" -eq 1 ]]
  then
    FREEPSPACE_ALL=$( echo "${FREEPSPACE_ALL} / 1024" | bc )
    MESSAGE_ERROR="${MESSAGE_ERROR} Less than 512 MB of free space is left on the drive. ${FREEPSPACE_ALL} MB left."
  fi
  if [[ "${FREEPSPACE_BOOT}" -lt 65536 ]] || [[ "${TEST_OUTPUT}" -eq 1 ]]
  then
    FREEPSPACE_BOOT=$( echo "${FREEPSPACE_BOOT} / 1024" | bc )
    MESSAGE_ERROR="${MESSAGE_ERROR} Less than 64 MB of free space is left in the boot folder. ${FREEPSPACE_BOOT} MB left."
  fi

  if [[ -z "${MESSAGE_ERROR}" ]]
  then
    if [[ "${FREEPSPACE_ALL}" -lt 1572864 ]] || [[ "${TEST_OUTPUT}" -eq 1 ]]
    then
      FREEPSPACE_ALL=$( echo "${FREEPSPACE_ALL} / 1024" | bc )
      MESSAGE_WARNING="${MESSAGE_WARNING} Less than 1.5 GB of free space is left on the drive. ${FREEPSPACE_ALL} MB left."
    fi
    if [[ "${FREEPSPACE_BOOT}" -lt 131072 ]] || [[ "${TEST_OUTPUT}" -eq 1 ]]
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

  if [[ "${DEBUG_OUTPUT}" -eq 1 ]]
  then
    echo "Freespace all: ${FREEPSPACE_ALL}"
    echo "Freespace boot: ${FREEPSPACE_BOOT}"
    echo
  fi

  RECOVERED_MESSAGE_SUCCESS="Hard drive has ${FREEPSPACE_ALL} MB Free; boot folder has ${FREEPSPACE_BOOT} MB Free."
  RECOVERED_TITLE_SUCCESS="Low diskspace issue has been resolved."
  PROCESS_MESSAGES "${NAME}" "${MESSAGE_ERROR}" "${MESSAGE_WARNING}" "${MESSAGE_INFO}" "${MESSAGE_SUCCESS}" "${RECOVERED_MESSAGE_SUCCESS}" "${RECOVERED_TITLE_SUCCESS}" "${DISCORD_WEBHOOK_USERNAME_DEFAULT}" "${DISCORD_WEBHOOK_AVATAR_DEFAULT}"
}

 CHECK_CPU_LOAD () {
  NAME='cpu_usage'
  MESSAGE_ERROR=''
  MESSAGE_WARNING=''
  MESSAGE_INFO=''
  MESSAGE_SUCCESS=''

  LOAD=$( uptime | grep -oE 'load average: [0-9]+([.][0-9]+)?' | grep -oE '[0-9]+([.][0-9]+)?' )
  CPU_COUNT=$( grep -c 'processor' /proc/cpuinfo )
  LOAD_PER_CPU="$( printf "%.3f\n" "$( bc -l <<< "${LOAD} / ${CPU_COUNT}" )" )"

  if [[ "$( echo "${LOAD_PER_CPU} >= 4" | bc -l )" -gt 0 ]] || [[ "${TEST_OUTPUT}" -eq 1 ]]
  then
    MESSAGE_ERROR=" :desktop: :fire:  CPU LOAD is over 4: ${LOAD_PER_CPU} :fire: :desktop: "
  elif [[ "$( echo "${LOAD_PER_CPU} > 2" | bc -l )" -gt 0 ]] || [[ "${TEST_OUTPUT}" -eq 1 ]]
  then
    MESSAGE_WARNING=" :desktop: CPU LOAD is over 2: ${LOAD_PER_CPU} :desktop: "
  fi

  if [[ "${DEBUG_OUTPUT}" -eq 1 ]]
  then
    echo "Load: ${LOAD}"
    echo "CPU Count: ${CPU_COUNT}"
    echo "Load per CPU: ${LOAD_PER_CPU}"
    echo
  fi

  RECOVERED_MESSAGE_SUCCESS="Load per CPU is ${LOAD_PER_CPU}."
  RECOVERED_TITLE_SUCCESS="CPU Load is back to normal."
  PROCESS_MESSAGES "${NAME}" "${MESSAGE_ERROR}" "${MESSAGE_WARNING}" "${MESSAGE_INFO}" "${MESSAGE_SUCCESS}" "${RECOVERED_MESSAGE_SUCCESS}" "${RECOVERED_TITLE_SUCCESS}" "${DISCORD_WEBHOOK_USERNAME_DEFAULT}" "${DISCORD_WEBHOOK_AVATAR_DEFAULT}"
}

 CHECK_SWAP () {
  NAME='swap_free'
  MESSAGE_ERROR=''
  MESSAGE_WARNING=''
  MESSAGE_INFO=''
  MESSAGE_SUCCESS=''

  SWAP_FREE_MB=$( free -wm | grep -i 'Swap:' | awk '{print $4}' )
  if [[ $( echo "${SWAP_FREE_MB} < 512" | bc ) -gt 0 ]] || [[ "${TEST_OUTPUT}" -eq 1 ]]
  then
    MESSAGE_ERROR=":desktop: :fire: Swap is under 512 MB: ${SWAP_FREE_MB} MB :fire: :desktop: "
  fi
  if ([[ $( echo "${SWAP_FREE_MB} >= 512" | bc ) -gt 0 ]] && [[ $( echo "${SWAP_FREE_MB} < 1024" | bc ) -gt 0 ]]) || [[ "${TEST_OUTPUT}" -eq 1 ]]
  then
    MESSAGE_WARNING=":desktop: Swap is under 1024 MB: ${SWAP_FREE_MB} MB :desktop: "
  fi

  if [[ "${DEBUG_OUTPUT}" -eq 1 ]]
  then
    echo "Swap Free MB: ${SWAP_FREE_MB}"
    echo
  fi

  RECOVERED_MESSAGE_SUCCESS="Free Swap space is ${SWAP_FREE_MB} MB."
  RECOVERED_TITLE_SUCCESS="Free sawp space is back to normal."
  PROCESS_MESSAGES "${NAME}" "${MESSAGE_ERROR}" "${MESSAGE_WARNING}" "${MESSAGE_INFO}" "${MESSAGE_SUCCESS}" "${RECOVERED_MESSAGE_SUCCESS}" "${RECOVERED_TITLE_SUCCESS}" "${DISCORD_WEBHOOK_USERNAME_DEFAULT}" "${DISCORD_WEBHOOK_AVATAR_DEFAULT}"
}

 CHECK_RAM () {
  NAME='ram_free'
  MESSAGE_ERROR=''
  MESSAGE_WARNING=''
  MESSAGE_INFO=''
  MESSAGE_SUCCESS=''

  MEM_TOTAL=$( sudo cat /proc/meminfo | grep -i 'MemTotal:' | awk '{print $2}' | head -n 1 )
  MEM_AVAILABLE=$( sudo cat /proc/meminfo | grep -i 'MemAvailable:\|MemFree:' | awk '{print $2}' | tail -n 1 )
  MEM_AVAILABLE_MB=$( echo "${MEM_AVAILABLE} / 1024" | bc )
  PERCENT_FREE=$( echo "${MEM_AVAILABLE} / ${MEM_TOTAL}" | bc -l )


  if [[ "${TEST_OUTPUT}" -eq 1 ]] || ([[ $( echo "${PERCENT_FREE} < 10" | bc -l ) -eq 1 ]] && [[ $( echo "${MEM_AVAILABLE_MB} < 256" | bc ) -gt 0 ]])
  then
    MESSAGE_ERROR=":desktop: :fire: Free RAM is under 256 MB: ${MEM_AVAILABLE_MB} MB :fire: :desktop: "
  fi
  if [[ "${TEST_OUTPUT}" -eq 1 ]] || ([[ $( echo "${PERCENT_FREE} < 20" | bc -l ) -eq 1 ]] && [[ $( echo "${MEM_AVAILABLE_MB} >= 256" | bc ) -gt 0 ]] && [[ $( echo "${MEM_AVAILABLE_MB} < 512" | bc ) -gt 0 ]])
  then
    MESSAGE_WARNING=":desktop: Free RAM is under 512 MB: ${MEM_AVAILABLE_MB} MB :desktop: "
  fi

  if [[ "${DEBUG_OUTPUT}" -eq 1 ]]
  then
    echo "Ram Free MB: ${MEM_AVAILABLE_MB}"
    echo
  fi

  RECOVERED_MESSAGE_SUCCESS="Free RAM is now at ${MEM_AVAILABLE_MB} MB."
  RECOVERED_TITLE_SUCCESS="Free RAM is back to normal."
  PROCESS_MESSAGES "${NAME}" "${MESSAGE_ERROR}" "${MESSAGE_WARNING}" "${MESSAGE_INFO}" "${MESSAGE_SUCCESS}" "${RECOVERED_MESSAGE_SUCCESS}" "${RECOVERED_TITLE_SUCCESS}" "${DISCORD_WEBHOOK_USERNAME_DEFAULT}" "${DISCORD_WEBHOOK_AVATAR_DEFAULT}"
}

 CHECK_CLOCK () {
  NAME='system_clock'
  MESSAGE_ERROR=''
  MESSAGE_WARNING=''
  MESSAGE_INFO=''
  MESSAGE_SUCCESS=''

  TIME_OFFSET=$( ntpdate -q pool.ntp.org | tail -n 1 | grep -o 'offset.*' | awk '{print $2 }' | tr -d '-' )

  if [[ $( echo "${TIME_OFFSET} > 1" | bc ) -gt 0 ]] || [[ "${TEST_OUTPUT}" -eq 1 ]]
  then
    MESSAGE_ERROR=":watch: :fire: System Clock if off by over 1 second. Offset: ${TIME_OFFSET} seconds :fire: :watch: "
  fi
  if [[ $( echo "${TIME_OFFSET} > 0.1" | bc ) -gt 0 ]] || [[ "${TEST_OUTPUT}" -eq 1 ]]
  then
    MESSAGE_WARNING=":watch: System Clock if off by over 0.1 seconds. Offset: ${TIME_OFFSET} seconds :watch: "
  fi

  if [[ "${DEBUG_OUTPUT}" -eq 1 ]]
  then
    echo "System clock offset: ${TIME_OFFSET}"
    echo
  fi

  RECOVERED_MESSAGE_SUCCESS="System clock is now at ${TIME_OFFSET} seconds."
  RECOVERED_TITLE_SUCCESS="System clock is back to normal."
  PROCESS_MESSAGES "${NAME}" "${MESSAGE_ERROR}" "${MESSAGE_WARNING}" "${MESSAGE_INFO}" "${MESSAGE_SUCCESS}" "${RECOVERED_MESSAGE_SUCCESS}" "${RECOVERED_TITLE_SUCCESS}" "${DISCORD_WEBHOOK_USERNAME_DEFAULT}" "${DISCORD_WEBHOOK_AVATAR_DEFAULT}"
}

 REPORT_INFO_ABOUT_NODE () {
  USRNAME=$( echo "${1}" | tr -d \" )
  DAEMON_BIN=$( echo "${2}" | tr -d \" )
  CONTROLLER_BIN_LOC=$( echo "${3}" | tr -d \" )
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
  ALL_STAKE_INPUTS_BALANCE_COUNT=$( echo "${17}" | tr -d \" )
  VERSION=$( echo "${18}" | tr -d \" )

  if [[ -z "${USRNAME}" ]]
  then
    return
  fi

  if [[ ! ${MASTERNODE} =~ ${RE} ]]
  then
    return
  fi

  DISCORD_WEBHOOK_AVATAR=''
  DISCORD_WEBHOOK_USERNAME=''
  EXTRA_INFO=$( echo "${DAEMON_BIN_LUT}" | grep -E "^${DAEMON_BIN} " )
  if [[ ! -z "${EXTRA_INFO}" ]]
  then
    DISCORD_WEBHOOK_AVATAR=$( echo "${EXTRA_INFO}" | cut -d ' ' -f2 )
    DISCORD_WEBHOOK_USERNAME=$( echo "${EXTRA_INFO}" | cut -d ' ' -f3- )
  fi

  if [[ "${MASTERNODE}" == '-1' ]]
  then
    PROCESS_NODE_MESSAGES "${USRNAME}" "not_running" "__${USRNAME} ${DAEMON_BIN} ${CONF_LOCATION}__
${MNINFO}" "" "" "" "" "" "${DISCORD_WEBHOOK_USERNAME}" "${DISCORD_WEBHOOK_AVATAR}"
    return
  fi

  if [[ "${MASTERNODE}" == '-2' ]]
  then
    PROCESS_NODE_MESSAGES "${USRNAME}" "frozen" "__${USRNAME} ${DAEMON_BIN} ${CONF_LOCATION}__
${MNINFO}" "" "" "" "" "" "${DISCORD_WEBHOOK_USERNAME}" "${DISCORD_WEBHOOK_AVATAR}"
    return
  fi

  MIN_STAKE=0
  STAKE_REWARD=0
  MASTERNODE_REWARD=0
#   BLOCKS_WAIT=0
#   SECONDS_WAIT=0
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
#     BLOCKS_WAIT=$( echo "${EXTRA_INFO}" | cut -d ' ' -f5 )
#     SECONDS_WAIT=$( echo "${EXTRA_INFO}" | cut -d ' ' -f6 )
    NET_HASH_FACTOR=$( echo "${EXTRA_INFO}" | cut -d ' ' -f7 )
    TICKER_NAME=$( echo "${EXTRA_INFO}" | cut -d ' ' -f8 )
    BLOCKTIME_SECONDS=$( echo "${EXTRA_INFO}" | cut -d ' ' -f9 )
    STAKE_REWARD_UPPER=$( echo "${STAKE_REWARD} + 0.3" | bc -l )
  fi

  # Report on connection count.
  if [[ ${GETCONNECTIONCOUNT} =~ ${RE} ]]
  then
    if [[ "${GETCONNECTIONCOUNT}" -lt 2 ]]
    then
      PROCESS_NODE_MESSAGES "${CONF_LOCATION}" "connection_count" "__${USRNAME} ${DAEMON_BIN}__
  Connection Count (${GETCONNECTIONCOUNT}) is very low!" "" "" "" "" "" "${DISCORD_WEBHOOK_USERNAME}" "${DISCORD_WEBHOOK_AVATAR}"
    elif [[ "${GETCONNECTIONCOUNT}" -lt 5 ]]
    then
      PROCESS_NODE_MESSAGES "${CONF_LOCATION}" "connection_count" "" "__${USRNAME} ${DAEMON_BIN}__
  Connection Count (${GETCONNECTIONCOUNT}) is low!" "" "" "" "" "${DISCORD_WEBHOOK_USERNAME}" "${DISCORD_WEBHOOK_AVATAR}"
    else
      PROCESS_NODE_MESSAGES "${CONF_LOCATION}" "connection_count" "" "" "" "" "__${USRNAME} ${DAEMON_BIN}__
  Connection count has been restored" "Connection Count Normal" "${DISCORD_WEBHOOK_USERNAME}" "${DISCORD_WEBHOOK_AVATAR}"
    fi
  fi

  # Masternode Status.
  if [[ ${MASTERNODE} -eq 1 ]]
  then
    if [[ ${MNINFO} -eq 1 ]]
    then
      PROCESS_NODE_MESSAGES "${CONF_LOCATION}" "masternode_status" "" "" "__${USRNAME} ${DAEMON_BIN}__
Masternode should be starting up soon." "" "" "" "${DISCORD_WEBHOOK_USERNAME}" "${DISCORD_WEBHOOK_AVATAR}"
    elif [[ ${MNINFO} -eq 2 ]]
    then
      PROCESS_NODE_MESSAGES "${CONF_LOCATION}" "masternode_status" "" "__${USRNAME} ${DAEMON_BIN}__
Masternode list shows the masternode as active bug masternode status doesn't. Hopefully this changes soon." "" "" "" "" "${DISCORD_WEBHOOK_USERNAME}" "${DISCORD_WEBHOOK_AVATAR}"
    else
      PROCESS_NODE_MESSAGES "${CONF_LOCATION}" "masternode_status" "__${USRNAME} ${DAEMON_BIN}__
Masternode is not currently running." "" "" "" "" "" "${DISCORD_WEBHOOK_USERNAME}" "${DISCORD_WEBHOOK_AVATAR}"
    fi
  elif [[ ${MASTERNODE} -eq 2 ]]
  then
    if [[ ${MNINFO} -eq 2 ]]
    then
      PROCESS_NODE_MESSAGES "${CONF_LOCATION}" "masternode_status" "" "" "" "" "__${USRNAME} ${DAEMON_BIN}__
Masternode status and masternode list are good!" "Masternode Running" "${DISCORD_WEBHOOK_USERNAME}" "${DISCORD_WEBHOOK_AVATAR}"
    elif [[ ${MNINFO} -eq 0 ]]
    then
      PROCESS_NODE_MESSAGES "${CONF_LOCATION}" "masternode_status" "" "" "" "" "__${USRNAME} ${DAEMON_BIN}__
Masternode status is good!" "Masternode Running" "${DISCORD_WEBHOOK_USERNAME}" "${DISCORD_WEBHOOK_AVATAR}"
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
in approximately ${MN_REWARD_IN_TIME}." "" "" "${DISCORD_WEBHOOK_USERNAME}" "${DISCORD_WEBHOOK_AVATAR}"
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
  if [[ $( echo "${BALANCE_DIFF} != 0 " | bc -l ) -eq 0 ]]
  then
    : # Do nothing.

  # Wallet has been drained.
  elif [[ -z "${GETTOTALBALANCE}" ]] || [[ $( echo "${GETTOTALBALANCE} == 0" | bc -l ) -eq 1 ]]
  then
    SEND_ERROR "__${USRNAME} ${DAEMON_BIN}__
Balance is now zero ${TICKER_NAME}!
Before: ${PAST_BALANCE}
After: ${GETTOTALBALANCE} " "" "${DISCORD_WEBHOOK_USERNAME}" "${DISCORD_WEBHOOK_AVATAR}"

  # Larger amount has been moved off this wallet.
  elif [[ $( echo "${BALANCE_DIFF} < -1" | bc -l ) -gt 0 ]]
  then
    SEND_WARNING "__${USRNAME} ${DAEMON_BIN}__
Balance has decreased by over 1 ${TICKER_NAME} Difference: ${BALANCE_DIFF}.
New Balance: ${GETTOTALBALANCE}" "" "${DISCORD_WEBHOOK_USERNAME}" "${DISCORD_WEBHOOK_AVATAR}"

  # Small amount has been moved.
  elif [[ $( echo "${BALANCE_DIFF} < 1" | bc -l ) -gt 0 ]]
  then
    SEND_INFO "__${USRNAME} ${DAEMON_BIN}__
Small amout of ${TICKER_NAME} has been transfered Difference: ${BALANCE_DIFF}.
New Balance: ${GETTOTALBALANCE}" "" "${DISCORD_WEBHOOK_USERNAME}" "${DISCORD_WEBHOOK_AVATAR}"

  # More than 1 Coin has been added.
  elif [[ $( echo "${BALANCE_DIFF} >= 1" | bc -l ) -gt 0 ]]
  then
    if [[ $( echo "${BALANCE_DIFF} == ${MASTERNODE_REWARD}" | bc -l ) -eq 1 ]]
    then
      SEND_SUCCESS "__${USRNAME} ${DAEMON_BIN}__
Masternode reward amout of ${BALANCE_DIFF} ${TICKER_NAME}.
New Balance: ${GETTOTALBALANCE}" "" "${DISCORD_WEBHOOK_USERNAME}" "${DISCORD_WEBHOOK_AVATAR}"
    elif [[ $( echo "${BALANCE_DIFF} >= ${STAKE_REWARD}" | bc -l ) -gt 0 ]] && [[ $( echo "${BALANCE_DIFF} < ${STAKE_REWARD_UPPER}" | bc -l ) -gt 0 ]]
    then
      SEND_SUCCESS "__${USRNAME} ${DAEMON_BIN}__
Staking reward amout of ${BALANCE_DIFF} ${TICKER_NAME}.
New Balance: ${GETTOTALBALANCE}" "" "${DISCORD_WEBHOOK_USERNAME}" "${DISCORD_WEBHOOK_AVATAR}"
    else
      SEND_SUCCESS "__${USRNAME} ${DAEMON_BIN}__
Larger amout of ${TICKER_NAME} has been transfered Difference: ${BALANCE_DIFF}.
New Balance: ${GETTOTALBALANCE}" "" "${DISCORD_WEBHOOK_USERNAME}" "${DISCORD_WEBHOOK_AVATAR}"
    fi
  fi

  # Get average staking times for masternode and staking rewards.
#   SECONDS_TO_AVERAGE_STAKE_MASTERNODE_REWARD=0
#   SECONDS_TO_AVERAGE_STAKE_STAKING_REWARD=0
  COINS_STAKED_TOTAL_NETWORK=$( echo "${NETWORKHASHPS} * ${NET_HASH_FACTOR}" | bc -l )
#   if [[ ! -z "${COINS_STAKED_TOTAL_NETWORK}" ]] && [[ $( echo "${COINS_STAKED_TOTAL_NETWORK} != 0" | bc -l ) -eq 1 ]]
#   then
#     SECONDS_TO_AVERAGE_STAKE_MASTERNODE_REWARD=$( echo "${MASTERNODE_REWARD} / ${GETBALANCE} * ${BLOCKTIME_SECONDS}" | bc -l )
#     SECONDS_TO_AVERAGE_STAKE_STAKING_REWARD=$( echo "${STAKE_REWARD} / ${GETBALANCE} * ${BLOCKTIME_SECONDS}" | bc -l )
#   fi
  # Report on staking.
  TIME_TO_STAKE=''
  if [[ ! -z "${GETBALANCE}" ]] && [[ "$( echo "${GETBALANCE} > 0.0" | bc -l )" -gt 0 ]]
  then

    if [[ ! -z "${COINS_STAKED_TOTAL_NETWORK}" ]] && [[ $( echo "${COINS_STAKED_TOTAL_NETWORK} != 0" | bc -l ) -eq 1 ]]
    then

      # Better staking info
      if [[ ! -z "${ALL_STAKE_INPUTS_BALANCE_COUNT}" ]]
      then
        STAKE_GETBALANCE=$( echo "${ALL_STAKE_INPUTS_BALANCE_COUNT}" | awk '{print $1}' )
        SECONDS_TO_AVERAGE_STAKE=$( echo "${COINS_STAKED_TOTAL_NETWORK} / ${STAKE_GETBALANCE} * ${BLOCKTIME_SECONDS}" | bc -l )
      else
        SECONDS_TO_AVERAGE_STAKE=$( echo "${COINS_STAKED_TOTAL_NETWORK} / ${GETBALANCE} * ${BLOCKTIME_SECONDS}" | bc -l )
      fi
      TIME_TO_STAKE=$( DISPLAYTIME "${SECONDS_TO_AVERAGE_STAKE}" )
    fi

    if [[ "$( echo "${MIN_STAKE} > ${GETBALANCE}" | bc -l )" -gt 0 ]]
    then
      PROCESS_NODE_MESSAGES "${CONF_LOCATION}" "staking_balance" "" "__${USRNAME} ${DAEMON_BIN}__
Balance (${GETBALANCE}) is below the minimum staking threshold (${MIN_STAKE}).
${GETBALANCE} < ${MIN_STAKE} " "" "" "" "" "${DISCORD_WEBHOOK_USERNAME}" "${DISCORD_WEBHOOK_AVATAR}"
    else
      PROCESS_NODE_MESSAGES "${CONF_LOCATION}" "staking_balance" "" "" "" "" "__${USRNAME} ${DAEMON_BIN}__
Has enough coins to stake now!" "Balance is above the minimum" "${DISCORD_WEBHOOK_USERNAME}" "${DISCORD_WEBHOOK_AVATAR}"
      if [[ "${STAKING}" -eq 0 ]]
      then
        GETSTAKINGSTATUS=$( su "${USRNAME}" -c "\"${CONTROLLER_BIN_LOC}\" \"-datadir=${CONF_FOLDER}\" getstakingstatus" 2>&1 | jq . | grep 'false' | tr -d \" )
        PROCESS_NODE_MESSAGES "${CONF_LOCATION}" "staking_status" "" "__${USRNAME} ${DAEMON_BIN}__
${GETSTAKINGSTATUS}" "" "" "" "" "${DISCORD_WEBHOOK_USERNAME}" "${DISCORD_WEBHOOK_AVATAR}"
      fi
      if [[ "${STAKING}" -eq 1 ]]
      then
        PROCESS_NODE_MESSAGES "${CONF_LOCATION}" "staking_status" "" "" "" "" "__${USRNAME} ${DAEMON_BIN}__
Staking status is now TRUE!" "Staking is enabled" "${DISCORD_WEBHOOK_USERNAME}" "${DISCORD_WEBHOOK_AVATAR}"
      fi
    fi
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

  _PAYLOAD="__${USRNAME} ${DAEMON_BIN}__
BlockCount: ${GETBLOCKCOUNT}
Connections: ${GETCONNECTIONCOUNT}
Staking Status: ${STAKING_TEXT}
Masternode Status: ${MASTERNODE_TEXT}
PID: ${DAEMON_PID}
Version: ${VERSION}
Uptime: ${UPTIME} seconds (${UPTIME_HUMAN})"
  if [[ ! -z "${GETBALANCE}" ]] && [[ "$( echo "${GETBALANCE} > 0.0" | bc -l )" -gt 0 ]]
  then
    _PAYLOAD="${_PAYLOAD}
Balance: ${GETBALANCE}
Total Balance: ${GETTOTALBALANCE}"
  fi
  if [[ ! -z "${TIME_TO_STAKE}" ]]
  then
    _PAYLOAD="${_PAYLOAD}
Staking Average ETA: ${TIME_TO_STAKE}"
  fi
  if [[ ! -z "${ALL_STAKE_INPUTS_BALANCE_COUNT}" ]]
  then
    STAKE_GETBALANCE=$( echo "${ALL_STAKE_INPUTS_BALANCE_COUNT}" | awk '{print $1}' )
    NUMBER_OF_STAKING_INPUTS=$( echo "${ALL_STAKE_INPUTS_BALANCE_COUNT}" | awk '{print $2}' )
    _PAYLOAD="${_PAYLOAD}
Staking Balance: ${STAKE_GETBALANCE}
Number of staking inputs: ${NUMBER_OF_STAKING_INPUTS}"
  fi

  PROCESS_NODE_MESSAGES "${CONF_LOCATION}" "node_info" "" "" "${_PAYLOAD}" "" "" "" "${DISCORD_WEBHOOK_USERNAME}" "${DISCORD_WEBHOOK_AVATAR}"
}

 GET_INFO_ON_THIS_NODE () {
  HAS_FUNCTION=${1}
  USRNAME=${2}
  CONTROLLER_BIN_LOC=${3}
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

  GETBLOCKCOUNT=$( su "${USRNAME}" -c "timeout 5 \"${CONTROLLER_BIN_LOC}\" \"-datadir=${CONF_FOLDER}\" getblockcount" 2>&1 | grep -o '[0-9].*' )
  GETCONNECTIONCOUNT=$( su "${USRNAME}" -c "timeout 5 \"${CONTROLLER_BIN_LOC}\" \"-datadir=${CONF_FOLDER}\" getconnectioncount" 2>&1 | grep -o '[0-9].*' )

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
    MASTERNODE_STATUS=$( su "${USRNAME}" -c "\"${CONTROLLER_BIN_LOC}\" \"-datadir=${CONF_FOLDER}\" masternode status" 2>&1 )
    if [[ $( echo "${MASTERNODE_STATUS}" | grep -ic "method not found" ) -gt 0 ]]
    then
      MASTERNODE_STATUS=$( su "${USRNAME}" -c "\"${CONTROLLER_BIN_LOC}\" \"-datadir=${CONF_FOLDER}\" masternode debug" 2>&1 )
    fi
    if [[ $( echo "${MASTERNODE_STATUS}" | grep -ic "method not found" ) -gt 0 ]] && [[ "${HAS_FUNCTION}" -gt 0 ]]
    then
      MASTERNODE_STATUS=$( bash -ic "source /var/multi-masternode-data/.bashrc; ${USRNAME} mnstatus" )
    fi
    if [[ $( echo "${MASTERNODE_STATUS}" | grep -ic "method not found" ) -gt 0 ]]
    then
      MASTERNODE_STATUS=$( su "${USRNAME}" -c "\"${CONTROLLER_BIN_LOC}\" \"-datadir=${CONF_FOLDER}\" getmasternodestatus" 2>&1 )
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

  # Get total balance in the wallet.
  WALLETINFO=$( su "${USRNAME}" -c "\"${CONTROLLER_BIN_LOC}\" \"-datadir=${CONF_FOLDER}\" getwalletinfo" 2>&1 )
  if [[ ! -z "${WALLETINFO}" ]] && [[ $( echo "${WALLETINFO}" | grep -ic 'balance' ) -gt 0 ]]
  then
    GETBALANCE=$( echo "${WALLETINFO}" | jq -r '.balance' )
    GETTOTALBALANCE=$( echo "${WALLETINFO}" | jq -r '.balance, .unconfirmed_balance, .immature_balance' | awk '{sum += $0} END {printf "%.8f", sum}' )
  else
    WALLETINFO=$( su "${USRNAME}" -c "\"${CONTROLLER_BIN_LOC}\" \"-datadir=${CONF_FOLDER}\" getbalance" 2>&1 )
  fi

  # Get the version number.
  VERSION=$( su "${USRNAME}" -c "timeout 5 \"${CONTROLLER_BIN_LOC}\" \"-datadir=${CONF_FOLDER}\" --help " 2>/dev/null | head -n 1 | sed 's/[^0-9.]*\([0-9.]*\).*/\1/' )
  if [[ -z "${VERSION}" ]]
  then
    VERSION=$( su "${USRNAME}" -c "timeout 5 \"${CONTROLLER_BIN_LOC}\" \"-datadir=${CONF_FOLDER}\" -version " 2>/dev/null | sed 's/[^0-9.]*\([0-9.]*\).*/\1/' )
  fi

  # Check staking status.
  STAKING=0
  GETSTAKINGSTATUS=''
  if [[ $( echo "${GETBALANCE} > 0" | bc -l ) -gt 0 ]]
  then
    GETSTAKINGSTATUS=$( su "${USRNAME}" -c "\"${CONTROLLER_BIN_LOC}\" \"-datadir=${CONF_FOLDER}\" getstakingstatus" 2>&1 )
    if [[ $( echo "${GETSTAKINGSTATUS}" | grep -c 'false' ) -eq 0 ]]
    then
      STAKING=1
    fi
  fi

  LIST_STAKE_INPUTS=''
  ALL_STAKE_INPUTS_BALANCE_COUNT=''
  if [[ $( echo "${GETBALANCE} > 0" | bc -l ) -gt 0 ]]
  then
    LIST_STAKE_INPUTS=$( su "${USRNAME}" -c "timeout 10 \"${CONTROLLER_BIN_LOC}\" \"-datadir=${CONF_FOLDER}\" liststakeinputs " 2>/dev/null )
    if [[ $( echo "${LIST_STAKE_INPUTS}" | grep -ci 'Method not found') -eq 0 ]] && [[ $( echo "${LIST_STAKE_INPUTS}" | grep -c 'amount' ) -gt 0 ]]
    then
      STAKING_INPUTS_COUNT=$( echo "${LIST_STAKE_INPUTS}" | grep -c 'amount' )
      STAKE_INPUTS_BALANCE=$( echo "${LIST_STAKE_INPUTS}" | jq '.[].amount' | awk '{s+=$1} END {print s}' )
      ALL_STAKE_INPUTS_BALANCE_COUNT="${STAKE_INPUTS_BALANCE} ${STAKING_INPUTS_COUNT}"
    fi
  fi

  # Check networkhashps
  GETNETHASHRATE=$( su "${USRNAME}" -c "\"${CONTROLLER_BIN_LOC}\" \"-datadir=${CONF_FOLDER}\" getnetworkhashps" 2>&1 | grep -Eo '[+-]?[0-9]+([.][0-9]+)?' 2>/dev/null )
  if [[ -z "${GETNETHASHRATE}" ]]
  then
    GETNETHASHRATE=0
  fi

  # Output info.
  CONF_LOCATION=$( dirname "${CONF_LOCATION}" )
  REPORT_INFO_ABOUT_NODE "${USRNAME}" "${DAEMON_BIN}" "${CONTROLLER_BIN_LOC}" "${CONF_FOLDER}" "${CONF_LOCATION}" "${MASTERNODE}" "${MNINFO}" "${GETBALANCE}" "${GETTOTALBALANCE}" "${STAKING}" "${GETCONNECTIONCOUNT}" "${GETBLOCKCOUNT}" "${UPTIME}" "${DAEMON_PID}" "${GETNETHASHRATE}" "${MNWIN}" "${ALL_STAKE_INPUTS_BALANCE_COUNT}" "${VERSION}"
}

 GET_ALL_NODES () {
  DAEMON_BIN_FILTER="${1}"

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
      FUNCTION_PARAMS=''
      DAEMON_BIN_LOC=''
      CONTROLLER_BIN_LOC=''
      if [[ $( grep -ric "nomnmon" "${CONF_LOCATION}" ) -gt 0 ]]
      then
        continue
      fi

      # Get daemon bin name and pid from lock in conf folder.
      CONF_FOLDER=$( dirname "${CONF_LOCATION}" )
      DAEMON_BIN=$( echo "${LSLOCKS}" | grep -m 1 "${CONF_FOLDER}" | awk '{print $1}' )
      CONTROLLER_BIN="${DAEMON_BIN}"
      DAEMON_PID=$( echo "${LSLOCKS}" | grep -m 1 "${CONF_FOLDER}" | awk '{print $2}' )

      # Get path to daemon bin.
      if [[ ! -z "${DAEMON_PID}" ]]
      then
        DAEMON_BIN_LOC=$( echo "${PS_LIST}" | cut -c 32- | grep " ${DAEMON_PID} " | awk '{print $3}' )
        CONTROLLER_BIN_LOC="${DAEMON_BIN_LOC}"
        COMMAND_FOLDER=$( dirname "${DAEMON_BIN_LOC}" )
        CONTROLLER_BIN_FOLDER=$( find "${COMMAND_FOLDER}" -executable -type f 2>/dev/null | grep -Ei "${DAEMON_BIN::-1}-cli$" )
        if [[ ! -z "${CONTROLLER_BIN_FOLDER}" ]]
        then
          CONTROLLER_BIN_LOC="${CONTROLLER_BIN_FOLDER}"
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
            DAEMON_BIN_LOC=$( bash -ic "source /var/multi-masternode-data/.bashrc; ${MN_USRNAME} daemon loc" )
            DAEMON_BIN=$( basename "${DAEMON_BIN_LOC}" )
          fi
        fi
        if [[ -z "${CONTROLLER_BIN_LOC}" ]]
        then
          CONTROLLER_BIN_LOC=$( bash -ic "source /var/multi-masternode-data/.bashrc; ${MN_USRNAME} cli loc" )
          CONTROLLER_BIN=$( basename "${CONTROLLER_BIN_LOC}" )
        fi
      fi

      UPTIME=0
      if [[ ! -z "${DAEMON_PID}" ]]
      then
        UPTIME=$( echo "${PS_LIST}" | cut -c 32- | grep " ${DAEMON_PID} " | awk '{print $2}' | head -n 1 | awk '{print $1}' | grep -o '[0-9].*' )
      fi

      if [[ ! -z "${DAEMON_BIN_FILTER}" ]] && [[ "${DAEMON_BIN_FILTER}" != "${DAEMON_BIN}" ]]
      then
        continue
      fi

      if [[ "${DEBUG_OUTPUT}" -eq 1 ]]
      then
        echo
        echo "+++++++++++++++++++++++++++++"
        echo "Has Function: ${HAS_FUNCTION}"
        echo "Function: ${FUNCTION_PARAMS}"
        echo "Username: ${USRNAME} ${MN_USRNAME}"
        echo "Cli: ${CONTROLLER_BIN} ${CONTROLLER_BIN_LOC}"
        echo "Daemon: ${DAEMON_BIN} ${DAEMON_BIN_LOC}"
        echo "Conf Location: ${CONF_LOCATION}"
        echo "PID: ${DAEMON_PID}"
        echo "Uptime: ${UPTIME}"
        echo
      fi

      GET_INFO_ON_THIS_NODE "${HAS_FUNCTION}" "${USRNAME}" "${CONTROLLER_BIN_LOC}" "${DAEMON_BIN}" "${CONF_LOCATION}" "${DAEMON_PID}" "${UPTIME}"
    done <<< "${CONF_LOCATIONS}"
  done <<< "$( cut -d: -f1 /etc/passwd | getent passwd | sed 's/:/ X /g' | sort -h )"
}

NOT_CRON_WORKFLOW () {
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
  DISCORD_WEBHOOK_URL=$( SQL_QUERY "SELECT value FROM variables WHERE key = 'discord_webhook_url_error';" )
  if [[ ! -z "${DISCORD_WEBHOOK_URL}" ]]
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
  DISCORD_WEBHOOK_URL=$( SQL_QUERY "SELECT value FROM variables WHERE key = 'discord_webhook_url_error';" )
  CHAT_ID=$( SQL_QUERY "SELECT value FROM variables WHERE key = 'telegram_chatid';" )
  if [[ ! -z "${DISCORD_WEBHOOK_URL}" ]]
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
}

# Main
  if [[ "${arg1}" == 'node_run' ]]
  then
    GET_ALL_NODES "${arg2}" "${arg3}"
  elif [[ "${arg1}" != 'cron' ]]
  then
    NOT_CRON_WORKFLOW
  else
    GET_LATEST_LOGINS
    CHECK_DISK
    CHECK_CPU_LOAD
    CHECK_SWAP
    CHECK_RAM
    CHECK_CLOCK
    GET_ALL_NODES
  fi

# End of the masternode monitor script.
