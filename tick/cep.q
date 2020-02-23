/q tick/r.q [host]:port[:usr:pwd] [host]:port[:usr:pwd] -tab tab1 tab2
/ CEP --> q tick/cep.q :5000 :5012 -p 5003 -tab trade quote

/2008.09.09 .k ->.q

system"l ",(getenv`SCRIPTS_DIR),"/u.q";

system"l ",(getenv`SCRIPTS_DIR),"/log.q";

.log.info["Running CEP Init"];

if[not "w"=first string .z.o;system "sleep 1"];

/ get the ticker plant and history ports, defaults are 5010,5012
.u.x:.z.x,(count .z.x)_(":5000";":5012");
h:hopen `$":",.u.x 0;
/ retrieve list of tables to subscribe to
.u.tab:`$(.Q.opt .z.x)`tab;

/ update function
upd:{[t;x] if[t in .u.tab; t insert x];
   neg[h](`.u.upd;`aggregation;
    value flip 0!lj[select maxTradePrice:max price, minTradePrice:min price, tradeVol:sum size by sym from trade;
        select maxBid:max bid, minAsk:min ask by sym from quote])
 };

/ init schema and sync up from log file;cd to hdb(so client save can run)
.u.rep:{(set[;].)each x;if[null first y;:()];-11!y};

.log.info["Subscribing to TP and replaying tplog"];

/ connect to ticker plant for (schema;(logcount;log))
.u.rep .(h@/:(`.u.sub;;`)each .u.tab;h(`.u;`i`L));

