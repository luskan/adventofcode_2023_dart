import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'common.dart';
import 'day.dart';
import 'solution_check.dart';

enum MapItemType {
  Ground,
  Rock,
  CubeRock
}

enum Direction {
  North, West, South, East
}

typedef MapType = List<List<MapItemType>>;

@DayTag()
class Day14 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static MapType parseData(var data) {
    return LineSplitter()
        .convert(data)
        .map((e) => e.split('').map((e) {
          if (e == ".") {
            return MapItemType.Ground;
          }
          if (e == "O") {
            return MapItemType.Rock;
          }
          if (e == "#") {
            return MapItemType.CubeRock;
          }
          throw Exception("Unknown field: $e");
    }).toList()).toList();
  }

  void _moveRockToSide(MapType data, Direction dir, Point pt) {
    var item = data[pt.y][pt.x];
    if (item != MapItemType.Rock)
      return;

    if (dir == Direction.North || dir == Direction.South) {
      int off = dir == Direction.North ? -1 : 1;
      int y_new = pt.y;
      for (int y = pt.y + off; y >= 0 && y < data.length; y += off) {
        if (data[y][pt.x] == MapItemType.Ground) {
          y_new = y;
        }
        else {
          break;
        }
      }
      if (y_new != pt.y) {
        data[pt.y][pt.x] = MapItemType.Ground;
        data[y_new][pt.x] = MapItemType.Rock;
      }
    }
    if (dir == Direction.West || dir == Direction.East) {
      int off = dir == Direction.West ? -1 : 1;
      int x_new = pt.x;
      for (int x = pt.x + off; x >= 0 && x < data[0].length; x += off) {
        if (data[pt.y][x] == MapItemType.Ground) {
          x_new = x;
        }
        else {
          break;
        }
      }
      if (x_new != pt.x) {
        data[pt.y][pt.x] = MapItemType.Ground;
        data[pt.y][x_new] = MapItemType.Rock;
      }
    }
  }

  int solve(MapType data, {var part2 = false}) {
    int total = 0;
    final int numberOfCycles = !part2 ? 1 : 1000000000;
    Point pt = Point(0, 0);

    List<int> weights = [];
    FoundCycle foundCycle = FoundCycle(0, 0, 0);

    for (int cycle = 0; cycle < numberOfCycles; ++cycle) {
      Direction dir = Direction.values[cycle % 4];
      switch(dir) {
        case Direction.North:
          pt.x = 0; pt.y = 0;
          for (pt.y = 0; pt.y < data.length; ++pt.y) {
            for (pt.x = 0; pt.x < data[0].length; ++pt.x) {
              _moveRockToSide(data, Direction.North, pt);
            }
          }
          break;
        case Direction.West:
          pt.x = 0; pt.y = 0;
          for (; pt.x < data[0].length; ++pt.x) {
            for (pt.y = 0; pt.y < data.length; ++pt.y) {
              _moveRockToSide(data, Direction.West, pt);
            }
          }
          break;
        case Direction.South:
          pt.x = 0; pt.y = data.length - 1;
          for (; pt.y >= 0; pt.y--) {
            for (pt.x = 0; pt.x < data[0].length; pt.x++) {
              _moveRockToSide(data, Direction.South, pt);
            }
          }
          break;
        case Direction.East:
          pt.x = data[0].length - 1; pt.y = 0;
          for (; pt.x >= 0; --pt.x) {
            for (pt.y = 0; pt.y < data.length; ++pt.y) {
              _moveRockToSide(data, Direction.East, pt);
            }
          }
          break;
      }

      if (cycle % 4 == 3 || !part2) {
        pt = Point(0, 0);
        var weight = 0;
        for (pt.y = 0; pt.y < data.length; ++pt.y) {
          for (pt.x = 0; pt.x < data[0].length; ++pt.x) {
            var item = data[pt.y][pt.x];
            if (item != MapItemType.Rock)
              continue;

            weight += (data.length - pt.y);
          }
        }
        if (!part2) {
          total += weight;
          break;
        }
        else {
          weights.add(weight);
          if (isCycleFound(weights, foundCycle) && foundCycle.cycleEnd == weights.length-1 && foundCycle.cycleLen > 1) {
            int startOff = weights.length - foundCycle.cycleLen*2;
            int resIndex = (numberOfCycles - startOff) % foundCycle.cycleLen;
            total = weights[startOff + resIndex - 1] ;
            break;
          }
        }
      }
    }

    return total;
  }

  @override
  Future<void> run() async {
    print("Day14");

    var data = readData("../adventofcode_input/2023/data/day14.txt");

    var res1 = solve(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2023/data/day14_result.txt", 0));

    var res2 = solve(data, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2023/data/day14_result.txt", 1));
  }
}
