import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'common.dart';
import 'day.dart';
import 'solution_check.dart';

@DayTag()
class Day06 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath, {var part2 = false}) {
    return parseData(File(filePath).readAsStringSync(), part2: part2);
  }

  static List<List<int>> parseData(var data, {var part2 = false}) {
    var res = <List<int>>[];
    RegExp(r"(Time|Distance):([\d ]+)").allMatches(data).forEach((m) {
      var entries = <int>[];
      var nums = m.group(2)!.trim();
      if (part2)
        nums = nums.replaceAll(' ', '');
      for (var d in nums.split(" ")) {
        if (d.isNotEmpty)
          entries.add(int.parse(d));
      }
      res.add(entries);
    });
    return res;
  }

  int solve(List<List<int>> data, {var part2 = false}) {
    int total = 1;
    for (var i = 0; i < data[0].length; i++) {
      var raceTime = data[0][i];
      var recordDistance = data[1][i];

      var winsCount = 0;

      for (int holdTime = 1; holdTime < raceTime; holdTime++) {

        var timeRemaining = raceTime - holdTime;
        var distance = holdTime * timeRemaining;

        if (distance > recordDistance) {
          winsCount++;
        }
      }

      total *= winsCount;

    }
    return total;
  }

  @override
  Future<void> run() async {
    print("Day06");

    var data = readData("../adventofcode_input/2023/data/day06.txt");

    var res1 = solve(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2023/data/day06_result.txt", 0));

    data = readData("../adventofcode_input/2023/data/day06.txt", part2: true);
    var res2 = solve(data, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2023/data/day06_result.txt", 1));
  }
}
