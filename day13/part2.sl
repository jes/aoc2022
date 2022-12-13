include "bufio.sl";

var in = bfdopen(0, O_READ);

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
            grpush(elems, readlist());
            ch = bgetc(in);
        } else if (isdigit(ch)) {
            n = ch-'0';
            ch = bgetc(in);
            if (isdigit(ch)) {
                n = 10;
                assert(ch == '0', "expected 0\n",0);
                ch = bgetc(in);
            };
            grpush(elems, n);
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
    var l = malloc(2);
    l[0] = x;
    l[1] = END;
    return l;
};

var typ = func(v) {
    if (v == END) return END;
    if (v lt 11) return NUMBER
    else return LIST;
};

var dumplist;
var listcmp = func(l1, l2) {
    if (l1 == l2) return 0;
    #printf("listcmp(", 0); dumplist(l1); putchar(','); dumplist(l2); puts(")\n");
    var type1; var type2;
    var val1; var val2;
    var r;
    var f;
    while (*l1 || *l2) {
        type1 = typ(*l1);
        type2 = typ(*l2);
        val1 = *(l1++);
        val2 = *(l2++);
        if (type1 == NUMBER && type2 == NUMBER) {
            r = val1-val2;
        } else if (type1 == LIST && type2 == LIST) {
            r = listcmp(val1, val2);
        } else if (type1 == NUMBER && type2 == LIST) {
            f = fakelist(val1);
            r = listcmp(f, val2);
            free(f);
        } else if (type1 == LIST && type2 == NUMBER) {
            f = fakelist(val2);
            r = listcmp(val1, f);
            free(f);
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

dumplist = func(l) {
    putchar('[');
    var type; var val;
    while (*l) {
        type = typ(*l);
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

var lists = grnew();

var divider1 = [[2,END],END];
var divider2 = [[6,END],END];
grpush(lists, divider1);
grpush(lists, divider2);

while (1) {
    assert(bgetc(in) == '[', "expected [\n", 0);
    list1 = readlist();
    assert(bgetc(in) == '\n', "expected newline\n", 0);
    assert(bgetc(in) == '[', "expected [\n", 0);
    list2 = readlist();
    assert(bgetc(in) == '\n', "expected newline\n", 0);

    grpush(lists, list1);
    grpush(lists, list2);

    if (bgetc(in) == EOF) break;
};

#grwalk(lists, func(l) {
#   dumplist(l); putchar('\n');
#});

grsort(lists, listcmp);

var i = 0;
var answer = 1;
while (i < grlen(lists)) {
    if (grget(lists,i) == divider1 || grget(lists,i) == divider2) {
        answer = mul(answer,i+1);
    };
    i++;
};

printf("%d\n", [answer]);
