include "bufio.sl";
include "bigint.sl";

var in = bfdopen(0, O_READ);
var line = malloc(128);

var cycles = 0;
var X = 1;
var cyclecounter = 20;
var answer = bignew(0);
var tmp = bignew(0);

var cycle = func() {
    cycles++;
    cyclecounter--;
    if (cyclecounter == 0) {
        printf("after %d cycles, X=%d\n", [cycles, X]);
        bigsetw(tmp, cycles);
        bigmulw(tmp, X);
        bigadd(answer, tmp);
        printf("answer=%b\n", [answer]);
        if (cycles == 220) exit(0);
        cyclecounter = 40;
    };
};

while (bgets(in, line, 128)) {
    if (line[0] == 'a') { # addx V
        cycle(); cycle();
        X = X + atoi(line+5);
    } else {
        cycle();
    };
};
