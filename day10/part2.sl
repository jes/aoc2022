include "bufio.sl";

var in = bfdopen(0, O_READ);
var line = malloc(128);

var cycles = 0;
var X = 1;
var cyclecounter = 1;

var abs = func(x) {
    if (x < 0) return -x
    else return x;
};

var cycle = func() {
    # if abs(X-cycles)<=1: draw a #
    # else: draw a space

    if (abs(X-cycles)<=1) putchar('#')
    else putchar(' ');

    cycles++;
    if (cycles == 40) {
        cycles = 0;
        putchar('\n');
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
