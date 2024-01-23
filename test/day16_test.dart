import 'package:test/test.dart';
import 'package:adventofcode_2023/day16.dart';

void main() {
  test('day16 ...', () async {
    var testData1 = r'''
.|...\....
|.-.\.....
.....|-...
........|.
..........
.........\
..../.\\..
.-.-/..|..
.|....-|.\
..//.|....
''';

    expect(Day16().solve(Day16.parseData(testData1)), equals(46));
    expect(Day16().solve(Day16.parseData(testData1), part2: true), equals(51));
  });
}
