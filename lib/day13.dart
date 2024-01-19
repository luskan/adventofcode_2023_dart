import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'common.dart';
import 'day.dart';
import 'solution_check.dart';

class Image {
  List<List<int>> raw = [];

  Image();
}

@DayTag()
class Day13 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static List<Image> parseData(var data) {
    List<Image> res = [];
    res.add(Image());
    LineSplitter()
        .convert(data)
        .map((e) => e.split('').map((e) => e == '.' ? 0 : 1).toList())
        .forEach((element) {
          if(element.isEmpty)
            res.add(Image());
          else
            res.last.raw.add(element);
    });
    return res;
  }

  int solve(List<Image> data, {var part2 = false}) {
    int total = 0;

    for (var img in data) {

      // Vertical check
      bool verticalFound = false;
      for (int x = 0; x < img.raw[0].length-1; ++x) {
        bool success = true;
        for (int dist = 0; dist < img.raw[0].length && success; ++dist) {
          int off1 = x - dist;
          int off2 = x + dist + 1;
          if (off1 < 0 || off2 >= img.raw[0].length) {
            break;
          }
          for (int y = 0; y < img.raw.length; ++y) {
            if (img.raw[y][off1] != img.raw[y][off2]) {
              success = false;
              break;
            }
          }
        }
        if (success) {
          total += x+1;
          verticalFound = true;
          break;
        }
      }

      //if (!verticalFound)
      {
        bool horizontalFound = false;
        for (int y = 0; y < img.raw.length - 1; ++y) {
          bool success = true;
          for (int dist = 0; dist < img.raw.length &&
              success; ++dist) {
            int off1 = y - dist;
            int off2 = y + dist + 1;
            if (off1 < 0 || off2 >= img.raw.length) {
              break;
            }
            for (int x = 0; x < img.raw[0].length; ++x) {
              if (img.raw[off1][x] != img.raw[off2][x]) {
                success = false;
                break;
              }
            }
          }
          if (success) {
            total += (y+1) * 100;
            horizontalFound = true;
            break;
          }
        }
      }

    }

    return total;
  }

  @override
  Future<void> run() async {
    print("Day13");

    var data = readData("../adventofcode_input/2023/data/day13.txt");

    var res1 = solve(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2023/data/day13_result.txt", 0));

    //var res2 = solve(data, part2: true);
    //print('Part2: $res2');
    //verifyResult(res2, getIntFromFile("../adventofcode_input/2023/data/day13_result.txt", 1));
  }
}
