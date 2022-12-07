include "bufio.sl";

var in = bfdopen(0, O_READ);
var line = malloc(128);

var answer = bignew(0);
var hundredk = bigatoi("100000");

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
    if (bigcmp(size, hundredk) <= 0) {
        bigadd(answer, size);
    };
    return size;
};

cd();
printf("%b\n", [answer]);
