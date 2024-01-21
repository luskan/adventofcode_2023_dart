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

  void _moveRockToSide(MapType data, Direction dir, int x, int y) {
    if (data[y][x] != MapItemType.Rock) return;
    int dy = dir == Direction.North ? -1 : dir == Direction.South ? 1 : 0;
    int dx = dir == Direction.West ? -1 : dir == Direction.East ? 1 : 0;
    int newY = y+dy, newX = x + dx;
    while (newY >= 0 && newY < data.length && newX >= 0 && newX < data[0].length && data[newY][newX] == MapItemType.Ground) {
      newY += dy;
      newX += dx;
    }
    if (newY- dy != y || newX- dx != x) {
      data[y][x] = MapItemType.Ground;
      data[newY - dy][newX - dx] = MapItemType.Rock;
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
      int dx = (dir == Direction.East) ? -1 : (dir == Direction.West) ? 1 : 0;
      int dy = (dir == Direction.South) ? -1 : (dir == Direction.North) ? 1 : 0;
      pt.x = dir == Direction.East ? data[0].length - 1 : 0;
      pt.y = (dir == Direction.South) ? data.length - 1 : 0;
      switch(dir) {
        case Direction.North:
        case Direction.South:
          for (; pt.y < data.length && pt.y >= 0; pt.y += dy) {
            for (pt.x = 0; pt.x < data[0].length; ++pt.x) {
              _moveRockToSide(data, dir, pt.x, pt.y);
            }
          }
          break;
        case Direction.West:
        case Direction.East:
          for (;pt.x >= 0 && pt.x < data[0].length; pt.x += dx) {
            for (pt.y = 0; pt.y < data.length; ++pt.y) {
              _moveRockToSide(data, dir, pt.x, pt.y);
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
