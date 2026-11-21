// Automatic FlutterFlow imports
import '/flutter_flow/ff_builtin_enums.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart' hide RepeatMode;
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MotionMicrosoft extends StatefulWidget {
  const MotionMicrosoft({
    Key? key,
    this.width,
    this.height,
    required this.targetIp,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String targetIp;

  @override
  State<MotionMicrosoft> createState() => _MotionMicrosoftState();
}

class _MotionMicrosoftState extends State<MotionMicrosoft> {
  // 0 = Head Tracker (Default), 1 = Flight Controls
  int _selectedTab = 0;
  bool _flightControlsMounted = false;

  @override
  void dispose() {
    // Restore default orientations when leaving the page
    SystemChrome.setPreferredOrientations([]);
    super.dispose();
  }

  void _switchTab(int index) {
    if (_selectedTab == index) return;
    HapticFeedback.selectionClick();
    setState(() {
      _selectedTab = index;
      if (index == 1) {
        _flightControlsMounted = true;
      }
    });

    if (index == 1) {
      // Force Landscape automatically for Flight Controls
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      // Restore normal orientations for Head Tracker
      SystemChrome.setPreferredOrientations([]);
    }
  }

  void _handleExitBack() {
    HapticFeedback.lightImpact();
    SystemChrome.setPreferredOrientations([]);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bool isFlightTab = _selectedTab == 1;
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final Color pageBg =
        isFlightTab ? const Color(0xFF070C13) : const Color(0xFF0B111A);

    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      child: Container(
        color: pageBg,
        child: Column(
          children: [
            // Top Avionics Mode Switcher Banner (Identical to MotionXplane)
            SafeArea(
              top: true,
              left: true,
              right: true,
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isLandscape ? 10 : 12,
                  isLandscape ? 4 : 6,
                  isLandscape ? 10 : 12,
                  isLandscape ? 2 : 4,
                ),
                child: _buildTopModeSwitcher(compact: isLandscape),
              ),
            ),

            // Active View (Both pages kept alive in IndexedStack)
            Expanded(
              child: IndexedStack(
                index: _selectedTab,
                children: [
                  _MsfsHeadTrackerPane(targetIp: widget.targetIp),
                  _flightControlsMounted
                      ? _MsfsFlightControlsPane(targetIp: widget.targetIp)
                      : const SizedBox.shrink(),
                ],
              ),
            ),

            // Shared Bottom Home Indicator (Always pops back to previous page)
            SafeArea(
              top: false,
              left: true,
              right: true,
              bottom: true,
              child: _buildHomeIndicator(
                onTap: _handleExitBack,
                compact: isFlightTab,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopModeSwitcher({required bool compact}) {
    return Container(
      height: compact ? 34 : 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFF09111B),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: const Color(0xFF223349),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSwitcherTab(
              label: 'HEAD TRACKER',
              icon: Icons.visibility_rounded,
              selected: _selectedTab == 0,
              compact: compact,
              onTap: () => _switchTab(0),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildSwitcherTab(
              label: 'FLIGHT CONTROLS',
              icon: Icons.sports_esports_rounded,
              selected: _selectedTab == 1,
              compact: compact,
              onTap: () => _switchTab(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitcherTab({
    required String label,
    required IconData icon,
    required bool selected,
    required bool compact,
    required VoidCallback onTap,
  }) {
    const Color accent = Color(0xFF639DF0);
    const Color cyan = Color(0xFF38BDF8);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accent.withOpacity(0.28),
                    cyan.withOpacity(0.14),
                  ],
                )
              : null,
          color: selected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? accent.withOpacity(0.9) : Colors.transparent,
            width: 1.1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: accent.withOpacity(0.30),
                    blurRadius: 10,
                    spreadRadius: 0.5,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: selected ? 6 : 0,
              height: selected ? 6 : 0,
              margin: EdgeInsets.only(right: selected ? 6 : 0),
              decoration: BoxDecoration(
                color: cyan,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: cyan.withOpacity(0.8),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
            Icon(
              icon,
              size: compact ? 13.5 : 15,
              color: selected ? Colors.white : const Color(0xFF8EA4BE),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF8EA4BE),
                  fontSize: compact ? 10 : 11.5,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                  letterSpacing: 0.7,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeIndicator({
    required VoidCallback onTap,
    required bool compact,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          bottom: compact ? 6.0 : 10.0,
          top: compact ? 6.0 : 20.0,
        ),
        alignment: Alignment.center,
        child: Container(
          width: 130,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// TAB 1: MSFS HEAD TRACKER (100% UNTOUCHED — OPENTRACK UDP 4242)
// ============================================================================

class _MsfsHeadTrackerPane extends StatefulWidget {
  const _MsfsHeadTrackerPane({
    Key? key,
    required this.targetIp,
  }) : super(key: key);

  final String targetIp;

  @override
  State<_MsfsHeadTrackerPane> createState() => _MsfsHeadTrackerPaneState();
}

class _MsfsHeadTrackerPaneState extends State<_MsfsHeadTrackerPane> {
  CameraController? _cameraController;
  CameraDescription?
      _frontCamera; // أضفنا هذا المتغير لقراءة زاوية الكاميرا في الأندرويد
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: false,
      enableLandmarks: false,
      enableClassification: false,
      enableTracking: false,
      performanceMode: FaceDetectorMode.fast,
    ),
  );

  bool _isTracking = false;
  bool _isProcessing = false;
  bool _showSettings = false;
  bool _isRecenteringEffect = false;

  // القيم الخام (للسنترة)
  double _rawYaw = 0.0;
  double _rawPitch = 0.0;
  double _rawRoll = 0.0;

  // القيم النهائية (للرسم وإرسالها لـ OpenTrack)
  double _smoothedYaw = 0.0;
  double _smoothedPitch = 0.0;
  double _smoothedRoll = 0.0;

  // إعدادات السنترة
  double _yawOffset = 0.0;
  double _pitchOffset = 0.0;
  double _rollOffset = 0.0;

  // إعدادات افتراضية ثابتة للـ Default
  final double _defYawMult = 3.0;
  final double _defPitchMult = 2.0;
  final double _defRollMult = 1.0;
  final double _defSmooth = 0.2;
  final double _defDeadzone = 2.0;
  final double _defYawLim = 90.0;
  final double _defPitchLim = 60.0;
  final double _defRollLim = 15.0;

  // الإعدادات النشطة
  late double _yawMultiplier = _defYawMult;
  late double _pitchMultiplier = _defPitchMult;
  late double _rollMultiplier = _defRollMult;
  late double _smoothingFactor = _defSmooth;
  late double _deadzoneRadius = _defDeadzone;
  late double _yawLimit = _defYawLim;
  late double _pitchLimit = _defPitchLim;
  late double _rollLimit = _defRollLim;
  bool _invertYaw = false;
  bool _invertPitch = false;
  bool _invertRoll = false;

  // نظام البروفايلات
  String _currentProfile = "Default";
  List<String> _profileNames = ["Default"];
  Map<String, Map<String, dynamic>> _profilesData = {};

  bool _isLowLight = false;
  DateTime? _lastFaceDetectedTime;
  Timer? _lowLightCheckTimer;

  // متغيرات الـ UDP للاتصال بـ OpenTrack
  int _targetPort = 4242;
  RawDatagramSocket? _udpSocket;
  Timer? _udpSenderTimer;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
    _initUdpSocket();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector.close();
    _lowLightCheckTimer?.cancel();
    _udpSenderTimer?.cancel();
    _udpSocket?.close();
    super.dispose();
  }

  Future<void> _initUdpSocket() async {
    try {
      _udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    } catch (e) {
      print("UDP Init Error: $e");
    }
  }

  void _startUdpSender() {
    _udpSenderTimer = Timer.periodic(const Duration(milliseconds: 33), (timer) {
      if (_isTracking && _udpSocket != null) {
        _sendOpenTrackPacket();
      }
    });
  }

  void _stopUdpSender() {
    _udpSenderTimer?.cancel();
  }

  void _sendOpenTrackPacket() {
    String activeIp =
        widget.targetIp.isNotEmpty ? widget.targetIp : "192.168.1.100";
    if (_udpSocket == null || activeIp.isEmpty) return;
    try {
      final ip = InternetAddress(activeIp);
      final bd = ByteData(48);

      bd.setFloat64(0, 0.0, Endian.little);
      bd.setFloat64(8, 0.0, Endian.little);
      bd.setFloat64(16, 0.0, Endian.little);
      bd.setFloat64(24, _smoothedYaw, Endian.little);
      bd.setFloat64(32, _smoothedPitch, Endian.little);
      bd.setFloat64(40, _smoothedRoll, Endian.little);

      final packet = bd.buffer.asUint8List();
      _udpSocket!.send(packet, ip, _targetPort);
    } catch (e) {
      print("UDP Send Error: $e");
    }
  }

  // --- نظام البروفايلات الاحترافي ---
  Future<void> _loadProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final String? profilesJson = prefs.getString('tracker_profiles_msfs_v2');

    if (profilesJson != null) {
      final Map<String, dynamic> decoded = json.decode(profilesJson);
      if (!mounted) return;
      setState(() {
        _profilesData = decoded.map(
            (key, value) => MapEntry(key, Map<String, dynamic>.from(value)));
        _profileNames = _profilesData.keys.toList();
        if (!_profileNames.contains("Default")) {
          _profileNames.insert(0, "Default");
        }
      });
    }
  }

  Future<void> _autoSaveCurrentProfile() async {
    if (_currentProfile == "Default") return; // حماية الديفولت

    final prefs = await SharedPreferences.getInstance();
    _profilesData[_currentProfile] = {
      'yawMult': _yawMultiplier,
      'pitchMult': _pitchMultiplier,
      'rollMult': _rollMultiplier,
      'smooth': _smoothingFactor,
      'deadzone': _deadzoneRadius,
      'yawLim': _yawLimit,
      'pitchLim': _pitchLimit,
      'rollLim': _rollLimit,
      'invYaw': _invertYaw,
      'invPitch': _invertPitch,
      'invRoll': _invertRoll,
    };
    await prefs.setString(
        'tracker_profiles_msfs_v2', json.encode(_profilesData));
  }

  void _applyProfile(String profileName) {
    setState(() {
      _currentProfile = profileName;
      if (profileName == "Default") {
        _yawMultiplier = _defYawMult;
        _pitchMultiplier = _defPitchMult;
        _rollMultiplier = _defRollMult;
        _smoothingFactor = _defSmooth;
        _deadzoneRadius = _defDeadzone;
        _yawLimit = _defYawLim;
        _pitchLimit = _defPitchLim;
        _rollLimit = _defRollLim;
        _invertYaw = false;
        _invertPitch = false;
        _invertRoll = false;
      } else if (_profilesData.containsKey(profileName)) {
        final data = _profilesData[profileName]!;
        _yawMultiplier = data['yawMult'] ?? _defYawMult;
        _pitchMultiplier = data['pitchMult'] ?? _defPitchMult;
        _rollMultiplier = data['rollMult'] ?? _defRollMult;
        _smoothingFactor = data['smooth'] ?? _defSmooth;
        _deadzoneRadius = data['deadzone'] ?? _defDeadzone;
        _yawLimit = data['yawLim'] ?? _defYawLim;
        _pitchLimit = data['pitchLim'] ?? _defPitchLim;
        _rollLimit = data['rollLim'] ?? _defRollLim;
        _invertYaw = data['invYaw'] ?? false;
        _invertPitch = data['invPitch'] ?? false;
        _invertRoll = data['invRoll'] ?? false;
      }
    });
  }

  Future<void> _addNewProfileDialog() async {
    TextEditingController controller = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0B111A),
          title: const Text("Create New Profile",
              style: TextStyle(color: Color(0xFF639DF0))),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Enter profile name...",
              hintStyle: TextStyle(color: Colors.white54),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF639DF0))),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF639DF0)),
              onPressed: () async {
                String newName = controller.text.trim();
                if (newName.isNotEmpty &&
                    newName != "Default" &&
                    !_profileNames.contains(newName)) {
                  setState(() {
                    _profileNames.add(newName);
                    _currentProfile = newName;
                  });
                  await _autoSaveCurrentProfile();
                  if (mounted) Navigator.pop(context);
                }
              },
              child:
                  const Text("Create", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _renameProfileDialog() async {
    if (_currentProfile == "Default") return;
    TextEditingController controller =
        TextEditingController(text: _currentProfile);
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0B111A),
          title: const Text("Rename Profile",
              style: TextStyle(color: Color(0xFF639DF0))),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF639DF0))),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF639DF0)),
              onPressed: () async {
                String newName = controller.text.trim();
                if (newName.isNotEmpty &&
                    newName != "Default" &&
                    newName != _currentProfile) {
                  final prefs = await SharedPreferences.getInstance();
                  setState(() {
                    _profilesData[newName] = _profilesData[_currentProfile]!;
                    _profilesData.remove(_currentProfile);
                    int index = _profileNames.indexOf(_currentProfile);
                    if (index != -1) _profileNames[index] = newName;
                    _currentProfile = newName;
                  });
                  await prefs.setString(
                      'tracker_profiles_msfs_v2', json.encode(_profilesData));
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteProfile() async {
    if (_currentProfile == "Default") return;
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profilesData.remove(_currentProfile);
      _profileNames.remove(_currentProfile);
      _currentProfile = "Default";
      _applyProfile("Default");
    });
    await prefs.setString(
        'tracker_profiles_msfs_v2', json.encode(_profilesData));
  }

  Future<void> _showEditNumberDialog(String label, double currentValue,
      double minVal, double maxVal, Function(double) onSaved) async {
    TextEditingController numController =
        TextEditingController(text: currentValue.toStringAsFixed(1));
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E2633),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFF639DF0))),
          title: Text("Set $label",
              style: const TextStyle(color: Colors.white, fontSize: 16)),
          content: TextField(
            controller: numController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(
                color: Color(0xFF639DF0),
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2),
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Color(0xFF0B111A),
              border: OutlineInputBorder(borderSide: BorderSide.none),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child:
                    const Text("Cancel", style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF639DF0)),
              onPressed: () {
                double? parsed = double.tryParse(numController.text);
                if (parsed != null) {
                  parsed = parsed.clamp(minVal, maxVal);
                  onSaved(parsed);
                }
                Navigator.pop(context);
              },
              child: const Text("Apply", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // --- دوال تحويل الصور الخاصة بالأندرويد فقط (YUV_420_888 إلى NV21) ---
  InputImageRotation _getAndroidRotation() {
    final int sensorOrientation = _frontCamera?.sensorOrientation ?? 270;
    switch (sensorOrientation) {
      case 0:
        return InputImageRotation.rotation0deg;
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
      default:
        return InputImageRotation.rotation270deg;
    }
  }

  Uint8List _yuv420ToNv21(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final int ySize = width * height;
    final int uvSize = width * height ~/ 2;
    final Uint8List nv21 = Uint8List(ySize + uvSize);

    final Plane yPlane = image.planes[0];
    final Plane uPlane = image.planes[1];
    final Plane vPlane = image.planes[2];

    final Uint8List yBytes = yPlane.bytes;
    final Uint8List uBytes = uPlane.bytes;
    final Uint8List vBytes = vPlane.bytes;

    final int yRowStride = yPlane.bytesPerRow;
    final int yPixelStride = yPlane.bytesPerPixel ?? 1;

    int idY = 0;
    if (yPixelStride == 1 && yRowStride == width && yBytes.length >= ySize) {
      nv21.setRange(0, ySize, yBytes);
      idY = ySize;
    } else {
      for (int row = 0; row < height; row++) {
        final int rowOffset = row * yRowStride;
        for (int col = 0; col < width; col++) {
          final int yIndex = rowOffset + col * yPixelStride;
          nv21[idY++] = yIndex < yBytes.length ? yBytes[yIndex] : 0;
        }
      }
    }

    final int uvRowStride = uPlane.bytesPerRow;
    final int uvPixelStride = uPlane.bytesPerPixel ?? 1;
    final int uvWidth = width ~/ 2;
    final int uvHeight = height ~/ 2;

    int idUV = ySize;
    for (int row = 0; row < uvHeight; row++) {
      final int rowOffset = row * uvRowStride;
      for (int col = 0; col < uvWidth; col++) {
        final int uvIndex = rowOffset + col * uvPixelStride;
        // صيغة NV21 في الأندرويد تتطلب V أولاً ثم U
        nv21[idUV++] = uvIndex < vBytes.length ? vBytes[uvIndex] : 128;
        nv21[idUV++] = uvIndex < uBytes.length ? uBytes[uvIndex] : 128;
      }
    }

    return nv21;
  }

  InputImage _buildAndroidInputImage(CameraImage image) {
    final Uint8List nv21Bytes =
        image.planes.length == 1 ? image.planes[0].bytes : _yuv420ToNv21(image);

    return InputImage.fromBytes(
      bytes: nv21Bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: _getAndroidRotation(),
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes.length == 1
            ? image.planes[0].bytesPerRow
            : image.width,
      ),
    );
  }

  Future<void> _startTracking() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front);

      _frontCamera = frontCamera; // حفظ بيانات الكاميرا للأندرويد

      if (Platform.isIOS) {
        // تشغيل كود الـ iOS الأصلي
        _cameraController = CameraController(
          frontCamera,
          ResolutionPreset.low,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.bgra8888,
        );
      } else {
        // تشغيل كود الأندرويد المدعوم
        _cameraController = CameraController(
          frontCamera,
          ResolutionPreset.low,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.yuv420,
        );
      }

      await _cameraController!.initialize();

      if (!mounted) return;

      setState(() {
        _isTracking = true;
        _isLowLight = false;
        _lastFaceDetectedTime = DateTime.now();
      });

      _startUdpSender();

      _lowLightCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_isTracking && _lastFaceDetectedTime != null) {
          final timeSinceLastFace =
              DateTime.now().difference(_lastFaceDetectedTime!).inMilliseconds;
          if (timeSinceLastFace > 2500 && !_isLowLight) {
            if (mounted) {
              setState(() {
                _isLowLight = true;
              });
            }
          } else if (timeSinceLastFace <= 2500 && _isLowLight) {
            if (mounted) {
              setState(() {
                _isLowLight = false;
              });
            }
          }
        }
      });

      _cameraController!.startImageStream((CameraImage image) {
        if (!_isProcessing) _processImage(image);
      });
    } catch (e) {
      print("Camera Error: $e");
    }
  }

  Future<void> _stopTracking() async {
    await _cameraController?.stopImageStream();
    await _cameraController?.dispose();
    _cameraController = null;
    _lowLightCheckTimer?.cancel();
    _stopUdpSender();
    if (!mounted) return;
    setState(() {
      _isTracking = false;
      _isLowLight = false;
      _smoothedYaw = 0.0;
      _smoothedPitch = 0.0;
      _smoothedRoll = 0.0;
      _yawOffset = 0.0;
      _pitchOffset = 0.0;
      _rollOffset = 0.0;
    });
  }

  void _recenter() {
    setState(() {
      _yawOffset = _rawYaw;
      _pitchOffset = _rawPitch;
      _rollOffset = _rawRoll;
      _smoothedYaw = 0.0;
      _smoothedPitch = 0.0;
      _smoothedRoll = 0.0;
      _isRecenteringEffect = true; // تشغيل إيفيكت السنترة
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isRecenteringEffect = false;
        });
      }
    });
  }

  Future<void> _processImage(CameraImage image) async {
    _isProcessing = true;

    final InputImage inputImage;
    if (Platform.isIOS) {
      // كود الـ iOS الأصلي تماماً
      inputImage = InputImage.fromBytes(
        bytes: image.planes[0].bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: InputImageRotation.rotation270deg,
          format: InputImageFormat.bgra8888,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );
    } else {
      // كود الأندرويد وتحويل الصيغ
      inputImage = _buildAndroidInputImage(image);
    }

    try {
      final faces = await _faceDetector.processImage(inputImage);
      if (faces.isNotEmpty) {
        _lastFaceDetectedTime = DateTime.now();
        final face = faces.first;

        _rawYaw = face.headEulerAngleY ?? 0.0;
        _rawPitch = face.headEulerAngleX ?? 0.0;
        _rawRoll = face.headEulerAngleZ ?? 0.0;

        double calYaw = -(_rawYaw - _yawOffset);
        double calPitch = (_rawPitch - _pitchOffset);
        double calRoll = -(_rawRoll - _rollOffset);

        if (calYaw.abs() < _deadzoneRadius) calYaw = 0.0;
        if (calPitch.abs() < _deadzoneRadius) calPitch = 0.0;
        if (calRoll.abs() < _deadzoneRadius) calRoll = 0.0;

        double dirYaw = _invertYaw ? -calYaw : calYaw;
        double dirPitch = _invertPitch ? -calPitch : calPitch;
        double dirRoll = _invertRoll ? -calRoll : calRoll;

        double targetYaw =
            (dirYaw * _yawMultiplier).clamp(-_yawLimit, _yawLimit);
        double targetPitch =
            (dirPitch * _pitchMultiplier).clamp(-_pitchLimit, _pitchLimit);
        double targetRoll =
            (dirRoll * _rollMultiplier).clamp(-_rollLimit, _rollLimit);

        _smoothedYaw = (_smoothedYaw * (1 - _smoothingFactor)) +
            (targetYaw * _smoothingFactor);
        _smoothedPitch = (_smoothedPitch * (1 - _smoothingFactor)) +
            (targetPitch * _smoothingFactor);
        _smoothedRoll = (_smoothedRoll * (1 - _smoothingFactor)) +
            (targetRoll * _smoothingFactor);

        if (mounted) setState(() {});
      }
    } catch (e) {
      print("Face Detection Error: $e");
    } finally {
      _isProcessing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0B111A),
      child: Column(
        children: [
          // الشريط العلوي مصمم بذكاء لمنع خروج العناصر من الشاشة
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: const Color(0xFF0B111A),
              border: Border(
                  bottom: BorderSide(
                      color: const Color(0xFF639DF0).withOpacity(0.3),
                      width: 1)),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    "COCKPIT HEAD TRACKER",
                    style: TextStyle(
                        color: Color(0xFF639DF0),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(Icons.tune,
                          color: _showSettings
                              ? Colors.white
                              : const Color(0xFF639DF0),
                          size: 22),
                      onPressed: () =>
                          setState(() => _showSettings = !_showSettings),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 32,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          backgroundColor: const Color(0xFF1E2633),
                          side: const BorderSide(
                              color: Color(0xFF639DF0), width: 1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                        ),
                        onPressed: _isTracking ? _recenter : null,
                        icon: const Icon(Icons.center_focus_strong,
                            color: Colors.white, size: 14),
                        label: const Text("Center",
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 32,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          backgroundColor: _isTracking
                              ? Colors.redAccent
                              : const Color(0xFF639DF0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                        ),
                        onPressed: _isTracking ? _stopTracking : _startTracking,
                        icon: Icon(_isTracking ? Icons.stop : Icons.play_arrow,
                            color: Colors.white, size: 14),
                        label: Text(_isTracking ? "Stop" : "Start",
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (_isLowLight)
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.orange)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.orange, size: 18),
                  SizedBox(width: 8),
                  Text("Low Light! Ensure your face is illuminated.",
                      style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ],
              ),
            ),

          // الشاشة التفاعلية والإعدادات
          Expanded(
            child: Stack(
              children: [
                // المحاكي الوهمي مع إيفيكت السنترة السحري
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(
                        color: _isRecenteringEffect
                            ? Colors.greenAccent
                            : const Color(0xFF1E2633),
                        width: _isRecenteringEffect ? 3 : 2),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: _isRecenteringEffect
                        ? [
                            BoxShadow(
                                color: Colors.greenAccent.withOpacity(0.5),
                                blurRadius: 15,
                                spreadRadius: 2)
                          ]
                        : [],
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final centerX = constraints.maxWidth / 2;
                      final centerY = constraints.maxHeight / 2;

                      final maxVisYaw = 180.0;
                      final maxVisPitch = 110.0;

                      final dotX = centerX +
                          (_smoothedYaw *
                              (constraints.maxWidth / (maxVisYaw * 2)));
                      final dotY = centerY +
                          (_smoothedPitch *
                              (constraints.maxHeight / (maxVisPitch * 2)));

                      final clampedX = math.min(math.max(dotX, 10.0),
                              constraints.maxWidth - 10.0) -
                          10.0;
                      final clampedY = math.min(math.max(dotY, 10.0),
                              constraints.maxHeight - 10.0) -
                          10.0;

                      final deadzoneVisualSize = (_deadzoneRadius *
                              _yawMultiplier *
                              (constraints.maxWidth / (maxVisYaw * 2))) *
                          2;

                      return Stack(
                        children: [
                          Align(
                              alignment: Alignment.center,
                              child: Container(
                                  width: constraints.maxWidth,
                                  height: 1,
                                  color: const Color(0xFF1E2633))),
                          Align(
                              alignment: Alignment.center,
                              child: Container(
                                  width: 1,
                                  height: constraints.maxHeight,
                                  color: const Color(0xFF1E2633))),
                          Align(
                            alignment: Alignment.center,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: deadzoneVisualSize,
                              height: deadzoneVisualSize,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: _isRecenteringEffect
                                          ? Colors.greenAccent
                                          : Colors.grey.withOpacity(0.2),
                                      width: 1),
                                  color: Colors.white.withOpacity(0.02)),
                            ),
                          ),
                          Positioned(
                            left: clampedX,
                            top: clampedY,
                            child: Transform.rotate(
                              angle: _smoothedRoll * (math.pi / 180),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 100),
                                width: _isRecenteringEffect ? 24 : 20,
                                height: _isRecenteringEffect ? 24 : 20,
                                decoration: BoxDecoration(
                                    color: _isRecenteringEffect
                                        ? Colors.greenAccent
                                        : const Color(0xFF639DF0),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                          color: _isRecenteringEffect
                                              ? Colors.greenAccent
                                              : const Color(0xFF639DF0),
                                          blurRadius: 12,
                                          spreadRadius: 3)
                                    ]),
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                      width: 2, height: 8, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // نافذة الإعدادات الشفافة بنظام البروفايلات الجديد
                if (_showSettings)
                  Positioned(
                    top: 16,
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B111A).withOpacity(0.96),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: const Color(0xFF639DF0).withOpacity(0.5),
                            width: 1),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.6),
                              blurRadius: 30,
                              spreadRadius: 5)
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  child: Text("PROFILES",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                          fontSize: 14)),
                                ),
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                      color: const Color(0xFF1E2633),
                                      borderRadius: BorderRadius.circular(6),
                                      border:
                                          Border.all(color: Colors.white24)),
                                  child: DropdownButton<String>(
                                    value: _currentProfile,
                                    dropdownColor: const Color(0xFF1E2633),
                                    style: const TextStyle(
                                        color: Color(0xFF639DF0),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12),
                                    underline: Container(),
                                    icon: const Icon(Icons.arrow_drop_down,
                                        color: Color(0xFF639DF0), size: 18),
                                    items: _profileNames
                                        .map((String value) =>
                                            DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value)))
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null) _applyProfile(val);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (_currentProfile == "Default")
                                  IconButton(
                                    icon: const Icon(Icons.add_circle,
                                        color: Color(0xFF639DF0)),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: _addNewProfileDialog,
                                  )
                                else ...[
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.white70, size: 20),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: _renameProfileDialog,
                                  ),
                                  const SizedBox(width: 12),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.redAccent, size: 20),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: _deleteProfile,
                                  ),
                                ],
                              ],
                            ),
                            const Divider(color: Colors.white24, height: 30),
                            const Text("AXIS INVERSION",
                                style: TextStyle(
                                    color: Color(0xFF639DF0),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildInvertButton("Yaw", _invertYaw, () {
                                  setState(() => _invertYaw = !_invertYaw);
                                  _autoSaveCurrentProfile();
                                }),
                                _buildInvertButton("Pitch", _invertPitch, () {
                                  setState(() => _invertPitch = !_invertPitch);
                                  _autoSaveCurrentProfile();
                                }),
                                _buildInvertButton("Roll", _invertRoll, () {
                                  setState(() => _invertRoll = !_invertRoll);
                                  _autoSaveCurrentProfile();
                                }),
                              ],
                            ),
                            const Divider(color: Colors.white24, height: 30),
                            const Text("SENSITIVITY (MULTIPLIERS)",
                                style: TextStyle(
                                    color: Color(0xFF639DF0),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            _buildSliderWithInput(
                                "Yaw Speed", _yawMultiplier, 1.0, 5.0, (val) {
                              setState(() => _yawMultiplier = val);
                              _autoSaveCurrentProfile();
                            }),
                            _buildSliderWithInput(
                                "Pitch Speed", _pitchMultiplier, 1.0, 5.0,
                                (val) {
                              setState(() => _pitchMultiplier = val);
                              _autoSaveCurrentProfile();
                            }),
                            _buildSliderWithInput(
                                "Roll Speed", _rollMultiplier, 1.0, 5.0, (val) {
                              setState(() => _rollMultiplier = val);
                              _autoSaveCurrentProfile();
                            }),
                            const Divider(color: Colors.white24, height: 30),
                            const Text("MAXIMUM LIMITS (DEGREES)",
                                style: TextStyle(
                                    color: Color(0xFF639DF0),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            _buildSliderWithInput(
                                "Yaw Limit", _yawLimit, 30.0, 180.0, (val) {
                              setState(() => _yawLimit = val);
                              _autoSaveCurrentProfile();
                            }),
                            _buildSliderWithInput(
                                "Pitch Limit", _pitchLimit, 30.0, 110.0, (val) {
                              setState(() => _pitchLimit = val);
                              _autoSaveCurrentProfile();
                            }),
                            _buildSliderWithInput(
                                "Roll Limit", _rollLimit, 0.0, 45.0, (val) {
                              setState(() => _rollLimit = val);
                              _autoSaveCurrentProfile();
                            }),
                            const Divider(color: Colors.white24, height: 30),
                            const Text("STABILITY & DEADZONE",
                                style: TextStyle(
                                    color: Color(0xFF639DF0),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            _buildSliderWithInput(
                                "Smoothing", _smoothingFactor, 0.05, 1.0,
                                (val) {
                              setState(() => _smoothingFactor = val);
                              _autoSaveCurrentProfile();
                            }),
                            _buildSliderWithInput(
                                "Deadzone", _deadzoneRadius, 0.0, 15.0, (val) {
                              setState(() => _deadzoneRadius = val);
                              _autoSaveCurrentProfile();
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvertButton(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: _currentProfile == "Default"
          ? null
          : onTap, // تعطيل الضغط في الديفولت
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF639DF0).withOpacity(0.2)
              : const Color(0xFF1E2633),
          border: Border.all(
              color: isSelected ? const Color(0xFF639DF0) : Colors.white24),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.swap_horiz : Icons.arrow_right_alt,
              color: _currentProfile == "Default"
                  ? Colors.white24
                  : (isSelected ? const Color(0xFF639DF0) : Colors.white54),
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              "Inv $label",
              style: TextStyle(
                color: _currentProfile == "Default"
                    ? Colors.white24
                    : (isSelected ? const Color(0xFF639DF0) : Colors.white54),
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderWithInput(String label, double value, double minVal,
      double maxVal, Function(double) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 85,
            child: Text(label,
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Slider(
              value: value,
              min: minVal,
              max: maxVal,
              activeColor: _currentProfile == "Default"
                  ? Colors.grey
                  : const Color(0xFF639DF0),
              inactiveColor: Colors.white12,
              onChanged: _currentProfile == "Default"
                  ? null
                  : onChanged, // تعطيل السلايدر في الديفولت
            ),
          ),
          InkWell(
            onTap: _currentProfile == "Default"
                ? null
                : () => _showEditNumberDialog(
                    label, value, minVal, maxVal, onChanged),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 50,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2633),
                border: Border.all(
                    color: _currentProfile == "Default"
                        ? Colors.white12
                        : const Color(0xFF639DF0).withOpacity(0.5)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                value.toStringAsFixed(1),
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: _currentProfile == "Default"
                        ? Colors.white54
                        : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// TAB 2: MSFS FLIGHT CONTROLS
// - Connection: close (ZERO 2-3s Python Keep-Alive stalls!)
// - Leak-proof abort + NO maxConnectionsPerHost cap (ZERO 30s freezes!)
// - User-locked Throttle slider + serialized queue (ZERO 31%->68% jumps!)
// - Real confirmed SimConnect button readback in ~50-150ms!
// ============================================================================

class _MsfsFlightControlsPane extends StatefulWidget {
  const _MsfsFlightControlsPane({
    Key? key,
    required this.targetIp,
  }) : super(key: key);

  final String targetIp;

  @override
  State<_MsfsFlightControlsPane> createState() =>
      _MsfsFlightControlsPaneState();
}

class _MsfsFlightControlsPaneState extends State<_MsfsFlightControlsPane> {
  static const int _port = 9090;
  static const String _settingsFileName =
      'sim_station_msfs_flight_controls_settings_v1.json';

  // Avionics Dark Cockpit Palette (Identical Design)
  static const Color _bg = Color(0xFF070C13);
  static const Color _cardTop = Color(0xFF121C2A);
  static const Color _cardBottom = Color(0xFF0C141F);
  static const Color _field = Color(0xFF09111B);
  static const Color _border = Color(0xFF223349);
  static const Color _borderLight = Color(0xFF324A68);
  static const Color _blue = Color(0xFF4D94FF);
  static const Color _cyan = Color(0xFF38BDF8);
  static const Color _muted = Color(0xFF8EA4BE);
  static const Color _red = Color(0xFFEF5350);
  static const Color _amber = Color(0xFFF59E0B);
  static const Color _green = Color(0xFF2DD48F);

  // Self-healing HTTP client: NO maxConnectionsPerHost cap, Connection: close on every request
  HttpClient _http = _createHttpClient();
  int _consecutiveNetErrors = 0;

  static HttpClient _createHttpClient() => HttpClient()
    ..connectionTimeout = const Duration(milliseconds: 1500)
    ..idleTimeout = const Duration(seconds: 1)
    ..autoUncompress = false;

  void _resetHttpClient() {
    final old = _http;
    _http = _createHttpClient();
    _consecutiveNetErrors = 0;
    try {
      old.close(force: true);
    } catch (_) {}
  }

  Timer? _statusTimer;
  Timer? _motionHeartbeatTimer;
  Timer? _rudderHeartbeat;
  Timer? _brakeHeartbeat;
  Timer? _trimHoldTimer;
  Timer? _reverseWarnTimer;

  StreamSubscription<GyroscopeEvent>? _gyroSub;
  StreamSubscription<AccelerometerEvent>? _accelSub;

  Future<void>? _inFlightStatus;
  Future<bool>? _inFlightSession;
  int _statusEpoch = 0;
  int _lastAppliedStatusEpoch = 0;
  DateTime? _lastCommandSentAt;

  String? _activeTrimName; // 'nose-up' or 'nose-down'
  DateTime? _trimDownAt;
  String? _pendingAction;
  DateTime? _commandPriorityUntil;

  bool _connected = false;
  bool _disposed = false;
  bool _motionWriteBusy = false;
  bool _reverseIdleWarning = false;

  // Throttle ownership + serialized coalescing queue (100% jump-proof!)
  bool _throttleTouched = false;
  bool _throttleDragging = false;
  bool _throttleWriteBusy = false;
  bool _hasPendingThrottle = false;
  bool _pendingThrottleFinal = false;
  int _pendingThrottleEngine = -1;
  double _pendingThrottleValue = 0.0;

  bool _rudderDragging = false;
  bool _rudderWriteBusy = false;
  bool _hasPendingRudder = false;
  bool _pendingRudderCenter = false;
  double _pendingRudderValue = 0.0;

  bool _brakeDragging = false;
  bool _brakeWriteBusy = false;
  bool _hasPendingBrake = false;
  bool _pendingBrakeRelease = false;
  double _pendingBrakeValue = 0.0;

  String _token = '';
  int _engines = 1;
  List<double> _throttles = <double>[];
  double _flapsPercent = -1;
  double _speedbrakePercent = 0;
  bool _speedbrakeArmed = false;
  double _trim = 0;
  bool _park = false;
  bool _parkKnown = false;
  int _gear = -1; // 0 = UP, 1 = DOWN, -1 = UNKNOWN

  bool _linkEngines = true;
  bool _reverse = false;
  bool _motionEnabled = false;
  bool _motionLocked = false;

  // Sensor Fusion State (Complementary Filter: Gyro + Accelerometer)
  double _ax = 0;
  double _ay = 0;
  double _az = 9.81;
  bool _hasAccel = false;
  bool _hasGyro = false;
  bool _needsInitialCenter = false;
  double _orientationSign = 1.0; // +1 Landscape Left, -1 Landscape Right

  double _rollAngle = 0;
  double _pitchAngle = 0;
  double _neutralRoll = 0;
  double _neutralPitch = 0;
  double _roll = 0;
  double _pitch = 0;
  double _rudder = 0;
  double _brakes = 0;

  // Persistent Yoke Sensitivity Settings
  double _rollRange = 35;
  double _pitchRange = 30;
  double _deadzone = 3;
  double _expo = 25;
  double _smooth = 10; // Crisp real-yoke feel by default
  bool _invertRoll = false;
  bool _invertPitch = false;
  bool _swapAxes = false;

  // Live callback for updating Sensitivity dialog preview in real time
  VoidCallback? _dialogRefresh;

  double _throttleTarget = 0;
  List<double> _individualThrottleTargets = <double>[];

  DateTime? _lastGyroTime;
  DateTime? _lastAccelTime;
  DateTime? _lastSensorTime;
  DateTime? _lastUiRefresh;
  DateTime? _lastMotionSentAt;
  double _lastRollSent = 0;
  double _lastPitchSent = 0;

  bool get _landscape =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  String _extractHost(String raw) {
    var h = raw.trim();
    if (h.startsWith('http://')) h = h.substring(7);
    if (h.startsWith('https://')) h = h.substring(8);
    final slash = h.indexOf('/');
    if (slash != -1) h = h.substring(0, slash);
    final colon = h.indexOf(':');
    if (colon != -1) h = h.substring(0, colon);
    return h.trim();
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startConnection();
    });
  }

  @override
  void didUpdateWidget(covariant _MsfsFlightControlsPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_extractHost(oldWidget.targetIp) != _extractHost(widget.targetIp)) {
      _token = '';
      _connected = false;
      _throttleTouched = false;
      _resetHttpClient();
      _startConnection();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _dialogRefresh = null;
    _statusTimer?.cancel();
    _motionHeartbeatTimer?.cancel();
    _rudderHeartbeat?.cancel();
    _brakeHeartbeat?.cancel();
    _trimHoldTimer?.cancel();
    _reverseWarnTimer?.cancel();
    _gyroSub?.cancel();
    _accelSub?.cancel();
    _releaseAllControls().whenComplete(() {
      try {
        _http.close(force: true);
      } catch (_) {}
    });
    super.dispose();
  }

  // ==================== PERSISTENT SETTINGS STORAGE (iOS & Android) ====================

  Future<List<File>> _candidateSettingsFiles() async {
    final files = <File>[];
    try {
      final tempPath =
          Directory.systemTemp.path.replaceAll(RegExp(r'[/\\]+$'), '');
      final parentDir = Directory(tempPath).parent;
      final candidateDirs = <Directory>[
        Directory('${parentDir.path}/Documents'), // iOS persistent Documents
        Directory(
            '${parentDir.path}/app_flutter'), // Android Flutter persistent
        Directory('${parentDir.path}/files'), // Android native persistent
      ];
      final home = Platform.environment['HOME'];
      if (home != null && home.isNotEmpty) {
        candidateDirs.add(Directory('$home/Documents'));
      }
      for (final dir in candidateDirs) {
        try {
          if (await dir.exists()) {
            files.add(File('${dir.path}/$_settingsFileName'));
          }
        } catch (_) {}
      }
    } catch (_) {}
    files.add(File('${Directory.systemTemp.path}/$_settingsFileName'));
    return files;
  }

  Future<void> _loadSettings() async {
    try {
      final candidates = await _candidateSettingsFiles();
      for (final file in candidates) {
        if (!await file.exists()) continue;
        final raw = await file.readAsString();
        final decoded = jsonDecode(raw);
        if (decoded is! Map<String, dynamic>) continue;
        if (_disposed || !mounted) return;
        setState(() {
          _rollRange = _asDouble(decoded['rollRange'], 35).clamp(8.0, 80.0);
          _pitchRange = _asDouble(decoded['pitchRange'], 30).clamp(8.0, 80.0);
          _deadzone = _asDouble(decoded['deadzone'], 3).clamp(0.0, 20.0);
          _expo = _asDouble(decoded['expo'], 25).clamp(0.0, 100.0);
          _smooth = _asDouble(decoded['smooth'], 10).clamp(0.0, 85.0);
          _invertRoll = decoded['invertRoll'] == true;
          _invertPitch = decoded['invertPitch'] == true;
          _swapAxes = decoded['swapAxes'] == true;
        });
        return;
      }
    } catch (_) {}
  }

  Future<void> _saveSettings() async {
    final payload = jsonEncode(<String, dynamic>{
      'rollRange': _rollRange,
      'pitchRange': _pitchRange,
      'deadzone': _deadzone,
      'expo': _expo,
      'smooth': _smooth,
      'invertRoll': _invertRoll,
      'invertPitch': _invertPitch,
      'swapAxes': _swapAxes,
    });
    final candidates = await _candidateSettingsFiles();
    for (final file in candidates) {
      try {
        await file.writeAsString(payload, flush: true);
        return;
      } catch (_) {}
    }
  }

  // ==================== MSFS VFC v0.1.5 SESSION & POLLING ====================

  Future<void> _startConnection() async {
    _statusTimer?.cancel();
    await _fetchSession();
    if (_disposed) return;
    await _readStatus(forceFresh: true);
    if (_disposed) return;
    // Fast end of recommended MSFS Bridge polling interval (500–700 ms)
    _statusTimer = Timer.periodic(
      const Duration(milliseconds: 550),
      (_) => _readStatus(),
    );
    _motionHeartbeatTimer ??= Timer.periodic(
      const Duration(milliseconds: 220),
      (_) => _dispatchMotionIfNeeded(forceHeartbeat: true),
    );
  }

  // ==================== INSTANT CONNECTION-CLOSE HTTP/JSON ENGINE ====================
  // CRITICAL: Sends Connection: close + persistentConnection = false on every request
  // so Python's http.server NEVER holds a thread waiting 2-3s for keep-alive!
  // AND always aborts + cancels stream on timeout with NO maxConnectionsPerHost cap
  // so it NEVER freezes after 30 seconds!

  Future<String> _readResponseText(
    HttpClientResponse response,
    Duration timeout,
  ) async {
    final completer = Completer<String>();
    final chunks = BytesBuilder(copy: false);
    StreamSubscription<List<int>>? sub;

    sub = response.listen(
      (data) => chunks.add(data),
      onDone: () {
        if (!completer.isCompleted) {
          completer.complete(
            utf8.decode(chunks.takeBytes(), allowMalformed: true),
          );
        }
      },
      onError: (Object err) {
        if (!completer.isCompleted) {
          completer.completeError(err);
        }
      },
      cancelOnError: true,
    );

    try {
      return await completer.future.timeout(timeout);
    } catch (_) {
      try {
        await sub.cancel();
      } catch (_) {}
      rethrow;
    }
  }

  Future<_MsfsApiResult> _requestJson(
    String path, {
    Map<String, dynamic>? body,
    bool needsToken = false,
    Duration timeout = const Duration(milliseconds: 1500),
  }) async {
    final host = _extractHost(widget.targetIp);
    if (host.isEmpty) {
      return const _MsfsApiResult(networkError: true, error: 'Empty target IP');
    }

    HttpClientRequest? request;
    final client = _http;
    try {
      final uri = Uri.parse('http://$host:$_port$path');
      request = body == null
          ? await client.getUrl(uri).timeout(timeout)
          : await client.postUrl(uri).timeout(timeout);

      // CRITICAL: Prevent Python HTTPServer keep-alive 2-3s stall!
      request.persistentConnection = false;
      request.headers.set(
        HttpHeaders.connectionHeader,
        'close',
        preserveHeaderCase: true,
      );
      request.headers.set(
        HttpHeaders.acceptHeader,
        'application/json',
        preserveHeaderCase: true,
      );

      if (needsToken && _token.isNotEmpty) {
        request.headers.set(
          'X-Station-Token',
          _token,
          preserveHeaderCase: true,
        );
      }

      if (body != null) {
        final encodedBody = utf8.encode(jsonEncode(body));
        request.headers.set(
          'Content-Type',
          'application/json',
          preserveHeaderCase: true,
        );
        request.headers.chunkedTransferEncoding = false;
        request.contentLength = encodedBody.length;
        request.add(encodedBody);
      }

      final response = await request.close().timeout(timeout);
      final rawText = await _readResponseText(response, timeout);

      _consecutiveNetErrors = 0;

      Map<String, dynamic>? decoded;
      try {
        final parsed = jsonDecode(rawText);
        if (parsed is Map<String, dynamic>) {
          decoded = parsed;
        }
      } catch (_) {}

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return _MsfsApiResult(
          statusCode: response.statusCode,
          data: decoded,
          rawBody: rawText,
          error: decoded?['error']?.toString() ??
              decoded?['code']?.toString() ??
              'HTTP ${response.statusCode}',
        );
      }

      return _MsfsApiResult(
        statusCode: response.statusCode,
        data: decoded,
        rawBody: rawText,
      );
    } catch (e) {
      try {
        request?.abort();
      } catch (_) {}

      _consecutiveNetErrors++;
      if (_consecutiveNetErrors >= 4 && identical(client, _http)) {
        _resetHttpClient();
      }
      return _MsfsApiResult(networkError: true, error: e.toString());
    }
  }

  Future<bool> _fetchSession() {
    if (_disposed) return Future<bool>.value(false);
    final existing = _inFlightSession;
    if (existing != null) return existing;
    final future = _doFetchSession();
    _inFlightSession = future;
    future.whenComplete(() {
      if (identical(_inFlightSession, future)) {
        _inFlightSession = null;
      }
    });
    return future;
  }

  Future<bool> _doFetchSession() async {
    final res = await _requestJson('/api/v1/session');
    if (_disposed) return false;
    final newToken = res.data?['token']?.toString() ?? '';
    if (newToken.isEmpty) return false;
    _token = newToken;
    return true;
  }

  Future<_MsfsApiResult> _postApi(
    String path,
    Map<String, dynamic> body, {
    bool allowRetry = true,
    Duration timeout = const Duration(milliseconds: 1500),
  }) async {
    if (_token.isEmpty) {
      await _fetchSession();
      if (_token.isEmpty) {
        return const _MsfsApiResult(networkError: true, error: 'Missing token');
      }
    }

    final res = await _requestJson(
      path,
      body: body,
      needsToken: true,
      timeout: timeout,
    );

    if (allowRetry && (res.statusCode == 401 || res.statusCode == 403)) {
      _token = '';
      final refreshed = await _fetchSession();
      if (refreshed && _token.isNotEmpty) {
        return _postApi(path, body, allowRetry: false, timeout: timeout);
      }
    }

    return res;
  }

  /// Epoch-guarded status read:
  /// - Never blocks a post-command fresh read behind an older periodic poll.
  /// - Discards any stale snapshot that finishes out of order.
  Future<void> _readStatus({bool forceFresh = false}) async {
    if (_disposed) return;

    if (!forceFresh) {
      if (_inFlightStatus != null ||
          _throttleDragging ||
          _throttleWriteBusy ||
          _hasPendingThrottle) {
        return;
      }
      if (_commandPriorityUntil != null &&
          DateTime.now().isBefore(_commandPriorityUntil!)) {
        return;
      }
    }

    final int myEpoch = ++_statusEpoch;
    final DateTime startedAt = DateTime.now();

    final future = _doReadStatus(myEpoch, startedAt);
    if (!forceFresh) {
      _inFlightStatus = future;
      future.whenComplete(() {
        if (identical(_inFlightStatus, future)) {
          _inFlightStatus = null;
        }
      });
    }
    await future;
  }

  Future<void> _doReadStatus(int myEpoch, DateTime startedAt) async {
    if (_token.isEmpty) {
      await _fetchSession();
    }
    final res = await _requestJson('/api/v1/status');
    if (_disposed || myEpoch < _lastAppliedStatusEpoch) return;

    if (res.data == null) {
      if (mounted && _connected) {
        setState(() => _connected = false);
      }
      return;
    }

    _lastAppliedStatusEpoch = myEpoch;
    final data = res.data!;
    final statusToken = data['token']?.toString() ?? '';
    if (statusToken.isNotEmpty) {
      _token = statusToken;
    }

    final count =
        (data['engines'] is num ? (data['engines'] as num).toInt() : 1)
            .clamp(1, 4)
            .toInt();

    List<double> throttleVals;
    if (data['throttles'] is List) {
      throttleVals = _numberList(data['throttles'], count)
          .map((v) => v.clamp(0.0, 1.0).toDouble())
          .toList();
    } else if (data['throttle_percent'] is List) {
      throttleVals = _numberList(data['throttle_percent'], count)
          .map((v) => (v / 100.0).clamp(0.0, 1.0).toDouble())
          .toList();
    } else {
      throttleVals = List<double>.filled(count, 0.0);
    }

    double flapsPct = -1;
    if (data['flaps_percent'] is num) {
      flapsPct = (data['flaps_percent'] as num).toDouble().clamp(0.0, 100.0);
    } else if (data['flaps'] is num) {
      final rawF = (data['flaps'] as num).toDouble();
      flapsPct = rawF < 0 ? -1 : (rawF * 100.0).clamp(0.0, 100.0);
    }

    double sbPct = 0;
    if (data['speedbrake_percent'] is num) {
      sbPct = (data['speedbrake_percent'] as num).toDouble().clamp(0.0, 100.0);
    } else if (data['speedbrake'] is num) {
      sbPct =
          ((data['speedbrake'] as num).toDouble() * 100.0).clamp(0.0, 100.0);
    }
    final bool sbArmed = data['speedbrake_armed'] == true;

    bool parkSet = _park;
    bool parkKnown = false;
    final pbObj = data['parking_brake'];
    if (pbObj is Map) {
      final stateStr = pbObj['state']?.toString().toUpperCase();
      if (pbObj['set'] is bool) {
        parkSet = pbObj['set'] == true;
        parkKnown = stateStr != 'UNKNOWN';
      } else if (stateStr == 'SET') {
        parkSet = true;
        parkKnown = true;
      } else if (stateStr == 'RELEASED') {
        parkSet = false;
        parkKnown = true;
      }
    } else if (data['park'] is bool) {
      parkSet = data['park'] == true;
      parkKnown = true;
    }

    int gearState = -1;
    final gearObj = data['landing_gear'];
    if (gearObj is Map) {
      if (gearObj['down'] == true) {
        gearState = 1;
      } else if (gearObj['up'] == true) {
        gearState = 0;
      }
    }
    if (gearState == -1 && data['gear'] is num) {
      final g = (data['gear'] as num).toInt();
      if (g == 0 || g == 1) gearState = g;
    }

    final bool reverseArmed = data['reverse_armed'] == true;

    // Ignore stale pre-command button fields if a button command fired AFTER this poll started
    final bool staleBeforeCommand =
        _lastCommandSentAt != null && startedAt.isBefore(_lastCommandSentAt!);

    if (!mounted) return;
    setState(() {
      _connected = data['sim_connected'] == true || _token.isNotEmpty;
      _engines = count;
      _throttles = throttleVals;
      _trim = _asDouble(data['trim']).clamp(-1.0, 1.0).toDouble();

      if (!staleBeforeCommand) {
        _flapsPercent = flapsPct;
        _speedbrakePercent = sbPct;
        _speedbrakeArmed = sbArmed;
        _park = parkSet;
        _parkKnown = parkKnown;
        _gear = gearState;
        _reverse = reverseArmed;
      }

      // CRITICAL: Once user touches Throttle, NEVER overwrite slider from status!
      // Eliminates 100% of 31%->68% or 50%->0%->70% slider jumps!
      if (!_throttleTouched) {
        _throttleTarget = throttleVals.isNotEmpty ? throttleVals.first : 0.0;
        _individualThrottleTargets = List<double>.generate(
          count,
          (i) => i < throttleVals.length ? throttleVals[i] : 0.0,
        );
      } else if (_individualThrottleTargets.length != count) {
        _individualThrottleTargets = List<double>.generate(
          count,
          (i) => i < _individualThrottleTargets.length
              ? _individualThrottleTargets[i]
              : _throttleTarget,
        );
      }
    });
  }

  List<double> _numberList(dynamic value, int count) {
    if (value is! List) return List<double>.filled(count, 0.0);
    return List<double>.generate(
      count,
      (i) => i < value.length ? _asDouble(value[i]) : 0.0,
    );
  }

  double _asDouble(dynamic value, [double fallback = 0]) =>
      value is num ? value.toDouble() : fallback;

  double _round4(double v) => double.parse(v.toStringAsFixed(4));
  double _round3(double v) => double.parse(v.toStringAsFixed(3));

  // ==================== FAST-CONFIRM REAL-READBACK MSFS COMMANDS ====================
  // NEVER fakes button color before confirmation; confirms real SimConnect state
  // rapidly (35ms -> 90ms -> 180ms if needed) over instant Connection: close!

  Future<void> _sendQuickPost(
    String path, {
    String? actionKey,
    bool Function()? didChange,
  }) async {
    HapticFeedback.mediumImpact();
    final now = DateTime.now();
    _lastCommandSentAt = now;
    _commandPriorityUntil = now.add(const Duration(milliseconds: 350));
    if (actionKey != null && mounted) {
      setState(() => _pendingAction = actionKey);
    }
    final res = await _postApi(path, const <String, dynamic>{});
    if (!res.isSuccess) {
      if (mounted && _pendingAction == actionKey) {
        setState(() => _pendingAction = null);
      }
      return;
    }

    // Fast confirmed SimConnect readback #1 (35ms)
    await Future<void>.delayed(const Duration(milliseconds: 35));
    await _readStatus(forceFresh: true);

    // If MSFS needed one more frame, confirm #2 (90ms)
    if (!_disposed && didChange != null && !didChange()) {
      await Future<void>.delayed(const Duration(milliseconds: 90));
      await _readStatus(forceFresh: true);
    }

    // Final confirmation #3 (160ms) for slower add-on aircraft
    if (!_disposed && didChange != null && !didChange()) {
      await Future<void>.delayed(const Duration(milliseconds: 160));
      await _readStatus(forceFresh: true);
    }

    if (mounted && _pendingAction == actionKey) {
      setState(() => _pendingAction = null);
    }
  }

  Future<void> _toggleParkingBrake() async {
    final before = _park;
    final path =
        _park ? '/api/v1/parking-brake/release' : '/api/v1/parking-brake/set';
    await _sendQuickPost(
      path,
      actionKey: 'park',
      didChange: () => _park != before,
    );
  }

  Future<void> _toggleGear() async {
    final before = _gear;
    final path =
        _gear == 0 ? '/api/v1/landing-gear/down' : '/api/v1/landing-gear/up';
    await _sendQuickPost(
      path,
      actionKey: 'gear',
      didChange: () => _gear != before,
    );
  }

  Future<void> _flapsDecrease() async {
    final before = _flapsPercent;
    await _sendQuickPost(
      '/api/v1/flaps/decrease',
      actionKey: 'flaps_dec',
      didChange: () => (_flapsPercent - before).abs() > 0.5,
    );
  }

  Future<void> _flapsIncrease() async {
    final before = _flapsPercent;
    await _sendQuickPost(
      '/api/v1/flaps/increase',
      actionKey: 'flaps_inc',
      didChange: () => (_flapsPercent - before).abs() > 0.5,
    );
  }

  Future<void> _speedbrakeDecrease() async {
    final beforePct = _speedbrakePercent;
    final beforeArm = _speedbrakeArmed;
    await _sendQuickPost(
      '/api/v1/speedbrake/decrease',
      actionKey: 'sb_dec',
      didChange: () =>
          (_speedbrakePercent - beforePct).abs() > 0.5 ||
          _speedbrakeArmed != beforeArm,
    );
  }

  Future<void> _speedbrakeIncrease() async {
    final beforePct = _speedbrakePercent;
    final beforeArm = _speedbrakeArmed;
    await _sendQuickPost(
      '/api/v1/speedbrake/increase',
      actionKey: 'sb_inc',
      didChange: () =>
          (_speedbrakePercent - beforePct).abs() > 0.5 ||
          _speedbrakeArmed != beforeArm,
    );
  }

  Future<void> _sendTrimHold(String direction, bool active) async {
    await _postApi(
      '/api/v1/elevator-trim/$direction',
      <String, dynamic>{'active': active},
    );
  }

  // ==================== ZERO-LAG DRIFT-FREE MOTION YOKE ====================

  double _wrapAngleDeg(double deg) {
    var a = deg;
    while (a > 180) a -= 360;
    while (a < -180) a += 360;
    return a;
  }

  double _computeRawAccelRollDeg(double ax, double ay, double az) {
    final xzNorm = math.sqrt(ax * ax + az * az);
    return math.atan2(_orientationSign * ay, xzNorm) * 180.0 / math.pi;
  }

  double _computeRawAccelPitchDeg(double ax, double az) {
    return math.atan2(_orientationSign * ax, az) * 180.0 / math.pi;
  }

  double _mappedAccelRoll() {
    final r = _computeRawAccelRollDeg(_ax, _ay, _az);
    final p = _computeRawAccelPitchDeg(_ax, _az);
    return _swapAxes ? p : r;
  }

  double _mappedAccelPitch() {
    final r = _computeRawAccelRollDeg(_ax, _ay, _az);
    final p = _computeRawAccelPitchDeg(_ax, _az);
    return _swapAxes ? r : p;
  }

  void _startMotionSensors() {
    if (_motionEnabled || !_landscape) return;
    HapticFeedback.mediumImpact();
    if (_token.isEmpty) {
      _fetchSession();
    }
    _gyroSub?.cancel();
    _accelSub?.cancel();

    _hasAccel = false;
    _hasGyro = false;
    _needsInitialCenter = true;
    _lastGyroTime = DateTime.now();
    _lastAccelTime = DateTime.now();
    _lastSensorTime = DateTime.now();
    _roll = 0;
    _pitch = 0;

    _accelSub = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 10),
    ).listen((event) {
      if (!_motionEnabled || _disposed) return;
      final now = DateTime.now();
      final prevAcc = _lastAccelTime;
      _lastAccelTime = now;
      _ax = event.x;
      _ay = event.y;
      _az = event.z;
      _hasAccel = true;
      _lastSensorTime = now;

      if (_needsInitialCenter) {
        _orientationSign = (_ax < -0.5) ? -1.0 : 1.0;
        _rollAngle = _mappedAccelRoll();
        _pitchAngle = _mappedAccelPitch();
        _neutralRoll = _rollAngle;
        _neutralPitch = _pitchAngle;
        _needsInitialCenter = false;
        _roll = 0;
        _pitch = 0;
        if (mounted) setState(() {});
        _dialogRefresh?.call();
        return;
      }

      if (!_hasGyro && !_motionLocked && _landscape) {
        final dt = prevAcc == null
            ? 0.016
            : (now.difference(prevAcc).inMicroseconds / 1000000.0)
                .clamp(0.004, 0.08)
                .toDouble();
        _rollAngle += _wrapAngleDeg(_mappedAccelRoll() - _rollAngle) * 0.30;
        _pitchAngle += _wrapAngleDeg(_mappedAccelPitch() - _pitchAngle) * 0.30;
        _updateMotionFromAngles(dt);
      }
    }, onError: (_) {});

    _gyroSub = gyroscopeEventStream(
      samplingPeriod: const Duration(milliseconds: 10),
    ).listen((event) {
      if (!_motionEnabled || _motionLocked || !_landscape || _disposed) return;
      final now = DateTime.now();
      final previous = _lastGyroTime;
      _lastGyroTime = now;
      _lastSensorTime = now;
      _hasGyro = true;
      if (previous == null || _needsInitialCenter) return;

      final dt = (now.difference(previous).inMicroseconds / 1000000.0)
          .clamp(0.001, 0.06)
          .toDouble();

      final xzNorm = math.sqrt(_ax * _ax + _az * _az);
      double rollRateRad;
      if (_hasAccel && xzNorm > 0.5) {
        final nx = _ax / xzNorm;
        final nz = _az / xzNorm;
        rollRateRad = (_orientationSign * nz * event.x) -
            (_orientationSign * nx * event.z);
      } else {
        rollRateRad = -event.z;
      }
      final pitchRateRad = _orientationSign * (-event.y);

      final rawRollRate = _swapAxes ? pitchRateRad : rollRateRad;
      final rawPitchRate = _swapAxes ? rollRateRad : pitchRateRad;

      final gyroRoll = _rollAngle + rawRollRate * dt * 180.0 / math.pi;
      final gyroPitch = _pitchAngle + rawPitchRate * dt * 180.0 / math.pi;

      if (_hasAccel) {
        final accRoll = _mappedAccelRoll();
        final accPitch = _mappedAccelPitch();
        _rollAngle = gyroRoll + _wrapAngleDeg(accRoll - gyroRoll) * 0.03;
        _pitchAngle = gyroPitch + _wrapAngleDeg(accPitch - gyroPitch) * 0.03;
      } else {
        _rollAngle = gyroRoll;
        _pitchAngle = gyroPitch;
      }

      _updateMotionFromAngles(dt);
    }, onError: (_) {
      _hasGyro = false;
      if (!_hasAccel) {
        _stopMotion();
      }
    });

    setState(() => _motionEnabled = true);
  }

  void _stopMotion() {
    HapticFeedback.lightImpact();
    _gyroSub?.cancel();
    _gyroSub = null;
    _accelSub?.cancel();
    _accelSub = null;
    _roll = 0;
    _pitch = 0;
    _lastSensorTime = null;
    if (mounted) setState(() => _motionEnabled = false);
    _postApi('/api/v1/yoke/center', const <String, dynamic>{});
  }

  void _updateMotionFromAngles(double dt, {bool instant = false}) {
    final rawRoll = _wrapAngleDeg(_rollAngle - _neutralRoll);
    final rawPitch = _wrapAngleDeg(_pitchAngle - _neutralPitch);
    final r = _curve(rawRoll, _rollRange, _invertRoll);
    final p = _curve(rawPitch, _pitchRange, _invertPitch);

    if (instant || _smooth <= 0.5) {
      _roll = r;
      _pitch = p;
    } else {
      final s = (_smooth / 100.0).clamp(0.0, 0.90);
      final tau = s * s * 0.24;
      final alpha =
          (1.0 - math.exp(-dt / math.max(tau, 0.001))).clamp(0.04, 1.0);
      _roll += (r - _roll) * alpha;
      _pitch += (p - _pitch) * alpha;
    }

    _dispatchMotionIfNeeded(forceHeartbeat: false);

    final now = DateTime.now();
    if (instant ||
        _lastUiRefresh == null ||
        now.difference(_lastUiRefresh!).inMilliseconds >= 16) {
      _lastUiRefresh = now;
      if (mounted) setState(() {});
      _dialogRefresh?.call();
    }
  }

  double _curve(double value, double range, bool invert) {
    final safeRange = range.clamp(8.0, 80.0);
    double x = (value / safeRange).clamp(-1.0, 1.0).toDouble();
    final dead = (_deadzone / 100.0).clamp(0.0, 0.45);
    if (x.abs() < dead) return 0;
    final sign = x.sign;
    x = ((x.abs() - dead) / (1.0 - dead)).clamp(0.0, 1.0).toDouble();
    final expoFactor = (_expo / 100.0).clamp(0.0, 1.0);
    x = (1.0 - expoFactor) * x + expoFactor * x * x * x;
    return sign * x * (invert ? -1.0 : 1.0);
  }

  void _recenter() {
    HapticFeedback.mediumImpact();
    if (_hasAccel) {
      _orientationSign = (_ax < -0.5) ? -1.0 : 1.0;
      _rollAngle = _mappedAccelRoll();
      _pitchAngle = _mappedAccelPitch();
    }
    _neutralRoll = _rollAngle;
    _neutralPitch = _pitchAngle;
    _roll = 0;
    _pitch = 0;
    _lastRollSent = 0;
    _lastPitchSent = 0;
    _postApi('/api/v1/yoke/center', const <String, dynamic>{});
    if (mounted) setState(() {});
    _dialogRefresh?.call();
  }

  void _resyncAfterAxisSwap() {
    if (_hasAccel) {
      _rollAngle = _mappedAccelRoll();
      _pitchAngle = _mappedAccelPitch();
      _neutralRoll = _rollAngle;
      _neutralPitch = _pitchAngle;
    } else {
      final tmpAngle = _rollAngle;
      _rollAngle = _pitchAngle;
      _pitchAngle = tmpAngle;
      final tmpNeutral = _neutralRoll;
      _neutralRoll = _neutralPitch;
      _neutralPitch = tmpNeutral;
    }
    _updateMotionFromAngles(0.016, instant: true);
  }

  Future<void> _dispatchMotionIfNeeded({required bool forceHeartbeat}) async {
    if (!_motionEnabled ||
        _motionLocked ||
        _token.isEmpty ||
        !_landscape ||
        _motionWriteBusy ||
        _disposed) {
      return;
    }
    // Yield briefly while a quick-control button or throttle drag is sending
    if (!forceHeartbeat &&
        (_throttleDragging ||
            (_commandPriorityUntil != null &&
                DateTime.now().isBefore(_commandPriorityUntil!)))) {
      return;
    }
    final lastSensor = _lastSensorTime;
    if (lastSensor == null ||
        DateTime.now().difference(lastSensor).inMilliseconds > 1800) {
      _stopMotion();
      return;
    }

    final now = DateTime.now();
    final elapsedMs = _lastMotionSentAt == null
        ? 9999
        : now.difference(_lastMotionSentAt!).inMilliseconds;

    if (elapsedMs < 28) return;

    final moved = (_roll - _lastRollSent).abs() >= 0.002 ||
        (_pitch - _lastPitchSent).abs() >= 0.002;

    if (!forceHeartbeat && !moved && elapsedMs < 220) return;

    _motionWriteBusy = true;
    _lastMotionSentAt = now;
    final sendRoll = _roll;
    final sendPitch = _pitch;
    _lastRollSent = sendRoll;
    _lastPitchSent = sendPitch;
    try {
      await _postApi(
        '/api/v1/yoke',
        <String, dynamic>{
          'roll': _round4(sendRoll),
          'pitch': _round4(sendPitch),
          'active': true,
        },
        timeout: const Duration(milliseconds: 900),
      );
    } finally {
      _motionWriteBusy = false;
    }
  }

  // ==================== ROCK-SOLID SERIALIZED THROTTLE / REVERSE / RUDDER / BRAKES ====================

  void _updateLocalThrottle(int engine, double v) {
    _throttleTouched = true;
    if (engine < 0) {
      _throttleTarget = v;
      _individualThrottleTargets = List<double>.filled(_engines, v);
    } else {
      while (_individualThrottleTargets.length < _engines) {
        _individualThrottleTargets.add(0.0);
      }
      _individualThrottleTargets[engine] = v;
      _throttleTarget = _individualThrottleTargets.first;
    }
    if (mounted) setState(() {});
  }

  void _onThrottleStart(int engine, double value) {
    _throttleTouched = true;
    _throttleDragging = true;
  }

  void _onThrottleChanged(int engine, double value) {
    final v = value.clamp(0.0, 1.0).toDouble();
    _throttleDragging = true;
    _updateLocalThrottle(engine, v);

    _pendingThrottleEngine = engine;
    _pendingThrottleValue = v;
    _pendingThrottleFinal = false;
    _hasPendingThrottle = true;
    _pumpThrottleQueue();
  }

  void _onThrottleEnd(int engine, double value) {
    final v = value.clamp(0.0, 1.0).toDouble();
    _throttleDragging = false;
    _updateLocalThrottle(engine, v);

    _pendingThrottleEngine = engine;
    _pendingThrottleValue = v;
    _pendingThrottleFinal = true;
    _hasPendingThrottle = true;
    _pumpThrottleQueue();
  }

  /// Sends throttle updates strictly ONE AT A TIME over instant Connection: close.
  /// Always coalesces to the latest user position and retries once on final release
  /// if a packet drops — guarantees exact position in MSFS with ZERO jumps!
  Future<void> _pumpThrottleQueue() async {
    if (_throttleWriteBusy || _disposed) return;
    _throttleWriteBusy = true;
    try {
      while (_hasPendingThrottle && !_disposed) {
        final int eng = _pendingThrottleEngine;
        final double val = _pendingThrottleValue;
        final bool isFinal = _pendingThrottleFinal;
        _hasPendingThrottle = false;
        _pendingThrottleFinal = false;

        final res = await _postApi(
          '/api/v1/throttle',
          <String, dynamic>{
            'engine': eng,
            'value': _round3(val),
            'reverse': _reverse,
          },
          timeout: const Duration(milliseconds: 1200),
        );

        // If the final resting value failed to deliver, retry once immediately
        if (isFinal && !res.isSuccess && !_hasPendingThrottle && !_disposed) {
          await _postApi(
            '/api/v1/throttle',
            <String, dynamic>{
              'engine': eng,
              'value': _round3(val),
              'reverse': _reverse,
            },
            timeout: const Duration(milliseconds: 1200),
          );
        }

        if (_hasPendingThrottle && !_disposed) {
          await Future<void>.delayed(const Duration(milliseconds: 24));
        }
      }
    } finally {
      _throttleWriteBusy = false;
    }
  }

  bool get _throttlesIdle {
    return _linkEngines
        ? _throttleTarget <= 0.02
        : _individualThrottleTargets.take(_engines).every((v) => v <= 0.02);
  }

  void _triggerReverseIdleWarning() {
    HapticFeedback.heavyImpact();
    _reverseWarnTimer?.cancel();
    if (mounted) {
      setState(() => _reverseIdleWarning = true);
    }
    _reverseWarnTimer = Timer(const Duration(milliseconds: 1700), () {
      if (mounted && !_disposed) {
        setState(() => _reverseIdleWarning = false);
      }
    });
  }

  Future<void> _toggleReverse() async {
    if (!_throttlesIdle) {
      _triggerReverseIdleWarning();
      return;
    }

    // Ensure any final 0% throttle POST completes before changing reverse mode
    while ((_throttleWriteBusy || _hasPendingThrottle) && !_disposed) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }

    HapticFeedback.mediumImpact();
    final now = DateTime.now();
    _lastCommandSentAt = now;
    _commandPriorityUntil = now.add(const Duration(milliseconds: 350));
    final before = _reverse;
    final path =
        _reverse ? '/api/v1/reverse/disable' : '/api/v1/reverse/enable';
    final res = await _postApi(path, const <String, dynamic>{});

    final bool blockedForIdle =
        (res.error ?? '').contains('reverse_change_requires_idle') ||
            (res.rawBody ?? '').contains('reverse_change_requires_idle');

    if (blockedForIdle || !res.isSuccess) {
      if (blockedForIdle) {
        _triggerReverseIdleWarning();
      }
      await _readStatus(forceFresh: true);
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 35));
    await _readStatus(forceFresh: true);
    if (!_disposed && _reverse == before) {
      await Future<void>.delayed(const Duration(milliseconds: 90));
      await _readStatus(forceFresh: true);
    }
  }

  void _onRudderChanged(double v) {
    setState(() {
      _rudder = v;
      _rudderDragging = true;
    });
    _pendingRudderCenter = false;
    _pendingRudderValue = v;
    _hasPendingRudder = true;
    _pumpRudderQueue();

    _rudderHeartbeat ??= Timer.periodic(
      const Duration(milliseconds: 160),
      (_) {
        if (_rudderDragging && !_disposed && !_rudderWriteBusy) {
          _pendingRudderCenter = false;
          _pendingRudderValue = _rudder;
          _hasPendingRudder = true;
          _pumpRudderQueue();
        }
      },
    );
  }

  void _onRudderReleased() {
    HapticFeedback.selectionClick();
    _rudderHeartbeat?.cancel();
    _rudderHeartbeat = null;
    setState(() {
      _rudder = 0;
      _rudderDragging = false;
    });
    _pendingRudderCenter = true;
    _pendingRudderValue = 0.0;
    _hasPendingRudder = true;
    _pumpRudderQueue();
  }

  Future<void> _pumpRudderQueue() async {
    if (_rudderWriteBusy || _disposed) return;
    _rudderWriteBusy = true;
    try {
      while (_hasPendingRudder && !_disposed) {
        final bool center = _pendingRudderCenter;
        final double val = _pendingRudderValue;
        _hasPendingRudder = false;

        if (center) {
          await _postApi('/api/v1/rudder/center', const <String, dynamic>{});
        } else {
          await _postApi(
            '/api/v1/rudder',
            <String, dynamic>{
              'value': _round3(val),
              'active': true,
            },
            timeout: const Duration(milliseconds: 1000),
          );
        }
        if (_hasPendingRudder && !_disposed) {
          await Future<void>.delayed(const Duration(milliseconds: 24));
        }
      }
    } finally {
      _rudderWriteBusy = false;
    }
  }

  void _onBrakesChanged(double v) {
    setState(() {
      _brakes = v;
      _brakeDragging = true;
    });
    _pendingBrakeRelease = false;
    _pendingBrakeValue = v;
    _hasPendingBrake = true;
    _pumpBrakeQueue();

    _brakeHeartbeat ??= Timer.periodic(
      const Duration(milliseconds: 160),
      (_) {
        if (_brakeDragging && !_disposed && !_brakeWriteBusy) {
          _pendingBrakeRelease = false;
          _pendingBrakeValue = _brakes;
          _hasPendingBrake = true;
          _pumpBrakeQueue();
        }
      },
    );
  }

  void _onBrakesReleased() {
    HapticFeedback.selectionClick();
    _brakeHeartbeat?.cancel();
    _brakeHeartbeat = null;
    setState(() {
      _brakes = 0;
      _brakeDragging = false;
    });
    _pendingBrakeRelease = true;
    _pendingBrakeValue = 0.0;
    _hasPendingBrake = true;
    _pumpBrakeQueue();
  }

  Future<void> _pumpBrakeQueue() async {
    if (_brakeWriteBusy || _disposed) return;
    _brakeWriteBusy = true;
    try {
      while (_hasPendingBrake && !_disposed) {
        final bool release = _pendingBrakeRelease;
        final double val = _pendingBrakeValue;
        _hasPendingBrake = false;

        if (release) {
          await _postApi(
              '/api/v1/manual-brakes/release', const <String, dynamic>{});
        } else {
          final b = _round3(val);
          await _postApi(
            '/api/v1/manual-brakes',
            <String, dynamic>{'left': b, 'right': b},
            timeout: const Duration(milliseconds: 1000),
          );
        }
        if (_hasPendingBrake && !_disposed) {
          await Future<void>.delayed(const Duration(milliseconds: 24));
        }
      }
    } finally {
      _brakeWriteBusy = false;
    }
  }

  void _beginTrimHold(String direction) {
    HapticFeedback.lightImpact();
    _trimHoldTimer?.cancel();
    setState(() => _activeTrimName = direction);
    _trimDownAt = DateTime.now();
    _sendTrimHold(direction, true);
    _trimHoldTimer = Timer.periodic(
      const Duration(milliseconds: 130),
      (_) => _sendTrimHold(direction, true),
    );
  }

  Future<void> _endTrimHold() async {
    final direction = _activeTrimName;
    final started = _trimDownAt;
    _trimHoldTimer?.cancel();
    _trimHoldTimer = null;
    if (mounted) setState(() => _activeTrimName = null);
    if (direction == null) return;
    if (started != null) {
      final elapsed = DateTime.now().difference(started).inMilliseconds;
      if (elapsed < 120) {
        await Future<void>.delayed(Duration(milliseconds: 120 - elapsed));
      }
    }
    await _sendTrimHold(direction, false);
    await Future<void>.delayed(const Duration(milliseconds: 35));
    await _readStatus(forceFresh: true);
  }

  Future<void> _releaseAllControls() async {
    if (_token.isEmpty) return;
    await _postApi('/api/v1/yoke/center', const <String, dynamic>{},
        allowRetry: false);
    await _postApi('/api/v1/rudder/center', const <String, dynamic>{},
        allowRetry: false);
    await _postApi('/api/v1/manual-brakes/release', const <String, dynamic>{},
        allowRetry: false);
    await _postApi(
      '/api/v1/elevator-trim/nose-up',
      const <String, dynamic>{'active': false},
      allowRetry: false,
    );
    await _postApi(
      '/api/v1/elevator-trim/nose-down',
      const <String, dynamic>{'active': false},
      allowRetry: false,
    );
    if (_reverse) {
      await _postApi('/api/v1/throttle/release', const <String, dynamic>{},
          allowRetry: false);
    }
  }

  void _toggleMotionLock() {
    HapticFeedback.mediumImpact();
    setState(() => _motionLocked = !_motionLocked);
    if (_motionLocked) {
      _roll = 0;
      _pitch = 0;
      _postApi('/api/v1/yoke/center', const <String, dynamic>{});
    }
  }

  // ==================== BUILD: FULL-SCREEN RESPONSIVE COCKPIT ====================

  @override
  Widget build(BuildContext context) {
    final landscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (!landscape) {
      return Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [Color(0xFF101C2B), _bg],
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            decoration: BoxDecoration(
              color: _cardBottom,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _border),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.screen_rotation_rounded, color: _blue, size: 44),
                SizedBox(height: 14),
                Text(
                  'LANDSCAPE REQUIRED',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Rotate your device sideways to open Flight Controls',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _muted, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      color: _bg,
      child: SafeArea(
        top: false,
        bottom: false,
        left: true,
        right: true,
        minimum: const EdgeInsets.fromLTRB(8, 2, 8, 2),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            final isTablet = w >= 880 && h >= 480;
            final isCompact = h < 360;
            final gap = isTablet ? 12.0 : 8.0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(isTablet: isTablet, isCompact: isCompact),
                SizedBox(height: isTablet ? 10 : 6),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // LEFT COLUMN: Motion Yoke + (Rudder | Elevator Trim)
                      Expanded(
                        flex: 11,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: isTablet ? 65 : 64,
                              child: _panel(
                                title: 'MOTION YOKE',
                                icon: Icons.sports_esports_rounded,
                                isTablet: isTablet,
                                isCompact: isCompact,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _statusPill(
                                      label: _motionLocked
                                          ? 'LOCKED'
                                          : (_motionEnabled
                                              ? 'ACTIVE'
                                              : 'STANDBY'),
                                      color: _motionLocked
                                          ? _amber
                                          : (_motionEnabled ? _green : _muted),
                                      isTablet: isTablet,
                                    ),
                                    const SizedBox(width: 6),
                                    _TactileButton(
                                      onTap: _motionEnabled
                                          ? _stopMotion
                                          : _startMotionSensors,
                                      active: _motionEnabled,
                                      accentColor:
                                          _motionEnabled ? _red : _green,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isTablet ? 12 : 9,
                                        vertical: isTablet ? 6 : 4,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _motionEnabled
                                                ? Icons.stop_rounded
                                                : Icons.play_arrow_rounded,
                                            size: isTablet ? 15 : 13,
                                            color:
                                                _motionEnabled ? _red : _green,
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            _motionEnabled ? 'STOP' : 'ENABLE',
                                            style: TextStyle(
                                              color: _motionEnabled
                                                  ? _red
                                                  : _green,
                                              fontSize: isTablet ? 11 : 9,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                child: _buildYokePanel(
                                  isTablet: isTablet,
                                  isCompact: isCompact,
                                ),
                              ),
                            ),
                            SizedBox(height: gap),
                            Expanded(
                              flex: isTablet ? 35 : 36,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    flex: 56,
                                    child: _panel(
                                      title: 'RUDDER',
                                      icon: Icons.navigation_rounded,
                                      isTablet: isTablet,
                                      isCompact: isCompact,
                                      trailing: _valueTag(
                                        '${(_rudder * 100).round()}%',
                                        color: _rudder.abs() > 0.02
                                            ? _cyan
                                            : Colors.white,
                                        isTablet: isTablet,
                                      ),
                                      child: _buildRudderPanel(
                                        isTablet: isTablet,
                                        isCompact: isCompact,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: gap),
                                  Expanded(
                                    flex: 44,
                                    child: _panel(
                                      title: 'ELEVATOR TRIM',
                                      icon: Icons.swap_vert_rounded,
                                      isTablet: isTablet,
                                      isCompact: isCompact,
                                      trailing: _valueTag(
                                        '${(_trim * 100).round()}%',
                                        color: _activeTrimName != null
                                            ? _blue
                                            : Colors.white,
                                        isTablet: isTablet,
                                      ),
                                      child: _buildTrimPanel(
                                        isTablet: isTablet,
                                        isCompact: isCompact,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: gap),
                      // RIGHT COLUMN: Throttle + Quick Controls
                      Expanded(
                        flex: 10,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: isTablet ? 38 : 37,
                              child: _panel(
                                title: 'THROTTLE',
                                icon: Icons.tune_rounded,
                                isTablet: isTablet,
                                isCompact: isCompact,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _TactileButton(
                                      onTap: () {
                                        HapticFeedback.selectionClick();
                                        setState(() {
                                          _linkEngines = !_linkEngines;
                                          if (_linkEngines &&
                                              _individualThrottleTargets
                                                  .isNotEmpty) {
                                            _throttleTarget =
                                                _individualThrottleTargets
                                                    .first;
                                          } else if (!_linkEngines) {
                                            _individualThrottleTargets =
                                                List<double>.filled(
                                                    _engines, _throttleTarget);
                                          }
                                        });
                                      },
                                      active: _linkEngines,
                                      accentColor: _blue,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isTablet ? 10 : 7,
                                        vertical: isTablet ? 5 : 3.5,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _linkEngines
                                                ? Icons.link_rounded
                                                : Icons.link_off_rounded,
                                            size: isTablet ? 14 : 11,
                                            color:
                                                _linkEngines ? _blue : _muted,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _linkEngines ? 'LINKED' : 'SPLIT',
                                            style: TextStyle(
                                              color: _linkEngines
                                                  ? Colors.white
                                                  : _muted,
                                              fontSize: isTablet ? 10 : 8.5,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    _TactileButton(
                                      onTap: _toggleReverse,
                                      active: _reverse || _reverseIdleWarning,
                                      accentColor:
                                          _reverseIdleWarning ? _amber : _red,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isTablet ? 10 : 7,
                                        vertical: isTablet ? 5 : 3.5,
                                      ),
                                      child: Text(
                                        _reverseIdleWarning
                                            ? 'IDLE!'
                                            : (_reverse ? 'REV ON' : 'REV'),
                                        style: TextStyle(
                                          color: _reverseIdleWarning
                                              ? _amber
                                              : (_reverse ? _red : _muted),
                                          fontSize: isTablet ? 10 : 8.5,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                child: _buildThrottlePanel(
                                  isTablet: isTablet,
                                  isCompact: isCompact,
                                ),
                              ),
                            ),
                            SizedBox(height: gap),
                            Expanded(
                              flex: isTablet ? 62 : 63,
                              child: _panel(
                                title: 'QUICK CONTROLS',
                                icon: Icons.dashboard_customize_rounded,
                                isTablet: isTablet,
                                isCompact: isCompact,
                                child: _buildQuickControls(
                                  isTablet: isTablet,
                                  isCompact: isCompact,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ==================== HEADER ====================

  Widget _buildHeader({required bool isTablet, required bool isCompact}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 14 : 10,
        vertical: isTablet ? 8 : (isCompact ? 4 : 6),
      ),
      decoration: BoxDecoration(
        color: _cardBottom,
        borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 3.5,
            height: isTablet ? 26 : 20,
            decoration: BoxDecoration(
              color: _blue,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(color: _blue.withOpacity(0.55), blurRadius: 8),
              ],
            ),
          ),
          SizedBox(width: isTablet ? 12 : 9),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    'VIRTUAL FLIGHT CONTROLS',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 16 : (isCompact ? 12.5 : 13.5),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.9,
                    ),
                  ),
                ),
                if (!isCompact) ...[
                  const SizedBox(width: 10),
                  Text(
                    'YOKE · THROTTLE · QUICK CONTROLS',
                    style: TextStyle(
                      color: _muted.withOpacity(0.75),
                      fontSize: isTablet ? 10.5 : 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== CARD SHELL ====================

  Widget _panel({
    required String title,
    required IconData icon,
    required Widget child,
    required bool isTablet,
    required bool isCompact,
    Widget? trailing,
  }) {
    final pad = isTablet ? 12.0 : (isCompact ? 7.0 : 9.0);
    return Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_cardTop, _cardBottom],
        ),
        borderRadius: BorderRadius.circular(isTablet ? 14 : 11),
        border: Border.all(color: _border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: _blue, size: isTablet ? 18 : 14),
              SizedBox(width: isTablet ? 8 : 6),
              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 12.5 : (isCompact ? 10 : 11),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          SizedBox(height: isTablet ? 8 : (isCompact ? 4 : 6)),
          Container(height: 1, color: _border.withOpacity(0.85)),
          SizedBox(height: isTablet ? 8 : (isCompact ? 4 : 6)),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _statusPill({
    required String label,
    required Color color,
    required bool isTablet,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 8 : 6,
        vertical: isTablet ? 3.5 : 2.5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: isTablet ? 9.5 : 8,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _valueTag(String text,
      {required Color color, required bool isTablet}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 8 : 6,
        vertical: isTablet ? 3 : 2,
      ),
      decoration: BoxDecoration(
        color: _field,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _border),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: isTablet ? 12 : 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  // ==================== MOTION YOKE PANEL ====================

  Widget _buildYokePanel({required bool isTablet, required bool isCompact}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _axisReadout(
                'PITCH',
                _pitch,
                isTablet: isTablet,
                isCompact: isCompact,
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, c) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: Size(c.maxWidth, c.maxHeight),
                          painter: _ReticlePainter(
                            roll: _roll,
                            pitch: _pitch,
                            active: _motionEnabled && !_motionLocked,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(isTablet ? 10 : 4),
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Transform.translate(
                              offset: Offset(_roll * 20, -_pitch * 14),
                              child: Transform.rotate(
                                angle: _roll * 0.34,
                                child: Transform.scale(
                                  scale:
                                      (1.0 + _pitch * 0.06).clamp(0.92, 1.08),
                                  child: _VirtualYokeArt(
                                    active: _motionEnabled && !_motionLocked,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              _axisReadout(
                'ROLL',
                _roll,
                isTablet: isTablet,
                isCompact: isCompact,
              ),
            ],
          ),
        ),
        SizedBox(height: isTablet ? 8 : (isCompact ? 4 : 6)),
        Row(
          children: [
            Expanded(
              child: _yokeActionBtn(
                'RECENTER',
                Icons.center_focus_strong_rounded,
                _recenter,
                isTablet: isTablet,
                isCompact: isCompact,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _yokeActionBtn(
                'CALIBRATE',
                Icons.gps_fixed_rounded,
                _showCalibration,
                isTablet: isTablet,
                isCompact: isCompact,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _yokeActionBtn(
                'SENSITIVITY',
                Icons.tune_rounded,
                _showSensitivityDialog,
                isTablet: isTablet,
                isCompact: isCompact,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _yokeActionBtn(
                _motionLocked ? 'UNLOCK' : 'LOCK',
                _motionLocked
                    ? Icons.lock_open_rounded
                    : Icons.lock_outline_rounded,
                _toggleMotionLock,
                active: _motionLocked,
                accentColor: _amber,
                isTablet: isTablet,
                isCompact: isCompact,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _yokeActionBtn(
    String label,
    IconData icon,
    VoidCallback onTap, {
    required bool isTablet,
    required bool isCompact,
    bool active = false,
    Color accentColor = _blue,
  }) {
    return _TactileButton(
      onTap: onTap,
      active: active,
      accentColor: accentColor,
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 8 : 4,
        vertical: isTablet ? 9 : (isCompact ? 5.5 : 7),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: active ? accentColor : _muted,
            size: isTablet ? 15 : 12,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: active ? Colors.white : _muted,
                fontSize: isTablet ? 10 : (isCompact ? 7.8 : 8.5),
                fontWeight: FontWeight.w800,
                letterSpacing: 0.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _axisReadout(
    String label,
    double value, {
    required bool isTablet,
    required bool isCompact,
  }) {
    final active = value.abs() > 0.02;
    return SizedBox(
      width: isTablet ? 64 : 46,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: _muted,
              fontSize: isTablet ? 10 : 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          SizedBox(height: isTablet ? 4 : 2),
          Text(
            '${(value * 100).round()}%',
            style: TextStyle(
              color: active ? _cyan : Colors.white,
              fontSize: isTablet ? 15 : (isCompact ? 11 : 12.5),
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: isTablet ? 8 : 5),
          Expanded(
            child: Container(
              width: isTablet ? 8 : 6,
              margin: const EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                color: _field,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: _border),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    height: 1.5,
                    color: _borderLight,
                  ),
                  Align(
                    alignment: Alignment(0, -value.clamp(-1.0, 1.0).toDouble()),
                    child: Container(
                      width: isTablet ? 10 : 8,
                      height: isTablet ? 10 : 8,
                      decoration: BoxDecoration(
                        color: active ? _cyan : _blue,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: (active ? _cyan : _blue).withOpacity(0.65),
                            blurRadius: 7,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== RUDDER PANEL ====================

  Widget _buildRudderPanel({required bool isTablet, required bool isCompact}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 2,
                  height: isTablet ? 20 : 14,
                  decoration: BoxDecoration(
                    color: _borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SliderTheme(
                  data: _sliderTheme(isTablet: isTablet, isCompact: isCompact),
                  child: Slider(
                    value: _rudder.clamp(-1.0, 1.0).toDouble(),
                    min: -1,
                    max: 1,
                    onChanged: _onRudderChanged,
                    onChangeEnd: (_) => _onRudderReleased(),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('LEFT',
                  style: TextStyle(
                      color: _muted,
                      fontSize: isTablet ? 10 : 8,
                      fontWeight: FontWeight.w700)),
              Text('CENTER',
                  style: TextStyle(
                      color: _muted.withOpacity(0.75),
                      fontSize: isTablet ? 10 : 8,
                      fontWeight: FontWeight.w700)),
              Text('RIGHT',
                  style: TextStyle(
                      color: _muted,
                      fontSize: isTablet ? 10 : 8,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== ELEVATOR TRIM PANEL (SIDE-BY-SIDE) ====================

  Widget _buildTrimPanel({required bool isTablet, required bool isCompact}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _trimHoldBtn(
            label: 'NOSE\nDN',
            icon: Icons.keyboard_arrow_down_rounded,
            direction: 'nose-down',
            isTablet: isTablet,
            isCompact: isCompact,
          ),
        ),
        SizedBox(width: isTablet ? 8 : 6),
        Expanded(
          child: _trimHoldBtn(
            label: 'NOSE\nUP',
            icon: Icons.keyboard_arrow_up_rounded,
            direction: 'nose-up',
            isTablet: isTablet,
            isCompact: isCompact,
          ),
        ),
      ],
    );
  }

  Widget _trimHoldBtn({
    required String label,
    required IconData icon,
    required String direction,
    required bool isTablet,
    required bool isCompact,
  }) {
    final isHolding = _activeTrimName == direction;
    return _TactileButton(
      onHoldStart: () => _beginTrimHold(direction),
      onHoldEnd: _endTrimHold,
      active: isHolding,
      accentColor: _blue,
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 8 : 4,
        vertical: isTablet ? 8 : 4,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isHolding ? _cyan : _blue,
            size: isTablet ? 24 : (isCompact ? 17 : 19),
          ),
          SizedBox(height: isTablet ? 3 : 1),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isHolding ? Colors.white : _muted,
              fontSize: isTablet ? 10.5 : (isCompact ? 8 : 8.5),
              fontWeight: FontWeight.w800,
              height: 1.1,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== THROTTLE PANEL ====================

  Widget _buildThrottlePanel(
      {required bool isTablet, required bool isCompact}) {
    if (_linkEngines) {
      return Center(
        child: _throttleRow(
          engine: -1,
          label: _reverse ? 'ALL REV' : 'ALL ENG',
          value: _throttleTarget,
          isTablet: isTablet,
          isCompact: isCompact,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final rows = List<Widget>.generate(
          _engines,
          (i) => Padding(
            padding: EdgeInsets.only(bottom: i == _engines - 1 ? 0 : 4),
            child: _throttleRow(
              engine: i,
              label: 'ENG ${i + 1}',
              value: i < _individualThrottleTargets.length
                  ? _individualThrottleTargets[i]
                  : 0.0,
              isTablet: isTablet,
              isCompact: isCompact,
            ),
          ),
        );
        if (_engines <= 2) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: rows,
          );
        }
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(children: rows),
        );
      },
    );
  }

  Widget _throttleRow({
    required int engine,
    required String label,
    required double value,
    required bool isTablet,
    required bool isCompact,
  }) {
    final activeColor = _reverse ? _red : _blue;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 10 : 7,
        vertical: isTablet ? 6 : (isCompact ? 2 : 4),
      ),
      decoration: BoxDecoration(
        color: _field,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: _reverse ? _red.withOpacity(0.55) : _border,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: isTablet ? 68 : 48,
            child: Text(
              label,
              style: TextStyle(
                color: _reverse ? _red : _muted,
                fontSize: isTablet ? 10.5 : 8.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: _sliderTheme(
                isTablet: isTablet,
                isCompact: isCompact,
                activeColor: activeColor,
              ),
              child: Slider(
                value: value.clamp(0.0, 1.0).toDouble(),
                min: 0,
                max: 1,
                onChangeStart: (v) => _onThrottleStart(engine, v),
                onChanged: (v) => _onThrottleChanged(engine, v),
                onChangeEnd: (v) => _onThrottleEnd(engine, v),
              ),
            ),
          ),
          SizedBox(
            width: isTablet ? 48 : 36,
            child: Text(
              '${(value * 100).round()}%',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: _reverse ? _red : Colors.white,
                fontSize: isTablet ? 13.5 : 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== QUICK CONTROLS PANEL ====================

  Widget _buildQuickControls(
      {required bool isTablet, required bool isCompact}) {
    final rowGap = isTablet ? 10.0 : (isCompact ? 5.0 : 7.0);

    final bool gearDown = _gear == 1;
    final bool gearUp = _gear == 0;
    final Color gearColor = gearDown ? _green : (gearUp ? _cyan : _muted);
    final String gearStateText = gearDown ? 'DOWN' : (gearUp ? 'UP' : '—');
    final Color parkColor = _park ? _red : _green;

    final bool showSbArmed = _speedbrakeArmed && _speedbrakePercent <= 0.5;
    final String speedbrakeText =
        showSbArmed ? 'ARM' : '${_speedbrakePercent.round()}%';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ROW 1: PARKING BRAKE (RED/GREEN) + SINGLE TOGGLE LANDING GEAR
        Expanded(
          flex: 34,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _toggleCockpitTile(
                  title: 'PARKING BRAKE',
                  value: _parkKnown ? (_park ? 'SET' : 'RELEASED') : 'RELEASED',
                  icon:
                      _park ? Icons.report_rounded : Icons.check_circle_rounded,
                  active: true,
                  busy: _pendingAction == 'park',
                  accentColor: parkColor,
                  onTap: _toggleParkingBrake,
                  isTablet: isTablet,
                  isCompact: isCompact,
                ),
              ),
              SizedBox(width: isTablet ? 10 : 7),
              Expanded(
                child: _toggleCockpitTile(
                  title: 'LANDING GEAR',
                  value: gearStateText,
                  icon: gearDown
                      ? Icons.flight_land_rounded
                      : Icons.flight_takeoff_rounded,
                  active: gearDown || gearUp,
                  busy: _pendingAction == 'gear',
                  accentColor: gearColor,
                  onTap: _toggleGear,
                  isTablet: isTablet,
                  isCompact: isCompact,
                  subtitleHint: gearDown ? 'TAP FOR UP' : 'TAP FOR DOWN',
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: rowGap),
        // ROW 2: FLAPS & SPEEDBRAKE SIDE-BY-SIDE COMPACT STEP PODS
        Expanded(
          flex: 33,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _stepPod(
                  title: 'FLAPS',
                  value: _flapsPercent < 0 ? '—' : '${_flapsPercent.round()}%',
                  onMinus: _flapsDecrease,
                  onPlus: _flapsIncrease,
                  isTablet: isTablet,
                  isCompact: isCompact,
                ),
              ),
              SizedBox(width: isTablet ? 10 : 7),
              Expanded(
                child: _stepPod(
                  title: 'SPEEDBRAKE',
                  value: speedbrakeText,
                  valueColor: showSbArmed ? _green : Colors.white,
                  onMinus: _speedbrakeDecrease,
                  onPlus: _speedbrakeIncrease,
                  isTablet: isTablet,
                  isCompact: isCompact,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: rowGap),
        // ROW 3: MANUAL BRAKES
        Expanded(
          flex: 33,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 11 : 8,
              vertical: isTablet ? 6 : 3,
            ),
            decoration: BoxDecoration(
              color: _field,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _brakes > 0.02 ? _red.withOpacity(0.55) : _border,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.disc_full_rounded,
                      size: isTablet ? 14 : 11,
                      color: _brakes > 0.02 ? _red : _muted,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        'MANUAL BRAKES',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _muted,
                          fontSize: isTablet ? 10 : 8.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    Text(
                      '${(_brakes * 100).round()}%',
                      style: TextStyle(
                        color: _brakes > 0.02 ? _red : Colors.white,
                        fontSize: isTablet ? 12 : 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _TactileButton(
                      onTap: _onBrakesReleased,
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 9 : 6,
                        vertical: isTablet ? 3.5 : 2,
                      ),
                      child: Text(
                        'RELEASE',
                        style: TextStyle(
                          color: _muted,
                          fontSize: isTablet ? 9 : 7.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Center(
                    child: SliderTheme(
                      data: _sliderTheme(
                        isTablet: isTablet,
                        isCompact: isCompact,
                        activeColor: _red,
                      ),
                      child: Slider(
                        value: _brakes.clamp(0.0, 1.0).toDouble(),
                        min: 0,
                        max: 1,
                        onChanged: _onBrakesChanged,
                        onChangeEnd: (_) => _onBrakesReleased(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _toggleCockpitTile({
    required String title,
    required String value,
    required IconData icon,
    required bool active,
    required bool busy,
    required Color accentColor,
    required VoidCallback onTap,
    required bool isTablet,
    required bool isCompact,
    String? subtitleHint,
  }) {
    return _TactileButton(
      onTap: onTap,
      active: active,
      accentColor: accentColor,
      borderRadius: 10,
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 12 : 8,
        vertical: isTablet ? 8 : (isCompact ? 4 : 6),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: isTablet ? 4.5 : 3.5,
            height: double.infinity,
            margin: EdgeInsets.symmetric(vertical: isTablet ? 3 : 2),
            decoration: BoxDecoration(
              color: active ? accentColor : _borderLight,
              borderRadius: BorderRadius.circular(4),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: accentColor.withOpacity(0.7),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
          ),
          SizedBox(width: isTablet ? 10 : 7),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _muted,
                    fontSize: isTablet ? 9.5 : 7.8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
                SizedBox(height: isTablet ? 3 : 1),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: active ? accentColor : Colors.white,
                          fontSize: isTablet ? 15 : (isCompact ? 11.5 : 12.5),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    if (isTablet && subtitleHint != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        subtitleHint,
                        style: TextStyle(
                          color: _muted.withOpacity(0.65),
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          busy
              ? SizedBox(
                  width: isTablet ? 16 : 13,
                  height: isTablet ? 16 : 13,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: accentColor,
                  ),
                )
              : Icon(
                  icon,
                  color: active ? accentColor : _muted.withOpacity(0.6),
                  size: isTablet ? 20 : 16,
                ),
        ],
      ),
    );
  }

  Widget _stepPod({
    required String title,
    required String value,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
    required bool isTablet,
    required bool isCompact,
    Color valueColor = Colors.white,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 10 : 7,
        vertical: isTablet ? 7 : (isCompact ? 4 : 5),
      ),
      decoration: BoxDecoration(
        color: _field,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _muted,
                    fontSize: isTablet ? 9.5 : 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: valueColor,
                  fontSize: isTablet ? 13 : 10.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 6 : 4),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _TactileButton(
                    onTap: onMinus,
                    accentColor: _blue,
                    padding: EdgeInsets.zero,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.remove_rounded,
                              color: Colors.white, size: isTablet ? 16 : 13),
                          if (isTablet) ...[
                            const SizedBox(width: 3),
                            const Text('UP',
                                style: TextStyle(
                                    color: _muted,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800)),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _TactileButton(
                    onTap: onPlus,
                    accentColor: _blue,
                    padding: EdgeInsets.zero,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_rounded,
                              color: Colors.white, size: isTablet ? 16 : 13),
                          if (isTablet) ...[
                            const SizedBox(width: 3),
                            const Text('DN',
                                style: TextStyle(
                                    color: _muted,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800)),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  SliderThemeData _sliderTheme({
    required bool isTablet,
    required bool isCompact,
    Color activeColor = _blue,
  }) =>
      SliderTheme.of(context).copyWith(
        activeTrackColor: activeColor,
        inactiveTrackColor: _border,
        thumbColor: Colors.white,
        overlayColor: activeColor.withOpacity(0.18),
        trackHeight: isTablet ? 6 : 4.5,
        thumbShape: RoundSliderThumbShape(
          enabledThumbRadius: isTablet ? 8.5 : (isCompact ? 6.5 : 7),
        ),
        overlayShape: RoundSliderOverlayShape(
          overlayRadius: isTablet ? 16 : 12,
        ),
      );

  // ==================== CALIBRATION & PERSISTENT SENSITIVITY DIALOGS ====================

  void _showCalibration() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _cardTop,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: _borderLight),
        ),
        title: const Text(
          'Yoke Calibration',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Hold your device at your natural flying angle, keep it steady, and tap CAPTURE CENTER. Sensor fusion prevents gyro drift and locks your center position.',
          style: TextStyle(color: _muted, height: 1.45, fontSize: 13),
        ),
        actions: [
          if (!_motionEnabled)
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _startMotionSensors();
              },
              child: const Text('ENABLE MOTION',
                  style: TextStyle(color: _blue, fontWeight: FontWeight.w800)),
            ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _recenter();
            },
            child: const Text('CAPTURE CENTER',
                style: TextStyle(color: _green, fontWeight: FontWeight.w800)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _showSensitivityDialog();
            },
            child: const Text('SENSITIVITY',
                style: TextStyle(color: _cyan, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  void _showSensitivityDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          _dialogRefresh = () {
            if (dialogContext.mounted) {
              setDialogState(() {});
            }
          };

          void applyLive(VoidCallback fn, {bool swapped = false}) {
            setDialogState(fn);
            if (swapped) {
              _resyncAfterAxisSwap();
            } else {
              _updateMotionFromAngles(0.016, instant: true);
            }
          }

          return AlertDialog(
            backgroundColor: _cardTop,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: _borderLight),
            ),
            title: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Yoke Sensitivity',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _field,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: _border),
                  ),
                  child: Text(
                    'P: ${(_pitch * 100).round()}%  ·  R: ${(_roll * 100).round()}%',
                    style: const TextStyle(
                      color: _cyan,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 430,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _settingSlider(
                      'Roll range',
                      _rollRange,
                      8,
                      80,
                      '°',
                      (v) => applyLive(() => _rollRange = v),
                    ),
                    _settingSlider(
                      'Pitch range',
                      _pitchRange,
                      8,
                      80,
                      '°',
                      (v) => applyLive(() => _pitchRange = v),
                    ),
                    _settingSlider(
                      'Center deadzone',
                      _deadzone,
                      0,
                      20,
                      '%',
                      (v) => applyLive(() => _deadzone = v),
                    ),
                    _settingSlider(
                      'Response curve (Expo)',
                      _expo,
                      0,
                      100,
                      '%',
                      (v) => applyLive(() => _expo = v),
                    ),
                    _settingSlider(
                      'Motion smoothing',
                      _smooth,
                      0,
                      85,
                      '%',
                      (v) => applyLive(() => _smooth = v),
                    ),
                    SwitchListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Invert roll',
                          style: TextStyle(color: _muted, fontSize: 12)),
                      value: _invertRoll,
                      activeColor: _blue,
                      onChanged: (v) => applyLive(() => _invertRoll = v),
                    ),
                    SwitchListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Invert pitch',
                          style: TextStyle(color: _muted, fontSize: 12)),
                      value: _invertPitch,
                      activeColor: _blue,
                      onChanged: (v) => applyLive(() => _invertPitch = v),
                    ),
                    SwitchListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Swap motion axes',
                          style: TextStyle(color: _muted, fontSize: 12)),
                      value: _swapAxes,
                      activeColor: _blue,
                      onChanged: (v) =>
                          applyLive(() => _swapAxes = v, swapped: true),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  final wasSwapped = _swapAxes;
                  applyLive(() {
                    _rollRange = 35;
                    _pitchRange = 30;
                    _deadzone = 3;
                    _expo = 25;
                    _smooth = 10;
                    _invertRoll = false;
                    _invertPitch = false;
                    _swapAxes = false;
                  }, swapped: wasSwapped);
                  _saveSettings();
                },
                child: const Text('RESTORE DEFAULTS',
                    style: TextStyle(color: _muted, fontSize: 11)),
              ),
              TextButton(
                onPressed: () async {
                  HapticFeedback.mediumImpact();
                  await _saveSettings();
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                  if (mounted) setState(() {});
                },
                child: const Text('SAVE',
                    style:
                        TextStyle(color: _blue, fontWeight: FontWeight.w900)),
              ),
            ],
          );
        },
      ),
    ).whenComplete(() {
      _dialogRefresh = null;
      _saveSettings();
    });
  }

  Widget _settingSlider(
    String label,
    double value,
    double min,
    double max,
    String unit,
    ValueChanged<double> onChanged,
  ) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label,
                    style: const TextStyle(color: _muted, fontSize: 11)),
              ),
              Text(
                '${value.round()}$unit',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800),
              ),
            ],
          ),
          SliderTheme(
            data: _sliderTheme(isTablet: true, isCompact: false),
            child: Slider(
              value: value.clamp(min, max).toDouble(),
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      );
}

// ==================== INTERNAL MODELS & TACTILE BUTTON ====================

class _MsfsApiResult {
  const _MsfsApiResult({
    this.statusCode,
    this.data,
    this.rawBody,
    this.networkError = false,
    this.error,
  });

  final int? statusCode;
  final Map<String, dynamic>? data;
  final String? rawBody;
  final bool networkError;
  final String? error;

  bool get isSuccess =>
      !networkError &&
      statusCode != null &&
      statusCode! >= 200 &&
      statusCode! < 300 &&
      (data == null || data!['ok'] != false);
}

class _TactileButton extends StatefulWidget {
  const _TactileButton({
    required this.child,
    this.onTap,
    this.onHoldStart,
    this.onHoldEnd,
    this.active = false,
    this.accentColor = const Color(0xFF4D94FF),
    this.borderRadius = 8,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onHoldStart;
  final VoidCallback? onHoldEnd;
  final bool active;
  final Color accentColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  @override
  State<_TactileButton> createState() => _TactileButtonState();
}

class _TactileButtonState extends State<_TactileButton> {
  bool _pressed = false;

  void _handleDown() {
    setState(() => _pressed = true);
    if (widget.onHoldStart != null) {
      widget.onHoldStart!();
    } else {
      HapticFeedback.lightImpact();
    }
  }

  void _handleUp({required bool triggerTap}) {
    if (_pressed) {
      setState(() => _pressed = false);
    }
    if (widget.onHoldEnd != null) {
      widget.onHoldEnd!();
    } else if (triggerTap && widget.onTap != null) {
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final highlighted = widget.active || _pressed;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _handleDown(),
      onTapUp: (_) => _handleUp(triggerTap: true),
      onTapCancel: () => _handleUp(triggerTap: false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 85),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: _pressed
                ? widget.accentColor.withOpacity(0.26)
                : (widget.active
                    ? widget.accentColor.withOpacity(0.15)
                    : const Color(0xFF0A131E)),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: highlighted
                  ? widget.accentColor.withOpacity(_pressed ? 0.95 : 0.72)
                  : const Color(0xFF223349),
              width: highlighted ? 1.2 : 1.0,
            ),
            boxShadow: _pressed
                ? [
                    BoxShadow(
                      color: widget.accentColor.withOpacity(0.32),
                      blurRadius: 10,
                    ),
                  ]
                : null,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

// ==================== YOKE ART & ATTITUDE RETICLE ====================

class _ReticlePainter extends CustomPainter {
  const _ReticlePainter({
    required this.roll,
    required this.pitch,
    required this.active,
  });

  final double roll;
  final double pitch;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.42;

    final ringPaint = Paint()
      ..color = active
          ? const Color(0xFF38BDF8).withOpacity(0.18)
          : const Color(0xFF223349).withOpacity(0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawCircle(center, radius, ringPaint);

    final crossPaint = Paint()
      ..color = const Color(0xFF223349).withOpacity(0.5)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(center.dx - radius * 1.15, center.dy),
      Offset(center.dx + radius * 1.15, center.dy),
      crossPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius * 1.1),
      Offset(center.dx, center.dy + radius * 1.1),
      crossPaint,
    );

    if (active) {
      final dot = Offset(
        center.dx + roll * radius * 0.75,
        center.dy - pitch * radius * 0.75,
      );
      canvas.drawCircle(
        dot,
        4,
        Paint()..color = const Color(0xFF38BDF8).withOpacity(0.85),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ReticlePainter oldDelegate) =>
      oldDelegate.roll != roll ||
      oldDelegate.pitch != pitch ||
      oldDelegate.active != active;
}

class _VirtualYokeArt extends StatelessWidget {
  const _VirtualYokeArt({this.active = false});
  final bool active;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 240,
        height: 155,
        child: CustomPaint(painter: _YokePainter(active: active)),
      );
}

class _YokePainter extends CustomPainter {
  const _YokePainter({this.active = false});
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 320;
    final sy = size.height / 188;
    canvas.save();
    canvas.scale(sx, sy);

    final shadow = Paint()
      ..color = Colors.black.withOpacity(0.48)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9);

    final shape = Path()
      ..moveTo(89, 35)
      ..cubicTo(77, 39, 76, 56, 71, 82)
      ..lineTo(60, 118)
      ..cubicTo(57, 142, 83, 147, 83, 147)
      ..lineTo(136, 147)
      ..lineTo(136, 169)
      ..lineTo(184, 169)
      ..lineTo(184, 147)
      ..lineTo(239, 147)
      ..cubicTo(260, 141, 258, 118, 258, 118)
      ..lineTo(250, 81)
      ..cubicTo(246, 53, 233, 36, 233, 36)
      ..cubicTo(226, 29, 218, 36, 218, 36)
      ..cubicTo(205, 46, 215, 62, 217, 82)
      ..lineTo(224, 112)
      ..cubicTo(225, 118, 215, 119, 215, 119)
      ..lineTo(186, 119)
      ..lineTo(183, 96)
      ..cubicTo(180, 88, 168, 88, 168, 88)
      ..lineTo(151, 88)
      ..cubicTo(138, 88, 136, 96, 136, 96)
      ..lineTo(134, 119)
      ..lineTo(104, 119)
      ..cubicTo(95, 119, 97, 111, 97, 111)
      ..lineTo(104, 82)
      ..cubicTo(108, 60, 116, 42, 104, 36)
      ..cubicTo(97, 30, 89, 35, 89, 35)
      ..close();

    canvas.drawPath(shape.shift(const Offset(0, 6)), shadow);

    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF3E4C5C), Color(0xFF151E29), Color(0xFF283544)],
      ).createShader(const Rect.fromLTWH(50, 25, 220, 150));

    canvas.drawPath(shape, bodyPaint);
    canvas.drawPath(
      shape,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = active ? const Color(0xFF4D94FF) : const Color(0xFF526477),
    );

    final hub = Path()
      ..moveTo(141, 104)
      ..quadraticBezierTo(160, 95, 179, 104)
      ..lineTo(187, 150)
      ..quadraticBezierTo(181, 164, 160, 166)
      ..quadraticBezierTo(139, 164, 133, 150)
      ..close();

    canvas.drawPath(hub, Paint()..color = const Color(0xFF1A2634));
    canvas.drawPath(
      hub,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = active ? const Color(0xFF38BDF8) : const Color(0xFF65778A),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(144, 114, 32, 35),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFF0B131D),
    );

    final symbol = Paint()
      ..color = active ? const Color(0xFF38BDF8) : const Color(0xFF9DC4FB)
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(160, 120), const Offset(160, 141), symbol);
    canvas.drawLine(const Offset(152, 134), const Offset(168, 134), symbol);

    canvas.drawCircle(
      const Offset(94, 46),
      10,
      Paint()..color = const Color(0xFF334254),
    );
    canvas.drawCircle(
      const Offset(226, 46),
      10,
      Paint()..color = const Color(0xFF334254),
    );
    canvas.drawCircle(
      const Offset(226, 46),
      5,
      Paint()..color = const Color(0xFFEF5350),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _YokePainter oldDelegate) =>
      oldDelegate.active != active;
}
