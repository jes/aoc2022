include "bufio.sl";

var in = bfdopen(0, O_READ);
var line = malloc(128);

var valvenumber = grnew();
var nvalves = 0;

var valveid = func(s) {
    var key = mul(s[0]-'A',26) + s[1]-'A';
    var i = 0;
    while (i < grlen(valvenumber)) {
        if (grget(valvenumber,i) == key) return i;
        i++;
    };
    grpush(valvenumber, key);
    nvalves++;
    return grlen(valvenumber)-1;
};
var valvename_str = "..";
var valvename = func(i) {
    var id = grget(valvenumber,i);
    valvename_str[0] = div(id,26)+'A';
    valvename_str[1] = mod(id,26)+'A';
    return valvename_str;
};

var skipover = func(s,ch) {
    while (*s) {
        if (*s == ch) return s+1;
        s++;
    };
    return 0;
};

var flowrate = zmalloc(65);
var neighbours = zmalloc(65);
var valvebit = zmalloc(65);
var nextvalvebit = 1;
var valves = grnew();
var id;
var p;

printf("reading input...\n", 0);

# Valve .. has flow rate=..; tunnels lead to valves ..[, ..]+
while (bgets(in,line,128)) {
    id = valveid(line+6);
    grpush(valves, id);
    flowrate[id] = atoi(line+23);
    if (flowrate[id]) {
        valvebit[id] = nextvalvebit;
        nextvalvebit = nextvalvebit+nextvalvebit;
    };
    neighbours[id] = grnew();
    p = skipover(line, 'd'); p = skipover(p, 's'); p++;
    while (p) {
        grpush(neighbours[id], valveid(p));
        p = skipover(p, ' ');
    };
};

printf("%d valves\n", [nvalves]);

var visited = zmalloc(65);
var realneighbours = zmalloc(65);
# write all neighbours of from who have non-zero flow to idx, recurse on neighbours who have 0 flow
var computeneighbours = func(from) {
    var idx = from;
    var q = grnew();
    var qidx = 0;
    grpush(q, cons(from, 0));
    var vl;
    var v; var len;
    var i;

    while (qidx < grlen(q)) {
        vl = grget(q, qidx++);
        from = vl[0]; len = vl[1];
        free(vl);
        i = 0;
        while (i < grlen(neighbours[from])) {
            v = grget(neighbours[from], i);
            if (!visited[v]) {
                visited[v] = 1;
                if (flowrate[v]) {
                    grpush(realneighbours[idx], cons(v,len+1));
                };
                grpush(q, cons(v,len+1));
            };
            i++;
        };
    };
};

printf("computing neighbours...\n", 0);

var rni;
var i = 0;
var v;
while (i < grlen(valves)) {
    v = grget(valves, i);
    realneighbours[v] = grnew();
    memset(visited, 0, 65);
    computeneighbours(v);
    rni = v;
    #grwalk(realneighbours[v], func(vl) {
    #    printf("Path from %s to ", [valvename(rni)]); printf("%s = %d\n", [valvename(vl[0]), vl[1]]);
    #});
    i++;
};

free(visited);
var vopen = zmalloc(65);

var dfs = func(from, levels) {
    if (levels == 0) return 0;

    var i = 0;
    var vl;
    var v; var l;
    var flow = 0;
    var bestflow = 0;
    var r;
    while (i < grlen(realneighbours[from])) {
        vl = grget(realneighbours[from], i);
        v = vl[0]; l = vl[1];
        if (!vopen[v] && levels > l) {
            vopen[v] = 1;

            flow = mul(flowrate[v], levels-(l+1)) + dfs(v,levels-(l+1));
            if (flow > bestflow) bestflow = flow;

            vopen[v] = 0;
        };
        i++;
    };
    return bestflow;
};

printf("running dfs...\n", 0);

printf("%d\n", [dfs(valveid("AA"), 30)]);
