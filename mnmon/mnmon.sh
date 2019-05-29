#!/bin/bash

WEBHOOK_USERNAME_DEFAULT='Masternode Monitor'
WEBHOOK_AVATAR_DEFAULT='https://i.imgur.com/8WHSSa7s.jpg'

arg1="${1}"

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
  sqlite3 -batch /var/multi-masternode-data/mnbot/mnmon.sqlite3.db "${1}"
}

# Create tables if they do not exist.
SQL_QUERY "CREATE TABLE IF NOT EXISTS webhook_urls (
 type TEXT PRIMARY KEY,
 url TEXT NOT NULL
);"

SQL_QUERY "CREATE TABLE IF NOT EXISTS events_log (
 time INTEGER NOT NULL,
 name_type TEXT NOT NULL,
 message TEXT NOT NULL,
 PRIMARY KEY (time, name_type)
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

  CONTENT=$( date -u )
  CONTENT=$( echo -n "${CONTENT} - " ; hostname -i )
  CONTENT=$( echo -n "${CONTENT} - " ; hostname )
  if [[ ! -z "${7}" ]]
  then
    CONTENT="${7}"
  fi

  # Build HTTP POST.
  _PAYLOAD=$( cat << PAYLOAD
{"username": "${WEBHOOK_USERNAME}",
  "avatar_url": "${WEBHOOK_AVATAR}",
  "content": "${CONTENT}",
  "embeds": [
    {
      "title": "${TITLE}",
      "color": ${WEBHOOK_COLOR},
      "description": "${DESCRIPTION}"
    }
  ]
}
PAYLOAD
)

  # Do the post.
  curl -H "Content-Type: application/json" \
  -X POST \
  -d "${_PAYLOAD}" "${URL}" 2>/dev/null
  sleep 0.3
}

TELEGRAM_SEND () {
  TOKEN=''
  GET_UPDATES=$( curl "https://api.telegram.org/bot${TOKEN}/getUpdates" 2>/dev/null )
  IS_OK=$( echo "${GET_UPDATES}" | jq '.ok' )
  echo "${IS_OK}"
  if [[ "${IS_OK}" == 'true' ]]
    CHAT_ID=$( echo "${GET_UPDATES}" | jq '.result[0].message.chat.id' )

  MESSAGE="Hello World"
  URL="https://api.telegram.org/bot$TOKEN/sendMessage"
  curl -s -X POST "${URL}" -d "chat_id=${CHAT_ID}" -d "text=${MESSAGE}"
}
TELEGRAM_SEND

WEBHOOK_SEND_ERROR () {
  URL=$( SQL_QUERY "SELECT url FROM webhook_urls WHERE type = 'Error';" )
  DESCRIPTION="${1}"
  if [[ -z "${DESCRIPTION}" ]]
  then
    DESCRIPTION="Error!"
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
  WEBHOOK_SEND "${URL}" "${DESCRIPTION}" "${TITLE}" "${3}" "${4}" "${WEBHOOK_COLOR}"
}

WEBHOOK_SEND_WARNING () {
  URL=$( SQL_QUERY "SELECT url FROM webhook_urls WHERE type = 'Warning';" )
  DESCRIPTION="${1}"
  if [[ -z "${DESCRIPTION}" ]]
  then
    DESCRIPTION="Warning."
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
  WEBHOOK_SEND "${URL}" "${DESCRIPTION}" "${TITLE}" "${3}" "${4}" "${WEBHOOK_COLOR}"
}

WEBHOOK_SEND_INFO () {
  URL=$( SQL_QUERY "SELECT url FROM webhook_urls WHERE type = 'Information';" )
  DESCRIPTION="${1}"
  if [[ -z "${DESCRIPTION}" ]]
  then
    DESCRIPTION="Information."
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
  WEBHOOK_SEND "${URL}" "${DESCRIPTION}" "${TITLE}" "${3}" "${4}" "${WEBHOOK_COLOR}"
}

WEBHOOK_SEND_SUCCESS () {
  URL=$( SQL_QUERY "SELECT url FROM webhook_urls WHERE type = 'Success';" )
  DESCRIPTION="${1}"
  if [[ -z "${DESCRIPTION}" ]]
  then
    DESCRIPTION="Success!"
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
  WEBHOOK_SEND "${URL}" "${DESCRIPTION}" "${TITLE}" "${3}" "${4}" "${WEBHOOK_COLOR}"
}

