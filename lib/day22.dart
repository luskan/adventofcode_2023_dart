import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'common.dart';
import 'day.dart';
import 'solution_check.dart';

class Brick {
  ImmutablePoint3 pt1;
  ImmutablePoint3 pt2;

  ImmutablePoint3 pt1Org = ImmutablePoint3(0,0,0);
  ImmutablePoint3 pt2Org = ImmutablePoint3(0,0,0);

  bool restore = false;

  void markToRestore() {
    restore = true;
  }

  void saveOrg() {
    pt1Org = ImmutablePoint3(pt1.x, pt1.y, pt1.z);
    pt2Org = ImmutablePoint3(pt2.x, pt2.y, pt2.z);
  }
  void restoreFromOrg() {
    pt1 = ImmutablePoint3(pt1Org.x, pt1Org.y, pt1Org.z);
    pt2 = ImmutablePoint3(pt2Org.x, pt2Org.y, pt2Org.z);
    restore = false;
  }

  String name;
  Brick(this.name, this.pt1, this.pt2);
}

@DayTag()
class Day22 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static List<Brick> parseData(var data) {
    /*1,0,1~1,2,1*/
    int n = 0;
    var res = LineSplitter()
        .convert(data)
        .map((e) {
          var parts = e.split("~");
          var pt1 = parts[0].split(",").map((e) => int.parse(e)).toList();
          var pt2 = parts[1].split(",").map((e) => int.parse(e)).toList();
          var brick = Brick(numberToLetters(n++), ImmutablePoint3(pt1[0], pt1[1], pt1[2]), ImmutablePoint3(pt2[0], pt2[1], pt2[2]));
          assert(brick.pt1.z <= brick.pt2.z);
          return brick;
        }).toList();
    res.sort((a, b) => a.pt1.z - b.pt1.z);
    return res;
  }

  bool _isCollision(Brick brick1, Brick brick2) {
    if (brick1.pt1.z > brick2.pt2.z) return false;
    if (brick1.pt2.z < brick2.pt1.z) return false;
    if (brick1.pt1.x > brick2.pt2.x) return false;
    if (brick1.pt2.x < brick2.pt1.x) return false;
    if (brick1.pt1.y > brick2.pt2.y) return false;
    if (brick1.pt2.y < brick2.pt1.y) return false;
    return true;
  }



  int _settleDownBricks(List<Brick> data,  {var test = false, var ignoreBrick = -1, var startBrick = 0, var failFast = false, var restoreOnDone = false}) {

    var byZMapOfBrickIndexes = <int, List<int>>{};
    for (var i = 0; i < data.length; i++) {
      var brick = data[i];
      if (!byZMapOfBrickIndexes.containsKey(brick.pt2.z)) {
        byZMapOfBrickIndexes[brick.pt2.z] = <int>[];
      }
      byZMapOfBrickIndexes[brick.pt2.z]!.add(i);
    }

    List<int> movedBrickTops = [];
    List<int> movedBrickMaxX = [];
    if (ignoreBrick != -1) {
      var ignoredBrick = data[ignoreBrick];
      movedBrickTops.add(ignoredBrick.pt2.z);
    }
    List<int> toRestoreIndexes = [];

    // Starting from the bottom most brick, move it along z down, as far as possible to the bottom, but no lower
    // than any other brick colliding with it.
    // Then move to the next brick, and repeat.
    Brick testBrick = Brick('?', ImmutablePoint3(0,0,0), ImmutablePoint3(0,0,0));
    int movedBricks = 0;
    for (var i = startBrick; i < data.length; i++) {
      if (i == ignoreBrick)
        continue;
      var brick = data[i];
      if (brick.pt1.z == 1)
        continue;

      if (ignoreBrick != -1 && failFast) {
        var ignoredBrick = data[ignoreBrick];
        if (ignoredBrick.pt2.z < brick.pt1.z-1 ) {
          break;;
        }
      }

      if (movedBrickTops.isNotEmpty) {
        if (!movedBrickTops.contains(brick.pt1.z-1))
          continue;
      }

      bool wasMoved = false;
      testBrick.pt1 = ImmutablePoint3(brick.pt1.x, brick.pt1.y, brick.pt1.z);
      testBrick.pt2 = ImmutablePoint3(brick.pt2.x, brick.pt2.y, brick.pt2.z);
      while (true) {

        if (ignoreBrick != -1) {
          var ignoredBrick = data[ignoreBrick];
          if (testBrick.pt2.z < ignoredBrick.pt1.z) {
            break;
          }
        }

        var collision = false;

        //if (toRestoreIndexes.isEmpty)
        byZMapOfBrickIndexes[testBrick.pt1.z]?.forEach((element) {
          if (element == ignoreBrick) return;
          if (element == i) return;
          var otherBrick = data[element];
          if (!_isCollision(otherBrick, testBrick))
            return;
          collision = true;
        });

        if (!collision) {
          if (testBrick.pt1.z != brick.pt1.z) {
            if (!wasMoved && movedBrickTops.isNotEmpty) {
              movedBrickTops.add(brick.pt2.z);
            }
            byZMapOfBrickIndexes[testBrick.pt2.z+1]!.remove(i);
            if (!byZMapOfBrickIndexes.containsKey(testBrick.pt2.z)) {
              byZMapOfBrickIndexes[testBrick.pt2.z] = [i];
            }
            else
              byZMapOfBrickIndexes[testBrick.pt2.z]!.add(i);
            wasMoved = true;
            if (failFast)
              break;
          }
          if (!test) {
            brick.pt1 = ImmutablePoint3(brick.pt1.x, brick.pt1.y, testBrick.pt1.z);
            brick.pt2 = ImmutablePoint3(brick.pt2.x, brick.pt2.y, testBrick.pt2.z);
          }
        }
        else {
          break;
        }
        testBrick.pt1 = testBrick.pt1.offset(0, 0, -1);
        testBrick.pt2 = testBrick.pt2.offset(0, 0, -1);
        if (testBrick.pt1.z < 1)
          break;
      }

      if (wasMoved) {
        movedBricks++;
        toRestoreIndexes.add(i);
        brick.markToRestore();
        if (failFast)
          break;
      }
    }
    if (restoreOnDone) {
      toRestoreIndexes.forEach((element) {data[element].restoreFromOrg();});
    }

    //print("start=${startBrick} i1=$i1, i2=$i2, i3=$i3, movedBricks=$movedBricks");
    return movedBricks;
  }

  void _printBricks(List<Brick> data) {
    int highestZ = 0;
    for (var brick in data) {
      if (brick.pt2.z > highestZ) {
        highestZ = brick.pt2.z;
      }
      if (brick.pt1.z > highestZ) {
        highestZ = brick.pt1.z;
      }
    }
    int lowestZ = highestZ;
    for (var brick in data) {
      if (brick.pt2.z < lowestZ) {
        lowestZ = brick.pt2.z;
      }
      if (brick.pt1.z < lowestZ) {
        lowestZ = brick.pt1.z;
      }
    }
    int highestX = 0;
    for (var brick in data) {
      if (brick.pt2.x > highestX) {
        highestX = brick.pt2.x;
      }
      if (brick.pt1.x > highestX) {
        highestX = brick.pt1.x;
      }
    }
    int lowestX = highestX;
    for (var brick in data) {
      if (brick.pt1.x < lowestX) {
        lowestX = brick.pt1.x;
      }
      if (brick.pt2.x < lowestX) {
        lowestX = brick.pt2.x;
      }
    }

    for (var z = highestZ; z >= lowestZ; z--) {
      String line = "";
      for (var x = lowestX; x <= highestX; x++) {
        String name = ".";
        for (var j = 0; j < data.length; j++) {
          var brick = data[j];
          if (z >= brick.pt1.z && z <= brick.pt2.z && x >= brick.pt1.x && x <= brick.pt2.x) {
            if (name == ".")
              name = brick.name;
            else
              name = "?";
          }
        }
        line += "$name";
      }
      line += " $z";
      print(line);
    }
  }

