#!/bin/bash

#Script to start websocket process

#Load env.config
source ~/advancedKDB/config/env.config

echo -----------------------------------
echo ------- Starting Websocket --------
echo -----------------------------------


~/q/l64/q ~/advancedKDB/html/q/websocket.q -p $WS_PORT > /dev/null 2>&1 &
sleep 3
if [ -z "$(ps -ef | grep $WS_PORT | grep websocket.q)" ];
then 
    echo "#### [ERROR] ####: Websocket process failed to start"
else
    echo "#### [INFO] ####: Websocket process started on port $WS_PORT"
fi