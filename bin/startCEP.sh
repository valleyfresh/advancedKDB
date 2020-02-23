#!/bin/bash

#Script to start CEP process

#Load env.config
source ~/advancedKDB/config/env.config

echo ----------------------------
echo ------- Starting CEP--------
echo ----------------------------

cd $SCRIPTS_DIR

~/q/l64/q $SCRIPTS_DIR/cep.q :$TP_PORT :$HDB_PORT -p $CEP_PORT -tab trade quote > /dev/null 2>&1 &
sleep 3
if [ -z "$(ps -ef | grep $CEP_PORT | grep $SCRIPTS_HOME/cep.q)" ];
then 
    echo "#### [ERROR] ####: CEP failed to start"
else
    echo "#### [INFO] ####: CEP started on port $CEP_PORT"
fi