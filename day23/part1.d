import std.stdio;
import std.string;
import std.conv;

struct Point {
    int x;
    int y;

    Point opBinary(string op : "+")(Point p) {
        Point o;
        o.x = p.x + this.x;
        o.y = p.y + this.y;
        return o;
    }
};

struct Grid {
    bool[Point] cells;
    Point[][Point] move;
};

enum Direction { North, South, East, West };

bool doMove(ref Grid grid, Point p, Direction d) {
    Point[][Direction] check;
    check[Direction.North] = [Point(-1,-1), Point(0,-1), Point(1,-1)];
    check[Direction.East] = [Point(1,-1), Point(1,0), Point(1,1)];
    check[Direction.South] = [Point(-1,1), Point(0,1), Point(1,1)];
    check[Direction.West] = [Point(-1,-1), Point(-1,0), Point(-1,1)];
    foreach (pd; check[d]) {
        if ((p+pd) in grid.cells) return false;
    }
    grid.move[p + check[d][1]] ~= p;
    return true;
}

void tryToMove(ref Grid grid, Point p, int round) {
    bool anyneighbours = false;
    foreach (y; -1..2) {
        foreach (x; -1..2) {
            if (x==0 && y==0) continue;
            if ((Point(x,y)+p) in grid.cells) anyneighbours = true;
        }
    }
    if (anyneighbours) {
        Direction[] directions = [Direction.North, Direction.South, Direction.West, Direction.East];
        foreach (i; 0 .. directions.length) {
            if (doMove(grid, p, directions[(i+round)%4]))
                return;
        }
    }
    grid.move[p] ~= p;
}

void oneRound(ref Grid grid, int round) {
    foreach (k,v; grid.cells) {
        tryToMove(grid, k, round);
    }
    grid.cells.clear();

    foreach (k,v; grid.move) {
        if (v.length == 1) {
            grid.cells[k] = true;
        } else {
            foreach (p; v) {
                grid.cells[p] = true;
            }
        }
    }
    grid.move.clear();
}

int countEmpty(Grid grid) {
    Point min;
    Point max;
    int numoccupied = 0;
    foreach (p; grid.cells.keys) {
        if (p.x < min.x) min.x = p.x;
        if (p.x > max.x) max.x = p.x;
        if (p.y < min.y) min.y = p.y;
        if (p.y > max.y) max.y = p.y;
        numoccupied++;
    }
    int w = 1 + max.x - min.x;
    int h = 1 + max.y - min.y;
    return w*h - numoccupied;
}

void main() {
    Grid grid;
    int y = 0;
    foreach (row; stdin.byLine) {
        foreach (x, c; row) {
            if (c == '#')
                grid.cells[Point(to!int(x), y)] = true;
        }
        y++;
    }
    foreach (i; 0 .. 10) {
        oneRound(grid, i);
    }
    writefln("%d", countEmpty(grid));
}
