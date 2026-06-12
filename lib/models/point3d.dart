import 'package:vector_math/vector_math_64.dart';

class Point3D {
  final Vector3 position;
  final DateTime timestamp;

  Point3D({
    required this.position,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  double get x => position.x;
  double get y => position.y;
  double get z => position.z;

  factory Point3D.fromVector3(Vector3 vec) {
    return Point3D(position: vec.clone());
  }

  @override
  String toString() => 'Point3D(x: ${x.toStringAsFixed(3)}, y: ${y.toStringAsFixed(3)}, z: ${z.toStringAsFixed(3)})';
}
