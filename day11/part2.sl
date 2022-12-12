include "bufio.sl";

var numrounds = 20;

var Mlevels = malloc(8);
var Mop = malloc(8);
var Mdivisor = malloc(8);
var Mtrue = malloc(8);
var Mfalse = malloc(8);
var Minspections = zmalloc(8);
var Minspections30k = zmalloc(8);
var nmonkeys;

var args = cmdargs()+1;
var runsample = 0;
# usage: part2 [--sample] [NUMROUNDS]
while (*args) {
    if (strcmp(args[0], "--sample") == 0) {
        runsample = 1;
    } else if (isdigit(args[0][0])) {
        numrounds = atoi(*args);
    } else {
        fprintf(2, "usage: part2 [--sample] [NUMROUNDS]\n", 0);
    };
    args++;
};

var monkey = func(id, startinglevels, op, divisor, true, false) {
    Mlevels[id] = grnew();
    var i = 0;
    while (startinglevels[i]) {
        grpush(Mlevels[id], startinglevels[i]);
        i++;
    };
    Mop[id] = op;
    Mdivisor[id] = divisor;
    Mtrue[id] = true;
    Mfalse[id] = false;
};

var monkeymul = func(m, x) {
    var i = 0;
    while (i < nmonkeys) {
        m[i] = mod(mul(m[i],x), Mdivisor[i]);
        i++;
    };
};

var monkeyadd = func(m, x) {
    var i = 0;
    while (i < nmonkeys) {
        m[i] = mod(m[i]+x, Mdivisor[i]);
        i++;
    };
};

var monkeysqr = func(m) {
    var i = 0;
    while (i < nmonkeys) {
        m[i] = mod(mul(m[i],m[i]), Mdivisor[i]);
        i++;
    };
};

if (runsample) {
    printf("Sample input!\n", 0);
    nmonkeys = 4;
    monkey(0, [79,98], func(x) { monkeymul(x,19) }, 23, 2, 3);
    monkey(1, [54,65,75,74], func(x) { monkeyadd(x,6) }, 19, 2, 0);
    monkey(2, [79,60,97], func(x) { monkeysqr(x) }, 13, 1, 3);
    monkey(3, [74], func(x) { monkeyadd(x,3) }, 17, 0, 1);
} else {
    printf("Real input!\n", 0);
    nmonkeys = 8;
    monkey(0, [76,88,96,97,58,61,67], func(x) { monkeymul(x,19) }, 3, 2, 3);
    monkey(1, [93,71,79,83,69,70,94,98], func(x) { monkeyadd(x,8) }, 11, 5, 6);
    monkey(2, [50,74,67,92,61,76], func(x) { monkeymul(x,13) }, 19, 3, 1);
    monkey(3, [76,92], func(x) { monkeyadd(x,6) }, 5, 1, 6);
    monkey(4, [74,94,55,87,62], func(x) { monkeyadd(x,5) }, 2, 2, 0);
    monkey(5, [59,62,53,62], func(x) { monkeysqr(x) }, 7, 4, 7);
    monkey(6, [62], func(x) { monkeyadd(x,2) }, 17, 5, 7);
    monkey(7, [85,54,53], func(x) { monkeyadd(x,3) }, 13, 4, 0);
};

var newmonkeyint = func(x) {
    var p = malloc(nmonkeys);
    var i = 0;
    while (i < nmonkeys) {
        p[i] = mod(x, Mdivisor[i]);
        i++;
    };
    return p;
};

var i = 0;
var j;
while (i < nmonkeys) {
    j = 0;
    while (j < grlen(Mlevels[i])) {
        grset(Mlevels[i], j, newmonkeyint(grget(Mlevels[i], j)));
        j++;
    };
    i++;
};

var runmonkey;
var round = func() {
    var i = 0;
    while (i < nmonkeys) runmonkey(i++);
};

var pass = func(level, m) {
    #printf("   passes %b to monkey %d\n", [level, m]);
    grpush(Mlevels[m], level);
};

runmonkey = func(m) {
    var i = 0;
    var num; var f;
    while (i < grlen(Mlevels[m])) {
        Minspections[m] = Minspections[m] + 1;
        if (Minspections[m] == 30000) {
            Minspections[m] = 0;
            Minspections30k[m] = Minspections30k[m] + 1;
        };
        num = grget(Mlevels[m], i);
        f = Mop[m];
        f(num);
        if (num[m] == 0) pass(num, Mtrue[m])
        else pass(num, Mfalse[m]);
        i++;
    };
    grfree(Mlevels[m]); Mlevels[m] = grnew();
};

i = 0;
while (i < numrounds) {
    printf("round %d/%d...\n", [i, numrounds]);
    round();
    i++;
};

i = 0;
var biginspections = grnew();
var b;
while (i < nmonkeys) {
    b = bignew(Minspections30k[i]);
    bigmulw(b, 30000);
    bigaddw(b, Minspections[i]);
    grpush(biginspections, b);
    i++;
};

grsort(biginspections, func (a,b) return bigcmp(b,a));

b = bigclone(grget(biginspections,0));
bigmul(b, grget(biginspections,1));

printf("%b * %b = %b\n", [grget(biginspections,0), grget(biginspections,1), b]);
