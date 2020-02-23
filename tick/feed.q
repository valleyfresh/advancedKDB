h:hopen 5000; /connect to tickerplant 
syms:`AAPL`WMT`GOOGL`MSFT`BRK.A`IBM.N; /stocks
prices:syms!45.15 191.10 178.50 128.04 341.30 123.40; /starting prices 
n:1; /number of rows per update
flag:1; /generate 10% of updates for trade and 90% for quote
getmovement:{[s] rand[0.0001]*prices[s]}; /get a random price movement 
/generate trade price
getprice:{[s] prices[s]+:rand[1 -1]*getmovement[s]; prices[s]}; 
getbid:{[s] prices[s]-getmovement[s]}; /generate bid price
getask:{[s] prices[s]+getmovement[s]}; /generate ask price

/timer function
.z.ts:{
  s:first n?syms;
  $[0<flag mod 10;
    h(`.u.upd;`quote;(.z.N;s;getbid[s];getask[s];first n?1000;first n?1000)); 
    h(`.u.upd;`trade;(.z.N;s;getprice[s];first n?1000))
  ];
  flag+:1
 };

/trigger timer every 100ms
\t 100
