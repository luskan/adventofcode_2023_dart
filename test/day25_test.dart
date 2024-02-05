import 'package:test/test.dart';
import 'package:adventofcode_2023/day25.dart';

void main() {
  test('day25 ...', () async {
    var testData1 = '''
jqt: rhn xhk nvd
rsh: frs pzl lsr
xhk: hfx
cmg: qnr nvd lhk bvb
rhn: xhk bvb hfx
bvb: xhk hfx
pzl: lsr hfx nvd
qnr: nvd
ntq: jqt hfx bvb xhk
nvd: lhk
lsr: lhk
rzs: qnr cmg lsr rsh
frs: qnr lhk lsr
''';

    var testData2 = '''
a: b d
b: a d c
c: b e f
d: a b e
e: d b c f g
f: c e g
g: e f
''';

    expect(Day25().solve(Day25.parseData(testData1)), equals(54));
  });
}
