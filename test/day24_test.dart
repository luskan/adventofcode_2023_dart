import 'package:test/test.dart';
import 'package:adventofcode_2023/day24.dart';

void main() {
  test('day24 ...', () async {
    var testData1 = '''
19, 13, 30 @ -2,  1, -2
18, 19, 22 @ -1, -1, -2
20, 25, 34 @ -2, -2, -4
12, 31, 28 @ -1, -2, -1
20, 19, 15 @  1, -5, -3
''';

    expect(Day24().solve(Day24.parseData(testData1), minX: 7.0, maxX: 27.0, minY: 7.0, maxY: 27.0), equals(2));
    expect(Day24().solve(Day24.parseData(testData1), part2: true), equals(47));
  });
}
