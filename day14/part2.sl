include "bufio.sl";
include "bitmap.sl";

var in = bfdopen(0, O_READ);
var line = malloc(512);

var x; var y;
var row;

var minx = 500-181; var maxx = 500+181;
var miny = 0; var maxy = 181;
var floory = 180;

var WALL = 1;
var SAND = 2;

#printf("change floory to 180!!!\n", 0);

var grid = bmnew(maxx-minx, maxy-miny);

var skipover = func(s, ch) {
    while (*s) {
        if (*s == ch) return s+1;
        s++;
    };
    return 0;
};

var addwall = func(x1, y1, x2, y2) {
    var x = x1; var y = y1;
    var dx = sign(x2-x1); var dy = sign(y2-y1);
    while (x != x2 || y != y2) {
        bmset(grid, x-minx, y-miny, 1);
        x = x+dx;
        y = y+dy;
    };
    bmset(grid, x-minx, y-miny, 1);
};

var drop = func(x,y) {
    if (y >= floory) return 0;
    if (bmget(grid, x-minx, y-miny)) return 0;
    bmset(grid, x-minx, y-miny, 1);
    return 1+drop(x,y+1)+drop(x-1,y+1)+drop(x+1,y+1);
};

var p;
var i;

while (bgets(in, line, 512)) {
    p = line;
    row = grnew();

    while (p) {
        x = atoi(p);
        p = skipover(p, ',');
        y = atoi(p);
        p = skipover(p, '>');
        if (p) p++;
    
        grpush(row, x); grpush(row, y);
    };

    i = 2;
    while (i < grlen(row)) {
        addwall(grget(row, i-2), grget(row,i-1), grget(row,i), grget(row,i+1));
        i = i + 2;
    };

    if (grlen(row) == 0) break;
    grfree(row);
};

var map;
var drawgrid = func() {
    var y = 0;
    var x;
    while (y < 12) {
        x = 490;
        while (x < 510) {
            if (map(x,y) == WALL) putchar('#')
            else if (map(x,y) == SAND) putchar('o')
            else putchar(' ');
            x++;
        };
        y++;
        putchar('\n');
    };
};

printf("%d\n", [drop(500,0)]);
#drawgrid();
