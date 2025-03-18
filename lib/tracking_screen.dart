// import 'dart:async';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:flutter_map_animated_marker/flutter_map_animated_marker.dart';
// import 'package:latlong2/latlong.dart';

// class VehicleTrackingMap extends StatefulWidget {
//   @override
//   State<VehicleTrackingMap> createState() => _VehicleTrackingMapState();
// }

// class _VehicleTrackingMapState extends State<VehicleTrackingMap> with TickerProviderStateMixin {
//   LatLng _vehiclePosition = const LatLng(22.3072, 73.1812); // Vadodara, Gujarat
//   final List<LatLng> _routeHistory = [];
//   final MapController _mapController = MapController();
//   final _animatedMarkerController = AnimatedMarkerController();

//   double _heading = 0;
//   Timer? _timer;

//   @override
//   void initState() {
//     super.initState();
//     _routeHistory.add(_vehiclePosition);
//     _startPolling();
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     _animatedMarkerController.dispose();
//     super.dispose();
//   }

//   void _startPolling() {
//     _timer = Timer.periodic(const Duration(seconds: 2), (_) {
//       _updateVehiclePosition();
//     });
//   }

//   void _updateVehiclePosition() {
//     final random = Random();

//     // Generate new coordinates within a small range to simulate movement
//     final newLat = _vehiclePosition.latitude + (random.nextDouble() - 0.5) * 0.005;
//     final newLng = _vehiclePosition.longitude + (random.nextDouble() - 0.5) * 0.005;
//     final newPosition = LatLng(newLat, newLng);

//     // Calculate heading based on previous and new position
//     if (_routeHistory.isNotEmpty) {
//       final lastPosition = _routeHistory.last;
//       _heading = atan2(
//         newPosition.longitude - lastPosition.longitude,
//         newPosition.latitude - lastPosition.latitude,
//       );
//     }

//     setState(() {
//       _vehiclePosition = newPosition;
//       _routeHistory.add(newPosition);
//     });

//     // Smoothly move the map like Google Maps' `animateCamera`
//     _animateCamera(newPosition);

//     // Animate marker smoothly to the new position
//     _animatedMarkerController.animatePoint(newPosition);
//   }

//   void _animateCamera(LatLng newPosition) {
//     final animationController = AnimationController(
//       duration: const Duration(milliseconds: 1000),
//       vsync: this,
//     );

//     final curvedAnimation = CurvedAnimation(
//       parent: animationController,
//       curve: Curves.easeInOut,
//     );

//     final oldPosition = _mapController.center;

//     animationController.addListener(() {
//       final lat = oldPosition.latitude +
//           (newPosition.latitude - oldPosition.latitude) * curvedAnimation.value;
//       final lng = oldPosition.longitude +
//           (newPosition.longitude - oldPosition.longitude) * curvedAnimation.value;
//       _mapController.move(LatLng(lat, lng), _mapController.zoom);
//     });

//     animationController.forward().whenComplete(() => animationController.dispose());
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Real-Time Vehicle Tracking')),
//       body: FlutterMap(
//         mapController: _mapController,
//         options: const MapOptions(
//           initialCenter: LatLng(22.3072, 73.1812),
//           initialZoom: 15.0,
//         ),
//         children: [
//           // OpenStreetMap Tiles
//           TileLayer(
//             urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//             userAgentPackageName: 'com.example.app',
//           ),

//           // Animated Marker Layer
//           AnimatedMarkerLayer(
//             options: AnimatedMarkerLayerOptions(
//               marker:               Marker(
//                 point: _vehiclePosition,
//                 child: Transform.rotate(
//                   angle: _heading,
//                   child: const Icon(
//                     Icons.directions_car,
//                     color: Colors.red,
//                     size: 40,
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           // Polyline Layer for route tracking
//           PolylineLayer(
//             polylines: [
//               Polyline(
//                 points: _routeHistory,
//                 color: Colors.blue,
//                 strokeWidth: 4.0,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