WEBHOOK_URL_PROMPT () {
  TEXT_A="${1}"
  WEBHOOKURL="${2}"
  while :
  do
    echo
    read -e -i "$WEBHOOKURL" -p "${TEXT_A}s WebHook URL: " input
    WEBHOOKURL="${input:-$WEBHOOKURL}"
    if [[ ! -z "${WEBHOOKURL}" ]]
    then
      TOKEN=$( wget -qO- -o- "${WEBHOOKURL}" | jq -r '.token' )
      if [[ -z "$TOKEN" ]]
      then
        echo "Given URL is not a webhook."
        echo
        echo -n 'Get Webhook URL: Your personal server (press plus on left if you do not have one)'
        echo -n ' -> Right click on your server -> Server Settings -> Webhooks'
        echo -n ' -> Create Webhook -> Copy webhook url -> save'
        echo
        WEBHOOKURL=''
      else
        break
      fi
    fi
  done
  SQL_QUERY "REPLACE INTO webhook_urls (type,url) VALUES ('${TEXT_A}','${WEBHOOKURL}');"
}

if [[ "${arg1}" != 'cron' ]]
then
  echo
  PREFIX='Setup'
  WEBHOOKURL=$( SQL_QUERY "SELECT url FROM webhook_urls WHERE type = 'Error';" )
  if [[ ! -z "${WEBHOOKURL}" ]]
  then
    PREFIX='Redo'
  fi
  read -p "Redo webhook URLs (y/n)? " -r
  echo
  REPLY=${REPLY,,} # tolower
  if [[ "${REPLY}" == y ]]
  then
    return 1 2>/dev/null
  fi

  GET_DISCORD_WEBHOOKS
fi

GET_DISCORD_WEBHOOKS () {
  WEBHOOKURL=$( SQL_QUERY "SELECT url FROM webhook_urls WHERE type = 'Error';" )
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

    WEBHOOK_URL_PROMPT "Error" "${WEBHOOKURL}"
    WEBHOOK_SEND_ERROR "Test"
  fi
  WEBHOOKURL=$( SQL_QUERY "SELECT url FROM webhook_urls WHERE type = 'Warning';" )
  if [[ -z "${WEBHOOKURL}" ]] || [[ "${REPLY}" == y ]]
  then
    WEBHOOK_URL_PROMPT "Warning" "${WEBHOOKURL}"
    WEBHOOK_SEND_WARNING "Test"
  fi
  WEBHOOKURL=$( SQL_QUERY "SELECT url FROM webhook_urls WHERE type = 'Information';" )
  if [[ -z "${WEBHOOKURL}" ]] || [[ "${REPLY}" == y ]]
  then
    WEBHOOK_URL_PROMPT "Information" "${WEBHOOKURL}"
    WEBHOOK_SEND_INFO "Test"
  fi
  WEBHOOKURL=$( SQL_QUERY "SELECT url FROM webhook_urls WHERE type = 'Success';" )
  if [[ -z "${WEBHOOKURL}" ]] || [[ "${REPLY}" == y ]]
  then
    WEBHOOK_URL_PROMPT "Success" "${WEBHOOKURL}"
    WEBHOOK_SEND_SUCCESS "Test"
  fi
}

GET_LATEST_LOGINS () {
  while read -r DATE_1 DATE_2 DATE_3 LINE
  do
    UNIX_TIME=$( date -u --date="${DATE_1} ${DATE_2} ${DATE_3}" +%s )
    MESSAGE=$( SQL_QUERY "SELECT message FROM events_log WHERE time == ${UNIX_TIME} AND name_type == 'ssh_login';" )
    if [[ ! -z "${MESSAGE}" ]] && [[ "${arg1}" != 'test' ]]
    then
      continue
    fi

    INFO=$( grep -B 20 -F "${DATE_1} ${DATE_2} ${DATE_3} ${LINE}" /var/log/auth.log | grep -v 'CRON\|preauth\|Invalid user\|user unknown\|Failed[[:space:]]password\|authentication[[:space:]]failure\|refused[[:space:]]connect\|ignoring[[:space:]]max\|not[[:space:]]receive[[:space:]]identification\|[[:space:]]sudo\|[[:space:]]su\|Bad[[:space:]]protocol' | grep 'port' | grep -oE '\]\: .*' | cut -c 4- )

    ERRORS=$( WEBHOOK_SEND_INFO "${INFO}" ":unlock: User logged in" )
    if [[ -z "${ERRORS}" ]]
    then
      echo "${ERRORS}"
      SQL_QUERY "REPLACE INTO events_log (time,name_type,message) VALUES ('${UNIX_TIME}','ssh_login','${INFO}');"
    fi
  done <<< "$( grep ' systemd-logind'  /var/log/auth.log | grep 'New' )"
}
GET_LATEST_LOGINS

