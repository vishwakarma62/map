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
  late StreamSubscription<LatLng> _positionSubscription;
  
  LatLng _currentPosition = const LatLng(51.5, -0.09);
  LatLng? _targetPosition;

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

    // Start listening to simulated live data
    _positionSubscription = _simulateLivePosition().listen((newPosition) {
      _startPositionAnimation(newPosition);
    });
  }

  Stream<LatLng> _simulateLivePosition() async* {
    final random = Random();
    var current = _currentPosition;
    while (true) {
      await Future.delayed(const Duration(seconds: 3));
      final newPosition = LatLng(
        current.latitude + (random.nextDouble() * 0.02 - 0.01),
        current.longitude + (random.nextDouble() * 0.02 - 0.01),
      );
      current = newPosition;
      yield newPosition;
    }
  }

  void _startPositionAnimation(LatLng newPosition) {
    final animation = LatLngTween(
      begin: _currentPosition,
      end: newPosition,
    ).animate(CurvedAnimation(
      parent: _movementController,
      curve: Curves.easeInOut,
    ));

    animation.addListener(() {
      setState(() => _currentPosition = animation.value);
      _mapController.move(animation.value, _mapController.camera.zoom);
    });

    _movementController
      ..reset()
      ..forward();
  }

  @override
  void dispose() {
    _positionSubscription.cancel();
    _movementController.dispose();
    _pulseController.dispose();
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

  const _AnimatedMarker({required this.pulseController});

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(
          parent: pulseController,
          curve: Curves.easeInOut,
        ),
      ),
      child: const Icon(
        Icons.location_pin,
        size: 50,
        color: Colors.red,
        shadows: [Shadow(blurRadius: 4)],
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