import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'common.dart';
import 'day.dart';
import 'solution_check.dart';
import 'package:more/more.dart';
import 'package:collection/collection.dart';

class Edge {
  String from;
  String to;
  String orgFrom="";
  String orgTo="";
  bool isLoop() {
    return from == to;
  }


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Edge &&
          runtimeType == other.runtimeType &&
          from == other.from &&
          to == other.to &&
          orgFrom == other.orgFrom &&
          orgTo == other.orgTo;

  @override
  int get hashCode =>
      from.hashCode ^ to.hashCode ^ orgFrom.hashCode ^ orgTo.hashCode;


  Edge(this.from, this.to, this.orgFrom, this.orgTo);

  void restore() {
    from = orgFrom;
    to = orgTo;
  }

  Edge clone() {
    return Edge(from, to, orgFrom, orgTo);
  }
}

class PGraph {
  Map<String, List<Edge>> connections = {};

  void addEdge(String from, String to) {
    if (connections[from]?.any((e) => e.from == from && e.to == to) ?? false)
      return;
    var edge = Edge(from, to, from, to);
    if (!connections.containsKey(from)) {
      connections[from] = [];
    }
    connections[from]!.add(edge);

    if (!connections.containsKey(to)) {
      connections[to] = [];
    }
    connections[to]!.add(edge);
  }

  // Remove specified edge from the graph. The two nodes become a single nod
  void contractEdge(String from, String to) {
    // "from" is the node to remove. It is contracted to "to" node


    //var t1 = Stopwatch()..start();

    // Assuming connections is a Map<dynamic, Set<Edge>> where Edge is a class that has 'from' and 'to' properties
    var oldEdges = connections.remove(from); // Directly remove 'from' and retrieve its edges
    if (oldEdges != null) {
      connections[to]?.addAll(oldEdges); // Safely add all old edges to 'to', if 'to' exists
    }

    connections.forEach((node, edges) { // Iterate over each node and its edges
      edges.forEach((e) { // Check each edge of the node
        if (e.from == from) { // If edge's 'from' is 'from', update it to 'to'
          e.from = to;
        }
        if (e.to == from) { // Similarly, if edge's 'to' is 'from', update it to 'to'
          e.to = to;
        }
      });
    });


    /*
    var oldEdges = connections[from]!;
    connections.remove(from);
    connections[to]!.addAll(oldEdges);

    for (var node in connections.keys) {
      for (var e in connections[node]!) {
        if (e.from == from) {
          e.from = to;
        }
        if (e.to == from) {
          e.to = to;
        }
      }
    }

     */

    //connections[node]!.removeWhere((e) => e.isLoop());

    //var v1 = connections[to]!;
    //var v2 = v1.toSet();
    //var v3 = v2.toList();
//    connections[to] = v3;



    //print('Recreate: ${t1.elapsed.toString()}');
  }


  var visited = <String>{};
  var stack = <String>[];
  Map<String, int> visitedCounts = {};
  int countGraphNodes([List<Edge> edgesToIgnore = const <Edge>[]]) {
    visited.clear();
    stack.clear();
    visitedCounts.clear();
    stack.add(connections.keys.first);
    while (stack.isNotEmpty) {
      var node = stack.removeLast();
      if (visited.contains(node)) {
        continue;
      }
      visited.add(node);
      visitedCounts.update(node, (value) => value + 1, ifAbsent: () => 1);
      var edges = connections[node]!;
      for (var n in edges) {
        if (edgesToIgnore.any((edg) => edg.from == n.from && edg.to == n.to || edg.from == n.to && edg.to == n.from)) {
          continue;
        }
        if (n.isLoop())
          continue;
        stack.add(n.to);
      }
    }
    return visited.length;
  }

  void printGraph() {
    print("");
    for (var node in connections.keys.sorted((a, b) => a.compareTo(b))) {
      var edges = connections[node]!
          //.where((e) => e.from == node)
          .fold<String>("", (value, element) => value + " ${element.from}->${element.to},");
      print("$node: ${edges}");
    }
  }
}

class Connection {
  String from = "";
  String to = "";
  Connection(this.from, this.to);
}

