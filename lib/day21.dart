import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'common.dart';
import 'day.dart';
import 'solution_check.dart';

enum CellType { Start, Plot, Rock }

@DayTag()
class Day21 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static List<List<CellType>> parseData(var data) {
    return LineSplitter()
        .convert(data)
        .map((e) => e.split('').map((e) {
            CellType cell = e == 'S' ? CellType.Start : e == '.' ? CellType.Plot : CellType.Rock;
            return cell;
          }).toList()
      ).toList();
  }

  var dirs = <ImmutablePoint>[
    ImmutablePoint(-1, 0),
    ImmutablePoint(1, 0),
    ImmutablePoint(0, -1),
    ImmutablePoint(0, 1),
  ];

  /**
   * Step counter, on each step it uses previous step points to find new points. It uses visited array to avoid
   * counting the same point twice. This should work in BFS manner.
   *
   * I optimized it until the overall time was ~0.7s for both parts on my i7 laptop.
   */
  void countSteps(List<List<CellType>> data, bool part2, List<int> countsToCollect, List<int> countsCollected) {
    int width = data[0].length;
    int height = data.length;

    // Find start point
    Point start = Point(width~/2, height~/2);

    var points = <Point>[];
    int pointsCount = 0;
    var points2 = <Point>[];
    int points2Count = 0;

    points.add(start);
    pointsCount = 1;

    int step = 0;

    int maxSteps = countsToCollect.reduce((a, b) => a > b ? a : b);

    List<List<int>> visited = List.generate(maxSteps*5, (index) => List.filled(maxSteps*5, -1));

    for (; step <= maxSteps; ++step) {
      if (countsToCollect.contains(step)) {
        countsCollected.add(pointsCount);
      }

      points2Count = 0;

      for (var i = 0; i < pointsCount; ++i)
      {
        var point = points[i];
        for (var dir in dirs) {
          int x = point.x + dir.x;
          int y = point.y + dir.y;
          if (!part2) {
            if (x < 0 || x >= width || y < 0 ||
                y >= height) {
              continue;
            }
          }
          var newCell = data[y % height][x % width];
          if (newCell == CellType.Rock) {
            continue;
          }
          if (visited[y+maxSteps*2][x+maxSteps*2] == step) {
            continue;
          }
          visited[y+maxSteps*2][x+maxSteps*2] = step;

          if (points2Count >= points2.length)
            points2.add(new Point(x, y));
          else {
            points2[points2Count].x = x;
            points2[points2Count].y = y;
          }
          points2Count++;
        }
      }

      /*
      // Some helper code to analyze alternative aproach to part2 where blocks are counted instead.
      //
      // Visualize counts in first block. After reaching edge of the block, the counts will alternate (Flip/Flop)
      // For my data its (starting at step 131):
      // 131 - 7541
      // 132 - 7483
      // 133 - 7541
      // 134 - 7483
      // 135 - 7541
      // 136 - 7483
      int countInFirstBlock = points2.fold<int>(0, (acc, pt) =>
        (pt.x >= 0 && pt.y >= 0 && pt.x < width && pt.y < height) ? acc + 1 : acc);
      int countInFirstRightBlock = points2.fold<int>(0, (acc, pt) =>
      (pt.x >= width && pt.y >= 0 && pt.x < 2*width && pt.y < height) ? acc + 1 : acc);
      int countInSecondRightBlock = points2.fold<int>(0, (acc, pt) =>
      (pt.x >= 2*width && pt.y >= 0 && pt.x < 3*width && pt.y < height) ? acc + 1 : acc);

      print("$step - $countInFirstBlock, $countInFirstRightBlock, $countInSecondRightBlock ${countsToCollect.contains(step) ? " <----" : ""}");
      */

      var tmp = points;
      points = points2;
      points2 = tmp;

      var tmpi = pointsCount;
      pointsCount = points2Count;
      points2Count = tmpi;
    }
  }

  /**
   * I am not very proud of this solution, but in the end it works. It uses polynomial fitting (as suggested on reddit)
   * to find the solution for part2 - it should work for different input data (but not sample data). It executes in <1s,
   * for both parts.
   *
   * I tried to devise some more clever solution like counting number of steps in each block and then multiplying
   * it with the number of blocks, also taking account of the half/... blocks, but it was going to be very complicated,
   * as the number of blocks is not constant (they alternate - flip/flop depending of whether step is odd or even).
   */
  int solve(List<List<CellType>> data, {var part2 = false, var maxSteps = 64, var part2Input = false}) {
    int total = 0;

    //print("Solving ${part2 ? "part2" : "part1"}, maxSteps=$maxSteps");

    if (part2 && part2Input) {
      int width = data[0].length;
      var countsCollected = <int>[];
      int halfWidth = width~/2;
      countSteps(data, part2, [
                halfWidth,
        halfWidth + width,
        halfWidth + width * 2,
      ], countsCollected);

      var f0 = countsCollected[0];
      var f1 = countsCollected[1];
      var f2 = countsCollected[2];

      /*
      Solution found on reddit for this day. It works only for specific input data, it does not work for
      test cases.

      Solution uses polynomial fitting at point 0 for 65, 1 for 65+131, 2 for 65+131*2. It works because the
      distances between poins are the same (131). Points 0, 1, 2 for polynomial derivation is used because
      it makes the equation simpler.

      equation: f(x) = ax^2 + bx + c
      f(0) = a*0^2 + b * 0 + c  => f(0) = c
      f(1) = a*1^2 + b * 1 + c  => f(1) = a + b + c
      f(2) = a*2^2 + b * 2 + c  => f(2) = 4a + 2b + c

      f(0) = c
      f(1) = a + b + c
      f(2) = 4a + 2b + c

      a = (f(2) - 2*f(1) + f(0)) / 2
      b = f(1) - f(0) - a
      c = f(0)
      */

      var a = (f2 - (2 * f1) + f0) / 2;
      var b = f1 - f0 - a;
      var c = f0;
      var n = (26501365 - halfWidth) / width;

      total = ((a * (n*n)) + (b * n) + c).round();

      return total;
    }

    var countsCollected = <int>[];
    countSteps(data, part2, [maxSteps], countsCollected);
    total = countsCollected[0];

    return total;
  }

  @override
  Future<void> run() async {
    print("Day21");

    var data = readData("../adventofcode_input/2023/data/day21.txt");

    var res1 = solve(data, maxSteps: 64);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2023/data/day21_result.txt", 0));

    var res2 = solve(data, part2: true, maxSteps: 26501365, part2Input: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2023/data/day21_result.txt", 1));
  }
}
