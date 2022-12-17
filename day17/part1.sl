include "bufio.sl";

var in = bfdopen(0, O_READ);
var jets = malloc(11000);

bgets(in, jets, 11000);
jets[strlen(jets)-1] = 0;
var njets = strlen(jets);

var rockpoints = malloc(5);
var rockw = malloc(5);
var rockh = malloc(5);

var mkrock = func(i, points, w, h) {
    rockpoints[i] = points;
    rockw[i] = w;
    rockh[i] = h;
};

# (x,y)
mkrock(0, [[0,0], [1,0], [2,0], [3,0]], 4, 1);
mkrock(1, [[1,0], [0,1], [1,1], [2,1], [1,2]], 3, 3);
mkrock(2, [[0,0], [1,0], [2,0], [2,1], [2,2]], 3, 3);
mkrock(3, [[0,0], [0,1], [0,2], [0,3]], 1, 4);
mkrock(4, [[0,0], [0,1], [1,0], [1,1]], 2, 2);

# bottom left of floor is at (0,0)
var maxmaxy = 8000;
var map = bmnew(7,maxmaxy);
var maxy = 0;
var rocktype = 0;
var jetpos = 0;

# test whether rock r at (x,y) would collide with the map
# return 1 if so, else 0
var collide = func(r,x,y) {
    var i = 0;
    var px; var py;
    while (rockpoints[r][i]) {
        px = rockpoints[r][i][0];
        py = rockpoints[r][i][1];
        if (x+px < 0 || x+px > 6 || y+py < 0) return 1;
        if (bmget(map,x+px,y+py)) return 1;
        i++;
    };
    return 0;
};

# paint rock r into the map at (x,y)
var paint = func(r,x,y) {
    var i = 0;
    var px; var py;
    while (rockpoints[r][i]) {
        px = rockpoints[r][i][0];
        py = rockpoints[r][i][1];
        bmset(map, x+px, y+py, 1);
        i++;
    };
};

var droprock = func() {
    var x = 2;
    var y = maxy+3;
    var r = rocktype++;
    if (rocktype == 5) rocktype = 0;

    var newx;

    while (1) {
        # slide
        newx = x;
        if (jets[jetpos] == '<') newx--
        else newx++;
        jetpos++;
        if (jetpos == njets) jetpos = 0;
        if (collide(r,newx,y)) newx = x;

        # fall
        if (collide(r,newx,y-1)) {
            paint(r,newx,y);
            if (y+rockh[r] > maxy) maxy = y+rockh[r];
            return 0;
        };

        x = newx; y--;
    };
};

var draw = func() {
    var y = maxy;
    var x;
    while (y >= 0) {
        x = 0;
        while (x < 7) {
            if (bmget(map,x,y)) putchar('#')
            else putchar('.');
            x++;
        };
        putchar('\n');
        y--;
    };
};

var i = 0;
while (i < 2022) {
    putchar('.');
    #jetpos = 0;
    droprock();
    #printf("after %d rocks, maxy=%d\n", [i+1,maxy]);
    #draw();
    #assert(maxy < maxmaxy, "maxy exceeded %d\n", [maxmaxy]);
    i++;
};
putchar('\n');

printf("%d\n", [maxy]);
