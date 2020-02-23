/ Create and open handle to log file
system"l ",(getenv`SCRIPTS_DIR),"/log.q";

.log.info["Running HDB Init"];

/To start q tick/hdb.q -p 5012
system"l ",(getenv`SCRIPTS_DIR),"/u.q";

/cd into hdblog directory and load hdb
system"cd ",getenv`HDB_LOG;system"l ."
.log.info["Loaded HDBs"];