#!/bin/bash

#Script to start feedhandler process

#Load env.config
source ~/advancedKDB/config/env.config

echo ----------------------------
echo --- Starting Feedhandler ---
echo ----------------------------

cd $SCRIPTS_DIR

nohup ~/q/l64/q $SCRIPTS_DIR/feed.q -p $FEED_PORT > /dev/null 2>&1 &
sleep 3
if [ -z "$(ps -ef | grep $FEED_PORT | grep $SCRIPTS_HOME/feed.q)" ];
then 
    echo "#### [ERROR] ####: Feedhandler failed to start"
else
    echo "#### [INFO] ####: Feedhandler started on port $CEP_PORT"
fi