/*
 x
012
.G. 9
.G. 8
... 7
FFF 6
..E 5 z
D.. 4
CCC 3
BBB 2
.A. 1
--- 0

 x
012
.G. 6
.G. 5
FFF 4
D.E 3 z
??? 2
.A. 1
--- 0
 */

  int solve(List<Brick> data, {var part2 = false}) {
    int total = 0;

    _settleDownBricks(data);
    data.sort((a, b) => a.pt1.z - b.pt1.z);

    if (part2)
      data.forEach((element) {element.saveOrg();});

    for (int j = 0; j < data.length; ++j) {
      if (part2) {
        int movedBricks = _settleDownBricks(data, ignoreBrick: j, startBrick:j, restoreOnDone: true);
        total += movedBricks;
      }
      else {
        int movedBricks = _settleDownBricks(data, test: true, ignoreBrick: j, startBrick:j, failFast: true);
        if (movedBricks == 0) {
          total++;
        }
      }
    }

    return total;
  }

  @override
  Future<void> run() async {
    print("Day22");

    var data = readData("../adventofcode_input/2023/data/day22.txt");

    var res1 = solve(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2023/data/day22_result.txt", 0));

    data = readData("../adventofcode_input/2023/data/day22.txt");
    var res2 = solve(data, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2023/data/day22_result.txt", 1));
  }
}
