import 'point3d.dart';

class Measurement {
  final Point3D pointA;
  final Point3D pointB;
  final double distanceMeters;
  final DateTime timestamp;

  Measurement({
    required this.pointA,
    required this.pointB,
    required this.distanceMeters,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() => 'Measurement(${distanceMeters.toStringAsFixed(2)}m)';
}
