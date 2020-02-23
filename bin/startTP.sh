#!/bin/bash

#Script to start TP process

#Load env.config
source ~/advancedKDB/config/env.config

echo ----------------------------
echo --- Starting Tickerplant ---
echo ----------------------------

cd $TICK_HOME

nohup ~/q/l64/q $TICK_HOME/tick.q sym -p $TP_PORT > /dev/null 2>&1 &
sleep 3
if [ -z "$(ps -ef | grep $TP_PORT | grep $TICK_HOME)" ];
then 
    echo "#### [ERROR] ####: Tickerplant failed to start"
else
    echo "#### [INFO] ####: Tickerplant started on port $TP_PORT"
fi