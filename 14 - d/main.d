import std.algorithm.iteration : map, reduce;
import std.algorithm.comparison : max, min;
import std.array;
import std.conv : to;
import std.file : readText;
import std.range : chain;
import std.stdio;
import std.typecons : tuple, Tuple;

alias Tuple!(int, int) Point;

pure Point parse_coords(string coords) {
    auto nums = coords.split(",").map!(n => to!int(n));
    return tuple(nums[0], nums[1]);
}

// Returns min_x, max_x, min_y, max_y
Tuple!(int, int, int, int) getBounds(InputRange)(InputRange parsed_lines) {
    Tuple!(int, int, int, int) bounds = tuple(500, 500, 0, 0);
    foreach(l; parsed_lines) {
        foreach(p; l) {
            if (p[0] < bounds[0]) bounds[0] = p[0];
            if (p[0] > bounds[1]) bounds[1] = p[0];
            if (p[1] < bounds[2]) bounds[2] = p[1];
            if (p[1] > bounds[3]) bounds[3] = p[1];
        }
    }
    bounds[1] = bounds[1] + 1;
    bounds[3] = bounds[3] + 1;
    return bounds;
}

void printGrid(bool[][] grid) {
    foreach(row; grid) {
        foreach(pos; row) {
            if (pos) {
                write('#');
            } else {
                write('.');
            }
        }
        writeln();
    }
}

void drawLine(bool[][] grid, Point a, Point b, Tuple!(int, int, int, int) bounds) {
    grid[a[0] - bounds[0]][a[1] - bounds[2]] = true;
    grid[b[0] - bounds[0]][b[1] - bounds[2]] = true;
    if (a[0] == b[0]) {
        // Horizontal line
        for (int i = min(a[1], b[1]); i < max(a[1], b[1]); ++ i) {
            grid[a[0] - bounds[0]][i - bounds[2]] = true;
        }
    }
    if (a[1] == b[1]) {
        // Vertical line
        for (int i = min(a[0], b[0]); i < max(a[0], b[0]); ++ i) {
            grid[i - bounds[0]][a[1] - bounds[2]] = true;
        }
    }
}

void addLines(InputRange)(bool[][] grid, InputRange parsed_lines, Tuple!(int, int, int, int) bounds) {
    foreach(line; parsed_lines) {
        auto start = line[0];
        foreach(point; line) {
            drawLine(grid, start, point, bounds);
            start = point;
        }
    }
}

// Will return false if the grain goes outside the bounds of the grid
bool addGrain(bool[][] grid, Tuple!(int, int, int, int) bounds) {
    auto p = tuple(500, 0);
    while(true) {
        // writeln(p[0], ",", p[1]);
        if (p[0] < bounds[0] || p[0] > bounds[1] || p[1] >= bounds[3] - 1) {
            return false;
        }
        if (grid[p[0] - bounds[0]][p[1] + 1] == false) {
            ++p[1];
        } else if (p[0] == bounds[0]) {
            // Going to fall off the side
            return false;
        } else if (grid[p[0] - bounds[0] - 1][p[1] + 1] == false) {
            --p[0];
            ++p[1];
        } else if (p[0] == bounds[1] - 1) {
            // Going to fall off the side
            return false;
        } else if (grid[p[0] - bounds[0] + 1][p[1] + 1] == false) {
            ++p[0];
            ++p[1];
        } else {
            grid[p[0] - bounds[0]][p[1]] = true;
            return true;
        }
    }
    return false;
}

void main () {
    string[] lines = readText("input.txt").split("\n");
    auto parsed_lines = map!((l) {
        string[] line_split = l.split(" -> ");
        auto res = map!(parse_coords)(line_split);
        return res;
    })(lines);
    auto bounds = getBounds(parsed_lines);
    writeln(bounds);
    int w = (bounds[1] - bounds[0]), h = (bounds[3] - bounds[2]);
    bool[][] grid = new bool[][](w, h);
    foreach(i; 0 .. w) {
        foreach(j; 0 .. h) {
            grid[i][j] = false;
        }
    }
    addLines(grid, parsed_lines, bounds);
    int count = 0;
    while (addGrain(grid, bounds)) {
        ++count;
    }
    writeln("Part 1: ", count);
    
    bounds[3] += 2;
    bounds[0] = 500 - bounds[3] - 1;
    bounds[1] = 500 + bounds[3] + 1;
    w = (bounds[1] - bounds[0]);
    h = (bounds[3] - bounds[2]);
    bool[][] p2Grid = new bool[][](w, h);
    foreach(i; 0 .. w) {
        foreach(j; 0 .. h) {
            p2Grid[i][j] = false;
        }
    }
    addLines(p2Grid, parsed_lines, bounds);
    foreach(i; 0 .. w) {
        p2Grid[i][bounds[3] - 1] = true;
    }
    count = 0;
    while (addGrain(p2Grid, bounds)) {
        ++count;
        if (p2Grid[500 - bounds[0]][0]) {
            break;
        }
    }
    // printGrid(p2Grid);
    writeln("Part 2: ", count);
}