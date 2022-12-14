include "bufio.sl";

var in = bfdopen(0, O_READ);
var line = malloc(512);

var x; var y;
var row;

var minx = 463; var maxx = 538;
var miny = 0; var maxy = 180;

var WALL = 1;
var SAND = 2;

var grid = vzmalloc([maxy-miny, maxx-minx]);

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
        grid[y-miny][x-minx] = WALL;
        x = x+dx;
        y = y+dy;
    };
    grid[y-miny][x-minx] = WALL;
};

var map = func(x,y) {
    if (x < minx || y < miny || x >= maxx || y >= maxy) return 0;
    return grid[y-miny][x-minx];
};

var plot = func(x,y,v) {
    if (x < minx || y < miny || x >= maxx || y >= maxy) return 0;
    grid[y-miny][x-minx] = v;
};

var drop = func(x,y) {
    while (1) {
        if (y >= maxy) return 0;
        if (!map(x,y+1)) {
            y++;
        } else if (!map(x-1,y+1)) {
            y++; x--;
        } else if (!map(x+1,y+1)) {
            y++; x++;
        } else {
            plot(x,y,SAND);
            return 1;
        };
    };
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

drawgrid();
var sands = 0;
while (1) {
    if (!drop(500,0)) break;
    sands++;
    putchar('.');
};
drawgrid();
printf("%d\n", [sands]);
