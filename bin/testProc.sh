#!/bin/bash

#############
# Functions #
#############

# Invalid input check
invalid_input () {
echo "#### [ERROR] #### Invalid input '$PROC'" >&2
exit 1
}

# Check proceess
check_proc() {
	if [ -z "$(ps -ef | grep $1.q | grep $TICK_HOME)" ]; then 
		warn $1
	else
		success $1 
	fi
}

# Info log
info () {
echo "#### [INFO] #### Checking for $1 process"
}

success () {
echo "#### [INFO] #### $1 process is running"
}

# Warning log
warn () {
echo "#### [WARN] #### $1 process is not up" 
}

###########################################
# Script for user to check process status #
###########################################
clear
echo ----------------------------
echo ------ Test Process --------
echo ----------------------------
echo 'Tickerplant ---------- (1)'
echo 'Feedhandle  ---------- (2)'
echo 'RDB         ---------- (3)'
echo 'CEP         ---------- (4)'
echo 'HDB         ---------- (5)'
echo 'ALL         ---------- (6)'
echo 'Quit        ---------- (0)'
read -p "Enter selection [0-6]: " PROC

# Load env.config
source ~/advancedKDB/config/env.config

# input is not a number (invalid)
[[ ! "$PROC" =~ ^[0-6]$ ]] && invalid_input

# case to check corresponding process based on user input
case $PROC in
    0)
        echo 'Program terminated'
        exit
        ;;
    1)
        info tick
        check_proc tick
        ;;
    2)
        info feed
        check_proc feed
        ;;
    3)
        info rdb
        check_proc rdb
        ;;
    4)
        info cep
        check_proc cep
        ;;
    5)
        info hdb
        check_proc hdb
        ;;
    6)
        info all 
        procs=(tick feed rdb cep hdb)
        for procName in ${procs[@]};
        do
            info $procName
            check_proc $procName
        done
        ;;
esac