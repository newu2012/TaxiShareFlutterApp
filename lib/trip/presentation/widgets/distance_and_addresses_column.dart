import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/trip.dart';
import '../../logic/map_controller.dart';
import 'widgets.dart';

class DistanceAndAddressesColumn extends StatelessWidget {
  const DistanceAndAddressesColumn({
    Key? key,
    required this.trip,
  }) : super(key: key);

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DistanceBetweenPointsRow(
              fromPoint: Provider.of<MapController>(context, listen: false)
                  .fromPointLatLng!,
              toPoint: trip.fromPointLatLng,
              fromUser: true,
            ),
            DistanceBetweenPointsRow(
              fromPoint: Provider.of<MapController>(context, listen: false)
                  .toPointLatLng!,
              toPoint: trip.toPointLatLng,
              fromUser: false,
            ),
          ],
        ),
        const SizedBox(
          width: 8,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 290,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  trip.fromPointAddress,
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            SizedBox(
              width: 290,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  trip.toPointAddress,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
