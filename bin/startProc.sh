#!/bin/bash

#Functions
#Invalid input check
invalid_input () {
echo "#### [ERROR] #### Invalid input '$PROC'" >&2
exit 1
}

#Script for user to select processes to start
clear
echo ---------------------------
echo ----- Start Process -------
echo ---------------------------
echo 'Tickerplant ---------- (1)'
echo 'Feedhandle  ---------- (2)'
echo 'RDB         ---------- (3)'
echo 'CEP         ---------- (4)'
echo 'HDB         ---------- (5)'
echo 'ALL         ---------- (6)'
echo 'Quit        ---------- (0)'
read -p "Enter selection [0-6]: " PROC

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
        ./startTP.sh 
        ;;
    2)
        ./startFeed.sh
        ;;
    3)
        ./startRDB.sh
        ;;
    4)
        ./startCEP.sh
        ;;
    5)
        ./startHDB.sh
        ;;
    6)
        ./startTP.sh
        ./startFeed.sh
        ./startRDB.sh
        ./startCEP.sh
        ./startHDB.sh
        echo "Finished starting all processes"
        ;;
esac
