import 'package:test/test.dart';
import 'package:adventofcode_2023/day07.dart';

void main() {
  test('day07 ...', () async {
    var testData1 = '''
32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483
''';

    expect(Day07().solve(Day07.parseData(testData1)), equals(6440));
    expect(Day07().solve(Day07.parseData(testData1), part2: true), equals(5905));
  });
}
