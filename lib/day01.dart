import 'dart:io';
import 'dart:convert';
import 'package:adventofcode_2023/common.dart';

import 'day.dart';
import 'solution_check.dart';

@DayTag()
class Day01 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static List<String> parseData(var data) {
    return LineSplitter()
        .convert(data);
  }

  var digitNames = <List<dynamic>>[
    ["zero", 0], ["one", 1], ["two", 2], ["three", 3],
    ["four", 4], ["five", 5], ["six", 6], ["seven", 7],
    ["eight", 8], ["nine", 9]
  ];

  String replaceNamedDigits(String input) {
    var result = "";

    // Replace each named digit one by one. This is to catch all the cases
    // like twone, threeight etc.
    for (var i = 0; i < input.length; ++i) {
      var c = input[i];
      var num = int.tryParse(c);
      if (num != null) {
        result += c;
      }
      else {
        for (var digit in digitNames) {
          var digitName = digit[0] as String;
          if (input.startsWith(digitName, i)) {
            result += (digit[1] as int).toString();
            break;
          }
        }
      }
    }

    return result;
  }

  int solve(List<String> data, {var part2 = false}) {
    int total = 0;
    for (var line in data) {
      //iterate each character in line
      int first = -1;
      int last = -1;

      if (part2)
        line = replaceNamedDigits(line);

      for (var i = 0; i < line.length; i++) {
        var c = line[i];
        //check if c is digit
        var num = int.tryParse(c);
        if (num != null) {
          if (first == -1) {
            first = num;
          }
          last = num;
        }
      }
      var val = first * 10 + last;
      total += val;
    }
    return total;
  }

  int solve2(var data) {
    return 0;
  }

  @override
  Future<void> run() async {
    print("Day01");

    var data = readData("../adventofcode_input/2023/data/day01.txt");

    var res1 = solve(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2023/data/day01_result.txt", 0));

    var res2 = solve(data, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2023/data/day01_result.txt", 1));
  }
}
