include "bufio.sl";

var in = bfdopen(0, O_READ);
var line = malloc(128);

var pri = func(ch) {
    if (islower(ch)) return ch-'a'+1;
    return ch-'A'+27;
};

var len;
var i;
var got = malloc(53);
var sum = 0;
while (bgets(in, line, 128)) {
    len = strlen(line)-1;
    line[len] = 0;

    memset(got, 0, 53);

    i = 0;
    while (i+i < len) {
        got[pri(line[i])] = 1;
        i++;
    };
    while (i < len) {
        if (got[pri(line[i])]) {
            sum = sum + pri(line[i]);
            break;
        };
        i++;
    };
};

printf("%d\n", [sum]);
