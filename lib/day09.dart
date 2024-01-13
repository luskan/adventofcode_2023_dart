import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'common.dart';
import 'day.dart';
import 'solution_check.dart';

@DayTag()
class Day09 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static List<List<int>> parseData(var data) {
    return LineSplitter()
        .convert(data)
        .map((e) => e
              .split(' ')
              .map((e) => int.parse(e.trim()))
              .toList())
        .toList();
  }

  int solve(List<List<int>> data, {var part2 = false}) {
    int total = 0;

    for (var historyItem in data) {
      List<List<int>> tab = [historyItem];
      while (!tab.last.every((element) => element == 0)) {
        List<int> next = [];
        for (var i = 0; i < tab.last.length - 1; i++) {
          int v1 = tab.last[i];
          int v2 = tab.last[i + 1];
          next.add(v2 - v1);
        }
        tab.add(next);
      }

      //10  13  16  21  30  45  68
      //   3   3   5   9  15  23
      //     0   2   4   6   8
      //        2   2   2   2
      //          0   0   0

      if (!part2) {
        // Add 0 to the bottom most
        tab.last.add(0);

        // Iteratively sum previous row last with the next row last
        for (var i = tab.length - 1; i > 0; i--) {
          tab[i - 1].add(tab[i - 1].last + tab[i].last);
        }

        total += tab[0].last;
      }
      else {
        tab.last.insert(0, 0);
        for (var i = tab.length - 1; i > 0; i--) {
          var val = tab[i - 1].first - tab[i].first;
          tab[i - 1].insert(0, val);
        }

        total += tab[0].first;
      }
    }

    return total;
  }

  @override
  Future<void> run() async {
    print("Day09");

    var data = readData("../adventofcode_input/2023/data/day09.txt");

    var res1 = solve(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2023/data/day09_result.txt", 0));

    var res2 = solve(data, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2023/data/day09_result.txt", 1));
  }
}
