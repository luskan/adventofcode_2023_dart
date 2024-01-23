import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'common.dart';
import 'day.dart';
import 'solution_check.dart';

class Lense {
  String label;
  int focal;

  Lense(this.label, this.focal);


}

class Box {
  List<Lense> lenses = [];

  void replaceOrAdd(Lense lense) {
    bool found = false;
    for (var e in lenses) {
      if (e.label == lense.label) {
        e.focal = lense.focal;
        found = true;
        break;
      }
    }
    if (!found)
      lenses.add(lense);
  }

  void removeByLabel(String label) {
    lenses.removeWhere((element) {
      return element.label == label;
    });
  }
}

@DayTag()
class Day15 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static List<String> parseData(String data) {
    return data.replaceAll('\n', '').split(',').toList();
  }

  int calculateHash(String s) {
    int val = 0;
    for (var i = 0; i < s.length; ++i) {
      var cu = s.codeUnitAt(i);
      val += cu;
      val = val * 17;
      val = val % 256;
    }
    return val;
  }

  int solve(List<String> data, {var part2 = false}) {
    int total = 0;
    if (!part2) {
      for (var s in data) {
        total += calculateHash(s);
      }
    }
    else {
      var boxes = List<Box>.generate(256, (index) => Box());
      var rg = RegExp(r'[=-]');
      for (var s in data) {
        var cmd = s.split(rg);
        var boxId = calculateHash(cmd[0]);
        if (s.endsWith('-')) {
          boxes[boxId].removeByLabel(cmd[0]);
        }
        else {
          var lense = Lense(cmd[0], int.parse(cmd[1]));
          boxes[boxId].replaceOrAdd(lense);
        }
      }

      for (int id = 0; id < boxes.length; ++id) {
        var box = boxes[id];
        for (int ind = 0; ind < box.lenses.length; ++ind) {
          total += (id + 1) * (ind + 1) * box.lenses[ind].focal;
        }
      }
    }
    return total;
  }

  @override
  Future<void> run() async {
    print("Day15");

    var data = readData("../adventofcode_input/2023/data/day15.txt");

    var res1 = solve(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2023/data/day15_result.txt", 0));

    var res2 = solve(data, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2023/data/day15_result.txt", 1));
  }
}
