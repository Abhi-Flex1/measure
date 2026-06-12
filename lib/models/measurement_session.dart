import 'package:flutter/foundation.dart';
import 'point3d.dart';
import 'measurement.dart';
import 'multi_measurement.dart';

enum MeasurementMode { simple, multi }

class MeasurementSession extends ChangeNotifier {
  MeasurementMode _mode = MeasurementMode.simple;
  
  // Mode 1: Simple A->B
  Point3D? _pointA;
  Point3D? _pointB;
  Measurement? _currentMeasurement;
  
  // Mode 2: Multi-point
  MultiMeasurement? _multiMeasurement;
  
  // Getters
  MeasurementMode get mode => _mode;
  Point3D? get pointA => _pointA;
  Point3D? get pointB => _pointB;
  Measurement? get currentMeasurement => _currentMeasurement;
  MultiMeasurement? get multiMeasurement => _multiMeasurement;
  
  bool get canAddPoint {
    if (_mode == MeasurementMode.simple) {
      return _pointB == null;
    } else {
      return true;
    }
  }
  
  bool get hasPoints {
    if (_mode == MeasurementMode.simple) {
      return _pointA != null;
    } else {
      return _multiMeasurement != null && _multiMeasurement!.points.isNotEmpty;
    }
  }

  void setMode(MeasurementMode mode) {
    _mode = mode;
    clear();
    notifyListeners();
  }

  void addPoint(Point3D point) {
    if (_mode == MeasurementMode.simple) {
      _addSimplePoint(point);
    } else {
      _addMultiPoint(point);
    }
    notifyListeners();
  }

  void _addSimplePoint(Point3D point) {
    if (_pointA == null) {
      _pointA = point;
    } else if (_pointB == null) {
      _pointB = point;
      _calculateSimpleMeasurement();
    }
  }

  void _addMultiPoint(Point3D point) {
    _multiMeasurement ??= MultiMeasurement(target: point);
    
    if (_multiMeasurement!.points.isEmpty && _multiMeasurement!.target == point) {
      return;
    }
    
    final distance = _calculateDistance(_multiMeasurement!.target, point);
    _multiMeasurement!.addPoint(MeasurementPoint(
      position: point,
      distanceFromTarget: distance,
    ));
  }

  void _calculateSimpleMeasurement() {
    if (_pointA != null && _pointB != null) {
      final distance = _calculateDistance(_pointA!, _pointB!);
      _currentMeasurement = Measurement(
        pointA: _pointA!,
        pointB: _pointB!,
        distanceMeters: distance,
      );
    }
  }

  double _calculateDistance(Point3D a, Point3D b) {
    final dx = b.x - a.x;
    final dy = b.y - a.y;
    final dz = b.z - a.z;
    return (dx * dx + dy * dy + dz * dz);
  }

  void undo() {
    if (_mode == MeasurementMode.simple) {
      if (_pointB != null) {
        _pointB = null;
        _currentMeasurement = null;
      } else if (_pointA != null) {
        _pointA = null;
      }
    } else {
      _multiMeasurement?.removeLastPoint();
      if (_multiMeasurement?.points.isEmpty ?? true) {
        _multiMeasurement = null;
      }
    }
    notifyListeners();
  }

  void clear() {
    _pointA = null;
    _pointB = null;
    _currentMeasurement = null;
    _multiMeasurement = null;
    notifyListeners();
  }
}