CHECK_DISK () {
  UNIX_TIME=$( date -u +%s )
  UNIX_TIME=$( echo "${UNIX_TIME}" - 7200 | bc )
  MESSAGE=$( SQL_QUERY "SELECT message FROM events_log WHERE time > ${UNIX_TIME} AND name_type == 'disk_space';" )
  if [[ ! -z "${MESSAGE}" ]] && [[ "${arg1}" != 'test' ]]
  then
    return
  fi

  FREEPSPACE_ALL=$( df -P . | tail -1 | awk '{print $4}' )
  FREEPSPACE_BOOT=$( df -P /boot | tail -1 | awk '{print $4}' )
  MESSAGE=''
  if [[ "${FREEPSPACE_ALL}" -lt 1572864 ]] || [[ "${arg1}" == 'test' ]]
  then
    FREEPSPACE_ALL=$( echo "${FREEPSPACE_ALL} / 1024" | bc )
    MESSAGE="${MESSAGE} Less than 1.5 GB of free space is left on the drive. ${FREEPSPACE_ALL} MB left."
  fi
  if [[ "${FREEPSPACE_BOOT}" -lt 131072 ]] || [[ "${arg1}" == 'test' ]]
  then
    FREEPSPACE_BOOT=$( echo "${FREEPSPACE_BOOT} / 1024" | bc )
    MESSAGE="${MESSAGE} Less than 128 MB of free space is left in the boot folder. ${FREEPSPACE_BOOT} MB left."
  fi

  if [[ ! -z "${MESSAGE}" ]]
  then
    UNIX_TIME=$( date -u +%s )
    ERRORS=$( WEBHOOK_SEND_WARNING ":floppy_disk: ${MESSAGE} :floppy_disk:" )
    if [[ -z "${ERRORS}" ]]
    then
      echo "${ERRORS}"
      SQL_QUERY "REPLACE INTO events_log (time,name_type,message) VALUES ('${UNIX_TIME}','disk_space','${MESSAGE}');"
    fi
  fi
}
CHECK_DISK

CHECK_CPU_LOAD () {
  UNIX_TIME=$( date -u +%s )
  UNIX_TIME=$( echo "${UNIX_TIME}" - 7200 | bc )
  MESSAGE=$( SQL_QUERY "SELECT message FROM events_log WHERE time > ${UNIX_TIME} AND name_type == 'cpu_usage';" )
  if [[ ! -z "${MESSAGE}" ]] && [[ "${arg1}" != 'test' ]]
  then
    return
  fi

  LOAD=$( uptime | grep -oE 'load average: [0-9]+([.][0-9]+)?' | grep -oE '[0-9]+([.][0-9]+)?' )
  CPU_COUNT=$( grep -c 'processor' /proc/cpuinfo )
  LOAD_PER_CPU="$( printf "%.3f\n" "$( bc -l <<< "${LOAD} / ${CPU_COUNT}" )" )"

  if [[ $( echo "${LOAD_PER_CPU} > 4" | bc ) -gt 0 ]] || [[ "${arg1}" == 'test' ]]
  then
    ERRORS=$( WEBHOOK_SEND_ERROR ":desktop: :fire:  CPU LOAD is over 4: ${LOAD_PER_CPU} :fire: :desktop: " )
    if [[ -z "${ERRORS}" ]] && [[ "${arg1}" != 'test' ]]
    then
      echo "${ERRORS}"
      SQL_QUERY "REPLACE INTO events_log (time,name_type,message) VALUES ('${UNIX_TIME}','cpu_usage','CPU LOAD is over 2');"
    fi
  fi
  if ([[ $( echo "${LOAD_PER_CPU} > 2" | bc ) -gt 0 ]] && [[ $( echo "${LOAD_PER_CPU} <= 4" | bc ) -gt 0 ]]) || [[ "${arg1}" == 'test' ]]
  then
    ERRORS=$( WEBHOOK_SEND_WARNING ":desktop: CPU LOAD is over 2: ${LOAD_PER_CPU} :desktop: " )
    if [[ -z "${ERRORS}" ]] && [[ "${arg1}" != 'test' ]]
    then
      echo "${ERRORS}"
      SQL_QUERY "REPLACE INTO events_log (time,name_type,message) VALUES ('${UNIX_TIME}','cpu_usage','CPU LOAD is over 2');"
    fi
  fi

}
CHECK_CPU_LOAD

