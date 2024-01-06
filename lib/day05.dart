import 'dart:collection';
import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'common.dart';
import 'day.dart';
import 'solution_check.dart';

class Entry {
  int destinationStart;
  int sourceStart;
  int length;

  Entry(this.destinationStart, this.sourceStart, this.length);
}

enum MapType {
  seedToSoil,
  soilToFertilizer,
  fertilizerToWater,
  waterToLight,
  lightToTemperature,
  temperatureToHumidity,
  humidityToLocation
}

class EntryIntervals {
  IntRange src;
  IntRange dst;

  EntryIntervals(this.src, this.dst);
}

class MapEntryIntervals {
  List<EntryIntervals> entries;

  MapEntryIntervals(this.entries);
}

class Almanach {
  var seeds = <int>[];
  var mappings = <MapType, List<Entry>>{};
}

@DayTag()
class Day05 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static Almanach parseData(var data) {
    Almanach almanach = Almanach();
    var lines = new LineSplitter().convert(data);
    for (var i = 0; i < lines.length; i++) {
      var line = lines[i];
      if (line.isEmpty) {
        continue;
      }
      if (line.startsWith("seeds:")) {
        almanach.seeds = line
            .substring(7)
            .split(' ')
            .map((e) => int.parse(e.trim()))
            .toList();
      } else {
        var parts = line.split(' ');
        var mapType = MapType.values.firstWhere((e) =>
            e.toString().toLowerCase() ==
            "maptype.${parts[0].replaceAll('-', '')}");
        for (i++; i < lines.length; i++) {
          if (lines[i].isEmpty) {
            break;
          }
          var parts = lines[i].split(' ');
          if (parts.length != 3) {
            throw Exception("Invalid entry: ${lines[i]}");
          }
          var entry = Entry(
              int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
          if (!almanach.mappings.containsKey(mapType)) {
            almanach.mappings[mapType] = [];
          }
          almanach.mappings[mapType]!.add(entry);
        }
      }
    }
    return almanach;
  }

  int findRangeEntry(List<Entry> list, int source) {
    for (var entry in list) {
      if (entry.sourceStart <= source &&
          entry.sourceStart + entry.length > source) {
        return entry.destinationStart + source - entry.sourceStart;
      }
    }
    return source;
  }

  MapEntryIntervals convertTointervals(List<Entry> entries) {
    var intervals = MapEntryIntervals([]);
    for (var entry in entries) {
      var dst = IntRange(
          entry.destinationStart, entry.destinationStart + entry.length);
      var src = IntRange(entry.sourceStart, entry.sourceStart + entry.length);
      intervals.entries.add(EntryIntervals(src, dst));
    }
    return intervals;
  }

  int solve(Almanach data, {var part2 = false}) {
    if (part2) return solve2(data);
    return solve1(data);
  }

  // ***** Part 1 *****

  int solve1(Almanach data, {var part2 = false}) {
    late List<IntRange> rangedSeed;
    if (part2) {
      // Bruteforce solution, not "very" efficient... never waited for the end of calculation.
      print(
          "calculating part 2 using bruteforce, this may take a while... (or not)");
      rangedSeed = _createInitialSeedIntervals(data.seeds);
      /*
      data.seeds.clear();
      for (var range in rangedSeed) {
        for (var i = range.start; i < range.end; i++) {
          data.seeds.add(i);
        }
      }
      print("seeds: ${data.seeds.length}");
       */
    }

    var maps = <MapType, Map<int, int>>{};
    for (var mapType in data.mappings.keys) {
      if (part2) print("calculating map $mapType");
      maps[mapType] = {};
      if (mapType == MapType.seedToSoil) {
        if (part2) {
          for (var range in rangedSeed) {
            for (var i = range.start; i < range.end; i++) {
              maps[mapType]![i] = findRangeEntry(data.mappings[mapType]!, i);
            }
          }
        } else {
          for (var seed in data.seeds) {
            maps[mapType]![seed] =
                findRangeEntry(data.mappings[mapType]!, seed);
          }
        }
      } else {
        var prev = maps[MapType.values[mapType.index - 1]];
        for (var value in prev!.values) {
          maps[mapType]![value] =
              findRangeEntry(data.mappings[mapType]!, value);
        }
      }
    }

    int lowestLocation = maxInt;
    for (var seed in data.seeds) {
      int prevValue = seed;
      for (var mapType in data.mappings.keys) {
        prevValue = maps[mapType]![prevValue]!;
      }
      //print("Seed $seed -> location: $prevValue");
      if (prevValue < lowestLocation) {
        lowestLocation = prevValue;
      }
    }

    return lowestLocation;
  }

