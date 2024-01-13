import 'package:test/test.dart';
import 'package:adventofcode_2023/day09.dart';

void main() {
  test('day09 ...', () async {
    var testData1 = '''
0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45
''';

    expect(Day09().solve(Day09.parseData(testData1)), equals(114));
    expect(Day09().solve(Day09.parseData(testData1), part2: true), equals(2));
  });
}
