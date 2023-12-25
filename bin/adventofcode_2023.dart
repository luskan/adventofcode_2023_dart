import 'dart:mirrors';
import 'package:adventofcode_2023/day.dart';
import 'package:adventofcode_2023/day01.dart';
import 'package:adventofcode_2023/day02.dart';
import 'package:adventofcode_2023/day03.dart';

import 'dart:developer';
import 'package:worker_manager/worker_manager.dart';

void main(List<String> arguments) async {
  //await Executor().warmUp(log: true);

  var days = <Day>[
    Day01(),
    Day02(),
    Day03(),
  ];

  for (var day in days) {
    var sw = Stopwatch()..start();
    await day.run();
    print('Profile: ${sw.elapsed.toString()}');
  }

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
