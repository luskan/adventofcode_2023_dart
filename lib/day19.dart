import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'common.dart';
import 'day.dart';
import 'solution_check.dart';

class Part {
  var ratings = <String, int>{};
}

enum Operation { Less, Greater, None }

class Rule {
  String rating;
  Operation operation;
  int value;
  String nextWorkFlow;

  Rule(this.rating, this.operation, this.value, this.nextWorkFlow);


  @override
  String toString() {
    return 'R{$rating, $operation, $value, $nextWorkFlow}';
  }

  Rule invert() {
    if (operation == Operation.Less) {
      return Rule(rating, Operation.Greater, max(0, value-1), nextWorkFlow);
    }
    else if (operation == Operation.Greater) {
      return Rule(rating, Operation.Less, min(4000,value+1), nextWorkFlow);
    }
    else {
      return Rule(rating, Operation.None, value, nextWorkFlow);
    }
  }
}

class Workflow {
  String name;
  List<Rule> rules = [];

  Workflow(this.name, this.rules);
}

class Mineral {
  var rating = <String, int>{};
}

class MineralProcessing {
  Map<String, Workflow> workflows = {};
  List<Mineral> minerals = [];
}

@DayTag()
class Day19 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static MineralProcessing parseData(var data) {
    //px{a<2006:qkq,m>2090:A,rfg}
    //{x=787,m=2655,a=1222,s=2876}
    MineralProcessing mp = MineralProcessing();

    var rg = RegExp(r'^(?<name>\w+)\{(?<rules>.*)\}$');
    var rgMaterial = RegExp(r'^\{(?<ratings>.*)\}$');
    bool materials = false;
    LineSplitter().convert(data).forEach((line) {
      if (line.isEmpty) {
        materials = true;
      } else if (!materials) {
        var m = rg.firstMatch(line)!;
        var name = m.namedGroup("name")!;
        var rules = m.namedGroup("rules")!;
        var split = rules.split(',');
        var workflow = Workflow(name, []);
        mp.workflows[name] = workflow;
        for (var s in split) {
          var rule = s.split(':');
          if (rule.length == 1) {
            workflow.rules.add(Rule('', Operation.None, 0, rule[0]));
            break;
          }
          var rating = rule[0][0];
          var operation = rule[0][1];
          var value = int.parse(rule[0].substring(2));
          var nextWorkFlow = rule[1];
          workflow.rules.add(Rule(rating,
              operation == '<' ? Operation.Less : Operation.Greater, value, nextWorkFlow));
        }
      }
      else {
        var m = rgMaterial.firstMatch(line)!;
        var ratings = m.namedGroup("ratings")!;
        var split = ratings.split(',');
        var mineral = Mineral();
        for (var s in split) {
          var rating = s.split('=');
          mineral.rating[rating[0]] = int.parse(rating[1]);
        }
        mp.minerals.add(mineral);
      }
    });

    return mp;
  }

  /**
   * This is a recursive function that will collect all the rules from the workflows and then
   * it will calculate the intervals for each rating. Some rules does not match but we need to
   * remove their combination range from the result so we add those rules as inverted into a collectedRules.
   * When finishing workflow A is reached, we cut the initial range to the collected rules (those that matchd and
   * those that didnt matched and were inverted).
   */
  void rulesRecursiveProcessing(MineralProcessing data, String workFlowName, List<Rule> collectedRules, List<List<IntRange>> results) {
    if (workFlowName == "A") {
      var minMax = { 'x': [1, 4000], 'm': [1, 4000], 'a': [1, 4000], 's': [1, 4000] };
      for (var r in collectedRules) {
        if (r.operation == Operation.Less) {
          minMax[r.rating]![1] = min(minMax[r.rating]![1], r.value - 1);
          assert(minMax[r.rating]![0] <= minMax[r.rating]![1]);
        }
        else if (r.operation == Operation.Greater) {
          minMax[r.rating]![0] = max(minMax[r.rating]![0], r.value + 1);
          assert(minMax[r.rating]![0] <= minMax[r.rating]![1]);
        }
      }
      results.add([
        IntRange(minMax['x']![0], minMax['x']![1]),
        IntRange(minMax['m']![0], minMax['m']![1]),
        IntRange(minMax['a']![0], minMax['a']![1]),
        IntRange(minMax['s']![0], minMax['s']![1]),
      ]);
      return;
    }
    if (workFlowName == "R") {
      return;
    }
    List<Rule> tmp = [];
    for (var r in data.workflows[workFlowName]!.rules) {
      rulesRecursiveProcessing(data, r.nextWorkFlow, [...collectedRules, ...tmp, r], results);
      tmp.add(r.invert());
    }
  }

  int solve(MineralProcessing data, {var part2 = false}) {
    int total = 0;

    if (part2) {
      List<List<IntRange>> intervals = [];
      rulesRecursiveProcessing(data, "in", [], intervals);
      for (var interval in intervals) {
        total += interval.fold(1, (previousValue, element) => previousValue * (element.isEmpty() ? 0 : element.length()+1));
      }
      return total;
    }
    else {
      List<Mineral> accepted = [];
      List<Mineral> rejected = [];

      for (var m in data.minerals) {
        var workflow = data.workflows["in"]!;

        bool isDone = false;
        while (!isDone) {
          for (var rule in workflow.rules) {
            bool isTrue = false;
            if (rule.operation == Operation.None) {
              isTrue = true;
            }
            else if (rule.operation == Operation.Less ? m.rating[rule.rating]! <
                rule.value : m.rating[rule.rating]! > rule.value) {
              isTrue = true;
            }
            if (isTrue) {
              if (rule.nextWorkFlow == "A") {
                accepted.add(m);
                isDone = true;
              }
              else if (rule.nextWorkFlow == "R") {
                rejected.add(m);
                isDone = true;
              }
              else {
                workflow = data.workflows[rule.nextWorkFlow]!;
              }
              break;
            }
          }
        }
      }

      for (var m in accepted) {
        for (var rating in m.rating.values) {
          total += rating;
        }
      }
    }

    return total;
  }

  @override
  Future<void> run() async {
    print("Day19");

    var data = readData("../adventofcode_input/2023/data/day19.txt");

    var res1 = solve(data);
    print('Part1: $res1');
    verifyResult(res1,
        getIntFromFile("../adventofcode_input/2023/data/day19_result.txt", 0));

    var res2 = solve(data, part2: true);
    print('Part2: $res2');
    verifyResult(res2,
        getIntFromFile("../adventofcode_input/2023/data/day19_result.txt", 1));
  }
}
