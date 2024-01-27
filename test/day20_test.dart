import 'package:test/test.dart';
import 'package:adventofcode_2023/day20.dart';

void main() {
  test('day20 ...', () async {
    var testData1 = '''
broadcaster -> a, b, c
%a -> b
%b -> c
%c -> inv
&inv -> a
''';

    var testData2 = '''
broadcaster -> a
%a -> inv, con
&inv -> b
%b -> con
&con -> output
''';

    expect(Day20().solve(Day20.parseData(testData1)), equals(32000000));
    expect(Day20().solve(Day20.parseData(testData2)), equals(11687500));
    //expect(Day20().solve(Day20.parseData(testData1), part2: true), equals(30));
  });
}
