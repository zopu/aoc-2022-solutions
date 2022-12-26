#include <iostream>
#include <vector>

#ifndef _GRID_H_
#define _GRID_H_

class Grid {
   public:
    Grid(int width, int height) {
        w = width;
        h = height;
        grid.resize(w * h);
    }

    void set(int x, int y, char value) {
        grid[y * w + x] = value;
    }

    bool is_blizzard(int x, int y, int step) {
        if (x < 0 || y < 0 || x >= w || y >= h) {
            return false;
        }
        if (step == 0) {
            return grid[y * w + x] != '.';
        }
        if (grid[((y + step) % h) * w + x] == '^') {
            return true;
        }
        int down_wind_y = (y - step) % h;
        if (down_wind_y < 0) {
            down_wind_y += h;
        }
        if (grid[down_wind_y * w + x] == 'v') {
            return true;
        }
        if (grid[y * w + ((x + step) % w)] == '<') {
            return true;
        }
        int east_wind_x = (x - step) % w;
        if (east_wind_x < 0) {
            east_wind_x += w;
        }
        if (grid[y * w + east_wind_x] == '>') {
            return true;
        }
        return false;
    }

    void print() {
        std::cout << "# ";
        for (int i = 0; i < w; ++i) {
            std::cout << "#";
        }
        std::cout << std::endl;

        for (int j = 0; j < h; ++j) {
            std::cout << "#";
            for (int i = 0; i < w; ++i) {
                std::cout << grid[j * w + i];
            }
            std::cout << "#" << std::endl;
        }
        for (int i = 0; i < w; ++i) {
            std::cout << "#";
        }
        std::cout << " #" << std::endl;
    }

    void print_blizzards(int step) {
        std::cout << "# ";
        for (int i = 0; i < w; ++i) {
            std::cout << "#";
        }
        std::cout << std::endl;

        for (int j = 0; j < h; ++j) {
            std::cout << "#";
            for (int i = 0; i < w; ++i) {
                if (is_blizzard(i, j, step)) {
                    std::cout << "#";
                } else {
                    std::cout << ".";
                }
            }
            std::cout << "#" << std::endl;
        }
        for (int i = 0; i < w; ++i) {
            std::cout << "#";
        }
        std::cout << " #" << std::endl;
    }

    int w;
    int h;

   private:
    std::vector<char> grid;
};

#endif  // _GRID_H_