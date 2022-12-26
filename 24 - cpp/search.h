#include <queue>
#include <set>

#include "grid.h"

void push_if_not_seen(std::queue<std::tuple<int, int, int> >* q, std::set<std::tuple<int, int, int> >* seen, int step, int x, int y) {
    auto t = std::make_tuple(step, x, y);
    if (!seen->contains(t)) {
        q->push(t);
        seen->insert(t);
    }
}

int bfs_min_steps(Grid* grid, int start_step, int start_x, int start_y, int end_x, int end_y) {
    std::queue<std::tuple<int, int, int> > q;  // step, x, y
    std::set<std::tuple<int, int, int> > seen;
    q.push(std::make_tuple(start_step, start_x, start_y));
    while (true) {
        std::tuple<int, int, int> s = q.front();
        q.pop();
        int step = std::get<0>(s);
        int x = std::get<1>(s);
        int y = std::get<2>(s);

        if ((x == end_x) && (y == end_y)) {
            std::cout << "RESULT (" << x << "," << y << ") at step " << step << std::endl;
            return step;
        }
        // Add down
        if (y < grid->h - 1) {
            if (!grid->is_blizzard(x, y + 1, step + 1)) {
                push_if_not_seen(&q, &seen, step + 1, x, y + 1);
            }
        }
        // Add right
        if (y >= 0 && y < grid->h && x < grid->w - 1) {
            if (!grid->is_blizzard(x + 1, y, step + 1)) {
                push_if_not_seen(&q, &seen, step + 1, x + 1, y);
            }
        }
        // Add up
        if (y > 0) {
            if (!grid->is_blizzard(x, y - 1, step + 1)) {
                push_if_not_seen(&q, &seen, step + 1, x, y - 1);
            }
        }
        // Add left
        if (y >= 0 && y < grid->h && x > 0) {
            if (!grid->is_blizzard(x - 1, y, step + 1)) {
                push_if_not_seen(&q, &seen, step + 1, x - 1, y);
            }
        }
        // Add wait
        if (!grid->is_blizzard(x, y, step + 1)) {
            q.push(std::make_tuple(step + 1, x, y));
        }
    }
}