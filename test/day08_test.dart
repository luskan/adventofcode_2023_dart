import 'package:test/test.dart';
import 'package:adventofcode_2023/day08.dart';

void main() {
  test('day08 ...', () async {
    var testData1 = '''
RL

AAA = (BBB, CCC)
BBB = (DDD, EEE)
CCC = (ZZZ, GGG)
DDD = (DDD, DDD)
EEE = (EEE, EEE)
GGG = (GGG, GGG)
ZZZ = (ZZZ, ZZZ)  
''';

    var testData2 = '''
LLR

AAA = (BBB, BBB)
BBB = (AAA, ZZZ)
ZZZ = (ZZZ, ZZZ)    
''';

    expect(Day08().solve(Day08.parseData(testData1)), equals(2));
    expect(Day08().solve(Day08.parseData(testData2)), equals(6));

    var testData3 = '''
LR

11A = (11B, XXX)
11B = (XXX, 11Z)
11Z = (11B, XXX)
22A = (22B, XXX)
22B = (22C, 22C)
22C = (22Z, 22Z)
22Z = (22B, 22B)
XXX = (XXX, XXX)
''';

    expect(Day08().solve(Day08.parseData(testData3), part2: true), equals(6));
  });
}
