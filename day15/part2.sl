include "bufio.sl";

biginit(2);

var in = bfdopen(0, O_READ);
var line = malloc(256);

var skipover = func(s, ch) {
    while (*s) {
        if (*s == ch) return s+1;
        s++;
    };
    return 0;
};

var SX = 0;
var SY = 1;
var BX = 2;
var BY = 3;
var RANGE = 4;

var makesensor = func(sx,sy,bx,by) {
    var s = malloc(5);
    s[SX] = sx;
    s[SY] = sy;
    s[BX] = bx;
    s[BY] = by;
    s[RANGE] = bignew(0);
    return s;
};

var sensors = grnew();

var p;
var sensorx; var sensory;
var beaconx; var beacony;
while (bgets(in, line, 256)) {
    p = line;
    p = skipover(p, '=');
    sensorx = bigatoi(p);
    p = skipover(p, '=');
    sensory = bigatoi(p);
    p = skipover(p, '=');
    beaconx = bigatoi(p);
    p = skipover(p, '=');
    beacony = bigatoi(p);
    grpush(sensors, makesensor(sensorx,sensory, beaconx,beacony));
};

var bigabstmp = bignew(0);
var bigabs = func(b) {
    if (bigcmpw(b,0) < 0) {
        bigsetw(bigabstmp, 0);
        bigsub(bigabstmp, b);
        bigset(b, bigabstmp);
    };
};

var dx = bignew(0); var dy = bignew(0);
var s;

#var rangebound = bignew(20);
#printf("Remember to change examiney,rangebound!\n", 0);

var rangebound = bigatoi("4000000");

var cansee = func(s,x,y) {
    # 1. what is the distance to x,y ?
    bigset(dx, s[SX]); bigsub(dx, x); bigabs(dx);
    bigset(dy, s[SY]); bigsub(dy, y); bigabs(dy);
    bigadd(dx,dy);

    # 2. is this distance <= the viewing range of s?
    #printf("dx=%b, srange=%b\n", [dx, s[RANGE]]);
    return bigcmp(dx,s[RANGE]) <= 0;
};

var dyexamine = bignew(0);
var i = 0;
while (i < grlen(sensors)) {
    s = grget(sensors, i);
    bigset(dx, s[SX]); bigsub(dx, s[BX]); bigabs(dx);
    bigset(dy, s[SY]); bigsub(dy, s[BY]); bigabs(dy);
    bigadd(dx,dy);
    bigset(s[RANGE], dx);
    i++;
};

var dist = bignew(0);
var plus = bignew(1);
var test = func(x,y,nots) {
    if (bigcmpw(y, 0) < 0) {
        bigsetw(dist, 0); bigsub(dist, y); bigsubw(dist, 1);
        bigsetw(y, -1); bigadd(x, dist);
        #printf("jump into bounds: (%b,%b)\n", [x,y]);
        return 0;
    };
    if (bigcmp(x, rangebound) > 0) return 0;
    if (bigcmp(y, rangebound) > 0) return 0;

    #printf("Test %b,%b\n", [x,y]);

    # for each sensor: can this sensor see (x,y)? if so, return
    var i = 0;
    var s;
    var gx; var gy;
    while (i < grlen(sensors)) {
        s = grget(sensors,i);
        if (s != nots)
            if (cansee(s,x,y)) {
                #printf("Sensor at %b,%b can see %b,%b (range=%b)\n", [s[SX],s[SY],x,y,s[RANGE]]);
                if (bigcmp(s[SX],x) > 0) { # left half
                    # advance to centre line in x
                    bigset(dist, s[SX]); bigsub(dist, x);
                } else if (bigcmp(y,s[SY]) > 0) { # bottom right
                    # find the distance from the centre
                    bigset(dx, x); bigsub(dx, s[SX]); bigabs(dx);
                    bigset(dy, y); bigsub(dy, s[SY]); bigabs(dy);
                    bigadd(dx, dy);

                    # subtract the distance from the centre from the viewing range
                    bigset(dist, s[RANGE]);
                    bigsub(dist, dx);
                    printf("viewing range = %b, distance from centre = %b\n", [s[RANGE],dx]);

                    # distance to add is that much, /2, -1
                    bigdivw(dist, 2); bigaddw(dist, -1);
                    printf("so, distance to add = %b\n", [dist]);
                } else { # top right
                    # advance to centre line in y
                    bigset(dist, s[SY]); bigsub(dist, y);
                };
                if (bigcmpw(dist, 0) > 0) {
                    bigadd(x, dist); bigadd(y, dist);
                } else {
                    printf("negative dist: (%b,%b) from sensor (%b,%b) seeing %b\n", [x,y,s[SX],s[SY],s[RANGE]]);
                };
                return 0;
            };
        i++;
    };

    # if none: print
    printf("%b * %b = ", [x,y]);
    bigmul(x,y);
    printf("%b\n", [x]);
    exit(0);
};

var walk = func(x,y,s) {
    while (bigcmp(y,s[SY]) <= 0) {
        printf("%b,%b\n", [x,y]);
        test(x,y,s);
        bigadd(x, plus); bigadd(y, plus);
        if (bigcmp(x, rangebound) > 0) return 0;
    };
};

var x = bignew(0);
var y = bignew(0);

i = 0;
while (i < grlen(sensors)) {
    printf("%d/%d\n", [i,grlen(sensors)]);
    s = grget(sensors, i);

    # 1. find all points just outside the viewing range
    # start at (sx,sy-range-1)
    bigset(x, s[SX]);
    bigset(y, s[SY]); bigsub(y, s[RANGE]); bigsubw(y, 1);

    # walk down and to the right until y==sy
    walk(x,y,s);

    i++;
};

printf("no solution\n",0);
