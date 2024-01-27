import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'common.dart';
import 'day.dart';
import 'solution_check.dart';


enum ModuleType { FlipFlop, Conjunction, Broadcaster }
enum PulseType { High, Low }

class Pulse {
  PulseType type;
  String source;
  String destination;

  Pulse(this.type, this.source, this.destination);
}

abstract class Module {
  ModuleType type;
  String name;
  List<String> destination;

  List<Pulse> receive(Pulse pulse);
  void reset();

  Module(this.type, this.name, this.destination);
}

class FlipFlop extends Module {
  bool on = false;

  @override
  void reset() {
    on = false;
  }

  @override
  List<Pulse> receive(Pulse pulse) {
    if (pulse.type == PulseType.High)
      return [];
    var res = destination.map((e) => Pulse(!on ? PulseType.High : PulseType.Low, name, e)).toList();
    on = !on;
    return res;
  }
  FlipFlop(String name, List<String> dst) : super(ModuleType.FlipFlop, name, dst);
}

class Conjunction extends Module {
  Conjunction(String name, List<String> dst) : super(ModuleType.Conjunction, name, dst);

  Map<String, PulseType> memory = {};

  @override
  void reset() {
    memory.clear();
  }

  bool isHigh() {
    for (var v in memory.values) {
      if (v == PulseType.Low)
        return false;
    }
    return true;
  }

  @override
  List<Pulse> receive(Pulse pulse) {
    memory[pulse.source] = pulse.type;
    PulseType newPulseType = isHigh() ? PulseType.Low : PulseType.High;
    var res = destination.map((e) => Pulse(newPulseType, name, e)).toList();
    return res;
  }

  void addInput(String name) {
    memory[name] = PulseType.Low;
  }
}

class Broadcaster extends Module {
  Broadcaster(String name, List<String> dst) : super(ModuleType.Broadcaster, name, dst);

  @override
  void reset() {
  }

  @override
  List<Pulse> receive(Pulse pulse) {
    return destination.map((e) => Pulse(pulse.type, name, e)).toList();
  }
}

@DayTag()
class Day20 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static List<Module> parseData(var data) {
    return LineSplitter()
        .convert(data)
        .map((e) {
      var split = e.split(' -> ');
      ModuleType type = split[0] == 'broadcaster'
          ? ModuleType.Broadcaster
          : split[0][0] == '%' ? ModuleType.FlipFlop : ModuleType.Conjunction;

      String name = type == ModuleType.Broadcaster ? split[0] : split[0]
          .substring(1);
      var dests = split[1]
          .split(',')
          .map((e) => e.trim())
          .toList();
      Module newModule;
      switch(type) {
        case ModuleType.Broadcaster:
          newModule = Broadcaster(name, dests);
          break;
        case ModuleType.Conjunction:
          newModule = Conjunction(name, dests);
          break;
        case ModuleType.FlipFlop:
          newModule = FlipFlop(name, dests);
          break;
      }
      return newModule;
    }).toList();
  }

  int solve(List<Module> data, {var part2 = false}) {
    int total = 0;

    var modules = <String, Module>{};
    for (var e in data) {
      modules[e.name] = e;
    }

    // For part 2 we will collect the modules which should sent high pulse to rx input module. Its
    // input module is &vd, and we need to know when each vs input is sending high to vd at the same moment.
    //
    List<String> vdInputs = [];
    List<List<int>> vdInputsHigh = []; // List of lists of ints, each list contains the time when the vd input was high.

    if (part2) {
      List<String> rxInputs = [];
      for (var e in data) {
        if (e.destination.contains("rx")) {
          rxInputs.add(e.name);
        }
      }
      for (var e in data) {
        for (var rxi in rxInputs) {
          if (e.destination.contains(rxi)) {
            vdInputs.add(e.name);
            vdInputsHigh.add([]);
          }
        }
      }
    }

    // Init Conjunctions input memory to low.
    for (var e in data) {
      if (e.type == ModuleType.Conjunction) {
        var conj = e as Conjunction;
        for (var e in data) {
          if (e.destination.contains(conj.name)) {
            conj.addInput(e.name);
          }
        }
      }
    }

    int low = 0, hi = 0;
    var done = false;
    int count = 0;
    for (; part2 ? !done : count < 1000; ++count) {
      List<Pulse> pulses = [Pulse(PulseType.Low, "", "broadcaster")];

      while (pulses.isNotEmpty) {
        var newPulses = <Pulse>[];

        if (part2) {

          // Collect button down counts for high pulses to vd
          for (var pulse in pulses) {
            if (pulse.type == PulseType.Low)
              continue;
            if (vdInputs.contains(pulse.source)) {
              var i = vdInputs.indexOf(pulse.source);
              vdInputsHigh[i].add(count);
            }
          }

          // Find cycles lengths for the high vd inputs
          List<int> cycles = [];
          for (var i = 0; i < vdInputsHigh.length; ++i) {
            var ins = vdInputsHigh[i];
            if (ins.length > 3) {
              var diff = ins[2] - ins[1];
              if (ins[2] + diff == ins[3]) {
                cycles.add(diff);
              }
            }
          }

          // If all cycles were found then calculate lcm of them and we are done.
          if (cycles.length == vdInputsHigh.length) {
            total = lcmOfList(cycles);
            done = true;
            break;
          }
        }

        for (var pulse in pulses) {
          if (pulse.type == PulseType.Low)
            low++;
          else
            hi++;

          if (pulse.destination == "output") {
            continue;
          }
          if (pulse.destination == "rx") {
            if (pulse.type == PulseType.Low)
              done = true;
            continue;
          }

          var module = modules[pulse.destination]!;
          var res = module.receive(pulse);
          newPulses.addAll(res);
        }
        pulses = newPulses;
      }
    }

    if (!part2)
      total = low * hi;
    return total;
  }

  @override
  Future<void> run() async {
    print("Day20");

    var data = readData("../adventofcode_input/2023/data/day20.txt");

    var res1 = solve(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2023/data/day20_result.txt", 0));

    var res2 = solve(data, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2023/data/day20_result.txt", 1));
  }
}
