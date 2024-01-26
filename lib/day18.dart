import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'common.dart';
import 'day.dart';
import 'solution_check.dart';

enum Turn { Left, Right, Up, Down }

class DigItem {
  Turn turn;
  int steps;
  int color;

  DigItem(this.turn, this.steps, this.color);
}

@DayTag()
class Day18 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath, var part2) {
    return part2 ? parseData2(File(filePath).readAsStringSync()) : parseData(File(filePath).readAsStringSync());
  }

  static List<DigItem> parseData(var data) {
    //R 6 (#70c710)
    var rg = RegExp(r'^(?<turn>\w)\s(?<steps>\d+)\s\((?<color>#[0-9a-f]{6})\)$');
    return LineSplitter()
        .convert(data)
        .map((e) {
          var m = rg.firstMatch(e);
          var turn = m?.namedGroup("turn") ?? "";
          var stepsStr = m?.namedGroup("steps") ?? "0";
          var steps = stepsStr.isEmpty ? 0 : int.parse(stepsStr);
          var color = m?.namedGroup("color") ?? "#000000";
          Turn turnEnum;
          switch (turn) {
            case "R":
              turnEnum = Turn.Right;
              break;
            case "L":
              turnEnum = Turn.Left;
              break;
            case "U":
              turnEnum = Turn.Up;
              break;
            case "D":
              turnEnum = Turn.Down;
              break;
            default:
              throw Exception("Unknown turn: $turn");
          }

          return DigItem(
              turnEnum, steps, int.parse(color.substring(1), radix: 16));
        })
        .toList();
  }

  static List<DigItem> parseData2(var data) {
    //R 6 (#70c710)
    var rg = RegExp(r'^(?<turn>\w)\s(?<steps>\d+)\s\((?<realsteps>#[0-9a-f]{5})(?<realturn>\d)\)$');
    return LineSplitter()
        .convert(data)
        .map((e) {
      var m = rg.firstMatch(e);
      var turn = m?.namedGroup("turn") ?? "";
      var stepsStr = m?.namedGroup("steps") ?? "0";
      var steps = stepsStr.isEmpty ? 0 : int.parse(stepsStr);
      var realsteps = m?.namedGroup("realsteps") ?? "#00000";
      var realturn = m?.namedGroup("realturn") ?? "0";
      Turn turnEnum;
      switch (realturn) {
        case "0":
          turnEnum = Turn.Right;
          break;
        case "1":
          turnEnum = Turn.Down;
          break;
        case "2":
          turnEnum = Turn.Left;
          break;
        case "3":
          turnEnum = Turn.Up;
          break;
        default:
          throw Exception("Unknown turn: $turn");
      }

      return DigItem(
          turnEnum, int.parse(realsteps.substring(1), radix: 16), 0);
    })
        .toList();
  }


  // Uses sholace algorithm to compute the interior points, and then the
  // Pick's theorem to compute the total area.
  int solveV2(List<DigItem> data, {var part2 = false}) {
    int total = 0;

    var turnDirs = <Turn, ImmutablePoint>{
      Turn.Left: ImmutablePoint(-1, 0),
      Turn.Right: ImmutablePoint(1, 0),
      Turn.Up: ImmutablePoint(0, -1),
      Turn.Down: ImmutablePoint(0, 1),
    };

    var polygon = <ImmutablePoint>[];
    ImmutablePoint lastPos = ImmutablePoint(0, 0);
    polygon.add(lastPos);

    int edge = 0;

    // Collect all points and also compute the edge length.
    for (var it in data) {
      var dir = turnDirs[it.turn]!;
      lastPos = ImmutablePoint(lastPos.x + dir.x * it.steps,
          lastPos.y + dir.y * it.steps);
      edge += it.steps;
      polygon.add(lastPos);
    }

    // Shoelace formula
    // https://en.wikipedia.org/wiki/Shoelace_formula
    var area = polygonArea(polygon);

    // Pick's theorem
    // https://en.wikipedia.org/wiki/Pick%27s_theorem#
    var interiorPoints = area - edge~/2 + 1;

    total = edge + interiorPoints;

    return total;
  }


  int polygonArea(List<ImmutablePoint> points) {
    var area = 0;
    int j = points.length - 1;  // The last vertex is the 'previous' one to the first

    for (int i = 0; i < points.length; i++) {
      area += (points[j].x + points[i].x) * (points[j].y - points[i].y);
      j = i;  // j is previous vertex to i
    }

    return area.abs() ~/ 2;
  }

  // Works very fast for part 1, but too slow for part 2 (actually I naver waited for it to finish).
  // Fills map with each box, then flood fills from outside. The result is the total area of the
  // bounding box of the map minus the area of the outside.
  //
  // This is the contour of the input data (boundary is +1 to allow for a floodfill):
  // .........
  // .#######.
  // .#.....#.
  // .###...#.
  // ...#...#.
  // ...#...#.
  // .###.###.
  // .#...#...
  // .##..###.
  // ..#....#.
  // ..######.
  // .........
  //
  // And the flood filled map of . which are outside of it:
  // #########
  // #.......#
  // #.......#
  // #.......#
  // ###.....#
  // #.......#
  // #.......#
  // #......##
  // #.......#
  // #.......#
  // #.......#
  // #..######
  int solve(List<DigItem> data, {var part2 = false}) {
    int total = 0;
    var map = <ImmutablePoint, int>{};

    var turnDirs = <Turn, ImmutablePoint>{
      Turn.Left: ImmutablePoint(-1, 0),
      Turn.Right: ImmutablePoint(1, 0),
      Turn.Up: ImmutablePoint(0, -1),
      Turn.Down: ImmutablePoint(0, 1),
    };
    ImmutablePoint lastPos = ImmutablePoint(0, 0);
    map[lastPos] = 0;
    Point minPos = Point(maxInt, maxInt);
    Point maxPos = Point(minInt, minInt);
    for (var it in data) {
      var dir = turnDirs[it.turn]!;
      for (var i = 0; i < it.steps; i++) {
        var p = ImmutablePoint(lastPos.x + dir.x * i, lastPos.y + dir.y * i);
        minPos = Point(min(minPos.x, p.x), min(minPos.y, p.y));
        maxPos = Point(max(maxPos.x, p.x), max(maxPos.y, p.y));
        map[p] = it.color;
      }
      lastPos = ImmutablePoint(lastPos.x + dir.x * it.steps,
          lastPos.y + dir.y * it.steps);
    }

    minPos.x--;
    minPos.y--;
    maxPos.x++;
    maxPos.y++;

    // Draw map
    ///*
      for (var y = minPos.y; y <= maxPos.y; ++y) {
        var line = "";
        for (var x = minPos.x; x <= maxPos.x; ++x) {
          var p = ImmutablePoint(x, y);
          if (map.containsKey(p)) {
            line += "#";
          }
          else {
            line += ".";
          }
        }
        print(line);
      }
//*/
    var stack = <ImmutablePoint>[]; // stack of points to flood fill
    var filledMap= <IPoint, int>{};

    var dirs = [
      ImmutablePoint(-1,0),
      ImmutablePoint(1,0),
      ImmutablePoint(0,-1),
      ImmutablePoint(0,1),
    ];

    stack.add(ImmutablePoint(minPos.x, maxPos.y));
    var visited = <ImmutablePoint>{};
    int outsideArea = 0;
    while (stack.isNotEmpty) {
      var pt = stack.removeLast();

      for (var dir in dirs) {
        var p = pt + dir;
        if (p.x < minPos.x || p.x > maxPos.x) continue;
        if (p.y < minPos.y || p.y > maxPos.y) continue;
        if (visited.contains(p))
          continue;
        visited.add(p);
        if (map.containsKey(p))
          continue;
        outsideArea++;
        filledMap[pt] = 1;
        stack.add(p);
      }
    }

    print("");

    // Draw map
    for (var y = minPos.y; y <= maxPos.y; ++y) {
      var line = "";
      for (var x = minPos.x; x <= maxPos.x; ++x) {
        var p = ImmutablePoint(x, y);
        if (filledMap.containsKey(p)) {
          line += "#";
        }
        else {
          line += ".";
        }
      }
      print(line);
    }

    int totalArea = (maxPos.x - minPos.x + 1) * (maxPos.y - minPos.y + 1);
    print("Total area: $totalArea");
    print("Outside area: $outsideArea");
    print("Edge: ${map.length}");
    total = totalArea - outsideArea;

    return total;
  }

  @override
  Future<void> run() async {
    print("Day18");

    var data = readData("../adventofcode_input/2023/data/day18.txt", false);

    var res1 = solveV2(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2023/data/day18_result.txt", 0));

    data = readData("../adventofcode_input/2023/data/day18.txt", true);
    var res2 = solveV2(data, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2023/data/day18_result.txt", 1));
  }

}
