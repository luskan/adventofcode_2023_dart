import 'dart:io';
import 'dart:convert';

import 'common.dart';
import 'day.dart';
import 'solution_check.dart';

import 'package:collection/collection.dart';

var dirs = [
  Point(0, -1),
  Point(0, 1),
  Point(-1, 0),
  Point(1, 0),
];

enum GroundType {
  Path,       // .
  Forest,     // #
  SlopeUp,    // ^
  SlopeDown,  // v
  SlopeLeft,  // <
  SlopeRight, // >
}

class NeighbourNode {
  int distance = 0;
  Point dir = Point(0, 0);
  Node node;
  NeighbourNode(this.dir, this.distance, this.node);
}

class Node {
  int id = 0;
  Point pt = Point(0, 0);
  var distances = <Point, NeighbourNode>{}; // key points represents other nodes, and value are distances to them from this node.
}

class GroundElement {
  GroundType type = GroundType.Path;
  int visited = -1;
  GroundElement(this.type);
}

class IslandMap {
  List<List<GroundElement>> map = [];
  int width = 0;
  int height = 0;
  Point start = Point(0, 0);
  Point end = Point(0, 0);

  GroundElement get(Point p) => map[p.y][p.x];

  bool isValidPosition(Point pt) {
    if (pt.x < 0 || pt.x >= width || pt.y < 0 || pt.y >= height) {
      return false;
    }
    var mi = get(pt);
    if (mi.type == GroundType.Forest) {
      return false;
    }
    return true;
  }

  void _printMap(Map<Point, Node> graph, List<Point> visitedNodes) {

    // Turn visitedNodes into a full path
    var visitedPositions = <Point>{};
    if (graph.isEmpty) {
     visitedPositions.addAll(visitedNodes);
    }
    else {
      for (int n = 0; n < visitedNodes.length - 1; ++n) {
        var start_point = visitedNodes[n];
        var end_point = visitedNodes[n + 1];

        Point start_point_dir = graph[start_point]!.distances[end_point]!.dir;

        visitedPositions.add(start_point);
        var queue = <Point>[];
        queue.add(start_point + start_point_dir);
        while (queue.isNotEmpty) {
          var pt = queue.removeLast();
          if (pt == end_point) {
            visitedPositions.add(pt);
            break;
          }
          if (visitedPositions.contains(pt)) {
            //assert(false);
            continue;
          }
          visitedPositions.add(pt);
          for (var dir in dirs) {
            var pt2 = Point(pt.x + dir.x, pt.y + dir.y);
            if (!isValidPosition(pt2))
              continue;
            if (visitedPositions.contains(pt2))
              continue;
            if (graph.containsKey(pt2))
              continue;
            queue.add(pt2);
          }
        }
      }
    }


    print(" vis = ${visitedPositions.length}" );

    print ("");
    for (var y = 0; y < height; y++) {
      var row = <String>[];
      for (var x = 0; x < width; x++) {
        var c = ".";
        var pt = Point(x, y);

        if (visitedNodes.contains(pt))
          c = "N";
        else if (graph.containsKey(pt)) {
          c = "n";
        }
        else if (visitedPositions.contains(pt)) {
          c = "O";
        }
        else
       // else
        //  if (walkingMap.contains(Point(x, y))) {
       //   c = "O";
        //}
       // else
        if (Point(x, y) == start) {
          c = "S";
        }
        else if (Point(x, y) == end) {
          c = "E";
        }
        else {
          switch (map[y][x].type) {
            case GroundType.Path:
              c = ".";
              break;
            case GroundType.Forest:
              c = "#";
              break;
            case GroundType.SlopeUp:
              c = "^";
              break;
            case GroundType.SlopeDown:
              c = "v";
              break;
            case GroundType.SlopeLeft:
              c = "<";
              break;
            case GroundType.SlopeRight:
              c = ">";
              break;
          }
        }
        row.add(c);
      }
      print(row.join(""));
    }
  }
}

class WalkItem {
  Point pos = Point(0, 0);
  WalkItem? prev;
  int distance = 0;

  WalkItem(this.pos, this.prev, this.distance);

  bool isVisited(Point pt) {
    var item = this;
    while (item.prev != null) {
      if (item.pos == pt) {
        return true;
      }
      item = item.prev!;
    }
    return false;
  }
}

class WalkItem2 {
  final Node node;
  final int visitedMap;
  final int distance;

  const WalkItem2(this.node, this.visitedMap, this.distance);