  // ***** Part 2 *****

  int solve2(Almanach data) {
    List<MapEntryIntervals> intervalMappings = _createIntervalMappings(data);
    List<IntRange> currentSource = _createInitialSeedIntervals(data.seeds);

    // General idea is to map the source data to the new intervals, and then merge the overlapping intervals.
    // This is done for each mapping, and the result is used as input for the next mapping
    // The final result is the start of the first interval
    // Initially (currentSource) is a list of intervals that represent the seeds.

    for (var map in intervalMappings) {
      currentSource = _mapSourceToNewIntervals(currentSource, map);
    }

    currentSource.sort((a, b) => a.start.compareTo(b.start));
    return currentSource.first.start;
  }

  List<MapEntryIntervals> _createIntervalMappings(Almanach data) {
    return MapType.values.map((mapType) {
      var entries = data.mappings[mapType]!;
      return convertTointervals(entries);
    }).toList();
  }

  List<IntRange> _createInitialSeedIntervals(List<int> seeds) {
    var seedIntervals = <IntRange>[];
    for (var i = 0; i < seeds.length - 1; i += 2) {
      seedIntervals.add(IntRange(seeds[i], seeds[i] + seeds[i + 1]));
    }
    return seedIntervals;
  }

  List<IntRange> _mapSourceToNewIntervals(
      List<IntRange> source, MapEntryIntervals map) {
    var mappedSource =
        <IntRange>[]; // Holds the source intervals mapped to the new intervals from map
    while (source.isNotEmpty) {
      var srcData = source.removeAt(0);
      if (!_tryMapSourceToDestination(map, srcData, mappedSource, source))
        mappedSource.add(srcData);
    }
    return mappedSource;
  }

  /**
   * @map - the map to use for mapping (example seed -> soil)
   * @srcData - the source data to map (its from source actually)
   * @source - the list of source intervals that were not mapped yet all
   * @mappedSource - the list of mapped source intervals, they will be used in the next
   *          mapping iteration
   *
   */
  bool _tryMapSourceToDestination(MapEntryIntervals map, IntRange srcData,
      List<IntRange> mappedSource, List<IntRange> source) {
    for (var entry in map.entries) {
      var intersection = intersect(srcData, entry.src);
      if (intersection.isNotEmpty()) {
        // Mapped data (initially seed then soil, etc.), we put it into the mappedSource list for the next mapping
        // iteration.
        mappedSource.add(_createMappedSource(intersection, entry));

        // Intersection could happen in the middle of the source interval, so we
        // need to add the remaining parts if any are present. According to rules
        // they should be mapped 1:1, but they are put back to source as they might
        // actually intersect with some next entry. If they don't, they will be
        // added to the mappedSource later in the outer loop. The interesting thing
        // is that in test data they never intersect, but in real data they do.
        // So replacing here source to mappedSource would work for test data, but
        // not for real data.
        _addRemainingIntervals(srcData, intersection, source);

        return true;
      }
    }
    return false;
  }

  IntRange _createMappedSource(IntRange intersection, EntryIntervals entry) {
    return IntRange(entry.dst.start + intersection.start - entry.src.start,
        entry.dst.start + intersection.end - entry.src.start);
  }

  void _addRemainingIntervals(
      IntRange srcData, IntRange intersection, List<IntRange> source) {
    if (srcData.start < intersection.start) {
      source.add(IntRange(srcData.start, intersection.start));
    }
    if (srcData.end > intersection.end) {
      source.add(IntRange(intersection.end, srcData.end));
    }
  }

  @override
  Future<void> run() async {
    print("Day05");

    var data = readData("../adventofcode_input/2023/data/day05.txt");

    var res1 = solve(data);
    print('Part1: $res1');
    verifyResult(res1,
        getIntFromFile("../adventofcode_input/2023/data/day05_result.txt", 0));

    var res2 = solve(data, part2: true);
    print('Part2: $res2');
    verifyResult(res2,
        getIntFromFile("../adventofcode_input/2023/data/day05_result.txt", 1));
  }
}
