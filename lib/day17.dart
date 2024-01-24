import 'dart:io';
import 'dart:convert';
import 'package:collection/collection.dart';

import 'common.dart';
import 'day.dart';
import 'solution_check.dart';

class Cell {
  int heat = 0;
  Cell(this.heat);
}

int IdOfVisitedItem(int x, int y, int xOff, int yOff, int steps) {
  return x
      + y * 1000
      + (xOff + 1) * 1000000 // xOff and yOff adjusted by 1, then multiplied by 10^6
      + (yOff + 1) * 10000000 // to avoid overlap with x and y
      + steps * 100000000; // steps multiplied by 10^8
}

class VisitedItem {
  final int x;
  final int y;
  final int xOff;
  final int yOff;
  final int steps;
  final int heatFromStart;

  const VisitedItem(
      this.x, this.y, this.heatFromStart, this.xOff, this.yOff, this.steps);

  int id() {
    return IdOfVisitedItem(x, y, xOff, yOff, steps);
  }
}

typedef CellMap = List<List<Cell>>;

@DayTag()
class Day17 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static CellMap parseData(var data) {
    var cellMap = CellMap.empty(growable: true);
    LineSplitter()
        .convert(data)
    .forEach((line) {
      var list = <Cell>[];
      line.runes.forEach((rune) {
        list.add(Cell(rune - '0'.codeUnitAt(0)));
      });
      cellMap.add(list);
    });
    return cellMap;
  }

  int solve(CellMap data, {var part2 = false}) {
    int total = 0;

    PriorityQueue<VisitedItem> unvisited = PriorityQueue((a, b) {
      if (a.heatFromStart != b.heatFromStart) {
        return a.heatFromStart - b.heatFromStart;
      }
      if (a.y != b.y) {
        return a.y - b.y;
      }
      if (a.x != b.x) {
        return a.x - b.x;
      }
      if (a.yOff != b.yOff) {
        return a.yOff - b.yOff;
      }
      if (a.xOff != b.xOff) {
        return a.xOff - b.xOff;
      }
      return a.steps - b.steps;
    });

    unvisited.add(VisitedItem(0,0, 0, 0,0, 1));
    var visited = <int>{};

    var width = data[0].length-1;
    var height = data.length-1;

    void tryAddNextPathNode(int xOff, int yOff, VisitedItem prevNodePos, int newSteps, bool part2) {
      var x = prevNodePos.x + xOff;
      var y = prevNodePos.y + yOff;
      if (x < 0 || x > width) {
        return;
      }
      if (y < 0 || y > height) {
        return;
      }

      var id = IdOfVisitedItem(x, y, xOff, yOff, newSteps);
      if (visited.contains(id))
        return;
      visited.add(id);

      var node = data[y][x];
      var newHeat = node.heat + prevNodePos.heatFromStart;
      unvisited.add(VisitedItem(x, y, newHeat, xOff, yOff, newSteps));
    }

    var dirs = [
      ImmutablePoint(-1,0),
      ImmutablePoint(1,0),
      ImmutablePoint(0,-1),
      ImmutablePoint(0,1),
    ];

    while(unvisited.isNotEmpty) {
      var nod = unvisited.removeFirst();

      if (nod.x == width && nod.y == height) {
        if (!part2 || nod.steps > 3) {
          total = nod.heatFromStart;
          break;
        }
      }

      for (var dir in dirs) {
        if (dir.x == nod.xOff && dir.y == nod.yOff) {
          if (nod.steps < (part2 ? 10 : 3))
            tryAddNextPathNode(nod.xOff, nod.yOff, nod, nod.steps + 1, part2);
        }
        else {
          if (dir.x != -nod.xOff || dir.y != -nod.yOff) {
           if (!part2 || nod.steps > 3 || (nod.xOff == 0 && nod.yOff == 0)) {
             tryAddNextPathNode(dir.x, dir.y, nod, 1, part2);
           }
          }
        }
      }
    }

    return total;
  }

  @override
  Future<void> run() async {
    print("Day17");

    var data = readData("../adventofcode_input/2023/data/day17.txt");

    var res1 = solve(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2023/data/day17_result.txt", 0));

    var res2 = solve(data, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2023/data/day17_result.txt", 1));
  }
}
