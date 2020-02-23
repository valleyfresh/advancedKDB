/ q tick.q sym . -p 5000 </dev/null >foo 2>&1 &
/2014.03.12 remove license check
/2013.09.05 warn on corrupt log
/2013.08.14 allow <endofday> when -u is set
/2012.11.09 use timestamp type rather than time. -19h/"t"/.z.Z -> -16h/"n"/.z.P
/2011.02.10 i->i,j to avoid duplicate data if subscription whilst data in buffer
/2009.07.30 ts day (and "d"$a instead of floor a)
/2008.09.09 .k -> .q, 2.4
/2008.02.03 tick/r.k allow no log
/2007.09.03 check one day flip
/2006.10.18 check type?
/2006.07.24 pub then log
/2006.02.09 fisx(2005.11.28) .z.ts end-of-day
/2006.01.05 @[;`sym;`g#] in tick.k load
/2005.12.21 tick/r.k reset `g#sym
/2005.12.11 feed can send .u.endofday
/2005.11.28 zero-end-of-day
/2005.10.28 allow`time on incoming
/2005.10.10 zero latency
"kdb+tick 2.8 2014.03.12"

/q tick.q SRC [DST] [-p 5010] [-o h]
/Load table schema from tick directory ~/tick/sym.q
system"l ",(getenv`SCRIPTS_DIR),"/",(first .z.x,enlist"sym"),".q";

/Set port to 5000 if no ports was assigned on startup
if[not system"p";system"p 5000"];

/Load u.q and log.q
system each"l ",/:(getenv`SCRIPTS_DIR),/:("/u.q";"/log.q");

\d .log
/Additional logging for tickerplant
time:.z.T;
/Log every minute 
/1) Number of messages processed by the table
/2) Subscription details of subcribers
tickSummary:if[60000<.z.T-time;
 (handle info@)each("Log File Message Count: ",(string .u.i),"\n";"Subscription Details: \n",.Q.s .u.w)
 ];

\d .u

/Called in .u.tick (ld d), .u.endofday 0(`.u.ld;d)
/takes in 1 arg [date] 
ld:{
    if[not type key L::`$(-10_string L),string x;
        .[L;();:;()]
    ];
    /Assign message count in tp log file to .u.i and .u.j
    i::j::-11!(-2;L);
    /Check if tp log file is corrupted and exit if it is
    if[0<=type i;
        -2 (string L)," is a corrupt log. Truncate to length ",(string last i)," and restart";exit 1
    ];
    /Open handle to tp logfile
    hopen L
 };

/.u.tick takes in 1 arg ["<TP log dir>"] Creates tplog file in <tplog dir>/local date
tick:{
    /.u.init - Define .u.t (table names) and .u.w (dictionary of tables)
    init[];
    /Error out if `time and `sym are not the first columns of the tables
    if[not min(`time`sym~2#key flip value@)each t;
        '`timesym
    ];
    /Apply grouped attribute to the sym column of each table
    @[;`sym;`g#]each t;
    /Define .u.d as the local date
    d::.z.D;
    /Define .u.L as `:<tplog dir>/.......... (.... will be replaced with date in .u.ld)
    /Define .u.l as handle to tplog file (last line of .u.ld is hopen .u.L)
    if[l::count x;
        L::`$":",x,"/",10#".";
        l::ld d
    ]
 };

endofday:{
    /Send async call to all processes to run .u.end[date]
    end d;
    /Set .u.d to next day
    d+:1;
    /Close the handle to the previous day tplog and create a new handle to the current day tplog
    if[l;hclose l;l::0(`.u.ld;d)]
 };

/Runs on a timer on .z.ts
ts:{
    /Check if .u.d is smaller than local date (.z.D) and run endofday if it is
    if[d<x;
        /If .u.d is less to local date-1 (i.e more than 1 day diff), set timer tick to 0 and error out
        if[d<x-1;
            system"t 0";
            '"more than one day?"
        ];
        endofday[]
    ]
 };

/Batching mode (timer tick is defined)
if[system"t";
    .z.ts:{
        .log.tickSummary;
        /Publish results for each table on the tickerplant
        pub'[t;value each t];
        /Apply grouped attribute to the sym column and flush out tickerplant tables
        @[`.;t;@[;`sym;`g#]0#];
        /Set .u.i to be .u.j since the results held in buffer have been published
        i::j;
        /Check for endofday
        ts .z.D
    };
    upd:{[t;x]
        /Check if timespan is the first value of the update. Add timespan as the first value if it is not present
        if[not -16=type first first x;
            if[d<"d"$a:.z.P;
                /Flush out buffer if .u.d is less than local date
                .z.ts[]
            ];
            a:"n"$a;
            x:$[0>type first x;
                a,x;
                (enlist(count first x)#a),x
            ]
        ];
    /Insert results into tick tables (will be flushed out each batch)
    t insert x;
    /Write upd to log file and increase .u.j by 1
    if[l;l enlist (`upd;t;x);j+:1];
    }
 ];

/Zero-latency mode
if[not system"t";system"t 1000";
 /Update tick summary every second and check for endofday
 .z.ts:{.log.tickSummary};
 /Define .u.upd
 upd:{[t;x]
    /Check for endofday
    ts"d"$a:.z.P;
    /Check if timespan is the first value of the update. Add timespan as the first value if it is not present
    if[not -16=type first first x;
        a:"n"$a;
        x:$[0>type first x;
            a,x;
            (enlist(count first x)#a),x
        ]
    ];
    /Assign col name of table as f
    f:key flip value t;
    /Publish values to the subscribed tables
    pub[t;
        /Create table based on list type to publish
        $[0>type first x;
            enlist f!x;
            flip f!x
        ]
    ];
    /Write upd to log file and increase .u.i by 1
    if[l;l enlist (`upd;t;x);i+:1];}
 ];

\d .
.u.tick[getenv`TP_LOG];



\
 globals used
 .u.w - dictionary of tables->(handle;syms)
 .u.i - msg count in log file
 .u.j - total msg count (log file plus those held in buffer)
 .u.t - table names
 .u.L - tp log filename, e.g. `:./sym2008.09.11
 .u.l - handle to tp log file
 .u.d - date

/test
>q tick.q
>q tick/ssl.q

/run
>q tick.q sym  .  -p 5010	/tick
>q tick/r.q :5010 -p 5011	/rdb
>q sym            -p 5012	/hdb
>q tick/ssl.q sym :5010		/feed
