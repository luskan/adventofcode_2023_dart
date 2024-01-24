import 'package:test/test.dart';
import 'package:adventofcode_2023/day17.dart';

void main() {
  test('day17 ...', () async {
    var testData1 = r'''
2413432311323
3215453535623
3255245654254
3446585845452
4546657867536
1438598798454
4457876987766
3637877979653
4654967986887
4564679986453
1224686865563
2546548887735
4322674655533
''';

    var testData2 = r'''
111111111111
999999999991
999999999991
999999999991
999999999991
''';

    expect(Day17().solve(Day17.parseData(testData1)), equals(102));
    expect(Day17().solve(Day17.parseData(testData1), part2: true), equals(94));
    expect(Day17().solve(Day17.parseData(testData2), part2: true), equals(71));

  });
}
