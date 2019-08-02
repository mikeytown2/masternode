#!/bin/bash

WEBHOOK_USERNAME_DEFAULT='Masternode Monitor'
WEBHOOK_AVATAR_DEFAULT='https://i.imgur.com/8WHSSa7s.jpg'

DAEMON_BIN_LUT="
energid https://s2.coinmarketcap.com/static/img/coins/128x128/3218.png Energi Monitor
dogecashd https://s2.coinmarketcap.com/static/img/coins/128x128/3672.png DogeCash Monitor
"

arg1="${1}"
arg2="${2}"
arg3="${3}"

RE='^[0-9]+$'

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

INSTALL_MN_MON_SERVICE () {
cat << SYSTEMD_CONF | sudo tee /etc/systemd/system/mnbot.service >/dev/null

[Unit]
Description=${DAEMON_NAME} ${MASTERNODE_NAME} for user ${USRNAME}
After=syslog.target network.target

[Service]
SyslogIdentifier=cftimer-test-energi-sentinel
Type=oneshot
Restart=no
RestartSec=5
UMask=0027
ExecStart=/bin/bash /var/multi-masternode-data/mnbot/mnmon.sh cron


[Timer]
OnBootSec=60
OnUnitActiveSec=60

SYSTEMD_CONF
}

WEBHOOK_SEND () {
(
  URL="${1}"
  DESCRIPTION="${2}"
  TITLE="${3}"
  WEBHOOK_USERNAME="${4}"
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

  SERVER_INFO=$( date -Ru )
  # shellcheck disable=SC2028
  SERVER_INFO=$( echo -n "${SERVER_INFO}\n - " ; hostname -i )
  # shellcheck disable=SC2028
  SERVER_INFO=$( echo -n "${SERVER_INFO}\n - " ; hostname )
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
  "username": "${WEBHOOK_USERNAME}",
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
      SECONDS_WAIT=$( printf "%.1f\n" $( echo "scale=3;${MS_WAIT}/1000" | bc -l ) )
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
  SERVER_INFO=$( echo -ne "${SERVER_INFO}\n - " ; hostname -i )
  SERVER_INFO=$( echo -ne "${SERVER_INFO}\n - " ; hostname )
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
        SQL_QUERY "REPLACE INTO variables (key,values) VALUES ('telegram_token','${TOKEN}');"
        SQL_QUERY "REPLACE INTO variables (key,values) VALUES ('telegram_chatid','${CHAT_ID}');"
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
  PREFIX='Setup'
  WEBHOOKURL=$( SQL_QUERY "SELECT value FROM variables WHERE key = 'discord_webhook_url_error';" )
  if [[ ! -z "${WEBHOOKURL}" ]]
  then
    PREFIX='Redo'
  fi
  read -p "${PREFIX} Discord Bot webhook URLs (y/n)? " -r
  REPLY=${REPLY,,} # tolower
  if [[ "${REPLY}" == y ]]
  then
    GET_DISCORD_WEBHOOKS
  fi

  PREFIX='Setup'
  CHAT_ID=$( SQL_QUERY "SELECT value FROM variables WHERE key = 'telegram_chatid';" )
  if [[ ! -z "${CHAT_ID}" ]]
  then
    PREFIX='Redo'
  fi
  read -p "${PREFIX} Telegram Bot token (y/n)? " -r
  REPLY=${REPLY,,} # tolower
  if [[ "${REPLY}" == y ]]
  then
    TELEGRAM_SETUP
  fi
fi

PROCESS_MESSAGES () {
  NAME=''
  MESSAGE_ERROR=''
  MESSAGE_WARNING=''
  MESSAGE_INFO=''
  MESSAGE_SUCCESS=''
  RECOVERED_MESSAGE_SUCCESS=''
  RECOVERED_TITLE_SUCCESS=''

  NAME=${1}
  MESSAGE_ERROR=${2}
  MESSAGE_WARNING=${3}
  MESSAGE_INFO=${4}
  MESSAGE_SUCCESS=${5}
  RECOVERED_MESSAGE_SUCCESS=${6}
  RECOVERED_TITLE_SUCCESS=${7}

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
#     echo "OLD MSG: ${MESSAGE_PAST}" >/dev/tty
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

    INFO=$( grep -B 20 -F "${DATE_1} ${DATE_2} ${DATE_3} ${LINE}" /var/log/auth.log | grep -v 'CRON\|preauth\|Invalid user\|user unknown\|Failed[[:space:]]password\|authentication[[:space:]]failure\|refused[[:space:]]connect\|ignoring[[:space:]]max\|not[[:space:]]receive[[:space:]]identification\|[[:space:]]sudo\|[[:space:]]su\|Bad[[:space:]]protocol' | grep 'port' | grep -oE '\]\: .*' | cut -c 4- )

    if [[ -z "${INFO}" ]]
    then
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
  done <<< "$( grep ' systemd-logind'  /var/log/auth.log | grep 'New' )"
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
  PROCESS_MESSAGES "${NAME}" "${MESSAGE_ERROR}" "${MESSAGE_WARNING}" "${MESSAGE_INFO}" "${MESSAGE_SUCCESS}" "${RECOVERED_MESSAGE_SUCCESS}" "${RECOVERED_TITLE_SUCCESS}"
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
  PROCESS_MESSAGES "${NAME}" "${MESSAGE_ERROR}" "${MESSAGE_WARNING}" "${MESSAGE_INFO}" "${MESSAGE_SUCCESS}" "${RECOVERED_MESSAGE_SUCCESS}" "${RECOVERED_TITLE_SUCCESS}"
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
  PROCESS_MESSAGES "${NAME}" "${MESSAGE_ERROR}" "${MESSAGE_WARNING}" "${MESSAGE_INFO}" "${MESSAGE_SUCCESS}" "${RECOVERED_MESSAGE_SUCCESS}" "${RECOVERED_TITLE_SUCCESS}"
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
  PROCESS_MESSAGES "${NAME}" "${MESSAGE_ERROR}" "${MESSAGE_WARNING}" "${MESSAGE_INFO}" "${MESSAGE_SUCCESS}" "${RECOVERED_MESSAGE_SUCCESS}" "${RECOVERED_TITLE_SUCCESS}"
}
CHECK_RAM

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

  CONF_N_USRNAMES=''
  LSLOCKS=$( lslocks -n -o COMMAND,PID,PATH )
  PS_LIST=$( ps --no-headers -axo user:32,pid,command )
  # shellcheck disable=SC2034
  while read -r USRNAME DEL_1 DEL_2 DEL_3 DEL_4 DEL_5 DEL_6 DEL_7 DEL_8 USR_HOME_DIR USR_HOME_DIR_ALT DEL_9
  do
    if [[ "${USR_HOME_DIR}" == 'X' ]]
    then
      USR_HOME_DIR=${USR_HOME_DIR_ALT}
    fi

    if [[ "${#USR_HOME_DIR}" -lt 3 ]] || [[ ${USR_HOME_DIR} == /var/* ]] || [[ ${USR_HOME_DIR} == '/proc' ]] || [[ ${USR_HOME_DIR} == '/dev' ]] || [[ ${USR_HOME_DIR} == /run/* ]] || [[ ${USR_HOME_DIR} == '/nonexistent' ]]
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
      TEMP_VAR_PID=$( echo "${LSLOCKS}" | grep -m 1 "${CONF_FOLDER}" | awk '{print $2}' )
      if [[ ! -z "${TEMP_VAR_PID}" ]]
      then
        DAEMON_BIN=$( echo "${PS_LIST}" | cut -c 32- | grep " ${TEMP_VAR_PID} " | awk '{print $2}' )
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
        if [[ -z "${DAEMON_BIN}" ]]
        then
          DAEMON_BIN=$( bash -ic "source /var/multi-masternode-data/.bashrc; ${MN_USRNAME} daemon loc" )
        fi
        if [[ -z "${CONTROLLER_BIN}" ]]
        then
          CONTROLLER_BIN=$( bash -ic "source /var/multi-masternode-data/.bashrc; ${MN_USRNAME} cli loc" )
        fi
      fi

      CONF_N_USRNAMES="${CONF_N_USRNAMES}
${HAS_FUNCTION} ${USRNAME} ${CONTROLLER_BIN} ${DAEMON_BIN} ${CONF_LOCATION} ${TEMP_VAR_PID}"
    done <<< "${CONF_LOCATIONS}"
  done <<< "$( cut -d: -f1 /etc/passwd | getent passwd | sed 's/:/ X /g' | sort -h )"

  # Clean up var.
  CONF_N_USRNAMES=$( echo "${CONF_N_USRNAMES}" | sed '/^[[:space:]]*$/d' )
  ROOT_ENTRY=$( echo "${CONF_N_USRNAMES}" | grep -E '^root .*' )
  CONF_N_USRNAMES=$( echo "${CONF_N_USRNAMES}" | sed '/^root .*/d' )
  CONF_N_USRNAMES="${CONF_N_USRNAMES}
${ROOT_ENTRY}"
  CONF_N_USRNAMES=$( echo "${CONF_N_USRNAMES}" | sed '/^[[:space:]]*$/d' )

  echo "${CONF_N_USRNAMES}" | column -t
}

GET_INFO_ON_ALL_NODES () {
  ALL_RUNNING_NODES=$( GET_ALL_NODES )

  PS_LIST=$( ps --no-headers -axo user:32,pid,etimes,command )

  while read -r HAS_FUNCTION USRNAME CONTROLLER_BIN DAEMON_BIN CONF_LOCATION DAEMON_PID
  do
    # is the daemon running.
    if [[ -z "${DAEMON_PID}" ]]
    then
      echo "${USRNAME} not-running"
      continue
    fi

    UPTIME=$( echo "${PS_LIST}" | cut -c 32- | grep " ${DAEMON_PID} " | awk '{print $2}' | head -n 1 | awk '{print $1}' | grep -o '[0-9].*' )

    # setup vars.
    CONF_FOLDER=$( dirname "${CONF_LOCATION}" )

    GETCONNECTIONCOUNT=$( su "${USRNAME}" -c "\"${CONTROLLER_BIN}\" \"-datadir=${CONF_FOLDER}\" getconnectioncount" 2>&1 | grep -o '[0-9].*' )
    GETBLOCKCOUNT=$( su "${USRNAME}" -c "\"${CONTROLLER_BIN}\" \"-datadir=${CONF_FOLDER}\" getblockcount" 2>&1 | grep -o '[0-9].*' )

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

    # check balance.
    GETBALANCE=$( su "${USRNAME}" -c "\"${CONTROLLER_BIN}\" \"-datadir=${CONF_FOLDER}\" getbalance" 2>&1 | grep -Eo '[+-]?[0-9]+([.][0-9]+)?' 2>/dev/null )
    if [[ -z "${GETBALANCE}" ]]
    then
      GETBALANCE=0
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

    # output info.
    DAEMON_BIN=$( basename "${DAEMON_BIN}" )
    CONF_LOCATION=$( dirname "${CONF_LOCATION}" )
    echo "${USRNAME} ${DAEMON_BIN} ${CONF_LOCATION} ${MASTERNODE} ${MNINFO} ${GETBALANCE} ${STAKING} ${GETCONNECTIONCOUNT} ${GETBLOCKCOUNT} ${UPTIME} ${DAEMON_PID} ${MNWIN}"
  done <<< "${ALL_RUNNING_NODES}"
}

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
  WEBHOOK_USERNAME="${9}"
  WEBHOOK_AVATAR="${10}"


  # Get past events.
  UNIX_TIME=$( date -u +%s )
  MESSAGE_PAST=$( SQL_QUERY "SELECT start_time,last_ping_time,message FROM node_log WHERE conf_loc == '${CONF_LOCATION}' AND type == '${TYPE}'; " )
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
#     echo "OLD MSG: ${MESSAGE_PAST}" >/dev/tty
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
    SQL_QUERY "REPLACE INTO node_log (start_time,last_ping_time,conf_loc,type,message) VALUES ('${START_TIME}','${UNIX_TIME}','${CONF_LOCATION}','${TYPE}','${MESSAGE}');"
  fi
}

REPORT_INFO_ABOUT_NODES () {
  NODE_INFO=$( GET_INFO_ON_ALL_NODES )
  NODE_INFO="Username binary Conf-Location MN-Status MN-Info Balance Staking Connection-Count BlockCount Uptime PID MN-Win
  ${NODE_INFO}"
  echo "${NODE_INFO}" | column -t

  while read -r USRNAME DAEMON_BIN CONF_LOCATION MASTERNODE MNINFO GETBALANCE STAKING GETCONNECTIONCOUNT GETBLOCKCOUNT UPTIME DAEMON_PID MNWIN
  do
    WEBHOOK_AVATAR=''
    WEBHOOK_USERNAME=''
    EXTRA_INFO=$( echo "${DAEMON_BIN_LUT}" | grep -E "^${DAEMON_BIN} " )
    if [[ ! -z "${EXTRA_INFO}" ]]
    then
      WEBHOOK_AVATAR=$( echo "${EXTRA_INFO}" | cut -d ' ' -f2 )
      WEBHOOK_USERNAME=$( echo "${EXTRA_INFO}" | cut -d ' ' -f3- )
    fi

    if [[ ${MASTERNODE} -eq 1 ]]
    then
      if [[ ${MNINFO} -eq 1 ]]
      then
        PROCESS_NODE_MESSAGES "${CONF_LOCATION}" "masternode_status" "" ""  "${USRNAME} masternode should be starting up soon." "" "" "" "${WEBHOOK_USERNAME}" "${WEBHOOK_AVATAR}"
      else
        PROCESS_NODE_MESSAGES "${CONF_LOCATION}" "masternode_status" "${USRNAME} masternode is not currently running." "" "" "" "" "" "${WEBHOOK_USERNAME}" "${WEBHOOK_AVATAR}"
      fi
    fi

  done <<< "${NODE_INFO}"
}
REPORT_INFO_ABOUT_NODES