include "bufio.sl";

var in = bfdopen(0, O_READ);
var line = malloc(128);

var a; var b; var c; var d;
var count = 0;
while (bscanf(in, "%d-%d,%d-%d", [&a,&b,&c,&d])) {
    # does a-b contain c-d?
    if (a <= c && b >= d) count++
    else if (c <= a && d >= b) count++;# does c-d contain a-b?
};
printf("%d\n", [count]);
