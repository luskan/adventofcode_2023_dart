import 'package:test/test.dart';
import 'package:adventofcode_2023/day15.dart';

void main() {
  test('day15 ...', () async {
    var testData1 = '''
rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7
''';

    expect(Day15().solve(Day15.parseData(testData1)), equals(1320));
    expect(Day15().solve(Day15.parseData(testData1), part2: true), equals(145));
  });
}
