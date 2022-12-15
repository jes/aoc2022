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
var MINX = 4;
var MAXX = 5;

var makesensor = func(sx,sy,bx,by) {
    var s = malloc(6);
    s[SX] = sx;
    s[SY] = sy;
    s[BX] = bx;
    s[BY] = by;
    s[MINX] = bignew(0);
    s[MAXX] = bignew(0);
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

var i = 0;
var dx = bignew(0); var dy = bignew(0);
var dist = bignew(0);
var s;

#var examiney = bignew(10);
#printf("Remember to change examiney!\n", 0);

var examiney = bigatoi("2000000");

var dyexamine = bignew(0);
while (i < grlen(sensors)) {
    printf("%d/%d (1)\n", [i,grlen(sensors)]);
    s = grget(sensors, i);
    bigset(dx, s[SX]); bigsub(dx, s[BX]); bigabs(dx);
    bigset(dy, s[SY]); bigsub(dy, s[BY]); bigabs(dy);
    bigadd(dx,dy);

    # for every 1 y coordinate s[SY] differs from examiney, we lose 1 off dx
    bigset(dyexamine, s[SY]); bigsub(dyexamine, examiney); bigabs(dyexamine);
    bigsub(dx, dyexamine);

    bigset(s[MINX], s[SX]); bigsub(s[MINX], dx);
    bigset(s[MAXX], s[SX]); bigadd(s[MAXX], dx);

    #if (bigcmp(s[MAXX], s[MINX]) >= 0) {
        #printf("Sensor at %b,%b (sees %b,%b) sees range from %b to %b\n", s);
    #};
    i++;
};

grsort(sensors, func(a,b) {
    return bigcmp(a[MINX],b[MINX]);
});

i = 0;
var prevmaxx = bigatoi("-2000000000");
var xrange = bignew(0);
var xmin = bignew(0);
while (i < grlen(sensors)) {
    printf("%d/%d (2)\n", [i,grlen(sensors)]);
    s = grget(sensors, i);

    if (bigcmp(s[MINX], prevmaxx) > 0) {
        # non-overlapping
        bigset(xmin, s[MINX]);
    } else {
        # overlapping
        bigset(xmin, prevmaxx);
        bigaddw(xmin, 1);
    };

    if (bigcmp(xmin, s[MAXX]) <= 0) {
        #printf("Sensor at %b,%b adds range from %b to %b\n", [s[SX],s[SY],xmin,s[MAXX]]);

        if (bigcmp(s[BY], examiney) == 0) {
            if (bigcmp(s[BX], xmin) >= 0) {
                printf("   (deletes 1 for the beacon at %b,%b)\n", [s[BX],s[BY]]);
                bigsubw(xrange, 1);
            };
        };

        bigadd(xrange, s[MAXX]);
        bigsub(xrange, xmin);
        bigaddw(xrange, 1);
    };

    #printf("%b\n", [xrange]);

    if (bigcmp(s[MAXX], prevmaxx) > 0)
        bigset(prevmaxx, s[MAXX]);
    i++;
};

printf("%b\n", [xrange]);
