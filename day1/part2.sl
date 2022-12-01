include "bufio.sl";
include "grarr.sl";
include "bigint.sl";

var in = bfdopen(0, O_READ);
var line = malloc(128);

var n;
var sum = bignew(0);
var answer = bignew(0);
var sums = grnew();
while (bgets(in, line, 128)) {
    if (line[0] == '\n') {
        grpush(sums, bigclone(sum));
        bigsetw(sum, 0);
    } else {
        if (strlen(line) == 6) {
            if (line[0] > '5') {
                bigaddw(sum, 25000);
                bigaddw(sum, 25000);
                line[0] = line[0] - 5;
            };
        };
        n = atoi(line);
        if (n gt 32767) {
            bigaddw(sum, 32767);
            n = n - 32767;
        };
        bigaddw(sum, n);
    };
};
grpush(sums, bigclone(sum));

grsort(sums, bigcmp);

var l = grlen(sums);
bigadd(answer, grget(sums, l-1));
bigadd(answer, grget(sums, l-2));
bigadd(answer, grget(sums, l-3));

printf("%b\n", [answer]);
