import 'dart:mirrors';
import 'package:adventofcode_2023/day.dart';
import 'package:adventofcode_2023/day01.dart';
import 'package:adventofcode_2023/day02.dart';
import 'package:adventofcode_2023/day03.dart';
import 'package:adventofcode_2023/day04.dart';
import 'package:adventofcode_2023/day05.dart';
import 'package:adventofcode_2023/day06.dart';
import 'package:adventofcode_2023/day07.dart';
import 'package:adventofcode_2023/day08.dart';
import 'package:adventofcode_2023/day09.dart';
import 'package:adventofcode_2023/day10.dart';
import 'package:adventofcode_2023/day11.dart';
import 'package:adventofcode_2023/day12.dart';
import 'package:adventofcode_2023/day13.dart';
import 'package:adventofcode_2023/day14.dart';
import 'package:adventofcode_2023/day15.dart';
import 'package:adventofcode_2023/day16.dart';
import 'package:adventofcode_2023/day17.dart';
import 'package:adventofcode_2023/day18.dart';
import 'package:adventofcode_2023/day19.dart';
import 'package:adventofcode_2023/day20.dart';
import 'package:adventofcode_2023/day21.dart';
import 'package:adventofcode_2023/day22.dart';
import 'package:adventofcode_2023/day23.dart';
import 'package:adventofcode_2023/day24.dart';
import 'package:adventofcode_2023/day25.dart';

import 'dart:developer';
import 'package:worker_manager/worker_manager.dart';

void main(List<String> arguments) async {
  //await Executor().warmUp(log: true);

  var days = <Day>[
    Day01(),
    Day02(),
    Day03(),
    Day04(),
    Day05(),
    Day06(),
    Day07(),
    Day08(),
    Day09(),
    Day10(),
    Day11(),
    Day12(),
    Day13(),
    Day14(),
    Day15(),
    Day16(),
    Day17(),
    Day18(),
    Day19(),
    Day20(),
    Day21(),
    Day22(),
    Day23(),
    Day24(),
    Day25(),
  ];

  var swTotal = Stopwatch()..start();
  for (var day in days) {
    var sw = Stopwatch()..start();
    await day.run();
    print('Profile: ${sw.elapsed.toString()}');
  }
  print('Total: ${swTotal.elapsed.toString()}');

  /*
  // Turned off as it does not alow to await for run method
  MirrorSystem mirrorSystem = currentMirrorSystem();
  mirrorSystem.libraries.forEach((lk, l) {
    l.declarations.forEach((dk, d) {
      if (d is ClassMirror) {
        ClassMirror cm = d as ClassMirror;
        cm.metadata.forEach((md) async {
          InstanceMirror metadata = md as InstanceMirror;
          if (metadata.type == reflectClass(DayTag)) {
            //print('found: ${cm.simpleName}');
            var day = cm.newInstance(Symbol.empty, []);
            var dd = day.reflectee;
            //Timeline.startSync('Profile: ${cm.simpleName}');
            var sw = Stopwatch()..start();
            await dd.run();
            print('Profile: ${sw.elapsed.toString()}');
          }
        });
      }
    });
  });
  */
}
