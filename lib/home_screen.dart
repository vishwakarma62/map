import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LiveAnimatedMarkers extends StatefulWidget {
  const LiveAnimatedMarkers({super.key});

  @override
  State<LiveAnimatedMarkers> createState() => _LiveAnimatedMarkersState();
}

class _LiveAnimatedMarkersState extends State<LiveAnimatedMarkers>
    with TickerProviderStateMixin {
  late final MapController _mapController;
  late final AnimationController _movementController;
  late final AnimationController _pulseController;
  late final AnimationController _rotationController;
  late Timer _timer;

  LatLng _currentPosition = const LatLng(51.5, -0.09);
  double _currentAngle = 0; // Initial angle
  LatLng? _targetPosition;
  double? _targetAngle;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _movementController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Start generating random positions at regular intervals
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      _generateRandomPosition();
    });
  }

  /// Simulate API call by generating random positions and angles
  void _generateRandomPosition() {
    final random = Random();

    final newPosition = LatLng(
      _currentPosition.latitude + (random.nextDouble() * 0.02 - 0.01),
      _currentPosition.longitude + (random.nextDouble() * 0.02 - 0.01),
    );

    final newAngle = random.nextDouble() * 360; // Angle between 0 and 360

    _startPositionAnimation(newPosition, newAngle);
  }

  void _startPositionAnimation(LatLng newPosition, double newAngle) {
    // Animate position
    final positionAnimation = LatLngTween(
      begin: _currentPosition,
      end: newPosition,
    ).animate(CurvedAnimation(
      parent: _movementController,
      curve: Curves.easeInOut,
    ));

    positionAnimation.addListener(() {
      setState(() {
        _currentPosition = positionAnimation.value;
      });
      _mapController.move(positionAnimation.value, _mapController.camera.zoom);
    });

    // Animate angle rotation
    final rotationAnimation = Tween<double>(
      begin: _currentAngle,
      end: newAngle,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));

    rotationAnimation.addListener(() {
      setState(() {
        _currentAngle = rotationAnimation.value;
      });
    });

    _movementController
      ..reset()
      ..forward();

    _rotationController
      ..reset()
      ..forward();
  }

  @override
  void dispose() {
    _timer.cancel();
    _movementController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _currentPosition,
        initialZoom: 15,
        onMapReady: () => _mapController.move(_currentPosition, 15),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'dev.fleaflet.flutter_map.example',
        ),
        MarkerLayer(
          markers: [
            Marker(
              width: 80,
              height: 80,
              point: _currentPosition,
              child: _AnimatedMarker(
                pulseController: _pulseController,
                angle: _currentAngle, // Pass angle to marker
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AnimatedMarker extends StatelessWidget {
  final AnimationController pulseController;
  final double angle;

  const _AnimatedMarker({
    required this.pulseController,
    required this.angle,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle * (pi / 180), // Convert degrees to radians
      child: ScaleTransition(
        scale: Tween(begin: 0.7, end: 1.0).animate(
          CurvedAnimation(
            parent: pulseController,
            curve: Curves.easeInOut,
          ),
        ),
        child: const Icon(
          Icons.navigation, // Use a directional icon
          size: 50,
          color: Colors.red,
          shadows: [Shadow(blurRadius: 4)],
        ),
      ),
    );
  }
}

class LatLngTween extends Tween<LatLng> {
  LatLngTween({required super.begin, required super.end});

  @override
  LatLng lerp(double t) => LatLng(
        begin!.latitude + (end!.latitude - begin!.latitude) * t,
        begin!.longitude + (end!.longitude - begin!.longitude) * t,
      );
}
