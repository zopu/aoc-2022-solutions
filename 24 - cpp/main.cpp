#include <fstream>
#include <iostream>
#include <string>
#include <vector>

#include "grid.h"
#include "search.h"

Grid parse_input_file(std::string filename) {
    std::ifstream file(filename);
    std::string txt;
    std::vector<std::string> lines;
    while (std::getline(file, txt)) {
        lines.push_back(txt);
    }
    file.close();

    Grid g(lines[0].size() - 2, lines.size() - 2);
    int linenum = 0;
    for (std::string line : lines) {
        if ((linenum == 0) || (linenum >= lines.size() - 1)) {
            ++linenum;
            continue;
        }
        for (auto i = 1; i < line.size() - 1; i++) {
            g.set(i - 1, linenum - 1, line[i]);
        }
        ++linenum;
    }
    return g;
}

int main(int argc, char** argv) {
    Grid grid = parse_input_file("input.txt");
    std::cout << "Grid dimensions: (" << grid.w << "," << grid.h << ")" << std::endl;
    grid.print();
    std::cout << std::endl;
    grid.print_blizzards(1);
    int part1 = bfs_min_steps(&grid, 0, 0, -1, grid.w - 1, grid.h - 1) + 1;
    std::cout << "Part 1: " << part1 << std::endl;
    int part2_a = bfs_min_steps(&grid, part1, grid.w - 1, grid.h, 0, 0) + 1;
    int part2_b = bfs_min_steps(&grid, part2_a, 0, -1, grid.w - 1, grid.h - 1) + 1;
    std::cout << "Part 2: " << part2_b << std::endl;
}