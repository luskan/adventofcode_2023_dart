import 'package:test/test.dart';
import 'package:adventofcode_2023/day01.dart';

void main() {
  test('day01 ...', () async {
    var testData1 = '''
1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet
''';
    var testData2 = '''
    two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen
''';
    expect(Day01().solve(Day01.parseData(testData1)), equals(142));
    expect(Day01().solve(Day01.parseData(testData2), part2: true), equals(281));
  });
}
