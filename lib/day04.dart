import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'common.dart';
import 'day.dart';
import 'solution_check.dart';

class Card {
  int id;
  int count;
  List<int> winning;
  List<int> numbers;
  Card(this.id, this.count, this.numbers, this.winning);
}

@DayTag()
class Day04 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static List<Card> parseData(var data) {
    //Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
    var rg = RegExp(r'Card\s*(\d+):\s*([\s\d]+)\s*\|\s*([\s\d]+)\s*');
    return LineSplitter()
        .convert(data)
        .map((e)
          {
            var id = 0;
            var winning = <int>[];
            var numbers = <int>[];

            var match = rg.firstMatch(e);
            id = int.parse(match!.group(1)!);
            for (var s in match.group(2)!.split(' ')) {
              if (s.isNotEmpty)
                winning.add(int.parse(s));
            }
            for (var s in match.group(3)!.split(' ')) {
              if (s.isNotEmpty)
                numbers.add(int.parse(s));
            }

            return Card(id, 1, numbers, winning);
          }
    ).toList();
  }

  int solve(List<Card> data, {var part2 = false}) {
    int total = 0;

    var winningNumbers = <int>[];
    for (var card in data) {
      winningNumbers.clear();
      for (var n in card.numbers) {
        if (card.winning.contains(n)) {
          winningNumbers.add(n);
        }
      }
      if (part2) {
        for (var k = 0; k < winningNumbers.length; k++) {
          var nextId = card.id+k+1;
          if (nextId-1 < data.length)
            data[nextId-1].count+=card.count;
        }
        total += card.count;
      }
      else {
        total += pow(2, winningNumbers.length - 1).toInt();
      }
    }

    return total;
  }

  @override
  Future<void> run() async {
    print("Day04");

    var data = readData("../adventofcode_input/2023/data/day04.txt");

    var res1 = solve(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2023/data/day04_result.txt", 0));

    var res2 = solve(data, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2023/data/day04_result.txt", 1));
  }
}
