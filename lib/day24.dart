import 'dart:io';
import 'dart:convert';

import 'common.dart';
import 'day.dart';
import 'solution_check.dart';

class HailStone {
  Point3<double> pos;
  Point3<double> vel;

  HailStone(this.pos, this.vel);
}

class IntersectionResult {
  Point3<double> point;
  double t;
  bool parallel;
  bool notIntersecting;

  IntersectionResult(this.point, this.t, this.parallel, this.notIntersecting);
}

// Intersects also on Z - axis, even though the task talks only about XY plane
IntersectionResult calculateIntersectionPoint(HailStone s1, HailStone s2) {
  // Extracting positions and velocities
  Point3<double> p1 = s1.pos;
  Point3<double> v1 = s1.vel;
  Point3<double> p2 = s2.pos;
  Point3<double> v2 = s2.vel;

  // Solving the system of equations
  // L1(t) = P1 + t * V1
  // L2(s) = P2 + s * V2
  // For intersection L1(t) = L2(s)

  // Check for parallelism (cross product is zero)
  if (v1.x * v2.y - v1.y * v2.x == 0 &&
      v1.x * v2.z - v1.z * v2.x == 0 &&
      v1.y * v2.z - v1.z * v2.y == 0) {
    return IntersectionResult(Point3<double>(0, 0, 0), 0, true, true); // Lines are parallel or coincident, no unique intersection
  }

  // This is a simplified method and may not work for all cases
  // Using Cramer's Rule for solving linear equations
  double determinant = v1.x.toDouble() * v2.y - v1.y * v2.x;
  if (determinant == 0) return IntersectionResult(Point3<double>(0, 0, 0), 0, false, true); // Lines don't intersect

  double t = ((p2.x - p1.x) * v2.y - (p2.y - p1.y) * v2.x) / determinant;

  // Calculate intersection point
  double intersectX = p1.x + (v1.x * t).toDouble();
  double intersectY = p1.y + (v1.y * t).toDouble();
  double intersectZ = p1.z + (v1.z * t).toDouble();

  return IntersectionResult(Point3<double>(intersectX, intersectY, intersectZ), t, false, false);
}

class LinearSystem {
  List<List<double>> coefficients;
  List<double> solutions;

  LinearSystem(this.coefficients, this.solutions);
}

class GaussianElimination {
  static void calculate(LinearSystem eq) {
    for (int i = 0; i < eq.coefficients.length; i++) {
      // Pivot selection with partial pivoting
      _pivotSelection(eq, i);

      // Normalize row i
      _normalizeRow(eq, i);

      // Row reduce using row i
      _rowReduce(eq, i);
    }
  }

  static void _pivotSelection(LinearSystem eq, int currentRow) {
    if (eq.coefficients[currentRow][currentRow] == 0) {
      for (int k = currentRow + 1; k < eq.coefficients.length; k++) {
        if (eq.coefficients[k][currentRow] != 0) {
          _swapRows(eq, currentRow, k);
          break;
        }
      }
    }
    if (eq.coefficients[currentRow][currentRow] == 0) {
      throw new Exception("No unique solution found.");
    }
  }

  static void _swapRows(LinearSystem eq, int row1, int row2) {
    var tempRow = eq.coefficients[row1];
    eq.coefficients[row1] = eq.coefficients[row2];
    eq.coefficients[row2] = tempRow;

    var tempSolution = eq.solutions[row1];
    eq.solutions[row1] = eq.solutions[row2];
    eq.solutions[row2] = tempSolution;
  }

  static void _normalizeRow(LinearSystem eq, int row) {
    double pivot = eq.coefficients[row][row];
    for (int j = 0; j < eq.coefficients.length; j++) {
      eq.coefficients[row][j] /= pivot;
    }
    eq.solutions[row] /= pivot;
  }

  static void _rowReduce(LinearSystem eq, int pivotRow) {
    for (int k = 0; k < eq.coefficients.length; k++) {
      if (k != pivotRow) {
        double factor = eq.coefficients[k][pivotRow];
        for (int j = 0; j < eq.coefficients.length; j++) {
          eq.coefficients[k][j] -= factor * eq.coefficients[pivotRow][j];
        }
        eq.solutions[k] -= factor * eq.solutions[pivotRow];
      }
    }
  }
}

@DayTag()
class Day24 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static List<HailStone> parseData(var data) {

