#!/bin/bash

#############
# Functions #
#############

# Invalid input check
invalid_input () {
echo "#### [ERROR] #### Invalid input '$PROC'" >&2
exit 1
}

# Function to shutdown process
stop_proc () {
echo "$(ps -ef | grep $1.q | grep $TICK_HOME | awk '{print $2}' | xargs kill)"
}

# Check proceess
check_proc() {
	if [ ! -z "$(ps -ef | grep $1.q | grep $TICK_HOME)" ]; then 
		warn $1
	else
		success $1
	fi
}

# Info log
info () {
echo "#### [INFO] #### Shutting down $1 processes"
}

success () {
echo "#### [INFO] #### Successfully shutdown $1 processes"
}

# Warning log
warn () {
echo "#### [WARN] #### Failed to shut down $1 processes"
}

###############################################
# Script for user to select processes to stop #
###############################################
clear
echo ----------------------------
echo ---- Shutdown Process ------
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

# input is empty (invalid)
#[[ -z $PROC ]] && invalid_input

# input is multiple items (invalid)
#(( $(echo $PROC | wc -w) > 1 )) && invalid_input

# input is not a number (invalid)
[[ ! "$PROC" =~ ^[0-6]$ ]] && invalid_input

# case to start corresponding process based on user input
case $PROC in
    0)
        echo 'Program terminated'
        exit
        ;;
    1)
		info TICKERPLANT
		stop_proc tick
		sleep 3
		check_proc tick
		;;
    2)  
		info FEED
		stop_proc feed
		sleep 3
		check_proc feed
		;;
    3)  
		info RDB
		stop_proc rdb
		sleep 3
		check_proc rdb
		;;
    4)  
		info CEP
		stop_proc cep
		sleep 3
		check_proc cep
		;;
    5)
		info HDB
		stop_proc hdb
		sleep 3
		check_proc hdb
		;;
    6)
		info All
		procs=(tick feed rdb cep hdb)
		for procName in ${procs[@]};
		do
			info $procName
			echo ""
			stop_proc $procName
			sleep 3
			check_proc $procName
		done
		;;
esac
