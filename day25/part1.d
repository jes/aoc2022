import std.stdio;
import std.algorithm;
import std.conv;

long parseSNAFU(const(char)[] line) {
    long n = 0;
    foreach (c; line) {
        n *= 5;
        switch (c) {
            case '0': .. case '2':
                n += c-'0';
                break;
            case '-':
                n -= 1;
                break;
            case '=':
                n -= 2;
                break;
            default:
                throw new Exception("illegal character in snafu number: " ~ c);
        }
    }
    return n;
}

char[] formatSNAFU(long n) {
    char[] base5 = to!(char[])(n, 5);
    long carry = 0;
    foreach_reverse (ref c; base5) {
        long digit = c - '0' + carry;
        carry = 0;
        if (digit >= 5) {
            digit -= 5;
            carry++;
        }
        switch (digit) {
            case 0: .. case 2:
                c = cast(char) (digit + '0');
                break;
            case 3:
                c = '=';
                carry++;
                break;
            case 4:
                c = '-';
                carry++;
                break;
            default:
                throw new Exception("illegal base5 digit: " ~ c);
        }
    }
    if (carry) {
        base5 = (cast(char) (carry+'0')) ~ base5;
    }
    return base5;
}

unittest {
    assert(parseSNAFU("2=-01") == 976);
    assert(parseSNAFU("20012") == 1257);
    assert(parseSNAFU("2=-1=0") == 4890);
    assert(parseSNAFU("1-0---0") == 12345);
    assert(parseSNAFU("1121-1110-1=0") == 314159265);

    foreach (i; 0 .. 10000) {
        if (parseSNAFU(formatSNAFU(i)) != i) {
            writefln("%d: formats as %s, parses as %d", i, formatSNAFU(i), parseSNAFU(formatSNAFU(i)));
            assert(false);
        }
    }
}

void main() {
    writefln("%s", stdin.byLine.map!(parseSNAFU).sum.formatSNAFU);
}