@DayTag()
class Day25 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static List<List<String>> parseData(var data) {
    return LineSplitter()
        .convert(data)
        .map((e) => e.split(RegExp(r'[: ]+'))).toList();
  }

  PGraph _buildGraph(List<List<String>> data) {
    var graph = PGraph();
    for (var line in data) {
      for (int k = 1; k < line.length; ++k) {
        graph.addEdge(line[0], line[k]);
        graph.addEdge(line[k], line[0]);
      }
    }
    return graph;
  }

  int solve(List<List<String>> data, {var part2 = false}) {
    //return solve_kargers(data, part2: part2);
    //return solve_brute_force(data, part2: part2);
    return solve_stoer_wagner_mincut(data, part2: part2);
  }

  /**
   * Library solution, ~2s
   */
  int solve_stoer_wagner_mincut(List<List<String>> data, {var part2 = false}) {
    Graph g = Graph.undirected();
    for (var line in data) {
      for (int k = 1; k < line.length; ++k) {
        g.addEdge(line[0], line[k]);
      }
    }
    var minCut = AlgorithmsGraphExtension(g).minCut();
    return minCut.graphs.fold<int>(1, (value, element) => value * element.vertices.length);
  }

  /**
   * Karger's algorithm
   * 1. Choose a random edge
   * 2. Contract the edge
   * 3. Repeat until only two nodes are left
   * 4. Count the number of edges between the two nodes
   * 5. Return the number of edges
   *
   * Takes randomly around 0.5 to 2 minutes
   */
  int solve_kargers(List<List<String>> data, {var part2 = false}) {
    var total = 0;

    PGraph graph = _buildGraph(data);
    PGraph graphOrg = _buildGraph(data);
    var rng = Random();
    List<Edge> edges = [];
    Set<Edge> checkedEdges = {};
    bool done = false;
    int testId = 0;
    while (!done) {

      // Bring graph to original state
      var t1 = Stopwatch()..start();
      graph.connections = graphOrg
          .connections
          .map((key, value) => MapEntry(key, List<Edge>.generate(value.length, (index) => value[index].clone())));

      testId++;
      while (true) {
        edges.clear();
        for (var node in graph.connections.keys) {
          graph.connections[node]!.forEach((e) {
            if (e.isLoop())
              return;
            edges.add(e);
          });
        }
        int totalEdges = edges.length;
        var randomEdge = edges[rng.nextInt(totalEdges)];

        // Contract this edge
        graph.contractEdge(randomEdge.from, randomEdge.to);

        if (graph.connections.keys.length == 2) {
          print("Test $testId");
          var minCutEdges = List<Edge>.empty(growable: true);
          for (var key in graph.connections.keys) {
            graph.connections[key]!.forEach((e) {
              if (e.isLoop())
                return;
              if (minCutEdges.any((element) =>
              element.orgFrom == e.orgTo && element.orgTo == e.orgFrom
                  || element.orgFrom == e.orgFrom && element.orgTo == e.orgTo))
                return;
              minCutEdges.add(Edge(e.from, e.to, e.orgFrom, e.orgTo));
            });
          }
          if (minCutEdges.length == 3) {
            minCutEdges.forEach((e) {
              e.restore();
            });
            int nodesCount = graphOrg.countGraphNodes(minCutEdges);
            total = nodesCount * (graphOrg.connections.keys.length - nodesCount);
            done = true;
            break;
          }
          else {
            break;
          }
        }
      }

    }

    return total;
  }

  // Uses Bruteforce aproach, choose all combinations of three edges
  // Way too slow
  int solve_brute_force(List<List<String>> data, {var part2 = false}) {
    var total = 0;

    PGraph graph = _buildGraph(data);

    List<Edge> edges = [];
    for (var node in graph.connections.keys) {
      graph.connections[node]!.forEach((e) {
        edges.add(e);
      });
    }

    for (var i = 0; i < edges.length; i+=2) {
      for (var j = i + 2; j < edges.length; j+=2) {
        for (var k = j + 2; k < edges.length; k+=2) {
          var edgesToIgnore = [edges[i], edges[j], edges[k]];
          int nodesCount = graph.countGraphNodes(edgesToIgnore);
          var res = nodesCount * (graph.connections.keys.length - nodesCount);
          if (res != 0) {
            total = res;
            return total;
          }
        }
      }
    }

    return 0;
  }

  @override
  Future<void> run() async {
    print("Day25");

    var data = readData("../adventofcode_input/2023/data/day25.txt");

    var res1 = solve(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2023/data/day25_result.txt", 0));
  }
}
