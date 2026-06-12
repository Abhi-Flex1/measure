import 'point3d.dart';

class MultiMeasurement {
  final Point3D target;
  final List<MeasurementPoint> points;

  MultiMeasurement({
    required this.target,
    List<MeasurementPoint>? points,
  }) : points = points ?? [];

  void addPoint(MeasurementPoint point) {
    points.add(point);
  }

  void removeLastPoint() {
    if (points.isNotEmpty) {
      points.removeLast();
    }
  }

  MeasurementPoint? get nearest {
    if (points.isEmpty) return null;
    return points.reduce((a, b) =>
        a.distanceFromTarget < b.distanceFromTarget ? a : b);
  }

  MeasurementPoint? get farthest {
    if (points.isEmpty) return null;
    return points.reduce((a, b) =>
        a.distanceFromTarget > b.distanceFromTarget ? a : b);
  }

  double get averageDistance {
    if (points.isEmpty) return 0;
    final total = points.fold<double>(0, (sum, p) => sum + p.distanceFromTarget);
    return total / points.length;
  }

  void clear() {
    points.clear();
  }
}

class MeasurementPoint {
  final Point3D position;
  final double distanceFromTarget;
  final DateTime timestamp;

  MeasurementPoint({
    required this.position,
    required this.distanceFromTarget,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
