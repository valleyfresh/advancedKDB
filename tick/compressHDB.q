/q compressHDB.q -date <tp log date>

/Write a script which will take the Ticker Plant log and 
/create a daily partitioned HDB in which all columns are compressed with the exception of sym and time.

/Init table schemas
/Load table schema from tick directory ~/tick/sym.q
system"l ",(getenv`SCRIPTS_DIR),"/sym.q";

/Define compression ratio
.z.zd:17 2 6;

/Retrieve compression date defined for the script
cdate:first(.Q.opt .z.x)`date;

/Define upd function
upd:{[t;x] if[any t in `trade`quote;t upsert x]};

/Replay log file to populate the tables
-11!hsym`$(getenv`TP_LOG),"/",cdate;

/Write down tables to the new compressed hdb directory
.Q.dpft[hsym`$(getenv`CHDB_DIR);"D"$cdate;`sym;]each `trade`quote;

/All columns are compressed except sym and time
/cd into new compressed hdb partion
system"cd ",(getenv`CHDB_DIR),"/",cdate;
/Get all column paths for compression e.g `:quote/asize and set them down compressed
{x set x}each ` sv'raze(`:quote;`:trade),/:'2_'cols each tables[]except `aggregation;
