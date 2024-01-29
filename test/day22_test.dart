import 'package:test/test.dart';
import 'package:adventofcode_2023/day22.dart';

void main() {
  test('day22 ...', () async {
    var testData1 = '''
1,0,1~1,2,1
0,0,2~2,0,2
0,2,3~2,2,3
0,0,4~0,2,4
2,0,5~2,2,5
0,1,6~2,1,6
1,1,8~1,1,9
''';

    expect(Day22().solve(Day22.parseData(testData1)), equals(5));
    expect(Day22().solve(Day22.parseData(testData1), part2: true), equals(7));
  });
}
