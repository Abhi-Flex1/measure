import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import '../models/point3d.dart';

class ARService {
  late ARSessionManager _sessionManager;
  late ARObjectManager _objectManager;
  // ignore: unused_field
  late ARAnchorManager _anchorManager;
  
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  
  Function(List<ARHitTestResult>)? onHitTestResult;
  Function(String)? onError;

  void initialize({
    required ARSessionManager sessionManager,
    required ARObjectManager objectManager,
    required ARAnchorManager anchorManager,
    Function(List<ARHitTestResult>)? onHitTest,
    Function(String)? onError,
  }) {
    _sessionManager = sessionManager;
    _objectManager = objectManager;
    _anchorManager = anchorManager;
    onHitTestResult = onHitTest;
    onError = onError;

    _sessionManager.onInitialize(
      showFeaturePoints: false,
      showPlanes: true,
      customPlaneTexturePath: null,
      showWorldOrigin: false,
      showAnimatedGuide: true,
    );

    _objectManager.onInitialize();
    
    _sessionManager.onPlaneOrPointTap = (results) {
      onHitTestResult?.call(results);
    };

    _isInitialized = true;
  }

  void dispose() {
    _sessionManager.dispose();
    _isInitialized = false;
  }

  Future<bool> addMarkerAtPoint(Point3D point) async {
    if (!_isInitialized) return false;

    final node = ARNode(
      type: NodeType.localGLTF2,
      uri: "https://github.com/nickvdyck/ar_flutter_plugin/raw/master/example/assets/Origin/models/origin.gltf",
      scale: vm.Vector3(0.01, 0.01, 0.01),
      position: vm.Vector3(point.x, point.y, point.z),
      rotation: vm.Vector4(0, 0, 0, 0),
    );

    final result = await _objectManager.addNode(node);
    return result ?? false;
  }

  Future<void> removeNode(ARNode node) async {
    if (!_isInitialized) return;
    _objectManager.removeNode(node);
  }

  Future<void> clearAllNodes(List<ARNode> nodes) async {
    if (!_isInitialized) return;
    for (var node in nodes) {
      _objectManager.removeNode(node);
    }
  }
}
