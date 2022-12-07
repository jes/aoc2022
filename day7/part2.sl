include "bufio.sl";

var in = bfdopen(0, O_READ);
var line = malloc(128);

var totalsize = bigatoi("70000000");
var needfree = bigatoi("30000000");
var usedspace = bigatoi("48008081");
var havefree = bigclone(totalsize); bigsub(havefree, usedspace);
var needtodelete = bigclone(needfree); bigsub(needtodelete, havefree);
var answer = bigclone(totalsize);

var cd = func() {
    var size = bignew(0);
    while (bgets(in, line, 128)) {
        if (line[0] == '$') {
            if (line[2] == 'c') { # cd
                if (line[5] == '.') { # $ cd ..
                    break;
                };
                bigadd(size, cd());
            } else if (line[2] == 'l') { # ls
                # nothing
            } else {
                assert(0, "unrecognised command: [%s]\n", [line]);
            };
        } else {
            if (line[0] == 'd') { # directory entry
                # nothing
            } else if (isdigit(line[0])) { # file
                bigadd(size, bigatoi(line));
            } else {
                assert(0, "unrecognised line: [%s]\n", [line]);
            };
        };
    };
    if (bigcmp(size, needtodelete) > 0) {
        if (bigcmp(size, answer) < 0) bigset(answer, size);
    };
    return size;
};

cd();
printf("%b\n", [answer]);
