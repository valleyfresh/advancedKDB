#!/usr/bin/python

# Pre-requisited: python3, pyq installed

# sample commands: 
# pyq pythonAPI.py trade.csv
# pyq pythonAPI.py quote.csv
# pyq pythonAPI.py trade.csv quote.csv

import os
import sys
import csv
import time
from pyq import K

########################################################################
# Function: headerLines
# Description: print header logging lines
########################################################################

def headerLines():
    print ("================================================================================================================")

########################################################################
# Function: bodyLines
# Description: print body logging lines
########################################################################

def bodyLines():
    print ("----------------------------------------------------------------------------------------------------------------")

########################################################################
# Function: info
# Description: print info log line
########################################################################

def info(x):
    print ("[INFO] {}".format(x))

########################################################################
# Function: error
# Description: print error log line
########################################################################

def error(x):
    print ("[ERROR] {}".format(x))

########################################################################
# Function: argCapture
# Description: print out arguments inputted to the script
########################################################################

def argCapture():
    global files
    files = sys.argv[1:]
    print ('Number of Files inputted:', len(files),'files.')
    print ('File List:'+ str(files))

########################################################################
# Function: csvFind
# Description: locate csv file directory
########################################################################

def csvFind():
    info ('Retrieving CSV directory env variable...')
    try:
        global csvDir
        csvDir = os.environ['CSV_DIR']
        print ('Located csv path: '+ csvDir)

    except NameError as error:
        error ('Unable to find TP env variable. '+ str(error))
        exit(1)

########################################################################
# Function: kdbConnect
# Description: establish connection to the KDB TP
########################################################################

def kdbConnect():
    info ('Retrieving kdb TP Port env variable...')
    try:
        port = os.environ['TP_PORT']
        print ('Tickerplant Port:', port)

    except NameError as error:
        error ('Unable to find TP env variable. ' + str(error))
        exit(1)

    # Establish a connection to the kdb TP process
    info ('Establishing connection to the TP process...')
    try: 
        global handle
        handle = q.hopen('::'+ port)
        print ('Opened a handle to the TP process: {}'.format(handle))
    except Exception as exception:
        error ('Unable to connect to the TP process ' + str(exception))
        exit(1)

########################################################################
# Function: convertTimeToLong
# Description: convert time value to a long value
########################################################################

def convertTimeToLong(timeValue):
    timeArray = time.strptime(timeValue,'%H:%M:%S.%f')
    # Sample output: time.struct_time(tm_year=1900, tm_mon=1, tm_mday=1, tm_hour=14, tm_min=53, tm_sec=10, tm_wday=0, tm_yday=1, tm_isdst=-1)
    # We need to multiply by 10^9 at the end as kdb timespan precision is up to the nano second
    return ((timeArray.tm_hour * 60 + timeArray.tm_min) * 60 + timeArray.tm_sec) * 10**9
    
########################################################################
# Function: csvReadandPublish
# Description: read in csv file(s) into python dataframe and publish to TP
########################################################################

def csvReadandPublish(dir,files):
    for i in files:
        path = dir + '/' + i
        info ('Reading in csv file from '+ path)

        with open(path) as csv_file:
            csv_reader = csv.reader(csv_file,delimiter=',')
            row_count = 0

            for row in csv_reader:
                if i == 'trade.csv':
                    if row_count > 0:
                        #print('Row values at index '+ str(row_count) + ':\n {} {} {} {}'.format(row[0],row[1],row[2],row[3]))
                        #print('Row type: \n {} \n {} \n {} \n {}'.format(type(row[0]),type(row[1]),type(row[2]),type(row[3])))
                        # CSV reader reads all values as str. Cast each value to the appropriate type
                        '''
                        Trade Table types
                        
                        time - timespan (.z.N) --> we will cast this to a long value which will be casted to timespan datatype on kdb
                        sym - symbol (no casting required) --> python str are automatically casted to kdb sym type
                        price - float
                        size - int
                        '''
                        row[0] = K.timespan(convertTimeToLong(row[0]))
                        row[2] = K.float(int(row[2]))
                        row[3] = K.int(int(row[3]))
                        
                        #Send the converted row values to the TP process through the handle
                        handle(('.u.upd','trade',(row[0],row[1],row[2],row[3])))
                    row_count += 1
                
                elif i == 'quote.csv':
                    if row_count > 0:
                        #print('Row values at index '+ str(row_count) + ':\n {} {} {} {}'.format(row[0],row[1],row[2],row[3]))
                        #print('Row type: \n {} \n {} \n {} \n {}'.format(type(row[0]),type(row[1]),type(row[2]),type(row[3])))
                        # CSV reader reads all values as str. Cast each value to the appropriate type
                        '''
                        Quote Table types
                        
                        time - timespan (.z.N) --> we will cast this to a long value which will be casted to timespan datatype on kdb
                        sym - symbol (no casting required) --> python str are automatically casted to kdb sym type
                        bid - float
                        ask - float
                        bsize - int
                        asize - int
                        '''
                        row[0] = K.timespan(convertTimeToLong(row[0]))
                        row[2] = K.float(int(row[2]))
                        row[3] = K.float(int(row[3]))
                        row[4] = K.int(int(row[4]))
                        row[5] = K.int(int(row[5]))

                        #Send the converted row values to the TP process through the handle
                        handle(('.u.upd','quote',(row[0],row[1],row[2],row[3],row[4],row[5])))
                    row_count += 1

########################################################
headerLines()
print ("Starting Python API Script")
headerLines()

bodyLines()
argCapture()
bodyLines()

bodyLines()
csvFind()
bodyLines()
########################################################

########################################################
headerLines()
print ("TASK 1: CONNECTING TO THE KDB TP PROCESS")
headerLines()

bodyLines()
kdbConnect()
bodyLines()
########################################################

########################################################
headerLines()
print ("TASK 2: READING AND PUBLISHING CSV FILES")
headerLines()

bodyLines()
csvReadandPublish(csvDir,files)
bodyLines()
########################################################

########################################################
bodyLines()
print ("SUCCESS!\nEXITING...")
bodyLines()
exit()
########################################################