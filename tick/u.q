/2019.06.17 ensure sym has g attr for schema returned to new subscriber
/2008.09.09 .k -> .q
/2006.05.08 add

\d .u

/Create .u.w and .u.t
init:{w::t!(count t::tables`.)#()}

/Delete subscriber handle from .u.w
/2 arg [table;handle]
del:{w[x]_:w[x;;0]?y};

/Remove subscriber details from .u.w when connection is closed to the tp
.z.pc:{del[;x]each t};

/Select function
/2 arg [table;list of syms]
sel:{$[`~y;x;select from x where sym in y]}

/Publish function
pub:{[t;x]
    {[t;x;w]
        /Check count of records for specified sym in table
        /Publish to subcriber if there are records
        if[count x:sel[x]w 1;
            (neg first w)(`upd;t;x)]
    }[t;x]each w t
 }

/Add subcriber to .u.w (handle;syms)
/2 args (handle;syms)
add:{
    /Check if subcriber's handle is in .u.w for the table
    $[(count w x)>i:w[x;;0]?.z.w;
        /If handle is already in .u.w for the table, update subscribed syms
        .[`.u.w;(x;i;1);union;y];
        /Else add (handle,syms) to the list
        w[x],:enlist(.z.w;y)
    ];
    (x;
        $[99=type v:value x;
            sel[v]y;
            @[0#v;`sym;`g#]
        ]
    )
 }

sub:{
    /If table not define, subscribe to the sym for all tables
    if[x~`;:sub[;y]each t];
    /If table not found, error out
    if[not x in t;'x];
    /Delete handle from table if it is present
    del[x].z.w;
    /Add handle to the table with subscription details
    add[x;y]
 }

/Retrieve distinct handles from .u.w and apply an async call to run .u.end[date] on the processes
end:{(neg union/[w[;;0]])@\:(`.u.end;x)}
