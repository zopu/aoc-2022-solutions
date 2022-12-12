import 'utils.dart';

class Grid {
  Point size = Point(0, 0);
  Point start = Point(0, 0);
  Point end = Point(0, 0);

  List<String> heightMap = [];

  void printMe() {
    for (final line in heightMap) {
      print(line);
    }
    print('Size:  ${size.x},${size.y}');
    print('Start: ${start.x},${start.y}');
    print('End:   ${end.x},${end.y}');
  }

  void addLine(line) {
    for (var i = 0; i < line.length; ++i) {
      if (line[i] == "S") {
        start.x = i;
        start.y = heightMap.length;
      }
      if (line[i] == "E") {
        end.x = i;
        end.y = heightMap.length;
      }
    }
    line = line.replaceAll("S", "a");
    line = line.replaceAll("E", "z");
    heightMap.add(line);
    size.y += 1;
    size.x = heightMap[0].length;
  }

  int heightAt(int x, int y) {
    return heightMap[y].codeUnitAt(x);
  }
}
