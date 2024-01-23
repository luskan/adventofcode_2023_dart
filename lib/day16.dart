import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'common.dart';
import 'day.dart';
import 'solution_check.dart';

enum ElementType {
  Ground, VerticalSplitter, HorizontalSplitter, BackMirror, FrontMirror
}

enum RayDir {
  North, West, South, East
}

class MapElement {
  ElementType elementType;
  List<RayDir> rays = [];

  MapElement(this.elementType);
}

class MirrorMap {
  List<List<MapElement>> raw = [];
}

class WorkItem {
  Point pt;
  RayDir dir;

  WorkItem(this.pt, this.dir);
}

@DayTag()
class Day16 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static MirrorMap parseData(var data) {
    var map = MirrorMap();
    LineSplitter()
        .convert(data)
        .forEach((line) {
          List<MapElement> lineElements = [];
          line.split('').forEach((element) {
            switch(element) {
              case '.':
                lineElements.add(MapElement(ElementType.Ground));
                break;
              case '-':
                lineElements.add(MapElement(ElementType.HorizontalSplitter));
                break;
              case '|':
                lineElements.add(MapElement(ElementType.VerticalSplitter));
                break;
              case r'\':
                lineElements.add(MapElement(ElementType.BackMirror));
                break;
              case r'/':
                lineElements.add(MapElement(ElementType.FrontMirror));
                break;
            }
          });
          map.raw.add(lineElements);
    })
    ;
    return map;
  }

  Point _rayToDir(RayDir dir) {
    switch(dir) {
      case RayDir.North:
        return Point(0, -1);
      case RayDir.West:
        return Point(-1, 0);
      case RayDir.South:
        return Point(0, 1);
      case RayDir.East:
        return Point(1, 0);
    }
    throw Exception("Unknown direction: $dir");
  }

  int solve(MirrorMap data, {var part2 = false}) {
    int total = 0;

    if (!part2) {
      total = _calculateEnergization(data, Point(-1, 0), RayDir.East);
    }
    else {

      var startData = [
        [Point(-1, 0), Point(0, 1), Point(-1, data.raw.length), RayDir.East], // ->
        [Point(data.raw[0].length, 0), Point(0, 1), Point(data.raw[0].length, data.raw.length), RayDir.West],
        [Point(0, -1), Point(1, 0), Point(data.raw[0].length, -1), RayDir.South],
        [Point(0, data.raw.length), Point(1, 0), Point(data.raw[0].length, data.raw.length),  RayDir.North],
      ];

      for (var sd in startData) {
        Point pt = Point.clone(sd[0] as Point);
        Point ptOff = Point.clone(sd[1] as Point);
        Point ptEnd = sd[2] as Point;
        RayDir dir = sd[3] as RayDir;
        do {
          var cur = _calculateEnergization(data, pt, dir);
          if (cur > total)
            total = cur;
          pt += ptOff;
        } while(pt != ptEnd);
      }

    }

    return total;
  }

  var _queue = <WorkItem>[];
  int _calculateEnergization(MirrorMap data, Point ptStart, RayDir dirStart) {
    int total = 0;
    _queue.clear();
    _queue.add(WorkItem(ptStart, dirStart));

    while (_queue.isNotEmpty) {
      var item = _queue.removeAt(0);
      var newDir = _rayToDir(item.dir);
      var newPt = Point(item.pt.x + newDir.x, item.pt.y + newDir.y);
      if (newPt.x < 0 || newPt.x >= data.raw[0].length || newPt.y < 0 || newPt.y >= data.raw.length)
        continue;

      //printMirrorMap(data);

      var newElement = data.raw[newPt.y][newPt.x];
      if (newElement.elementType == ElementType.Ground) {
        if (!newElement.rays.contains(item.dir)) {
          newElement.rays.add(item.dir);
          _queue.add(WorkItem(newPt, item.dir));
        }
        continue;
      }
      else if (newElement.elementType == ElementType.HorizontalSplitter) {
        if (item.dir == RayDir.North || item.dir == RayDir.South) {
          if (!newElement.rays.contains(item.dir)) {
            newElement.rays.add(item.dir);
            _queue.add(WorkItem(newPt, RayDir.West));
            _queue.add(WorkItem(newPt, RayDir.East));
          }
          continue;
        }
        if (item.dir == RayDir.East) {
          if (!newElement.rays.contains(item.dir)) {
            newElement.rays.add(item.dir);
            _queue.add(WorkItem(newPt, item.dir));
          }
          continue;
        }
        if (item.dir == RayDir.West) {
          if (!newElement.rays.contains(item.dir)) {
            newElement.rays.add(item.dir);
            _queue.add(WorkItem(newPt, item.dir));
          }
          continue;
        }
      }
      else if (newElement.elementType == ElementType.VerticalSplitter) {
        if (item.dir == RayDir.West || item.dir == RayDir.East) {
          if (!newElement.rays.contains(item.dir)) {
            newElement.rays.add(item.dir);
            _queue.add(WorkItem(newPt, RayDir.North));
            _queue.add(WorkItem(newPt, RayDir.South));
          }
          continue;
        }
        if (item.dir == RayDir.North) {
          newElement.rays.add(RayDir.North);
          _queue.add(WorkItem(newPt, RayDir.North));
          continue;
        }
        if (item.dir == RayDir.South) {
          newElement.rays.add(RayDir.South);
          _queue.add(WorkItem(newPt, RayDir.South));
          continue;
        }
      }
      else if (newElement.elementType == ElementType.BackMirror) { // \
        if (item.dir == RayDir.North) {
          newElement.rays.add(RayDir.West);
          _queue.add(WorkItem(newPt, RayDir.West));
          continue;
        }
        if (item.dir == RayDir.West) {
          newElement.rays.add(RayDir.North);
          _queue.add(WorkItem(newPt, RayDir.North));
          continue;
        }
        if (item.dir == RayDir.South) {
          newElement.rays.add(RayDir.East);
          _queue.add(WorkItem(newPt, RayDir.East));
          continue;
        }
        if (item.dir == RayDir.East) {
          newElement.rays.add(RayDir.South);
          _queue.add(WorkItem(newPt, RayDir.South));
          continue;
        }
      }
      else if (newElement.elementType == ElementType.FrontMirror) { // /
        if (item.dir == RayDir.North) {
          newElement.rays.add(RayDir.East);
          _queue.add(WorkItem(newPt, RayDir.East));
          continue;
        }
        if (item.dir == RayDir.West) {
          newElement.rays.add(RayDir.South);
          _queue.add(WorkItem(newPt, RayDir.South));
          continue;
        }
        if (item.dir == RayDir.South) {
          newElement.rays.add(RayDir.West);
          _queue.add(WorkItem(newPt, RayDir.West));
          continue;
        }
        if (item.dir == RayDir.East) {
          newElement.rays.add(RayDir.North);
          _queue.add(WorkItem(newPt, RayDir.North));
          continue;
        }
      }
      else
        throw Exception("Unknown element type: ${newElement.elementType}");
    }

    for (var y = 0; y < data.raw.length; ++y) {
      for (var x = 0; x < data.raw[y].length; ++x) {
        var element = data.raw[y][x];
        if (element.rays.isNotEmpty)
          total++;
      }
    }

    for (var y = 0; y < data.raw.length; ++y) {
      for (var x = 0; x < data.raw[y].length; ++x) {
        var element = data.raw[y][x];
        element.rays.clear();
      }
    }

    return total;
  }

  void printMirrorMap(MirrorMap data) {
    for (var y = 0; y < data.raw.length; ++y) {
      String line = "";
      for (var x = 0; x < data.raw[y].length; ++x) {
        var element = data.raw[y][x];
        if (element.rays.isEmpty)
          line += '.';
        else if (element.rays.length >= 1) {
          switch(element.rays[0]) {
            case RayDir.North:
              line += '^';
              break;
            case RayDir.West:
              line += '<';
              break;
            case RayDir.South:
              line += 'v';
              break;
            case RayDir.East:
              line += '>';
              break;
          }
        }
        else
          line += '.';
      }
      print(line);
    }
    print("\n");
  }

  @override
  Future<void> run() async {
    print("Day16");

    var data = readData("../adventofcode_input/2023/data/day16.txt");

    var res1 = solve(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2023/data/day16_result.txt", 0));

    var res2 = solve(data, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2023/data/day16_result.txt", 1));
  }

}
