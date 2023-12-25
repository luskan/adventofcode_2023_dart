import 'package:test/test.dart';
import 'package:adventofcode_2023/day03.dart';

void main() {
  test('day03 ...', () async {
    var testData1 = '''
467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...\$.*....
.664.598..
''';

    expect(Day03().solve(Day03.parseData(testData1)), equals(4361));
    expect(Day03().solve(Day03.parseData(testData1), part2: true), equals(467835));
  });
}
