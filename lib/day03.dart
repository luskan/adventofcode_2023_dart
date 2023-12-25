import 'dart:io';
import 'dart:convert';

import 'common.dart';
import 'day.dart';
import 'solution_check.dart';

@DayTag()
class Day03 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static const int empty = -1;
  static int gear = "*".codeUnitAt(0);

  static List<List<int>> parseData(var data) {
    /**
     * I am parsing to int-s for efficiency and easy way to compare values.
     * empty (-1) is for .
     * digits are changed to actual ints
     * symbols are changed to their code units
     */
    return LineSplitter()
        .convert(data)
        .map((e) => e.split('').map((e) {
          if (e == '.') return empty;
          if (int.tryParse(e) != null) return int.parse(e);
          return e.codeUnitAt(0);
        }).toList()).toList();
  }

  /**
   * Safely check if x,y is in data, and returns its value
   * This way I can easily scan even negative y or x. This
   * makes loops easier to write.
   */
  int getAt(List<List<int>> data, int x, int y) {
    if (x < 0 || x >= data[0].length)
      return empty;
    if (y < 0 || y >= data.length)
      return empty;
    return data[y][x];
  }

  /**
   * Adds gear number to gearsMap. key is x+y*line_length.
   * This is for part 2
   */
  void addGear(Map<int, List<int>> gearsMap, int key, int number) {
    if (gearsMap.containsKey(key)) {
      gearsMap[key]?.add(number);
    } else {
      gearsMap[key] = [number];
    }
  }

  int solve(List<List<int>> data, {var part2 = false}) {

    // Gear map is for part 2.
    // key is x+y*line_length and represents single *
    // all its nearby numbers (parts) are added to the list
    var gearsMap = <int, List<int>>{};

    int total = 0;

    // Iterate each line and find numbers
    for (var y = 0; y < data.length; ++y) {
      var line = data[y];
      for (var x = 0; x < line.length; ++x) {
        var c = line[x];
        if (c == empty || c > 9)
          continue;

        // find the number
        var xr = x;
        var number = 0;
        while (true) {
          var c = getAt(data, xr, y);
          if (c == empty || c > 9)
            break;
          number = number * 10 + c;
          xr++;
          if (xr == line.length) {
            break;
          }
        }
        xr--;

        // now check around this number for c>9 which means its a symbol
        var foundSymbol = false;
        for(var yy = y - 1; yy <= y + 1; ++yy) {
          for(var xx = x - 1; xx <= xr + 1; xx++) {
            var c = getAt(data, xx, yy);
            if (c <= 9)
              continue; // its either empty or number
            if (part2) {
              // Here I check if we have a gear *. and if so, add this number to the list
              if (c == gear) {
                addGear(gearsMap, xx + yy * data.length, number);
                foundSymbol = true; // It appears we dont need to check more
                break;
              }
            }
            else {
              // This is for part1
              // If here, then any symbol was found so we can add the number
              foundSymbol = true;
              total += number;
              break;
            }
          }
          if (foundSymbol)
            break;
        }
        x = xr;
      }
    }

    if (part2) {
      // Multiply and add all the numbers in gearsMap
      total += gearsMap
          .values
          .where((gears) => gears.length >= 2) //yes, more than two parts can be connected
          .fold(0, (acc, gears) => acc + gears.reduce((a, b) => a * b));
    }

    return total;
  }

  @override
  Future<void> run() async {
    print("Day03");

    var data = readData("../adventofcode_input/2023/data/day03.txt");

    var res1 = solve(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2023/data/day03_result.txt", 0));

    var res2 = solve(data, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2023/data/day03_result.txt", 1));
  }
}
