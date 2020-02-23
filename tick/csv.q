/q csv.q -tab quote/trade -path $CSV_DIR/filename -port $CSV_PORT

/Retrieve meta from sym file
system "l ",(getenv`SCRIPTS_DIR),"/sym.q";

/Determine table to write down to based on input    
tab:`$first(.Q.opt .z.x)`tab;

/Types to cast from meta
tabType:upper exec t from meta tab;

/Path to csv file based on input
fp:hsym`$first(.Q.opt .z.x)`path;

/Read in csv file based on meta
tabVal:1_flip(tabType;",")0:fp;

/open handle to TP
h:hopen "J"$getenv`TP_PORT;

/publish csv contents to the TP
{h(".u.upd";tab;x)}each (),tabVal;

hclose h;