/q ibmTick.q -path $TP_LOG/<filename>

-1"###[INFO]### Starting TP file creation for IBM sym";

fileDetails:get hsym`$pathName:raze(.Q.opt .z.x)`path;
/get trade details from tplog for IBM
fileDetails@:where `trade=fileDetails[;1];
fileDetails@:where `IBM.N=fileDetails[;2;1];
/set new logFile down in tplog dir
set[hsym`$(getenv`TP_LOG),"/IBM",-10#pathName;fileDetails];

-1"###[INFO]### Completed TP file creation for IBM sym";