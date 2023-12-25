import 'dart:convert';
import 'dart:io';

class Point {
  int x;
  int y;

  Point(this.x, this.y);

  Point.clone(Point point): this(point.x, point.y);

  @override
  bool operator ==(dynamic other) {
    return x == other.x && y == other.y;
  }

  @override
  int get hashCode => x^y;

  @override
  String toString() {
    return "Point($x, $y)";
  }
}

final int maxInt = (double.infinity is int) ? double.infinity as int : ~minInt;
final int minInt = (double.infinity is int) ? -double.infinity as int : (-1 << 63);

class IntRange {
  final int start;
  final int end;

  IntRange(this.start, this.end);

  bool overlaps(IntRange other) {
    return !(end < other.start || start > other.end);
  }

  IntRange merge(IntRange other) {
    return IntRange(
      start < other.start ? start : other.start,
      end > other.end ? end : other.end,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IntRange &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => start.hashCode ^ end.hashCode;

  @override
  String toString() => '($start, $end)';
}

IntRange union(IntRange r1, IntRange r2) {
  int start = r1.start < r2.start ? r1.start : r2.start;
  int end = r1.end > r2.end ? r1.end : r2.end;
  return IntRange(start, end);
}

List<IntRange> mergeOverlappingIntervals(List<IntRange> intervals) {
  if (intervals.isEmpty) return [];

  // Sort the intervals by their start value
  intervals.sort((a, b) => a.start.compareTo(b.start));

  List<IntRange> mergedIntervals = [intervals.first];

  for (var i = 1; i < intervals.length; i++) {
    var last = mergedIntervals.last;
    var current = intervals[i];

    if (last.overlaps(current)) {
      // Remove the last interval and add the merged interval
      mergedIntervals.removeLast();
      mergedIntervals.add(last.merge(current));
    } else {
      // Add the current interval as it does not overlap
      mergedIntervals.add(current);
    }
  }

  return mergedIntervals;
}

class Line {
  final Point p1;
  final Point p2;

  const Line(this.p1, this.p2);

  double get slope => (p2.y - p1.y) / (p2.x - p1.x);
  double get yIntercept => p1.y - slope * p1.x;

  @override
  String toString() => 'Line from $p1 to $p2';
}

Point findPerpendicularPoint(Point p1, Point linePoint1, Point linePoint2) {
  // Calculate the slope of the line
  var slope = (linePoint2.y - linePoint1.y) / (linePoint2.x - linePoint1.x);

  // Calculate the slope of the perpendicular line
  var perpSlope = -1 / slope;

  // Calculate the y-intercept of the perpendicular line
  var perpYIntercept = p1.y - perpSlope * p1.x;

  // Calculate the y-intercept of the original line
  var lineYIntercept = linePoint1.y - slope * linePoint1.x;

  // Now, find the intersection point of the original line and the perpendicular line
  // x = (b2 - b1) / (m1 - m2)
  var ptX = (lineYIntercept - perpYIntercept) / (perpSlope - slope);

  // y = m1 * x + b1
  var ptY = slope * ptX + lineYIntercept;

  return Point(ptX.toInt(), ptY.toInt());
}

int getIntFromFile(String s, int i) {
  return int.parse(LineSplitter().convert(File(s).readAsStringSync())[i]);
}

String getStringFromFile(String s, int start, {int end = -1}) {
  var res = "";
  var list = LineSplitter().convert(File(s).readAsStringSync());
  if (end == -1) {
    end = start+1;
  }
  for (var i = start; i < end; ++i) {
    if (i > start) {
      res += "\n";
    }
    res += list[i];
  }
  return res;
}