    return LineSplitter()
        .convert(data)
        .map((e) {
          var split = e.split("@");
          var split_pos = split[0].trim().split(",");
          var pos = Point3<double>(int.parse(split_pos[0].trim()).toDouble(), int.parse(split_pos[1].trim()).toDouble(), int.parse(split_pos[2].trim()).toDouble());
          var split_vel = split[1].trim().split(",");
          var vel = Point3<double>(int.parse(split_vel[0].trim()).toDouble(), int.parse(split_vel[1].trim()).toDouble(), int.parse(split_vel[2].trim()).toDouble());
          return HailStone(pos, vel);
        }).toList();
  }

  bool isInThePast(HailStone data, Point3<double> pointToCheck) {
    // The direction of the velocity vector
    Point3<double> direction = Point3<double>(
        data.vel.x.sign,
        data.vel.y.sign,
        data.vel.z.sign
    );

    // Check if pointToCheck is behind data.pos in the direction of movement
    double dx = (pointToCheck.x - data.pos.x) * direction.x;
    double dy = (pointToCheck.y - data.pos.y) * direction.y;
    //double dz = (pointToCheck.z - data.pos.z) * direction.z;

    return dx <= 0
        && dy <= 0;
    // Dont check z as the task talks only about XY plane
    //&&
    //dz <= 0;
  }

  LinearSystem constructMatrixXY(List<HailStone> data) {
    LinearSystem eq = LinearSystem(List.generate(4, (_) => List.filled(4, 0.0)), List.filled(4, 0.0));

    // H  is first heilstone data[i]
    // H2 is second heilstone data[i+1]
    // Rx*(H2Vy - HVy) + Ry*(HVx - H2Vx) + RVx*(Hy - H2y) - RVy*(Hx + H2x) = -Hx*HVy + Hy*HVx + H2x*H2Vy - H2y*H2Vx
    for (int i = 0; i < 4; i++) {
      eq.coefficients[i][0] = data[i+1].vel.y - data[i].vel.y; // H2Vy - HVy
      eq.coefficients[i][1] = data[i].vel.x - data[i+1].vel.x; // HVx - H2Vx
      eq.coefficients[i][2] = data[i].pos.y - data[i+1].pos.y; // Hy - H2y
      eq.coefficients[i][3] = data[i+1].pos.x - data[i].pos.x; // Hx + H2x
      eq.solutions[i] =
          - data[i].pos.x * data[i].vel.y      // -Hx*HVy
          + data[i].pos.y * data[i].vel.x      //  Hy*HVx
          + data[i+1].pos.x * data[i+1].vel.y  //  H2x*H2Vy
          - data[i+1].pos.y * data[i+1].vel.x; // -H2y*H2Vx
    }

    return eq;
  }

  LinearSystem constructMatrixXZ(List<HailStone> data) {
    LinearSystem eq = LinearSystem(List.generate(4, (_) => List.filled(4, 0)), List.filled(4, 0));

    // H  is first heilstone data[i]
    // H2 is second heilstone data[i+1]
    // Rx*(H2Vz + HVz) + Rz*(HVx - H2Vx) + RVx*(Hz - H2z) - RVz*(H2x - Hx) = -Hx*HVz + Hz*HVx + H2x*H2Vz - H2z*H2Vx
    for (int i = 0; i < 4; i++) {
      eq.coefficients[i][0] = data[i+1].vel.z - data[i].vel.z; // H2Vz + HVz
      eq.coefficients[i][1] = data[i].vel.x - data[i+1].vel.x; // HVx - H2Vx
      eq.coefficients[i][2] = data[i].pos.z - data[i+1].pos.z; // Hz - H2z
      eq.coefficients[i][3] = data[i+1].pos.x - data[i].pos.x; // H2x - Hx
      eq.solutions[i] =
          - data[i].pos.x * data[i].vel.z     // -Hx*HVz
          + data[i].pos.z * data[i].vel.x     //  Hz*HVx
          + data[i+1].pos.x * data[i+1].vel.z //  H2x*H2Vz
          - data[i+1].pos.z * data[i+1].vel.x;// -H2z*H2Vx
    }

    return eq;
  }

  /*
    For part two, we will use system of linear equations to calculate the position of the rock at the time of the collision.
    We want to rewrite the equation to allow for gaussian elimination. Below is the process of rewriting the equation.

    Rock is defined by following: position: Rx,Ry,Rz and velocity: RVx, RVy, RVz. Those are unknowns
    which we want to calculate.

    Any heilstone is defined by following position: Hx,Hy,Hz and velocity: HVx, HVy, HVz.
    The rock will hit the heilstone if the following equation is true:
      Rx + RVx * t = Hx + HVx * t
    for some t which is a time in nanoseconds. Lets rewrite the equation specifically for the variable t:

    To rewrite the equation "Rx + RVx * t = Hx + HVx * t" specifically for the variable t,
    we want to isolate t on one side of the equation:

    1. Start with the original equation: Rx + RVx * t = Hx + HVx * t
    2. To isolate t, we need to get all the terms involving t on one side and the rest on the other.
      So, let's move RVx * t to the right side by subtracting it from both sides:
       Rx = Hx + HVx * t - RVx * t.
    3. Combine the terms involving t: Rx = Hx + t * (HVx - RVx).
    4. Now, isolate t by dividing both sides by (HVx - RVx), assuming HVx - RVx is not zero:
       t = (Rx - Hx) / (HVx - RVx).

    The rewritten equation for t is

       t = (Rx - Hx) / (HVx - RVx)

    We can do the same for y and z coordinates. So, we have three equations for t:

       t = (Rx - Hx) / (HVx - RVx)
       t = (Ry - Hy) / (HVy - RVy)
       t = (Rz - Hz) / (HVz - RVz)

     (Rx - Hx) / (HVx - RVx) = (Ry - Hy) / (HVy - RVy) = (Rz - Hz) / (HVz - RVz)

      Now rewrite first two above equations so that we will have a constant:
       Ry*RVx - Rx*RVy
      on the left side. This is constant because its initial position and velocity of a rock.

      1. Start with the original equation: (Rx - Hx) / (HVx - RVx) = (Ry - Hy) / (HVy - RVy).
      2. Cross-multiply to eliminate the denominators: (Rx - Hx) * (HVy - RVy) = (Ry - Hy) * (HVx - RVx).
      3. Expand both sides: Rx * HVy - Rx * RVy - Hx * HVy + Hx * RVy = Ry * HVx - Ry * RVx - Hy * HVx + Hy * RVx.
      4. Rearrange to bring the terms Ry * RVx and -Rx * RVy to the left side:
         Ry * RVx - Rx * RVy = Hx * HVy - Hx * RVy - Hy * HVx + Hy * RVx - Rx * HVy + Ry * HVx.

      So, the rearranged equation is
        Ry*RVx - Rx*RVy = -Rx*HVy + Hx*HVy - Hx*RVy + Ry*HVx - Hy*HVx + Hy*RVx

      Now lets compute it for the second heilstone:
        Ry*RVx - Rx*RVy = -Rx*H2Vy + H2x*H2Vy - H2x*RVy + Ry*H2Vx - H2y*H2Vx + H2y*RVx

      Left side is the same for H and H2, so we can make a single equation:
        -Rx*HVy + Hx*HVy - Hx*RVy + Ry*HVx - Hy*HVx + Hy*RVx = -Rx*H2Vy + H2x*H2Vy - H2x*RVy + Ry*H2Vx - H2y*H2Vx + H2y*RVx
      Then rearange into a form of Rx Ry Vx Vy
        -Rx*HVy + Hx*HVy - Hx*RVy + Ry*HVx - Hy*HVx + Hy*RVx + Rx*H2Vy - H2x*H2Vy + H2x*RVy - Ry*H2Vx + H2y*H2Vx - H2y*RVx = 0
        -Rx*HVy + Rx*H2Vy + Ry*HVx - Ry*H2Vx + Hy*RVx - H2y*RVx - Hx*RVy + H2x*RVy + Hx*HVy - Hy*HVx - H2x*H2Vy + H2y*H2Vx = 0
        Rx*(H2Vy - HVy) + Ry*(HVx - H2Vx) + RVx*(Hy - H2y) - RVy*(Hx + H2x) = -Hx*HVy + Hy*HVx + H2x*H2Vy - H2y*H2Vx
      Right side is constant, and on the left side, the only unknowns are Rx, Ry, RVx, RVy.

      The same can be computed to calculate Z:

      Rx*(H2Vz + HVz) + Rz*(HVx - H2Vx) + RVx*(Hz - H2z) - RVz*(H2x - Hx) = -Hx*HVz + Hz*HVx + H2x*H2Vz - H2z*H2Vx
   */
  int calculateSumOfRockCoordinates(List<HailStone> data) {
    LinearSystem eqXY = constructMatrixXY(data);
    GaussianElimination.calculate(eqXY);
    LinearSystem eqXZ = constructMatrixXZ(data);
    GaussianElimination.calculate(eqXZ);

    var rockPos = Point3<double>(eqXY.solutions[0], eqXY.solutions[1], eqXZ.solutions[1]);

    // Not actually needed
    var rockVel = Point3<double>(eqXY.solutions[2], eqXY.solutions[3], eqXZ.solutions[3]);

    return (rockPos.x + rockPos.y + rockPos.z).toInt();
  }

  int solve(List<HailStone> data, {var part2 = false, var minX = 7, var maxX = 27, var minY = 7, var maxY = 27}) {

    if (part2) {
      return calculateSumOfRockCoordinates(data);
    }

    var total = 0;

    for (var i = 0; i < data.length; ++i) {
      for (var j = i+1; j < data.length; ++j) {
        var intersect = calculateIntersectionPoint(data[i], data[j]);

        if (intersect.parallel) {

        }
        else {
          if (intersect.point.x >= minX && intersect.point.x <= maxX &&
              intersect.point.y >= minY && intersect.point.y <= maxY)
          {
            if (isInThePast(data[i], intersect.point) || isInThePast(data[j], intersect.point)) {
              continue;
            }
            //print("A: ${data[i].pos} @ ${data[i].vel}");
            //print("B: ${data[j].pos} @ ${data[j].vel}");
            //print("   ${intersect==null ? "null" : intersect.point}, t=${intersect==null ? "null" : intersect.t}");
            total++;
          }
        }
      }
    }

    return total;
  }

  @override
  Future<void> run() async {
    print("Day24");

    var data = readData("../adventofcode_input/2023/data/day24.txt");

    var res1 = solve(data, minX: 200000000000000.0, maxX: 400000000000000.0, minY: 200000000000000.0, maxY: 400000000000000.0);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2023/data/day24_result.txt", 0));

    var res2 = solve(data, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2023/data/day24_result.txt", 1));
  }
}
