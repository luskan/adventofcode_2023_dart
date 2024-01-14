import 'package:test/test.dart';
import 'package:adventofcode_2023/day10.dart';

void main() {
  test('day10 ...', () async {
    var testData1 = '''
.....
.S-7.
.|.|.
.L-J.
.....
''';

    var testData2 = '''
...........
.S-------7.
.|F-----7|.
.||.....||.
.||.....||.
.|L-7.F-J|.
.|..|.|..|.
.L--J.L--J.
...........
''';

    var testData3 = '''
.F----7F7F7F7F-7....
.|F--7||||||||FJ....
.||.FJ||||||||L7....
FJL7L7LJLJ||LJ.L-7..
L--J.L7...LJS7F-7L7.
....F-J..F7FJ|L7L7L7
....L7.F7||L7|.L7L7|
.....|FJLJ|FJ|F7|.LJ
....FJL-7.||.||||...
....L---J.LJ.LJLJ...
''';

    var testData5 = '''
FF7FSF7F7F7F7F7F---7
L|LJ||||||||||||F--J
FL-7LJLJ||||||LJL-77
F--JF--7||LJLJ7F7FJ-
L---JF-JLJ.||-FJLJJ7
|F|F-JF---7F7-L7L|7|
|FFJF7L7F-JF7|JL---7
7-L-JL7||F7|L7F-7F7|
L.L7LFJ|||||FJL7||LJ
L7JLJL-JLJLJL--JLJ.L
''';
    
    var testData4 = '''
..........
.S------7.
.|F----7|.
.||....||.
.||....||.
.|L-7F-J|.
.|..||..|.
.L--JL--J.
..........
''';    

    expect(Day10().solve(Day10.parseData(testData1)), equals(4));
    expect(Day10().solve(Day10.parseData(testData2), part2: true), equals(4));
    expect(Day10().solve(Day10.parseData(testData4), part2: true), equals(4));

    expect(Day10().solve(Day10.parseData(testData3), part2: true), equals(8));
    expect(Day10().solve(Day10.parseData(testData5), part2: true), equals(10));
  });
}
