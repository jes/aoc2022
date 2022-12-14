include "bufio.sl";

var in = bfdopen(0, O_READ);
var line = zmalloc(128);

var stacks = malloc(10);
var i = 0;
while (i < 10)
    stacks[i++] = grnew();

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
while (i < 10)
    grrev(stacks[i++]);

var count; var from; var to;
var c;
while (bscanf(in, "move %d from %d to %d", [&count, &from, &to])) {
    c = count;
    while (c--)
        grpush(stacks[to], grget(stacks[from], grlen(stacks[from])-c-1));
    while (count--)
        grpop(stacks[from]);
};

i = 1;
while (i < 10) {
    putchar(grget(stacks[i], grlen(stacks[i])-1));
    i++;
};
putchar('\n');
