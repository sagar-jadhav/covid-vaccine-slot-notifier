#!/bin/bash

# Read params from user
printf "Enter State: "
read -r STATE
printf "Enter City: "
read -r CITY
printf "Enter Minumum Age (18/45): "
read -r MIN_AGE
printf "Enter Rechecking Interval in Seconds (e.g. 5s): "
read -r INTERVAL

# Computing Date
DATE=$(date +"%d-%m-%Y")

# Computing District
STATE_RETRIEVE_URL="https://cdn-api.co-vin.in/api/v2/admin/location/states"
STATES=$(curl -s -X GET "$STATE_RETRIEVE_URL" -H "Accept: application/json" -H "Accept-Language: hi_IN" \
    -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.93 Safari/537.36 Edg/90.0.818.51" |
    jq '.states')
STATES_LENGTH=$(echo $STATES | jq '. | length')
STATES_INDEX=0
STATE_ID=0

while [ $STATES_INDEX -lt $STATES_LENGTH ]; do
    V_STATE=$(echo $STATES | jq -r --arg index $STATES_INDEX '.[$index | tonumber].state_name')
    if [ "$V_STATE" = "$STATE" ]; then
        STATE_ID=$(echo $STATES | jq -r --arg index $STATES_INDEX '.[$index | tonumber].state_id')
        break
    fi
    STATES_INDEX=$((STATES_INDEX + 1))
done

# Compute District
DISTRICT_RETRIEVE_URL=$(printf "https://cdn-api.co-vin.in/api/v2/admin/location/districts/$STATE_ID")
DISTRICTS=$(curl -s -X GET "$DISTRICT_RETRIEVE_URL" -H "Accept: application/json" -H "Accept-Language: hi_IN" \
    -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.93 Safari/537.36 Edg/90.0.818.51" |
    jq '.districts')
DISTRICTS_LENGTH=$(echo $DISTRICTS | jq '. | length')
DISTRICTS_INDEX=0
DISTRICT_ID=0

while [ $DISTRICTS_INDEX -lt $DISTRICTS_LENGTH ]; do
    V_DISTRICT=$(echo $DISTRICTS | jq -r --arg index $DISTRICTS_INDEX '.[$index | tonumber].district_name')

    if [ "$V_DISTRICT" = "$CITY" ]; then
        DISTRICT_ID=$(echo $DISTRICTS | jq -r --arg index $DISTRICTS_INDEX '.[$index | tonumber].district_id')
        break
    fi
    DISTRICTS_INDEX=$((DISTRICTS_INDEX + 1))
done

# Computing URL to retrieve available slots
URL=$(printf "https://cdn-api.co-vin.in/api/v2/appointment/sessions/calendarByDistrict?district_id=$DISTRICT_ID&date=$DATE")

# Triggering infinite loop
while true; do
    CENTERS=$(curl -s -X GET "$URL" -H "Accept: application/json" -H "Accept-Language: hi_IN" \
        -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.93 Safari/537.36 Edg/90.0.818.51" |
        jq '.centers')
    CENTERS_LENGTH=$(echo $CENTERS | jq '. | length')
    INDEX=0
    AVAILABLE=0

    echo "-----------------"

    while [ $INDEX -lt $CENTERS_LENGTH ]; do
        NAME=$(echo $CENTERS | jq -r --arg index $INDEX '.[$index | tonumber].name')
        SESSIONS=$(echo $CENTERS | jq -r --arg index $INDEX '.[$index | tonumber].sessions')
        SESSIONS_LENGTH=$(echo $SESSIONS | jq '. | length')
        SESSION_INDEX=0

        while [ $SESSION_INDEX -lt $SESSIONS_LENGTH ]; do
            AVAILABLE_FACILITY=$(echo $SESSIONS | jq -r --arg index $SESSION_INDEX '.[$index | tonumber].available_capacity')
            MIN_AGE_LIMIT=$(echo $SESSIONS | jq -r --arg index $SESSION_INDEX '.[$index | tonumber].min_age_limit')

            SESSION_INDEX=$((SESSION_INDEX + 1))

            if [ $MIN_AGE_LIMIT == $MIN_AGE ]; then
                if [ $AVAILABLE_FACILITY -gt "0" ]; then
                    AVAILABLE=1
                    echo "-----------------"
                    echo "$AVAILABLE_FACILITY slots available at $NAME center 😊"
                    echo "-----------------"
                    break
                fi
            fi

        done

        INDEX=$((INDEX + 1))

        if [ $AVAILABLE -eq "1" ]; then
            NOTIFICATION_MESSAGE=$(echo "Slot Available at $NAME")
            NOTIFICATION_SUBTITLE=$(echo "$AVAILABLE_FACILITY slots available")
            osascript -e 'display notification "'"$NOTIFICATION_MESSAGE"'" with title "Vaccine Alert" subtitle "'"$NOTIFICATION_SUBTITLE"'" sound name "Alert"'
            break
        fi
    done

    if [ $AVAILABLE -eq "0" ]; then
        echo "😔 No slots available, rechecking after $INTERVAL 🏃🏻"
    fi

    echo "-----------------"
    sleep $INTERVAL

done
