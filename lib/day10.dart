import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'common.dart';
import 'day.dart';
import 'solution_check.dart';

enum PipeType {
  //| is a vertical pipe connecting north and south.
  vertical,
  //- is a horizontal pipe connecting east and west.
  horizontal,
  //L is a 90-degree bend connecting north and east.
  northEast_L,
  //J is a 90-degree bend connecting north and west.
  northWest_J,
  //7 is a 90-degree bend connecting south and west.
  southWest_7,
  //F is a 90-degree bend connecting south and east.
  southEast_F,
  //    . is ground; there is no pipe in this tile.
  ground,
  //S is the starting position of the animal;
  start
}

const DirUp = ImmutablePoint(0, -1);
const DirRight = ImmutablePoint(1, 0);
const DirDown = ImmutablePoint(0, 1);
const DirLeft = ImmutablePoint(-1, 0);
const DirError = ImmutablePoint(-1, -1);

Point PipeTypeToNewPos(Point prev, Point pipe, PipeType type) {
  switch (type) {
    case PipeType.vertical:
      // x
      // |
      if (prev.x == pipe.x && prev.y == pipe.y - 1) return pipe + DirDown;
      // |
      // x
      if (prev.x == pipe.x && prev.y == pipe.y + 1) return pipe + DirUp;
      // x|
      if (prev.x == pipe.x - 1 && prev.y == pipe.y) return Point.fromIPoint(DirError);
      // |x
      if (prev.x == pipe.x + 1 && prev.y == pipe.y) return Point.fromIPoint(DirError);
      throw Exception('Unknown PipeType: $type');
    case PipeType.horizontal:
      // x--
      if (prev.x == pipe.x - 1 && prev.y == pipe.y) return pipe + DirRight;
      // --x
      if (prev.x == pipe.x + 1 && prev.y == pipe.y) return pipe + DirLeft;
      // x
      // -
      if (prev.x == pipe.x && prev.y == pipe.y - 1) return Point.fromIPoint(DirError);
      // -
      // x
      if (prev.x == pipe.x && prev.y == pipe.y + 1) return Point.fromIPoint(DirError);
      throw Exception('Unknown PipeType: $type');
    case PipeType.northEast_L:
      {
        // x
        // L-
        if (prev.x == pipe.x && prev.y == pipe.y - 1) return pipe + DirRight;
        // |
        // Lx
        if (prev.x == pipe.x + 1 && prev.y == pipe.y) return pipe + DirUp;
        //  |
        // xL
        if (prev.x == pipe.x - 1 && prev.y == pipe.y) return Point.fromIPoint(DirError);
        //  |
        //  L
        //  x
        if (prev.x == pipe.x && prev.y == pipe.y + 1) return Point.fromIPoint(DirError);
        throw Exception('Unknown PipeType: $type');
      }
    case PipeType.northWest_J:
      {
        //  x
        // -J
        if (prev.x == pipe.x && prev.y == pipe.y - 1) return pipe + DirLeft;
        //  |
        // xJ
        if (prev.x == pipe.x - 1 && prev.y == pipe.y) return pipe + DirUp;
        //  |
        // Jx
        if (prev.x == pipe.x + 1 && prev.y == pipe.y) return Point.fromIPoint(DirError);
        //  |
        //  J
        //  x
        if (prev.x == pipe.x && prev.y == pipe.y + 1) return Point.fromIPoint(DirError);
        throw Exception('Unknown PipeType: $type');
      }
    case PipeType.southWest_7:
      {
        // -7
        //  x
        if (prev.x == pipe.x && prev.y == pipe.y + 1) return pipe + DirLeft;
        // x7
        //  |
        if (prev.x == pipe.x - 1 && prev.y == pipe.y) return pipe + DirDown;
        //  7x
        //  |
        if (prev.x == pipe.x + 1 && prev.y == pipe.y) return Point.fromIPoint(DirError);
        //  x
        //  7
        //  |
        if (prev.x == pipe.x && prev.y == pipe.y - 1) return Point.fromIPoint(DirError);
        throw Exception('Unknown PipeType: $type');
      }
    case PipeType.southEast_F:
      {
        // Fx
        // |
        if (prev.x == pipe.x + 1 && prev.y == pipe.y) return pipe + DirDown;
        // F-
        // x
        if (prev.x == pipe.x && prev.y == pipe.y + 1) return pipe + DirRight;
        // xF
        //  |
        if (prev.x == pipe.x - 1 && prev.y == pipe.y) return Point.fromIPoint(DirError);
        //  x
        //  F
        //  |
        if (prev.x == pipe.x && prev.y == pipe.y - 1) return Point.fromIPoint(DirError);
        throw Exception('Unknown PipeType: $type');
      }
    case PipeType.ground:
      return Point.fromIPoint(DirError);
    case PipeType.start:
      return Point.fromIPoint(DirError);
    default:
      throw Exception('Unknown PipeType: $type');
  }
}

