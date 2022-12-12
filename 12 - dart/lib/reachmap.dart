import "dart:io";
import 'dart:math';

import 'package:cli/grid.dart';
import 'utils.dart';

const int longerThanAnyRouteShouldBe = 10000;

class ReachMap {
  Point size = Point(0, 0);
  List<List<int>> map = [];
  Grid grid = Grid();

  ReachMap(Grid g) {
    grid = g;
    size = Point(g.size.x, g.size.y);
    for (int i = 0; i < size.y; ++i) {
      map.add(List.filled(size.x, longerThanAnyRouteShouldBe));
    }
  }

  set(Point location, int value) {
    map[location.y][location.x] = value;
  }

  // Runs one tick of updating the reach map
  // based on reachability of neighbouring locations
  update() {
    for (int i = 0; i < size.x; ++i) {
      for (int j = 0; j < size.y; ++j) {
        int height = grid.heightAt(i, j);

        // Check up
        if (j > 0) {
          int upHeight = grid.heightAt(i, j - 1);
          if (upHeight >= height - 1) {
            map[j][i] = min(map[j][i], map[j - 1][i] + 1);
          }
        }

        // Check down
        if (j < size.y - 1) {
          int downHeight = grid.heightAt(i, j + 1);
          if (downHeight >= height - 1) {
            map[j][i] = min(map[j][i], map[j + 1][i] + 1);
          }
        }

        // Check left
        if (i > 0) {
          int leftHeight = grid.heightAt(i - 1, j);
          if (leftHeight >= height - 1) {
            map[j][i] = min(map[j][i], map[j][i - 1] + 1);
          }
        }

        // Check right
        if (i < size.x - 1) {
          int rightHeight = grid.heightAt(i + 1, j);
          if (rightHeight >= height - 1) {
            map[j][i] = min(map[j][i], map[j][i + 1] + 1);
          }
        }
      }
    }
  }

  is_reachable(Point p) {
    return map[p.y][p.x] < longerThanAnyRouteShouldBe;
  }

  printMe() {
    for (int i = 0; i < size.y; ++i) {
      for (int j = 0; j < size.x; ++j) {
        if (map[i][j] == longerThanAnyRouteShouldBe) {
          stdout.write("x");
        } else {
          stdout.write(map[i][j]);
        }
        stdout.write(".");
      }
      stdout.write("\n");
    }
  }
}
