include "bufio.sl";
include "grarr.sl";
include "bigint.sl";

var in = bfdopen(0, O_READ);
var line = malloc(128);

var sum = bignew(0);
var answer = bignew(0);
while (bgets(in, line, 128)) {
    if (line[0] == '\n') {
        if (bigcmp(sum, answer) > 0) bigset(answer, sum);
        bigsetw(sum, 0);
    } else {
        bigaddw(sum, atoi(line));
    };
};

printf("%b\n", [answer]);
