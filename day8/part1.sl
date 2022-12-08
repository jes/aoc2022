include "bufio.sl";

var in = bfdopen(0, O_READ);

var x; var y = 0; var w; var h;

var grid = vzmalloc([110,110]);

while (bgets(in, grid[y], 128)) {
    w = strlen(grid[y])-1;
    grid[w] = 0;
    y++;
};
h=y;

var counted = vzmalloc([h+2,w+2]);

var nvisible = w+w+h-2+h-2;

printf("%d\n", [nvisible]);

var scan = func(x, y, dx, dy, highest) {
    while (x >= 1 && x < w-1 && y >= 1 && y < h-1) {
        if (grid[y][x] > highest) {
            if (!counted[y][x]) nvisible++;
            #printf("saw a %c at %d,%d (counted=%d)\n", [grid[y][x], x,y, counted[y][x]]);
            counted[y][x] = 1;
            highest = grid[y][x];
            if (highest == '9') break;
        };
        x = x + dx;
        y = y + dy;
    };
};

x = 1;
while (x < w-1) {
    scan(x, 1, 0, 1, grid[0][x]);
    scan(x, h-2, 0, -1, grid[h-1][x]);
    x++;
};
y = 1;
while (y < h-1) {
    scan(1, y, 1, 0, grid[y][0]);
    scan(w-2, y, -1, 0, grid[y][w-1]);
    y++;
};

printf("%d\n", [nvisible]);
