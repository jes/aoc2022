include "bufio.sl";

var in = bfdopen(0, O_READ);
var line = malloc(128);

var a; var b; var c; var d;
var count = 0;
while (bscanf(in, "%d-%d,%d-%d", [&a,&b,&c,&d])) {
    if (a <= c && b >= d) count++ # does a-b contain c-d?
    else if (c <= a && d >= b) count++ # does c-d contain a-b?
    else if (a <= c && b >= c) count++ # does a-b span c?
    else if (a <= d && b >= d) count++ # does a-b span d?
    else if (c <= a && d >= a) count++ # does c-d span a?
    else if (c <= b && d >= b) count++ # does c-d span b?
    ;
};
printf("%d\n", [count]);
