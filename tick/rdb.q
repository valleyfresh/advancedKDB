/q tick/r.q [host]:port[:usr:pwd] [host]:port[:usr:pwd] -tab tab1 tab2
/ RDB 1 --> q tick/rdb.q :5000 :5012 -p 5001 -tab trade quote
/ RDB 2 --> q tick/rdb.q :5000 :5012 -p 5002 -tab aggregation

/2008.09.09 .k ->.q

system"l ",(getenv`SCRIPTS_DIR),"/u.q";

if[not "w"=first string .z.o;system "sleep 1"];

/ Create and open handle to log file
system"l ",(getenv`SCRIPTS_DIR),"/log.q";

.log.info["Running RDB Init"];

/ get the ticker plant and history ports, defaults are 5010,5012
.u.x:.z.x,(count .z.x)_(":5000";":5012");

/ retrieve list of tables to subscribe to
.u.tab:`$(.Q.opt .z.x)`tab;

/ update function
upd:{[t;x] if[t in .u.tab; t upsert x]};

/ end of day: save, clear, hdb reload
.u.end:{
    t:tables`.;
    t@:where `g=attr each t@\:`sym;
    .Q.hdpf[`$":",.u.x 1;
        `$":",getenv`HDB_LOG;x;`sym
    ];
    @[;`sym;`g#] each t;
 };

/ init schema and sync up from log file;cd to hdb(so client save can run)
.u.rep:{
    (set[;].)each x;
    if[null first y;:()];
    -11!y;system "cd ",getenv`HDB_LOG
 };
/ HARDCODE \cd if other than logdir/db

.log.info["Subscribing to TP and replaying tplog"];

/ connect to ticker plant for (schema;(logcount;log))
.u.rep .(h@/:(`.u.sub;;`)each .u.tab;(h:hopen `$":",.u.x 0)(`.u;`i`L))

