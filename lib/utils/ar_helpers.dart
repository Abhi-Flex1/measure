import 'package:vector_math/vector_math_64.dart';
import '../models/point3d.dart';

class ARHelpers {
  static double calculateDistance(Point3D a, Point3D b) {
    final dx = b.x - a.x;
    final dy = b.y - a.y;
    final dz = b.z - a.z;
    return (dx * dx + dy * dy + dz * dz);
  }

  static Point3D midpoint(Point3D a, Point3D b) {
    return Point3D(
      position: Vector3(
        (a.x + b.x) / 2,
        (a.y + b.y) / 2,
        (a.z + b.z) / 2,
      ),
    );
  }

  static Vector3 vectorFromTo(Point3D from, Point3D to) {
    return Vector3(
      to.x - from.x,
      to.y - from.y,
      to.z - from.z,
    );
  }

  static double angleBetween(Point3D a, Point3D b, Point3D c) {
    final ab = vectorFromTo(a, b);
    final ac = vectorFromTo(a, c);
    
    final dotProduct = ab.dot(ac);
    final magnitudeAB = ab.length;
    final magnitudeAC = ac.length;
    
    if (magnitudeAB == 0 || magnitudeAC == 0) return 0;
    
    final cosAngle = dotProduct / (magnitudeAB * magnitudeAC);
    return cosAngle.clamp(-1.0, 1.0);
  }
}
