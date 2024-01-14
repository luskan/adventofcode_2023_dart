import 'package:test/test.dart';
import 'package:adventofcode_2023/day12.dart';

void main() {
  test('day12 ...', () async {
    var testData1 = '''
???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1    
''';

    expect(Day12().solve(Day12.parseData(testData1)), equals(21));
    expect(Day12().solve(Day12.parseData(testData1), part2: true), equals(525152));
  });
}
