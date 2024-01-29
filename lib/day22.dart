import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'common.dart';
import 'day.dart';
import 'solution_check.dart';

class Brick {
  ImmutablePoint3 pt1;
  ImmutablePoint3 pt2;

  ImmutablePoint3 pt1Org = ImmutablePoint3(0, 0, 0);
  ImmutablePoint3 pt2Org = ImmutablePoint3(0, 0, 0);

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
    var res = LineSplitter().convert(data).map((e) {
      var parts = e.split("~");
      var pt1 = parts[0].split(",").map((e) => int.parse(e)).toList();
      var pt2 = parts[1].split(",").map((e) => int.parse(e)).toList();
      var brick = Brick(
          numberToLetters(n++),
          ImmutablePoint3(pt1[0], pt1[1], pt1[2]),
          ImmutablePoint3(pt2[0], pt2[1], pt2[2]));
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

  int _settleDownBricks(List<Brick> data, Map<int, List<int>> byZMapOfBrickIndexes,
      {var test = false,
      var ignoreBrickIndex = -1,
      var startBrick = 0,
      var failFast = false,
      var restoreOnDone = false}) {

    // Stores bricks top positions (pt2.z). But only for bricks that were moved.
    // Only other bricks with the same pt1.z should move - because they are above them - touching.
    List<int> movedBrickTops = [];
    late var ignoredBrick;
    if (ignoreBrickIndex != -1) {
      ignoredBrick = data[ignoreBrickIndex];
      movedBrickTops.add(ignoredBrick.pt2.z);
    }

    // After simulation of moving bricks, we need to restore them back to original positions.
    // Only if this is not an initial process of making all bricks falling down.
    List<int> toRestoreIndexes = [];

    // Starting from the bottom most brick, move it along z-axia down, as far as possible to the bottom, but no lower
    // than any other brick colliding with it. Then move to the next brick, and repeat.
    Brick testBrick =
        Brick('?', ImmutablePoint3(0, 0, 0), ImmutablePoint3(0, 0, 0));
    int movedBricks = 0;
    for (var i = startBrick; i < data.length; i++) {
      if (i == ignoreBrickIndex) continue;

      var brick = data[i];
      if (brick.pt1.z == 1) continue;

      if (ignoreBrickIndex != -1 && failFast) {
        if (brick.pt1.z - 1 > ignoredBrick.pt2.z) {
          break;
        }
      }

      if (movedBrickTops.isNotEmpty) {
        if (!movedBrickTops.contains(brick.pt1.z - 1)) continue;
      }

      bool wasMoved = false;
      testBrick.pt1 = ImmutablePoint3(brick.pt1.x, brick.pt1.y, brick.pt1.z);
      testBrick.pt2 = ImmutablePoint3(brick.pt2.x, brick.pt2.y, brick.pt2.z);

      // Simulate falling of the testBrick brick down, one step at a time.
      while (true) {

        testBrick.pt1 = testBrick.pt1.offset(0, 0, -1);
        testBrick.pt2 = testBrick.pt2.offset(0, 0, -1);
        if (testBrick.pt1.z < 1)
          break;

        if (ignoreBrickIndex != -1) {
          if (testBrick.pt2.z < ignoredBrick.pt1.z) {
            break;
          }
        }

        var collision = false;

        // Quickly find possible collisions by checking only bricks with the same pt1.z
        byZMapOfBrickIndexes[testBrick.pt1.z]?.apply((indexes) {
          for (var k = 0; k < indexes.length; ++k) {
            var element = indexes[k];
            if (element == ignoreBrickIndex) continue;
            if (element == i) continue;
            var otherBrick = data[element];
            if (!_isCollision(otherBrick, testBrick)) continue;
            collision = true;
            break;
          }
        });

        if (!collision) {
          // If no collision was found, then this brick can move further down.

          // Update top positions of moved bricks
          if (!wasMoved && movedBrickTops.isNotEmpty) {
            movedBrickTops.add(brick.pt2.z);
          }

          // Update cache by z position
          byZMapOfBrickIndexes[testBrick.pt2.z + 1]!.remove(i);
          byZMapOfBrickIndexes.update(
              testBrick.pt2.z,
                  (list) => list..add(i),
              ifAbsent: () => [i]
          );

          wasMoved = true;
          if (failFast) break;

        } else {
          break;
        }
      }

      if (wasMoved) {
        if (!test) {
          // Update brick new position, +1 is because last moved caused collision so we need to go back.
          brick.pt1 = ImmutablePoint3(brick.pt1.x, brick.pt1.y, testBrick.pt1.z + 1);
          brick.pt2 = ImmutablePoint3(brick.pt2.x, brick.pt2.y, testBrick.pt2.z + 1);
        }
        movedBricks++;
        toRestoreIndexes.add(i);
        brick.markToRestore();
        if (failFast) break;
      }
    }

    if (restoreOnDone) {
      toRestoreIndexes.forEach((index) {
        var brick = data[index];
        byZMapOfBrickIndexes[brick.pt2.z]!.remove(index);
        brick.restoreFromOrg();
        byZMapOfBrickIndexes.update(
            brick.pt2.z,
                (list) => list..add(index),
            ifAbsent: () => [index]
        );
      });
    }

    return movedBricks;
  }

  void _printBricks(List<Brick> data) {
    var zValues = data.expand((b) => [b.pt1.z, b.pt2.z]);
    var xValues = data.expand((b) => [b.pt1.x, b.pt2.x]);
    int highestZ = zValues.reduce(max);
    int lowestZ = zValues.reduce(min);
    int highestX = xValues.reduce(max);
    int lowestX = xValues.reduce(min);

    print("");
    for (var z = highestZ; z >= lowestZ; z--) {
      String line = List.generate(highestX - lowestX + 1, (x) {
        var name = data
            .firstWhere(
                (b) =>
                    z >= b.pt1.z &&
                    z <= b.pt2.z &&
                    x + lowestX >= b.pt1.x &&
                    x + lowestX <= b.pt2.x,
                orElse: () => Brick(
                    '.', ImmutablePoint3(0, 0, 0), ImmutablePoint3(0, 0, 0)))
            .name;
        return name == '.' ? '.' : data.where((b) =>
                            z >= b.pt1.z &&
                            z <= b.pt2.z &&
                            x + lowestX >= b.pt1.x &&
                            x + lowestX <= b.pt2.x).length > 1 ? '?' : name;
      }).join();
      print("$line $z");
    }
  }

  Map<int, List<int>> createByZMapOfBrickIndexes(List<Brick> data) {
    var byZMapOfBrickIndexes = <int, List<int>>{};
    for (var i = 0; i < data.length; i++) {
      byZMapOfBrickIndexes.putIfAbsent(data[i].pt2.z, () => <int>[]).add(i);
    }
    return byZMapOfBrickIndexes;
  }

  int solve(List<Brick> data, {var part2 = false}) {

    // Make a cache of bricks by z value
    var byZMapOfBrickIndexes = createByZMapOfBrickIndexes(data);

    // First, move bricks down.
    //_printBricks(data);
    _settleDownBricks(data, byZMapOfBrickIndexes);

    // Resort list by z
    data.sort((a, b) => a.pt1.z - b.pt1.z);
    byZMapOfBrickIndexes = createByZMapOfBrickIndexes(data);

    //_printBricks(data);

    // Remember original positions
    data.forEach((element) {
      element.saveOrg();
    });

    int total = 0;
    if (part2) {
      for (int j = 0; j < data.length; ++j) {
        total += _settleDownBricks(data, byZMapOfBrickIndexes,
            ignoreBrickIndex: j, startBrick: j, restoreOnDone: true);
      }
    } else {
      for (int j = 0; j < data.length; ++j) {
        if (0 ==
            _settleDownBricks(data, byZMapOfBrickIndexes,
                test: true, restoreOnDone: true, ignoreBrickIndex: j, startBrick: j, failFast: true)) {
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
    verifyResult(res1,
        getIntFromFile("../adventofcode_input/2023/data/day22_result.txt", 0));

    data = readData("../adventofcode_input/2023/data/day22.txt");
    var res2 = solve(data, part2: true);
    print('Part2: $res2');
    verifyResult(res2,
        getIntFromFile("../adventofcode_input/2023/data/day22_result.txt", 1));
  }
}
