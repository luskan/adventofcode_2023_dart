import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'common.dart';
import 'day.dart';
import 'solution_check.dart';

@DayTag()
class Day06 extends Day with ProblemReader, SolutionCheck {
  static List<List<int>> readData(String filePath, {bool part2 = false}) {
    final fileContent = File(filePath).readAsStringSync();
    return parseData(fileContent, part2: part2);
  }

  static List<List<int>> parseData(String data, {bool part2 = false}) {
    final result = <List<int>>[];
    final regex = RegExp(r"(Time|Distance):([\d ]+)");
    for (final match in regex.allMatches(data)) {
      final numbers = part2 ?
        match.group(2)!.replaceAll(' ', '').split(' ')
        :  match.group(2)!.trim().split(' ');
      final entries = numbers.where((n) => n.isNotEmpty)
          .map((n) => int.parse(n))
          .toList();
      result.add(entries);
    }
    return result;
  }

  int solve(List<List<int>> data, {bool part2 = false}) {
    var total = 1;
    for (var i = 0; i < data[0].length; i++) {
      final raceTime = data[0][i];
      final recordDistance = data[1][i];
      var winsCount = 0;

      for (var holdTime = 1; holdTime < raceTime; holdTime++) {
        final timeRemaining = raceTime - holdTime;
        final distance = holdTime * timeRemaining;

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
