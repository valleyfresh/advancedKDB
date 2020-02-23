#!/bin/bash

#Script to start RDB processes

#Load env.config
source ~/advancedKDB/config/env.config

echo ----------------------------
echo ------ Starting RDB1 -------
echo ----------------------------

cd $SCRIPTS_DIR

~/q/l64/q $SCRIPTS_DIR/rdb.q :$TP_PORT :$HDB_PORT -p $RDB1_PORT -tab trade quote > /dev/null 2>&1 &
sleep 3
if [ -z "$(ps -ef | grep $RDB1_PORT | grep $SCRIPTS_DIR/rdb.q)" ];
then 
    echo "#### [ERROR] ####: RDB1 failed to start"
else
    echo "#### [INFO] ####: RDB1 started on port $RDB1_PORT"
fi

echo ----------------------------
echo ------ Starting RDB2 -------
echo ----------------------------

~/q/l64/q $SCRIPTS_DIR/rdb.q :$TP_PORT :$HDB_PORT -p $RDB2_PORT -tab aggregation > /dev/null 2>&1 &
sleep 5
if [ -z "$(ps -ef | grep $RDB2_PORT | grep $SCRIPTS_DIR/rdb.q)" ];
then 
    echo "#### [ERROR] ####: RDB2 failed to start"
else
    echo "#### [INFO] ####: RDB2 started on port $RDB2_PORT"
fi