class MapPlace {
  PipeType type;
  int count;
  bool? floodFillIsInside;
  bool floodFillVisited = false;
  bool loopPoint = false;
  List<int> visited = [];

  MapPlace(this.type, this.count);
}

class WorkItem {
  Point pt;
  Point ptPrev;
  int tag;
  int count; // number of steps so far
  WorkItem? prevItem;

  bool isStartPoint() => tag == 0;

  WorkItem(this.tag, this.pt, this.ptPrev, this.count, this.prevItem);
}

class FloodItem {
  Point pt;

  FloodItem(this.pt);
}

@DayTag()
class Day10 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static List<List<MapPlace>> parseData(var data) {
    return LineSplitter().convert(data).map((e) {
      List<MapPlace> row = [];
      for (var i = 0; i < e.length; i++) {
        var c = e[i];
        switch (c) {
          case '|':
            row.add(MapPlace(PipeType.vertical, 0));
            break;
          case '-':
            row.add(MapPlace(PipeType.horizontal, 0));
            break;
          case 'L':
            row.add(MapPlace(PipeType.northEast_L, 0));
            break;
          case 'J':
            row.add(MapPlace(PipeType.northWest_J, 0));
            break;
          case '7':
            row.add(MapPlace(PipeType.southWest_7, 0));
            break;
          case 'F':
            row.add(MapPlace(PipeType.southEast_F, 0));
            break;
          case '.':
            row.add(MapPlace(PipeType.ground, 0));
            break;
          case 'S':
            row.add(MapPlace(PipeType.start, 0));
            break;
          default:
            throw Exception('Unknown char: $c');
        }
      }
      return row;
    }).toList();
  }

  int solve(List<List<MapPlace>> data, {var part2 = false}) {
    int total = 0;

    // find start
    Point startPoint = Point(-1, -1);
    for (var i = 0; i < data.length; i++) {
      var row = data[i];
      for (var j = 0; j < row.length; j++) {
        var place = row[j];
        if (place.type == PipeType.start) {
          startPoint.x = j;
          startPoint.y = i;
          break;
        }
      }
    }

    List<ImmutablePoint> dirs = [
      DirRight,
      DirDown,
      DirLeft,
      DirUp,
    ];

    List<WorkItem> stack = [];
    int tag = 1;
    for (var dir in dirs) {
      var p = startPoint + dir;
      stack.add(WorkItem(tag++, p, startPoint, 1, null));
    }

    var loopPoints = <Point>{};

    while (stack.isNotEmpty) {
      var item = stack.removeAt(0);
      if (!(item.pt.x >= 0 &&
          item.pt.x < data[0].length &&
          item.pt.y >= 0 &&
          item.pt.y < data.length)) continue;
      var place = data[item.pt.y][item.pt.x];
      if (place.visited.contains(item.tag)) continue;
      if (place.type == PipeType.ground) continue;
      if (place.type == PipeType.start && !item.isStartPoint()) {
        Point firstAfterStart = Point(-1, -1);
        var loopBackItem = item;
        while (true) {
          if (loopBackItem.prevItem == null) {
            firstAfterStart = loopBackItem.pt;
            break;
          }
          loopBackItem = loopBackItem.prevItem!;
        }

        PipeType startPosPipeType = data[item.pt.y][item.pt.x].type;
        Point prevDir = item.pt - item.ptPrev;
        Point nextDir = firstAfterStart - item.pt;

        if (prevDir == DirUp && nextDir == DirUp ||
            prevDir == DirDown && nextDir == DirDown)
          startPosPipeType = PipeType.vertical;
        if (prevDir == DirRight && nextDir == DirRight ||
            prevDir == DirLeft && nextDir == DirLeft)
          startPosPipeType = PipeType.horizontal;
        if (prevDir == DirDown && nextDir == DirRight ||
            prevDir == DirLeft && nextDir == DirUp)
          startPosPipeType = PipeType.northEast_L;
        if (prevDir == DirDown && nextDir == DirLeft ||
            prevDir == DirRight && nextDir == DirUp)
          startPosPipeType = PipeType.northWest_J;
        if (prevDir == DirUp && nextDir == DirLeft ||
            prevDir == DirRight && nextDir == DirDown)
          startPosPipeType = PipeType.southWest_7;
        if (prevDir == DirUp && nextDir == DirRight ||
            prevDir == DirLeft && nextDir == DirDown)
          startPosPipeType = PipeType.southEast_F;

        data[item.pt.y][item.pt.x].type = startPosPipeType;

        if (part2) {
          while (true) {
            loopPoints.add(item.pt);
            data[item.pt.y][item.pt.x].floodFillVisited = true;
            data[item.pt.y][item.pt.x].loopPoint = true;
            if (item.prevItem == null) break;
            item = item.prevItem!;
          }
        } else {
          total += (item.count) ~/ 2;
        }
        break;
      }
      var newPos = PipeTypeToNewPos(item.ptPrev, item.pt, place.type);
      if (newPos == DirError) continue;
      place.visited.add(item.tag);
      stack.insert(
          0, WorkItem(item.tag, newPos, item.pt, item.count + 1, item));
    }

    if (part2) {
      final debugMode = false;
      if (debugMode) {
        for (var y = 0; y < data.length; y++) {
          var row = data[y];
          String line = "";
          for (var x = 0; x < row.length; x++) {
            var place = row[x];
            ;
            if (loopPoints.contains(Point(x, y)))
              line += PlaceTypeToStr(place.type);
            else {
              line += '*';
            }
          }
          print(line);
        }
      }

      var insidePoints = <Point>{};
      var stack = <FloodItem>[]; // stack of points to flood fill
      var counters = [0, 0, 0, 0];

      for (var y = 0; y < data.length; y++) {
        var row = data[y];
        for (var x = 0; x < row.length; x++) {
          var place = row[x];
          if (place.floodFillVisited)
            continue;

          counters[0] = 0;
          counters[1] = 0;
          counters[2] = 0;
          counters[3] = 0;

          if (true) {

            //
            // Polygon-In-Point algorithm

            for (var i = 0; i < dirs.length; ++i) {
              var dir = dirs[i];
              var p = Point(x, y);
              var loopLineCounter = 0;
              MapPlace? lastFirstLoopPlace;
              while (p.x >= 0 && p.x < data[0].length && p.y >= 0 && p.y < data.length) {
                var place = data[p.y][p.x];
                if (place.loopPoint) {
                  if (loopLineCounter == 0) {
                    counters[i]++;
                    loopLineCounter++;
                    lastFirstLoopPlace = data[p.y][p.x];
                  } else {
                    Point prevPt = p - dir;
                    var prevPlace = data[prevPt.y][prevPt.x];
                    var curPlace = data[p.y][p.x];
                    if (!PipesConnectorsMatch(
                        dir, prevPlace.type, curPlace.type)) {
                      counters[i]++;
                      lastFirstLoopPlace = data[p.y][p.x];
                    } else {
                      loopLineCounter++;

                      String se = PlaceTypeToStr(lastFirstLoopPlace!.type) +
                          PlaceTypeToStr(curPlace.type);
                      var inOutEdged = ['J7', 'LF', 'LJ', '7F'];
                      if (inOutEdged.contains(se) ||
                          inOutEdged.contains(se.split('').reversed.join('')))
                        counters[i]++;
                    }
                  }
                } else {
                  loopLineCounter = 0;
                }
                p += dir;
              }

              if (counters[i] % 2 == 0 && counters[i] != 0) {
                break;
              }
            }

            // check if each counters is odd and non zero
            var isInside = counters.every((n) => n % 2 != 0 && n != 0);
            if (isInside) {
              var place = data[y][x];
              place.floodFillIsInside = true;
              if (debugMode)
                insidePoints.add(Point(x, y));
              total++;
              if (debugMode) {
                print(
                    "Found: $total x:$x, y:$y R=${counters[0]}, D=${counters[1]}, L=${counters[2]}, U=${counters[3]}");
              }
            }
            else
              place.floodFillIsInside = false;

            if (true) {
              stack.clear();
              stack.add(FloodItem(Point(x, y)));
              while (stack.isNotEmpty) {
                var item = stack.removeLast();
                var place = data[item.pt.y][item.pt.x];
                if (place.floodFillVisited)
                  continue;
                place.floodFillVisited = true;

                if (place.floodFillIsInside == null) {
                  place.floodFillIsInside = isInside;
                  if (isInside) {
                    if (debugMode)
                      insidePoints.add(Point(item.pt.y, item.pt.x));
                    total++;
                  }
                }

                for (var dir in dirs) {
                  var p = item.pt + dir;
                  if (p.x >= 0 && p.x < data[0].length && p.y >= 0 && p.y < data.length) {
                    stack.add(FloodItem(p));
                  }
                }
              }
            } // floodfill

          }
        }
      }

      if (debugMode) {
        print("");
        for (var y = 0; y < data.length; y++) {
          var row = data[y];
          String line = "";
          for (var x = 0; x < row.length; x++) {
            var place = row[x];
            ;
            if (loopPoints.contains(Point(x, y)))
              line += PlaceTypeToStr(place.type);
            else {
              if (insidePoints.contains(Point(x, y)))
                line += 'I';
              else
                line += 'O';
            }
          }
          print(line);
        }
      }
    }

    return total;
  }

  @override
  Future<void> run() async {
    print("Day10");

    var data = readData("../adventofcode_input/2023/data/day10.txt");
    var res1 = solve(data);
    print('Part1: $res1');
    verifyResult(res1,
        getIntFromFile("../adventofcode_input/2023/data/day10_result.txt", 0));

    data = readData("../adventofcode_input/2023/data/day10.txt");
    var res2 = solve(data, part2: true);
    print('Part2: $res2');
    verifyResult(res2,
        getIntFromFile("../adventofcode_input/2023/data/day10_result.txt", 1));

  }

  String PlaceTypeToStr(PipeType type) {
    const typeToStr = {
      PipeType.vertical: '|', PipeType.horizontal: '-',  PipeType.northEast_L: 'L', PipeType.northWest_J: 'J',
      PipeType.southWest_7: '7', PipeType.southEast_F: 'F', PipeType.ground: '.', PipeType.start: 'S'
    };
    return typeToStr[type]!;
  }


  bool PipesConnectorsMatch(ImmutablePoint dir, PipeType type, PipeType type2) {
    const connectorsMap = {
      PipeType.vertical: {
        DirUp: [PipeType.vertical, PipeType.southEast_F, PipeType.southWest_7],
        DirDown: [PipeType.vertical, PipeType.northWest_J, PipeType.northEast_L],
      },
      PipeType.horizontal: {
        DirRight: [PipeType.horizontal, PipeType.southWest_7, PipeType.northWest_J],
        DirLeft: [PipeType.horizontal, PipeType.southEast_F, PipeType.northEast_L],
      },
      PipeType.northEast_L: {
        DirUp: [PipeType.vertical, PipeType.southEast_F, PipeType.southWest_7],
        DirRight: [PipeType.horizontal, PipeType.northWest_J, PipeType.southWest_7],
      },
      PipeType.northWest_J: {
        DirLeft: [PipeType.horizontal, PipeType.northEast_L, PipeType.southEast_F],
        DirUp: [PipeType.vertical, PipeType.southWest_7, PipeType.southEast_F],
      },
      PipeType.southWest_7: {
        DirLeft: [PipeType.horizontal, PipeType.southEast_F, PipeType.northEast_L],
        DirDown: [PipeType.vertical, PipeType.northWest_J, PipeType.northEast_L],
      },
      PipeType.southEast_F: {
        DirRight: [PipeType.horizontal, PipeType.northWest_J, PipeType.southWest_7],
        DirDown: [PipeType.vertical, PipeType.northWest_J, PipeType.northEast_L],
      },
    };

    return connectorsMap[type]?[dir]?.contains(type2) ?? false;
  }

}
