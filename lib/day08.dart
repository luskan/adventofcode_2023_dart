import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'common.dart';
import 'day.dart';
import 'solution_check.dart';
import 'package:collection/collection.dart';

enum Direction {
  Left,
  Right
}

final IndexSpace = 'Z'.codeUnitAt(0) - '0'.codeUnitAt(0) + 1;
final totalSpace = IndexSpace * IndexSpace * IndexSpace;

class MapData {
  List<Direction> route = [];
  List<List<int>> map = List.generate(totalSpace, (i) => [-1, -1, 0]);
}

@DayTag()
class Day08 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static int StrIdToIndex(String name) {
    var i1 = name.codeUnitAt(0) - '0'.codeUnitAt(0);
    var i2 = name.codeUnitAt(1) - '0'.codeUnitAt(0);
    var i3 = name.codeUnitAt(2) - '0'.codeUnitAt(0);
    var index = i1*IndexSpace*IndexSpace + i2*IndexSpace + i3;
    if (index < 0 || index >= totalSpace) {
      throw ArgumentError('Index out of valid range.');
    }
    return index;
  }

  static String indexToStrId(int index) {
    if (index < 0 || index >= totalSpace) {
      throw ArgumentError('Index out of valid range.');
    }

    int i1 = index ~/ (IndexSpace * IndexSpace);
    int i2 = (index % (IndexSpace * IndexSpace)) ~/ IndexSpace;
    int i3 = index % IndexSpace;

    var char1 = String.fromCharCode(i1 + '0'.codeUnitAt(0));
    var char2 = String.fromCharCode(i2 + '0'.codeUnitAt(0));
    var char3 = String.fromCharCode(i3 + '0'.codeUnitAt(0));

    return char1 + char2 + char3;
  }

  static MapData parseData(var data) {
    var map = MapData();
    var rg = RegExp(r"([A-Z0-9]{3}) = \(([A-Z0-9]{3}), ([A-Z0-9]{3})\)");
    LineSplitter()
        .convert(data)
        .forEach((element) {
      if (element.isEmpty) {
        return;
      }
      if (map.route.isEmpty) {
        map.route = element.split('').map((e) => e == 'L' ? Direction.Left : Direction.Right).toList();
      } else {
        var match = rg.firstMatch(element)!;
        var c1 = match.group(1)!;
        var c2 = match.group(2)!;
        var c3 = match.group(3)!;
        int index = StrIdToIndex(c1);
        var ind1 = StrIdToIndex(c2);
        var ind2 = StrIdToIndex(c3);
        map.map[index][0] = ind1;
        map.map[index][1] = ind2;
      }
    });
    if (map.route.length != LineSplitter().convert(data)[0].length) {
      throw Exception("Invalid input data");
    }
    return map;
  }

  int solve(MapData mapData, {var part2 = false}) {
    int step = 0;
    var index = <int>[];
    var indexStart = <int>[];
    late List<int> indexZRouteIndex;

    if (part2) {
      for (var i = 0; i < mapData.map.length; i++) {
        var e = mapData.map[i];
        if (e[0] >= 0) {
          if((i % IndexSpace) + '0'.codeUnitAt(0) == 'A'.codeUnitAt(0)) {
            index.add(i);
            indexStart.add(i);
          }
        }
      }
      indexZRouteIndex = List.generate(index.length, (i) => 0);
    }
    else {
      index.add(StrIdToIndex('AAA'));
    }
    int end = StrIdToIndex('ZZZ');
    int routeIndex = 0;
    int zCU = 'Z'.codeUnitAt(0);
    int zeroCU = '0'.codeUnitAt(0);
    int totalEndingWithZ = 0;

    while(true) {
      if (part2) {

        // Check if given route is now at place ending with Z
        // If so, then remember count number of steps for this route.
        for (var i = 0; i < index.length; ++i) {
          if (index[i] % IndexSpace + zeroCU == zCU) {
            totalEndingWithZ++;
            if (indexZRouteIndex[i] == 0) {
              indexZRouteIndex[i] = step;
            }
          }
        }

        // If all the routes are at place ending with Z, then we are done.
        if (totalEndingWithZ == indexZRouteIndex.length) {
          // Each route will now cyclicaly do the same number of steps between current step and next __Z
          // Return the least common multiple of all the route steps.
          step = lcmOfList(indexZRouteIndex);
          break;
        }
      }
      else {
        // Check if we are at the end of the route
        if (index[0] == end)
          break;
      }

      // Move all the routes to the next step
      var route = mapData.route[routeIndex];
      routeIndex = (routeIndex + 1) % mapData.route.length;
      for (var i = 0; i < index.length; ++i) {
        index[i] = mapData.map[index[i]][route.index];
      }
      step++;
    }

    return step;
  }

  @override
  Future<void> run() async {
    print("Day08");

    var data = readData("../adventofcode_input/2023/data/Day08.txt");

    var res1 = solve(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2023/data/Day08_result.txt", 0));

    var res2 = solve(data, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2023/data/Day08_result.txt", 1));
  }
}
