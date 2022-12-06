include "bufio.sl";

var in = bfdopen(0, O_READ);

var check = func(gr) {
    if (grlen(gr) < 4) return 0;
    var l = grlen(gr);
    var i = 0;
    var j;
    while (i < 3) {
        j = i+1;
        while (j < 4) {
            if (grget(gr, l-i-1) == grget(gr, l-j-1)) return 0;
            j++;
        };
        i++;
    };
    printf("%d\n", [l]);
    exit(0);
};

var chars = grnew();
var ch;
while (1) {
    ch = bgetc(in);
    if (ch == '\n') break;
    grpush(chars,ch);
    check(chars);
};
