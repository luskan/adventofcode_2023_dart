import 'dart:io';
import 'dart:convert';
import 'package:adventofcode_2023/common.dart';

import 'day.dart';
import 'solution_check.dart';

enum Color {
  red,
  green,
  blue,
}

class Cubes {
  Color color;
  int count;
  Cubes(this.color, this.count);
}

class GameSubset {
  List<Cubes> cubes;
  GameSubset(this.cubes);
}

class Game {
  int id;
  List<GameSubset> subsets;
  Game(this.id, this.subsets);
}

@DayTag()
class Day02 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static List<Game> parseData(var data) {
    var games = <Game>[];
    for (var line in LineSplitter().convert(data)) {
      var split = line.split(':');
      int gameId = int.parse(RegExp(r'\d+').firstMatch(split[0])!.group(0)!);
      Game game = Game(gameId, []);
      games.add(game);
      for (var sub in split[1].split(';')) {
        GameSubset subset = GameSubset([]);
        game.subsets.add(subset);
        for (var cub in sub.split(',')) {
          Color? color;
          var count = 0;
          var cubSplit = cub.toLowerCase().trim().split(' ');
          for (var c in Color.values) {
            if (c.name == cubSplit[1]) {
              color = c;
              break;
            }
          }
          if (color == null)
            throw Exception("Invalid color: ${cubSplit[0]}" );
          count = int.parse(cubSplit[0]);
          subset.cubes.add(Cubes(color, count));
        }
      }
    }
    return games;
  }


  int solve(List<Game> data, {var part2 = false}) {
    int total = 0;

    // only 12 red cubes, 13 green cubes, and 14 blue cubes
    for (var game in data) {
      var isOk = true;

      // For part2
      var minRed = 0;
      var minGreen = 0;
      var minBlue = 0;

      for (var subset in game.subsets) {
        var red = 0;
        var green = 0;
        var blue = 0;
        for (var cub in subset.cubes) {
          if (cub.color == Color.red)
            red += cub.count;
          else if (cub.color == Color.green)
            green += cub.count;
          else if (cub.color == Color.blue)
            blue += cub.count;
        }
        if (part2) {
          if (red > minRed) {
            minRed = red;
          }
          if (green > minGreen) {
            minGreen = green;
          }
          if (blue > minBlue) {
            minBlue = blue;
          }
        }
        else {
          if (!(red <= 12 && green <= 13 && blue <= 14)) {
            isOk = false;
            break;
          }
        }
      }
      if (part2) {
       total += minRed*minGreen*minBlue;
      } else {
        if (isOk)
          total += game.id;
      }
    }

    return total;
  }

  int solve2(var data) {
    return 0;
  }

  @override
  Future<void> run() async {
    print("Day02");

    var data = readData("../adventofcode_input/2023/data/day02.txt");

    var res1 = solve(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2023/data/day02_result.txt", 0));

    var res2 = solve(data, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2023/data/day02_result.txt", 1));
  }
}
