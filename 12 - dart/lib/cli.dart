import 'dart:convert';
import 'dart:io';
import 'package:cli/reachmap.dart';
import 'package:cli/utils.dart';

import 'grid.dart';

Future<void> run() async {
  final lines = utf8.decoder
      .bind(File('input.txt').openRead())
      .transform(const LineSplitter());

  var grid = Grid();
  await for (final line in lines) {
    grid.addLine(line);
  }
  print('${grid.start.x},${grid.start.y}');

  var reachMap = ReachMap(grid);
  reachMap.set(grid.start, 0);
  while (!reachMap.is_reachable(grid.end)) {
    reachMap.update();
  }

  print("Part 1:");
  int part1 = reachMap.map[grid.end.y][grid.end.x];
  print(part1);

  reachMap = ReachMap(grid);
  for (int i = 0; i < grid.size.x; ++i) {
    for (int j = 0; j < grid.size.y; ++j) {
      if (grid.heightAt(i, j) == "a".codeUnitAt(0)) {
        reachMap.set(Point(i, j), 0);
      }
    }
  }
  for (int i = 0; i < part1; ++i) {
    reachMap.update();
  }

  print("Part 2:");
  print(reachMap.map[grid.end.y][grid.end.x]);
}
