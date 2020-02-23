#!/bin/bash

#Script to start HDB process

#Load env.config
source ~/advancedKDB/config/env.config

echo ----------------------------
echo ------- Starting HDB--------
echo ----------------------------

cd $SCRIPTS_DIR

~/q/l64/q $SCRIPTS_DIR/hdb.q -p $HDB_PORT > /dev/null 2>&1 &
sleep 3
if [ -z "$(ps -ef | grep $HDB_PORT | grep $SCRIPTS_HOME/hdb.q)" ];
then 
    echo "#### [ERROR] ####: HDB failed to start"
else
    echo "#### [INFO] ####: HDB started on port $HDB_PORT"
fi