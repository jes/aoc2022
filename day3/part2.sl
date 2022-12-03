include "bufio.sl";

var in = bfdopen(0, O_READ);
var line = malloc(128);

var pri = func(ch) {
    if (islower(ch)) return ch-'a'+1;
    return ch-'A'+27;
};

var len;
var i;
var got = zmalloc(53);
var sum = 0;
var idx = 0;
var count;
var ch;
while (bgets(in, line, 128)) {
    puts(line);
    len = strlen(line)-1;
    line[len] = 0;

    idx++;
    i = 0;
    while (i < len) {
        ch = pri(line[i]);
        if (got[ch] == idx-1) {
            #printf("count %c\n", [line[i]]);
            got[ch] = got[ch] + 1;
        };
        i++;
    };
    if (idx == 3) {
        idx = 0;
        i = 1;
        count = 0;
        while (i < 53) {
            if (got[i] == 3) {
                sum = sum + i;
                #if (i < 27) printf("letter %c\n", [i+'a'-1])
                #else printf("letter %c\n", [i+'A'-27]);
                count++;
            };
            i++;
        };
        assert(count==1, "count=%d", [count]);
        memset(got, 0, 53);
    };
};

printf("%d\n", [sum]);
