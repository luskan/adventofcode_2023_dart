import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'common.dart';
import 'day.dart';
import 'solution_check.dart';
import 'package:tuple/tuple.dart';

enum State {
  Operational,
  Damaged,
  Unknown
}

class BrokenSprings {
  List<State> row = [];
  List<int> extraData = [];

  BrokenSprings(this.row, this.extraData);

  @override
  String toString() {
    String rowStr = row.map((e) {
      if (e == State.Operational) {
        return '.';
      }
      else if (e == State.Damaged) {
        return '#';
      }
      else {
        return '?';
      }
    }).join('');
    return '$rowStr ${extraData.join(',')}';
  }
}

@DayTag()
class Day12 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static List<BrokenSprings> parseData(var data) {
    // Parse: #.#.### 1,1,3
    return LineSplitter()
        .convert(data)
        .map((e) => e.split(' '))
        .map((e) => BrokenSprings(e[0].split('').map((e) {
          if (e == '.') {
            return State.Operational;
          }
          else if (e == '#') {
            return State.Damaged;
          }
          else {
            return State.Unknown;
          }
        }).toList(), e[1].split(',').map((e) => int.parse(e)).toList()))
        .toList();
  }

  int findFirstSpanOfLength(List<State> row, int start, int span) {
    int lastPos = -1;
    for (var k = start; k < row.length; k++) {
      int spanLen = 0;
      for (var p = k; p < row.length; p++) {
        if (row[p] == State.Damaged) {
          spanLen++;
        }
        else {
          break;
        }
      }
      if (spanLen == span) {
        lastPos = k;
        break;
      }
    }
    return lastPos;
  }

  bool checkIfRowIsValid(List<State> newRow, List<int> extraData) {

    var totalHashes = 0;
    for (var i in newRow) {
      if (i == State.Damaged) {
        totalHashes++;
      }
    }
    if (totalHashes != extraData.reduce((value, element) => value + element)) {
      return false;
    }

    int lastPos = 0;
    for (var i = 0; i < extraData.length; i++) {
      var span = extraData[i];
      var newLastPos = findFirstSpanOfLength(newRow, lastPos, span);
      if (newLastPos == -1) {
        return false;
      }
      else {
        if (newLastPos > 0 && newRow[newLastPos-1] == State.Damaged) {
          return false;
        }
        if (newLastPos+span < newRow.length && newRow[newLastPos+span] == State.Damaged) {
          return false;
        }
        lastPos = newLastPos + span;
        lastPos++;
      }
    }
    return true;
  }

  int countOnes(int number) {
    int count = 0;
    while (number > 0) {
      number &= (number - 1);
      count++;
    }
    return count;
  }

  int recursivelyCheckRows(int rowIndex, int groupIndex, BrokenSprings bs, Map<Tuple2<int, int>, int> memo) {
    // Check if we already calculated this combination.
    if (memo.containsKey(Tuple2(rowIndex, groupIndex))) {
      return memo[Tuple2(rowIndex, groupIndex)]!;
    }

    if (rowIndex >= bs.row.length) {
      // No more springs left to check.
      if (groupIndex == bs.extraData.length) {
        // And also no more groups left. This is a valid solution.
        memo[Tuple2(rowIndex, groupIndex)] = 1;
        return 1;
      }
      // But there are groups left
      memo[Tuple2(rowIndex, groupIndex)] = 0;
      return 0;
    }

    if (groupIndex == bs.extraData.length) {
      // No more groups to check. Check if there are any damaged springs left.
      for (int i = rowIndex; i < bs.row.length; i++){
        if (bs.row[i] == State.Damaged){
          // If groups are finished and there are still damaged springs left, this is not a valid solution.
          memo[Tuple2(rowIndex, groupIndex)] = 0;
          return 0;
        }
      }

      // All groups were checked and there are no damaged springs left. This is a valid solution.
      memo[Tuple2(rowIndex, groupIndex)] = 1;
      return 1;
    }

    int res = 0;
    if (bs.row[rowIndex] == State.Operational || bs.row[rowIndex] == State.Unknown) {
      res += recursivelyCheckRows(rowIndex + 1, groupIndex, bs, memo);
    }

    if (bs.row[rowIndex] == State.Damaged || bs.row[rowIndex] == State.Unknown) {
      // This is a start of a block. But first check if this block fits the length of row.
      if (rowIndex + bs.extraData[groupIndex] <= bs.row.length) {

        // Check if this group is consecutive (its all ? or # for the length of group) starting from rowIndex
        for (int i = rowIndex; i < rowIndex + bs.extraData[groupIndex]; i++) {
          if (bs.row[i] == State.Operational) {
            memo[Tuple2(rowIndex, groupIndex)] = res;
            return res;
          }
        }

        if (
        // If after this group there are still some spring, then if group is for example 3 then its ### and after it only . or ? can exist: ###. or ###?.
        (rowIndex + bs.extraData[groupIndex] < bs.row.length &&
            bs.row[rowIndex + bs.extraData[groupIndex]] != State.Damaged) ||

            // Check if this group fits the length of row.
            (rowIndex + bs.extraData[groupIndex] == bs.row.length))
        {
          res += recursivelyCheckRows(
              rowIndex + bs.extraData[groupIndex] + 1, groupIndex + 1, bs,
              memo);
        }
      }
    }

    memo[Tuple2(rowIndex, groupIndex)] = res;
    return res;
  }

  int solve(List<BrokenSprings> data, {var part2 = false}) {
    int total = 0;
    if (part2) {
      // Expand 5x
      for (var bs in data) {
        List<State> newRow = [...bs.row];
        List<int> newExtra = [...bs.extraData];

        for (int n = 0; n < 4; ++n) {
          newRow.add(State.Unknown);
          newRow.addAll([...bs.row]);
          newExtra.addAll([...bs.extraData]);
        }
        bs.extraData = newExtra;
        bs.row = newRow;
      }
    }

    for (var row in data) {
      total += recursivelyCheckRows(0, 0, row, <Tuple2<int, int>, int>{});
    }

    return total;
  }

  /**
   * Very slow solution, it increments number and checks every possible comination. For part1 its ok, but for
   * part2 it would take forever.
   */
  int solveVerySlow(List<BrokenSprings> data, {var part2 = false}) {
    int total = 0;

    print("$part2");

    if (part2) {
      // Expand 5x
      for (var bs in data) {
        List<State> newRow = [...bs.row];
        List<int> newExtra = [...bs.extraData];

        for (int n = 0; n < 4; ++n) {
          newRow.add(State.Unknown);
          newRow.addAll([...bs.row]);
          newExtra.addAll([...bs.extraData]);
        }
        bs.extraData = newExtra;
        bs.row = newRow;
        print(bs);
      }
    }

    for (var row in data) {
      var rowLen = row.row.length;
      var extraData = row.extraData;
      int lastPos = 0;
      int valid = 0;

      int unknownCount = row.row.where((element) => element == State.Unknown).length;
      int knownCount = row.row.where((element) => element == State.Damaged).length;

      int maxNum = pow(2, unknownCount).toInt();
      print("$maxNum");
      int totalHashesToFind = extraData.reduce((value, element) => value + element) - knownCount;
      for (var i = 0; i < maxNum; i++) {
        var ones = countOnes(i);
        if (ones != totalHashesToFind) {
          continue;
        }
        var binStr = i.toRadixString(2).padLeft(unknownCount, '0');
        var binStrIndex = 0;
        var newRow = row.row.map((e) => e).toList();
        for (var j = 0; j < rowLen; j++) {
          if (newRow[j] == State.Unknown) {
            newRow[j] = binStr[binStrIndex++] == '1' ? State.Damaged : State.Operational;
          }
        }

        if (checkIfRowIsValid(newRow, extraData)) {
          //print(newRow.join(''));
          valid++;
        }
      }
      total += valid;
    }

    return total;
  }

  @override
  Future<void> run() async {
    print("Day12");

    var data = readData("../adventofcode_input/2023/data/day12.txt");

    var res1 = solve(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2023/data/day12_result.txt", 0));

    var res2 = solve(data, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2023/data/day12_result.txt", 1));
  }
}
