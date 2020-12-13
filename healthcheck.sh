#!/bin/bash

FILE=/config/config.ini

until test -f $FILE; do sleep 1; done

API=$(cat /config/config.ini | grep 'api_key =' | egrep -v 'disable|rating' | awk -F '= ' '{print $2}')
curl -f "http://localhost:8080/api/system/status?apikey=$API" || exit 1
