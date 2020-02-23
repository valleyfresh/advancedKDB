/start log \l log.q

/start log script with .log namespace
\d .log

/init connection table
connect:flip `date`user`ipAddress`handle`startTime`endTime`duration!"ds*ittt"$\:();

/Dictionary of port to process for log file creation
filename:(5000;5012;5001;5002;5003)!("tick";"hdb";"rdb1";"rdb2";"cep");

/Open handle to corresponding log file
handle:hopen`$":",getenv[`LOG_DIR],"/",filename[system"p"],".log";

/Generalized log messages
info:{.log.handle(string .z.P)," #### [INFO] #### ",x,"\n"};
warn:{.log.handle(string .z.P)," #### [WARN] #### ",x,"\n"};
error:{.log.handle(string .z.P)," #### [ERROR] #### ",x,"\n"};
memStats:{.Q.s .Q.w[]};

\c 200 200

/action on connection open and close
.z.po:{`.log.connect upsert (.z.D;.z.u;"."sv string"h"$0x0 vs .z.a;x;.z.T;00:00:00.000;00:00:00.000);
    .log.handle .log.info["Connection opened by ",(raze string exec user from .log.connect where handle=x),"\n",.log.memStats[]]
 };
.z.pc:{update endTime:.z.T,duration:.z.T-startTime from `.log.connect where handle=x;
    .log.handle .log.info["Connection closed by ",(raze string exec user from .log.connect where handle=x),"\n",.log.memStats[]]
 };

