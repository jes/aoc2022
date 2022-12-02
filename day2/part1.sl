include "bufio.sl";

var in = bfdopen(0, O_READ);
var line = malloc(128);

var score = 0;

var beats = [1,2,0];

var outcome = func(a,b) {
    if (a==b) return 3;
    if (beats[a] == b) return 6;
    return 0;
};

var opponent;
var me;

while (bgets(in, line, 128)) {
    opponent = line[0]-'A';
    me = line[2]-'X';
    # rock=0, paper=1, scissors=2
    score = score + 1 + me + outcome(opponent, me);
};

printf("%d\n", [score]);
