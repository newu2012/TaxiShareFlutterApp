import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../logic/map_controller.dart';

class GoogleMapWidget extends StatefulWidget {
  GoogleMapWidget({Key? key}) : super(key: key);

  @override
  _GoogleMapWidgetState createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  late GoogleMapController _mapController;
  var _markers;

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      Provider.of<MapController>(context, listen: false).mapController =
          controller;
      _markers = Provider.of<MapController>(context, listen: false).markers;
      _mapController = controller;
      _moveCamera();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder(
        future: _getCurrentLocation(),
        builder: (context, AsyncSnapshot<Position> position) {
          if (position.hasData) {
            final pos = position.data as Position;
            _markers =
                Provider.of<MapController>(context, listen: false).markers;

            return GoogleMap(
              onMapCreated: _onMapCreated,
              markers: _markers ?? {},
              initialCameraPosition: CameraPosition(
                target: LatLng(pos.latitude, pos.longitude),
                zoom: 17.0,
              ),
              myLocationEnabled: true,
              gestureRecognizers: Set()
                ..add(Factory<EagerGestureRecognizer>(
                  () => EagerGestureRecognizer(),
                )),
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error('Location permissions are permanently denied, '
          'we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return Geolocator.getCurrentPosition();
  }

  void _moveCamera() {
    LatLng target;
    target = _markers.length == 2
        ? LatLng(
            (_markers.first.position.latitude +
                    _markers.last.position.latitude) /
                2,
            (_markers.first.position.longitude +
                    _markers.last.position.longitude) /
                2,
          )
        : _markers.first.position;

    var zoomLevel = 12.0;
    if (_markers.length == 2) {
      final radius = GeolocatorPlatform.instance.distanceBetween(
        _markers.first.position.latitude,
        _markers.first.position.longitude,
        _markers.last.position.latitude,
        _markers.last.position.longitude,
      );
      final scale = radius / 500;
      zoomLevel = (16 - log(scale * 1.5) / log(2)) - 1;
    }

    _mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: target,
      zoom: zoomLevel,
    )));
  }
}
