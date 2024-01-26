import 'package:adventofcode_2023/common.dart';
import 'package:test/test.dart';
import 'package:adventofcode_2023/day19.dart';

void main() {
  test('day19 ...', () async {
    var testData1 = '''
px{a<2006:qkq,m>2090:A,rfg}
pv{a>1716:R,A}
lnx{m>1548:A,A}
rfg{s<537:gd,x>2440:R,A}
qs{s>3448:A,lnx}
qkq{x<1416:A,crn}
crn{x>2662:A,R}
in{s<1351:px,qqz}
qqz{s>2770:qs,m<1801:hdj,R}
gd{a>3333:R,R}
hdj{m>838:A,pv}

{x=787,m=2655,a=1222,s=2876}
{x=1679,m=44,a=2067,s=496}
{x=2036,m=264,a=79,s=2244}
{x=2461,m=1339,a=466,s=291}
{x=2127,m=1623,a=2188,s=1013}
''';

    expect(Day19().solve(Day19.parseData(testData1)), equals(19114));
    assert(167409079868000 < maxInt);
    expect(Day19().solve(Day19.parseData(testData1), part2: true), equals(167409079868000));
  });
}
