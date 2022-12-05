include "bufio.sl";

var in = bfdopen(0, O_READ);
var line = malloc(128);

var score = 0;

var beats = [1,2,0];
var losesto = [2,0,1];

var outcome = func(a,b) {
    if (a==b) return 3;
    if (beats[a] == b) return 6;
    return 0;
};

var opponent;
var want;
var me;

while (bgets(in, line, 128)) {
    opponent = line[0]-'A';
    want = line[2]-'X';
    if (want == 1) { # draw
        me = opponent;
    } else if (want == 0) { # lose
        me = losesto[opponent];
    } else { # win
        me = beats[opponent];
    };
    # rock=0, paper=1, scissors=2
    score = score + 1 + me + outcome(opponent, me);
};

printf("%d\n", [score]);
