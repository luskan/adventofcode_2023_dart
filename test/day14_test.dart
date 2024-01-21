import 'package:test/test.dart';
import 'package:adventofcode_2023/day14.dart';

void main() {
  test('day14 ...', () async {
    var testData1 = '''
O....#....
O.OO#....#
.....##...
OO.#O....O
.O.....O#.
O.#..O.#.#
..O..#O..O
.......O..
#....###..
#OO..#....
''';

    expect(Day14().solve(Day14.parseData(testData1)), equals(136));
    expect(Day14().solve(Day14.parseData(testData1), part2: true), equals(64));
  });
}
