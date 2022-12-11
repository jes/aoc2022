include "bufio.sl";
include "bigint.sl";

var Mlevels = malloc(8);
var Mop = malloc(8);
var Mdivisor = malloc(8);
var Mtrue = malloc(8);
var Mfalse = malloc(8);
var Minspections = zmalloc(8);
var nmonkeys;

var args = cmdargs()+1;
var runsample = 0;
if (*args && strcmp(args[0], "--sample") == 0) {
    runsample = 1;
};

var monkey = func(id, startinglevels, op, divisor, true, false) {
    Mlevels[id] = grnew();
    var i = 0;
    while (startinglevels[i]) {
        grpush(Mlevels[id], bignew(startinglevels[i]));
        i++;
    };
    Mop[id] = op;
    Mdivisor[id] = divisor;
    Mtrue[id] = true;
    Mfalse[id] = false;
};

if (runsample) {
    printf("Sample input!\n", 0);
    nmonkeys = 4;
    monkey(0, [79,98], func(x) { bigmulw(x,19) }, 23, 2, 3);
    monkey(1, [54,65,75,74], func(x) { bigaddw(x,6) }, 19, 2, 0);
    monkey(2, [79,60,97], func(x) { bigmul(x,x) }, 13, 1, 3);
    monkey(3, [74], func(x) { bigaddw(x,3) }, 17, 0, 1);
} else {
    printf("Real input!\n", 0);
    nmonkeys = 8;
    monkey(0, [76,88,96,97,58,61,67], func(x) { bigmulw(x,19) }, 3, 2, 3);
    monkey(1, [93,71,79,83,69,70,94,98], func(x) { bigaddw(x,8) }, 11, 5, 6);
    monkey(2, [50,74,67,92,61,76], func(x) { bigmulw(x,13) }, 19, 3, 1);
    monkey(3, [76,92], func(x) { bigaddw(x,6) }, 5, 1, 6);
    monkey(4, [74,94,55,87,62], func(x) { bigaddw(x,5) }, 2, 2, 0);
    monkey(5, [59,62,53,62], func(x) { bigmul(x,x) }, 7, 4, 7);
    monkey(6, [62], func(x) { bigaddw(x,2) }, 17, 5, 7);
    monkey(7, [85,54,53], func(x) { bigaddw(x,3) }, 13, 4, 0);
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

var tmp = bignew(0);

runmonkey = func(m) {
    var i = 0;
    var old; var f;
    while (i < grlen(Mlevels[m])) {
        Minspections[m] = Minspections[m] + 1;
        old = grget(Mlevels[m], i);
        #printf("Monkey %d inspects item with level %b\n", [m, old]);
        f = Mop[m];
        f(old);
        #printf("   transforms item to level %b (", [old]);
        bigdivw(old, 3);
        #printf("%b)\n", [old]);
        bigset(tmp, old);
        bigmodw(tmp, Mdivisor[m]);
        if (bigcmpw(tmp,0) == 0) pass(old, Mtrue[m])
        else pass(old, Mfalse[m]);
        i++;
    };
    grfree(Mlevels[m]); Mlevels[m] = grnew();
};

var i = 0;
while (i < 20) {
    printf("round %d...\n", [i]);
    round();
    i++;
};

# pick 2 most-inspected monkeys & mutliply the 2 inspection counts together
sort(Minspections, nmonkeys, func(a,b) {
    return b-a;
});
printf("%d * %d\n", [Minspections[0], Minspections[1]]);
