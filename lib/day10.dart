import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'common.dart';
import 'day.dart';
import 'solution_check.dart';

@DayTag()
class Day10 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static List<String> parseData(var data) {
    return LineSplitter()
        .convert(data);
  }

  int solve(List<String> data, {var part2 = false}) {
    int total = 0;
    return total;
  }

  @override
  Future<void> run() async {
    print("Day10");

    var data = readData("../adventofcode_input/2023/data/day10.txt");

    var res1 = solve(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2023/data/day10_result.txt", 0));

    var res2 = solve(data, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2023/data/day10_result.txt", 1));
  }
}
