import 'package:test/test.dart';
import 'package:adventofcode_2023/day21.dart';

void main() {
  test('day21 ...', () async {
    var testData1 = '''
...........
.....###.#.
.###.##..#.
..#.#...#..
....#.#....
.##..S####.
.##..#...#.
.......##..
.##.#.####.
.##..##.##.
...........
''';

    // Those uncommented passes in 1-2 seconds in total
    expect(Day21().solve(Day21.parseData(testData1), maxSteps: 6), equals(16));
    expect(Day21().solve(Day21.parseData(testData1), maxSteps: 10, part2: true), equals(50));
    expect(Day21().solve(Day21.parseData(testData1), maxSteps: 50, part2: true), equals(1594));
    expect(Day21().solve(Day21.parseData(testData1), maxSteps: 100, part2: true), equals(6536));
    expect(Day21().solve(Day21.parseData(testData1), maxSteps: 500, part2: true), equals(167004));

    // It passes but it takes too long to run (but at most few minutes
    //expect(Day21().solve(Day21.parseData(testData1), maxSteps: 1000, part2: true), equals(668697));

    // Never waited for this one...
    //expect(Day21().solve(Day21.parseData(testData1), maxSteps: 5000, part2: true), equals(16733044));
  });
}
