
//////////////////////////////////
/ HDB init 
//////////////////////////////////

/ Create and open handle to log file
system"l ",(getenv`SCRIPTS_DIR),"/log.q";

.log.info["Running HDB Init"];

/To start q tick/hdb.q -p 5012
system"l ",(getenv`SCRIPTS_DIR),"/u.q";

/cd into hdblog directory and load hdb
system"cd ",getenv`HDB_LOG;system"l .";

.log.info["Loaded HDBs"];

//////////////////////////////////
/ Websocket init 
//////////////////////////////////

.log.info["Running Websocket init"];

/Create websocket message handler
/Converts kdb+ output to JSON format
.z.ws:{neg[.z.w] .j.j @[{select from trade where sym=x};`$x;{`$ "'",x}]};

/Init websocket connection table
activeWSConnections: ([] handle:(); connectTime:());

/Add and remove connection detail when a new websocket connection is established or dropped

.z.wo:{`activeWSConnections upsert (x;.z.t)};

.z.wc:{delete from `activeWSConnections where handle = x};
