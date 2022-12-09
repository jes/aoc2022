include "bufio.sl";
include "bitmap.sl";

var in = bfdopen(0, O_READ);
var line = malloc(128);

var knotx = [0,0,0,0,0,0,0,0,0,0];
var knoty = [0,0,0,0,0,0,0,0,0,0];

var minx = -68;
var maxx = 307;
var miny = -108;
var maxy = 106;

var visited = bmnew(maxx-minx+1, maxy-miny+1);

var mark = func(x,y) {
    bmset(visited, x-minx, y-miny, 1);
};

# isclose(x) = 1 if close, 0 otherwise
var isclose = asm {
    pop x
    # is x -1, 0, or 1? if so return 1, else return 0
    cmp x, 0
    jz isclose_yes
    cmp x, 1
    jz isclose_yes
    cmp x, -1
    jz isclose_yes
    ld r0, 0
    ret
    isclose_yes:
    ld r0, 1
    ret
};

# sign(x) = 0 if x == 0, 1 if x > 0, -1 if x < 0
var sign = asm {
    pop x
    cmp x, 0
    jz sign_zero
    and x, 0x8000
    jz sign_positive
    ld r0, -1
    ret
    sign_zero:
    ld r0, 0
    ret
    sign_positive:
    ld r0, 1
    ret
};

var updatetail = func() {
    var headx; var heady; var tailx; var taily;
    var dx; var dy;
    var i = 0;
    while (i < 9) {
        headx = knotx[i];
        heady = knoty[i];
        tailx = knotx[i+1];
        taily = knoty[i+1];
    
        dx = headx-tailx;
        dy = heady-taily;
        if (isclose(dx)) if (isclose(dy)) return 0;
        tailx = tailx + sign(dx);
        taily = taily + sign(dy);

        if (i == 8) mark(tailx, taily);

        knotx[i+1] = tailx;
        knoty[i+1] = taily;
   
        i++;
    };
};

var move = func(dx, dy, dist) {
    while (dist--) {
        knotx[0] = knotx[0] + dx;
        knoty[0] = knoty[0] + dy;

        updatetail();
    };
};

mark(0,0);

var dir;
var dist;
while (bgets(in, line, 128)) {
    dir = line[0];
    dist = atoi(line+2);
    if (dir == 'U') move(0, -1, dist)
    else if (dir == 'D') move(0, 1, dist)
    else if (dir == 'R') move(1, 0, dist)
    else if (dir == 'L') move(-1, 0, dist)
    else assert(0, "illegal direction: %c\n", [dir]);
};

printf("%d\n", [bmcount(visited)]);