CHECK_SWAP () {
  UNIX_TIME=$( date -u +%s )
  UNIX_TIME=$( echo "${UNIX_TIME}" - 7200 | bc )
  MESSAGE=$( SQL_QUERY "SELECT message FROM events_log WHERE time > ${UNIX_TIME} AND name_type == 'swap_free';" )
  if [[ ! -z "${MESSAGE}" ]] && [[ "${arg1}" != 'test' ]]
  then
    return
  fi

  SWAP_FREE_MB=$( free -wm | grep -i 'Swap:' | awk '{print $4}' )
  if [[ $( echo "${SWAP_FREE_MB} < 512" | bc ) -gt 0 ]] || [[ "${arg1}" == 'test' ]]
  then
    ERRORS=$( WEBHOOK_SEND_ERROR ":desktop: :fire: Swap is under 512 MB: ${SWAP_FREE_MB} :fire: :desktop: " )
    if [[ -z "${ERRORS}" ]] && [[ "${arg1}" != 'test' ]]
    then
      echo "${ERRORS}"
      SQL_QUERY "REPLACE INTO events_log (time,name_type,message) VALUES ('${UNIX_TIME}','cpu_usage','Swap is under 512 MB');"
    fi
  fi
  if ([[ $( echo "${SWAP_FREE_MB} >= 512" | bc ) -gt 0 ]] && [[ $( echo "${SWAP_FREE_MB} < 1024" | bc ) -gt 0 ]]) || [[ "${arg1}" == 'test' ]]
  then
    ERRORS=$( WEBHOOK_SEND_WARNING ":desktop: Swap is under 1024 MB: ${SWAP_FREE_MB} :desktop: " )
    if [[ -z "${ERRORS}" ]] && [[ "${arg1}" != 'test' ]]
    then
      echo "${ERRORS}"
      SQL_QUERY "REPLACE INTO events_log (time,name_type,message) VALUES ('${UNIX_TIME}','cpu_usage','Swap is under 1024 MB');"
    fi
  fi

}
CHECK_SWAP

CHECK_RAM () {
  UNIX_TIME=$( date -u +%s )
  UNIX_TIME=$( echo "${UNIX_TIME}" - 7200 | bc )
  MESSAGE=$( SQL_QUERY "SELECT message FROM events_log WHERE time > ${UNIX_TIME} AND name_type == 'ram_free';" )
  if [[ ! -z "${MESSAGE}" ]] && [[ "${arg1}" != 'test' ]]
  then
    continue
  fi

  MEM_AVAILABLE=$( sudo cat /proc/meminfo | grep -i 'MemAvailable:\|MemFree:' | awk '{print $2}' | tail -n 1 )
  MEM_AVAILABLE_MB=$( echo "${MEM_AVAILABLE} / 1024" | bc )

  if [[ $( echo "${MEM_AVAILABLE_MB} < 256" | bc ) -gt 0 ]] || [[ "${arg1}" == 'test' ]]
  then
    ERRORS=$( WEBHOOK_SEND_ERROR ":desktop: :fire: Free RAM is under 256 MB: ${MEM_AVAILABLE_MB} :fire: :desktop: " )
    if [[ -z "${ERRORS}" ]] && [[ "${arg1}" != 'test' ]]
    then
      echo "${ERRORS}"
      SQL_QUERY "REPLACE INTO events_log (time,name_type,message) VALUES ('${UNIX_TIME}','cpu_usage','Free RAM is under 256 MB');"
    fi
  fi
  if ([[ $( echo "${MEM_AVAILABLE_MB} >= 256" | bc ) -gt 0 ]] && [[ $( echo "${MEM_AVAILABLE_MB} < 512" | bc ) -gt 0 ]]) || [[ "${arg1}" == 'test' ]]
  then
    ERRORS=$( WEBHOOK_SEND_WARNING ":desktop: Free RAM is under 512 MB: ${MEM_AVAILABLE_MB} :desktop: " )
    if [[ -z "${ERRORS}" ]] && [[ "${arg1}" != 'test' ]]
    then
      echo "${ERRORS}"
      SQL_QUERY "REPLACE INTO events_log (time,name_type,message) VALUES ('${UNIX_TIME}','cpu_usage','Free RAM is under 512 MB');"
    fi
  fi
}
CHECK_RAM