  bool isVisited(int nodeId) {
    return (visitedMap & nodeId) != 0 ? true : false;
  }
}

class GraphBuildWalkItem {
  Point pos;
  Node lastNode;
  Point lastNodeLeaveDir;
  Point lastDir;
  int distFromLastNode;

  GraphBuildWalkItem(this.pos, this.lastNodeLeaveDir, this.lastDir, this.lastNode, this.distFromLastNode);
}

@DayTag()
class Day23 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static IslandMap parseData(var data) {
    IslandMap islandMap = IslandMap();
    LineSplitter()
        .convert(data)
        .forEach((line) {
          var row = <GroundElement>[];
          for (var x = 0; x < line.length; x++) {
            var c = line[x];
            switch (c) {
              case ".":
                row.add(GroundElement(GroundType.Path));
                break;
              case "#":
                row.add(GroundElement(GroundType.Forest));
                break;
              case "^":
                row.add(GroundElement(GroundType.SlopeUp));
                break;
              case "v":
                row.add(GroundElement(GroundType.SlopeDown));
                break;
              case "<":
                row.add(GroundElement(GroundType.SlopeLeft));
                break;
              case ">":
                row.add(GroundElement(GroundType.SlopeRight));
                break;
              default:
                throw Exception("Unknown char $c");
            }
          }
          islandMap.map.add(row);
        });
    islandMap.height = islandMap.map.length;
    islandMap.width = islandMap.map[0].length;
    islandMap.start = Point(1, 0);
    islandMap.end = Point(islandMap.width - 2, islandMap.height - 1);
    return islandMap;
  }

  GroundType getSlopeEndType(GroundType slopeStart) {
    switch (slopeStart) {
      case GroundType.SlopeUp:
        return GroundType.SlopeDown;
      case GroundType.SlopeDown:
        return GroundType.SlopeUp;
      case GroundType.SlopeLeft:
        return GroundType.SlopeRight;
      case GroundType.SlopeRight:
        return GroundType.SlopeLeft;
      default:
        throw Exception("Unknown slope type $slopeStart");
    }
  }

  Map<Point, Node> _buildGraph(IslandMap map) {

    var visited = <Point>{};
    var queue = <GraphBuildWalkItem>[];
    var graph = <Point, Node>{};

    bool tryAddNextPathNode(Point dir, GraphBuildWalkItem item, IslandMap map,
        List<GraphBuildWalkItem> queue) {
      var pt = Point(item.pos.x + dir.x, item.pos.y + dir.y);
      if (!map.isValidPosition(pt)) {
        return false;
      }
      if (visited.contains(pt)) {
        if (!graph.containsKey(pt))
          return false;
      }

      // Update new best length for new map element.
      Point leaveDir = item.lastNodeLeaveDir;;
      if (item.distFromLastNode == 0) {
        leaveDir = dir;
      }
      queue.add(GraphBuildWalkItem(pt, leaveDir, dir, item.lastNode, item.distFromLastNode+1));
      return true;
    }

    Node startNode = Node();
    startNode.pt = map.start;
    graph[map.start] = startNode;
    queue.add(GraphBuildWalkItem(map.start, Point(0, 1), Point(0,0), startNode, 0));

    while (queue.isNotEmpty) {
      var item = queue.removeLast();
      if (item.pos.x < 0 || item.pos.x >= map.width || item.pos.y < 0 ||
          item.pos.y >= map.height) {
        continue;
      }
      if (visited.contains(item.pos)) {
        if (graph.containsKey(item.pos) && item.lastNode.pt != item.pos) {

          Node node = graph[item.pos]!;
          Node lastNode = item.lastNode;
          node.distances[lastNode.pt] = NeighbourNode(item.lastNodeLeaveDir, item.distFromLastNode, lastNode);
          lastNode.distances[item.pos] = NeighbourNode(item.lastDir, item.distFromLastNode, node);

          continue;
        }
        else
          continue;
      }
      visited.add(item.pos);

      int validDirsCount = 0;
      for (var dir in dirs) {
        var pt = Point(item.pos.x + dir.x, item.pos.y + dir.y);

        if (!map.isValidPosition(pt)) {
          continue;
        }
        if (visited.contains(pt)) {
          if (!graph.containsKey(pt) || item.lastNode.pt == pt)
            continue;
        }
        validDirsCount++;
      }

      if (validDirsCount > 1 || item.pos == map.end) {
        var node = Node();
        if (graph.containsKey(item.pos))
          node = graph[item.pos]!;
        node.pt = item.pos;
        assert(!item.lastNode.distances.containsKey(item.pos));
        item.lastNode.distances[item.pos] = NeighbourNode(item.lastNodeLeaveDir, item.distFromLastNode, node);
        assert(!node.distances.containsKey(item.lastNode.pt));
        node.distances[item.lastNode.pt] = NeighbourNode(item.lastDir, item.distFromLastNode, item.lastNode);
        graph[item.pos] = node;
        item.lastNode = node;
        item.distFromLastNode = 0;
      }

      for (var dir in dirs) {
        tryAddNextPathNode(dir, item, map, queue);
      }
    }


    //map.printMap({}, visited.toList());

    for (int n = 0; n < graph.values.length; ++n) {
      var node = graph.values.elementAt(n);
      node.id = setNthBit(0, n);
    }

    return graph;
  }

  /**
   *
   */
  int solve(IslandMap map, var part2) {
    int total = 0;

    var slopeToDir = {
      GroundType.SlopeUp: Point(0, -1),
      GroundType.SlopeDown: Point(0, 1),
      GroundType.SlopeLeft: Point(-1, 0),
      GroundType.SlopeRight: Point(1, 0),
    };

    var queue = <WalkItem>[];

    void tryAddNextPathNode(Point dir, WalkItem item, IslandMap map, List<WalkItem> queue) {
      var pt = Point(item.pos.x + dir.x, item.pos.y + dir.y);

      if (!map.isValidPosition(pt)) {
        return;
      }

      // Check if this point was already visited on current route. If Yes then skip it.
      if (item.isVisited(pt)) {
        return;
      }

      // Update new best length for new map element.
      queue.add(WalkItem(
          pt, item, item.distance + 1));
  }

  queue.add(WalkItem(map.start, null, 0));

    while(queue.isNotEmpty) {
      var item = queue.removeLast();
      if (item.pos.x < 0 || item.pos.x >= map.width || item.pos.y < 0 ||
          item.pos.y >= map.height) {
        continue;
      }
      var mi = map.get(item.pos);

      if (item.pos == map.end) {
        if (item.distance > total) {
          total = item.distance;
        }
      }

      if (part2) {
        for (var dir in dirs) {
          tryAddNextPathNode(dir, item, map, queue);
        }
      }
      else {
        if (slopeToDir.keys.contains(mi.type)) {
          var nextDir = slopeToDir[mi.type]!;
          tryAddNextPathNode(nextDir, item, map, queue);
        }
        else {
          for (var dir in dirs) {
            tryAddNextPathNode(dir, item, map, queue);
          }
        }
      }

    }

    return total;
  }

  /**
   * Solution for second part which is an NP problem - finding longest path in graph with cycles. Solution first
   * finds nodes - the location on input map which have more than two possible ways to exit from them. Number of such
   * nodes is around 37. This number allows to use brute force algorithm to find the longest path. The algorithm
   * iterates over all possible combinations of nodes and finds the longest path. The algorithm is not optimal, but
   * it works for the input data. On i7 cpu it takes around 2-4 seconds to execute. There are other aproaches to optimize it
   * like visited nodes are kept in integer as bit fields - small amount of nodes allow for it.
   */
  int solve2(IslandMap map) {
    int total = 0;
    var queue = <WalkItem2>[];
    var graph = _buildGraph(map);

    var endNode = graph[map.end]!;
    var startNode = graph[map.start]!;

    queue.add(WalkItem2(startNode, graph[map.start]!.id, 0));

    while(queue.isNotEmpty) {
      var item = queue.removeLast();
      var node = item.node;

      if (node == endNode) {
        if (item.distance > total) {
          total = item.distance;
        }
      }

      // Iterate entries in node.disgances
      for (var pos in node.distances.keys) {
        var nextNode = graph[pos]!;
        if (item.isVisited(nextNode.id))
          continue;
        queue.add(
            WalkItem2(nextNode, item.visitedMap | nextNode.id, item.distance + node.distances[pos]!.distance));
      }
    }

    //map.printMap();
    //if (!part2)
    //  total = map.get(map.end).distFromStart;

    return total;
  }

  @override
  Future<void> run() async {
    print("Day23");

    var data = readData("../adventofcode_input/2023/data/day23.txt");
    var res1 = solve(data, false);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2023/data/day23_result.txt", 0));

    data = readData("../adventofcode_input/2023/data/day23.txt");
    var res2 = solve2(data);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2023/data/day23_result.txt", 1));
  }
}
