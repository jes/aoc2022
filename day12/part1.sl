include "bufio.sl";
include "bitmap.sl";

var in = bfdopen(0, O_READ);

var grid = vzmalloc([50,90]);
var visited = bmnew(90,50);

var x; var y = 0; var w; var h;
var startx; var starty; var endx; var endy;

while (bgets(in, grid[y], 128)) {
    w = strlen(grid[y])-1;
    grid[y][w] = 0;

    x = 0;
    while (x < w) {
        if (grid[y][x] == 'S') {
            startx = x; starty = y;
        };
        if (grid[y][x] == 'E') {
            endx = x; endy = y;
        };
        x++;
    };
    y++;
};
h = y;

printf("start=(%d,%d), end=(%d,%d)\n", [startx,starty,endx,endy]);

grid[starty][startx] = 'a';
grid[endy][endx] = 'z';

var q = grnew();
grpush(q, startx); grpush(q, starty); grpush(q, 0);
bmset(visited, startx, starty, 1);

var qidx = 0;

var height;
var len;

var dx = [-1,0,1,0];
var dy = [0,-1,0,1];
var i;

var nx; var ny;

while (qidx < grlen(q)) {
    x = grget(q, qidx++);
    y = grget(q, qidx++);
    len = grget(q, qidx++);
    height = grid[y][x];
    i = 0;
    while (i < 4) {
        nx = x+dx[i]; ny = y+dy[i];
        if (nx >= 0 && ny >= 0 && nx < w && ny < h) { # nx,ny within bounds
            if (grid[ny][nx] <= height+1) {
                if (nx == endx && ny == endy) {
                    printf("%d\n", [len+1]);
                    exit(0);
                };
                if (!bmget(visited,nx,ny)) {
                    grpush(q, nx); grpush(q, ny); grpush(q, len+1);
                    bmset(visited,nx,ny,1);
                };
            };
        };
        i++;
    };
};
printf("no solution\n",0);
