include "bufio.sl";

var in = bfdopen(0, O_READ);
var line = zmalloc(128);

var stacks = malloc(10);
var i = 0;
while (i < 10) {
    stacks[i] = grnew();
    i++;
};

var idx;

while (bgets(in, line, 128)) {
    if (line[1] == '1') {
        bgets(in, line, 128);
        break;
    };

    i = 1;
    idx = 1;
    while (i < 10) {
        if (isupper(line[idx])) grpush(stacks[i], line[idx]);
        i++;
        idx = idx+4;
    };
    
    memset(line, 0, 128);
};

i = 1;
while (i < 10) {
    grrev(stacks[i]);
    printf("%d: ", [i]);
    grwalk(stacks[i], putchar);
    putchar('\n');
    i++;
};

var dumpstacks = func() {
    var i = 1;
    while (i < 10) {
        printf("%d: ", [i]);
        grwalk(stacks[i], putchar);
        putchar('\n');
        i++;
    };
};

var count; var from; var to;
while (bscanf(in, "move %d from %d to %d", [&count, &from, &to])) {
    #printf("move %d from %d to %d:\n", [count,from,to]);
    while (count--) {
        grpush(stacks[to], grpop(stacks[from]));
    };
    #dumpstacks();
};

i = 1;
while (i < 10) {
    putchar(grget(stacks[i], grlen(stacks[i])-1));
    i++;
};
putchar('\n');
