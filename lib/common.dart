import 'dart:convert';
import 'dart:io';
import 'dart:math';

abstract class IPoint<T> {
  T get x;
  T get y;
}

class ImmutablePoint implements IPoint<int> {
  final int x;
  final int y;

  const ImmutablePoint(this.x, this.y);

  operator +(ImmutablePoint other) {
    return ImmutablePoint(x + other.x, y + other.y);
  }

  @override
  String toString() => "ImmutablePoint($x, $y)";
}

class Point implements IPoint<int> {
  int x;
  int y;

  Point(this.x, this.y);

  Point.clone(Point point): this(point.x, point.y);

  // Factory constructor to create a Point from an IPoint<int>
  factory Point.fromIPoint(IPoint<int> other) {
    return Point(other.x, other.y);
  }

  @override
  bool operator ==(dynamic other) {
    return x == other.x && y == other.y;
  }

  Point operator +(IPoint<int> other) {
    return Point(x + other.x, y + other.y);
  }

  Point operator -(IPoint<int> other) {
    return Point(x - other.x, y - other.y);
  }

  @override
  int get hashCode => x^y;

  @override
  String toString() {
    return "Point($x, $y)";
  }
}

class Point3<T extends num> {  // Constrain T to be a subtype of num
  final T x;
  final T y;
  final T z;

  Point3(this.x, this.y, this.z);

  Point3.clone(Point3<T> point) : this(point.x, point.y, point.z);

  @override
  String toString() {
    String formatValue(T value) {
      return value is double ? value.toStringAsFixed(3) : value.toString();
    }

    return 'Point3{x: ${formatValue(x)}, y: ${formatValue(y)}, z: ${formatValue(z)}}';
  }

  Point3<double> normalize() {
    double magnitude = sqrt(x * x + y * y + z * z);  // Correct casting
    if (magnitude == 0) {
      throw Exception("Cannot normalize a zero vector");
    }
    return Point3<double>(x / magnitude, y / magnitude, z / magnitude);
  }

  Point3<T> offset(T xOff, T yOff, T zOff) {
    return Point3(
        x + xOff as T,
        y + yOff as T,
        z + zOff as T
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Point3 &&
              runtimeType == other.runtimeType &&
              x == other.x &&
              y == other.y &&
              z == other.z;

  @override
  int get hashCode => x.hashCode ^ y.hashCode ^ z.hashCode;
}

final int maxInt = (double.infinity is int) ? double.infinity as int : ~minInt;
final int minInt = (double.infinity is int) ? -double.infinity as int : (-1 << 63);

// [start, end)
class IntRange {
  final int start;
  final int end;

  // Static instance for an invalid range
  static const IntRange invalid = IntRange._invalid();

  int length() => end - start;

  bool isEmpty() => start == end;

  bool isNotEmpty() => !isEmpty();

  IntRange(this.start, this.end) {
    if (start >= end) {
      throw ArgumentError('Invalid range: start ($start) should not be greater than end ($end)');
    }
  }

  // Private constructor for the invalid range
  const IntRange._invalid() : start = 0, end = 0;

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

IntRange intersect(IntRange r1, IntRange r2) {
  int start = r1.start > r2.start ? r1.start : r2.start;
  int end = r1.end < r2.end ? r1.end : r2.end;
  if (start >= end) {
    // No intersection, returning an empty range
    return IntRange.invalid;
  }
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

int gcd(int a, int b) {
  if (b == 0) {
    return a;
  }
  return gcd(b, a % b);
}

int gcdOfList(List<int> numbers) {
  return numbers.reduce((a, b) => gcd(a, b));
}

int lcmOfList(List<int> numbers) {
  var gcd = gcdOfList(numbers);
  return numbers.reduce((a, b) => a * (b ~/ gcd));
}

/// Generates all possible combinations of a specified length from a given list.
/// (often denoted as C(n,len) or "n choose len")
///
/// This function iteratively computes combinations of elements from the list `arr`,
/// each of the specified length `len`. It uses an iterative approach instead of
/// recursion, making it more efficient for larger datasets. The function is
/// generic and works with any type of list elements.
///
/// The algorithm uses a stack (implemented as an array of indices) to track the
/// current combination being formed. It iteratively builds combinations by incrementing
/// and resetting indices in the stack, mimicking the behavior of recursive calls.
///
/// When the stack is filled to the desired length (`len`), a valid combination is
/// found and added to the result list. The process continues until all combinations
/// are explored.
///
/// Parameters:
///   - `arr`: The list of elements to form combinations from. Can be of any type.
///   - `len`: The length of each combination. Must be a non-negative number.
///
/// Returns:
///   A list of lists, where each inner list is a combination of elements from `arr`.
///
/// Example:
///   Given `arr = [1, 2, 3]` and `len = 2`, the function returns `[[1, 2], [1, 3], [2, 3]]`.
///
/// Note:
///   - If `len` is 0, the function returns a list containing an empty list.
///   - If `len` is greater than the length of `arr`, the function returns an empty list,
///     as no combinations of that length are possible.
List<List<T>> combinations<T>(List<T> arr, int len) {
  // Return an empty combination if the requested length is zero
  if (len == 0) return [[]];

  // If the requested length is greater than the array length, return empty as no combinations are possible
  if (len > arr.length) return [];

  List<List<T>> result = [];
  // Initialize a stack with the size equal to the combination length
  List<int> indexStack = List<int>.filled(len, 0, growable: false);
  int stackPointer = 0;

  // Iterate until the stack is not empty
  while (stackPointer >= 0) {
    // Check if the current index is within the array bounds
    if (indexStack[stackPointer] < arr.length) {
      // If the stackPointer reaches the last position, a valid combination is formed
      if (stackPointer == len - 1) {
        // Add the current combination to the result
        result.add([for (var i in indexStack) arr[i]]);
        // Move to the next index in the array
        indexStack[stackPointer]++;
      } else {
        // Prepare the next position in the stack for the next element
        indexStack[stackPointer + 1] = indexStack[stackPointer] + 1;
        // Move the stackPointer forward
        stackPointer++;
      }
    } else {
      // If the current index is out of bounds, move back in the stack
      stackPointer--;
      if (stackPointer >= 0) {
        // Increment the previous index in the stack
        indexStack[stackPointer]++;
      }
    }
  }

  return result;
}
