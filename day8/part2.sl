include "bufio.sl";

var in = bfdopen(0, O_READ);

var x; var y = 0; var w; var h;

var grid = vzmalloc([101,101]);

while (bgets(in, grid[y], 128)) {
    w = strlen(grid[y])-1;
    grid[w] = 0;
    y++;
};
h=y;

var xscenic = vzmalloc([h+1,w+1]);
var yscenic = vzmalloc([h+1,w+1]);
y = 0;
while (y < h) {
    x = 0;
    while (x < w) {
        xscenic[y][x] = 1;
        yscenic[y][x] = 1;
        x++;
    };
    y++;
};

var scan = func(x, y, dx, dy, scenic) {
    var sawat = [0,0,0,0,0,0,0,0,0,0];
    var H;
    var p = 0;
    while (x >= 0 && x < w && y >= 0 && y < h) {
        H = grid[y][x] - '0';
        scenic[y][x] = mul(scenic[y][x], p-sawat[H]);
        while (H >= 0) sawat[H--] = p;
        x = x + dx;
        y = y + dy;
        p++;
    };
};

x = 0;
while (x < w) {
    printf("x=%d\n", [x]);
    scan(x, 0, 0, 1, xscenic);
    scan(x, h-1, 0, -1, xscenic);
    x++;
};
y = 0;
while (y < h) {
    printf("y=%d\n", [y]);
    scan(0, y, 1, 0, yscenic);
    scan(w-1, y, -1, 0, yscenic);
    y++;
};

var answer = bignew(0);
var tmp = bignew(0);
y = 0;
while (y < h) {
    x = 0;
    while (x < w) {
        bigsetw(tmp, xscenic[y][x]);
        bigmulw(tmp, yscenic[y][x]);
        if (bigcmp(tmp, answer) > 0) bigset(answer, tmp);
        x++;
    };
    y++;
};

printf("%b\n", [answer]);
