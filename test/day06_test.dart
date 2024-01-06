import 'package:test/test.dart';
import 'package:adventofcode_2023/day06.dart';

void main() {
  test('day06 ...', () async {
    var testData1 = '''
Time:      7  15   30
Distance:  9  40  200
''';

    expect(Day06().solve(Day06.parseData(testData1)), equals(288));
    expect(Day06().solve(Day06.parseData(testData1, part2: true), part2: true), equals(71503));
  });
}
