import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'common.dart';
import 'day.dart';
import 'solution_check.dart';

class SpaceElement {
  int data;
  SpaceElement(this.data);
}

@DayTag()
class Day11 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static int SpaceEmpty = 0;
  static int SpaceWithGalaxy = 1;

  static List<List<SpaceElement>> parseData(var data) {
    return LineSplitter()
        .convert(data)
        .map((line) => line.split('').map((e) => SpaceElement(e == '#' ? SpaceWithGalaxy : SpaceEmpty)).toList()).toList();
  }

  int solve(List<List<SpaceElement>> data, int expandValue) {
    int total = 0;
    List<int> expandOnXValues = List.filled(data[0].length, 0);
    List<int> expandOnYValues = List.filled(data.length, 0);

    for (int y = 0; y < data.length; y++) {
      var line = data[y];
      if (line.every((element) => element.data == SpaceEmpty)) {
        expandOnYValues[y] = expandValue;
      }
    }

    for (int x = 0; x < data[0].length; x++) {

      // Check column if its all space
      if (data.every((element) => element[x].data == SpaceEmpty)) {
        expandOnXValues[x] = expandValue;
      }
    }

    // Find all galaxies and put them in a List<Point>
    List<Point> galaxies = [];
    for (int y = 0; y < data.length; y++) {
      for (int x = 0; x < data[y].length; x++) {
        if (data[y][x].data == SpaceWithGalaxy) {
          galaxies.add(Point(x, y));
        }
      }
    }

    // Calculate distance between all galaxies
    List<List<int>> distances = [];
    for (int i = 0; i < galaxies.length; i++) {
      distances.add([]);
      for (int j = 0; j < galaxies.length; j++) {
        var pt1 = galaxies[i];
        var pt2 = galaxies[j];
        var manhatanDistance = 0;//(pt1.x - pt2.x).abs() + (pt1.y - pt2.y).abs();

        int x1 = pt1.x;
        int x2 = pt2.x;
        int y1 = pt1.y;
        int y2 = pt2.y;

        if (x1 > x2) {
          x1 = pt2.x;
          x2 = pt1.x;
        }
        if (y1 > y2) {
          y1 = pt2.y;
          y2 = pt1.y;
        }

        // Now space expansionx on X
        for (int x = x1+1; x <= x2; x++) {
          manhatanDistance += expandOnXValues[x] == 0 ? 1 : expandOnXValues[x];
        }
        // Now space expansionx on Y
        for (int y = y1+1; y <= y2; y++) {
          manhatanDistance += expandOnYValues[y] == 0 ? 1 : expandOnYValues[y];
        }

        distances[i].add(manhatanDistance);
      }
    }

    // Sum all distances
    for (int i = 0; i < distances.length; i++) {
      for (int j = i+1; j < distances[i].length; j++) {
        total += distances[i][j];
      }
    }

    // Print distance between each galaxy
    /*
    for (int i = 0; i < distances.length; i++) {
      for (int j = 0; j < distances[i].length; j++) {
        print( "From ${i+1} to ${j+1} : " + distances[i][j].toString().padLeft(3));
      }
    }

     */

    return total;
  }

  @override
  Future<void> run() async {
    print("Day11");

    var data = readData("../adventofcode_input/2023/data/day11.txt");

    var res1 = solve(data, 2);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2023/data/day11_result.txt", 0));

    var res2 = solve(data, 1000000);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2023/data/day11_result.txt", 1));
  }
}
