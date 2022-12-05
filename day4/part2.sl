include "bufio.sl";

var in = bfdopen(0, O_READ);

var a; var b; var c; var d;
var count = 0;
var got = malloc(101);
var i;
while (bscanf(in, "%d-%d,%d-%d", [&a,&b,&c,&d])) {
    memset(got, 0, 101);
    i = a;
    while (i <= b) {
        got[i] = 1;
        i++;
    };
    i = c;
    while (i <= d) {
        if (got[i]) {
            count++; break;
        };
        i++;
    };
};
printf("%d\n", [count]);
