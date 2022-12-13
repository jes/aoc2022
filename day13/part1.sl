include "bufio.sl";

var in = bfdopen(0, O_READ);
var line = malloc(256);

var END = 0;
var LIST = 1;
var NUMBER = 2;

var list1; var list2;
var idx = 1;
var sum = 0;

var readlist = func() {
    var ch;
    var elems = grnew();
    var n;
    
    while (1) {
        ch = bgetc(in);
        if (ch == '\n') assert(0, "unexpected end of line\n", 0)
        else if (ch == '[') {
            grpush(elems, LIST); grpush(elems, readlist());
            ch = bgetc(in);
        } else if (isdigit(ch)) {
            n = ch-'0';
            ch = bgetc(in);
            if (isdigit(ch)) {
                n = 10;
                assert(ch == '0', "expected 0\n",0);
                ch = bgetc(in);
            };
            grpush(elems, NUMBER); grpush(elems, n);
        } else if (ch == ']') {
            break;
        } else {
            assert(0, "unexpected ch: %c\n", [ch]);
        };

        if (ch == ']') break;
        assert(ch == ',', "expected ,\n", 0);
    };
    grpush(elems, END);
    var elems2 = malloc(grlen(elems));
    memcpy(elems2, grbase(elems), grlen(elems));
    grfree(elems);
    return elems2;
};

var fakelist = func(x) {
    var l = malloc(3);
    l[0] = NUMBER;
    l[1] = x;
    l[2] = END;
    return l;
};

var listcmp = func(l1, l2) {
    var type1; var type2;
    var val1; var val2;
    var r;
    while (*l1 || *l2) {
        type1 = *(l1++);
        type2 = *(l2++);
        val1 = *(l1++);
        val2 = *(l2++);
        if (type1 == NUMBER && type2 == NUMBER) {
            r = val1-val2;
        } else if (type1 == LIST && type2 == LIST) {
            r = listcmp(val1, val2);
        } else if (type1 == NUMBER && type2 == LIST) {
            r = listcmp(fakelist(val1), val2);
        } else if (type1 == LIST && type2 == NUMBER) {
            r = listcmp(val1, fakelist(val2));
        } else if (type1 == END) {
            return -1;
        } else if (type2 == END) {
            return 1;
        } else {
            assert(0, "unrecognised types: [%d,%d]\n", [type1,type2]);
        };
        if (r) return r;
    };
    return 0;
};

var dumplist = func(l) {
    putchar('[');
    var type; var val;
    while (*l) {
        type = *(l++);
        val = *(l++);
        if (type == NUMBER) {
            printf("%d", [val]);
        } else {
            dumplist(val);
        };
        if (*l) putchar(',');
    };
    putchar(']');
};

var listfree = func(l) {
    var p = l;
    var type; var val;
    while (*p) {
        type = *(p++);
        val = *(p++);
        if (type == LIST) listfree(val);
    };
    free(l);
};

while (1) {
    assert(bgetc(in) == '[', "expected [\n", 0);
    list1 = readlist();
    assert(bgetc(in) == '\n', "expected newline\n", 0);
    assert(bgetc(in) == '[', "expected [\n", 0);
    list2 = readlist();
    assert(bgetc(in) == '\n', "expected newline\n", 0);
    #printf("comparing:\n", 0); dumplist(list1); putchar('\n'); dumplist(list2); putchar('\n');
    if (listcmp(list1, list2) < 0) sum = sum + idx;
    listfree(list1); listfree(list2);
    #printf("sum=%d\n\n", [sum]);
    idx++;
    if (bgetc(in) == EOF) break;
};

printf("%d\n", [sum]);
