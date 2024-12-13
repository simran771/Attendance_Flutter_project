import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/member.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'page2.dart';

class PastLocationDetailsPage extends StatefulWidget {
  final Member member;
  final PastLocation pastLocation;

  const PastLocationDetailsPage({
    Key? key,
    required this.member,
    required this.pastLocation,
  }) : super(key: key);

  @override
  _PastLocationDetailsPageState createState() => _PastLocationDetailsPageState();
}

class _PastLocationDetailsPageState extends State<PastLocationDetailsPage> {
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _initializeMapData();
  }

  void _initializeMapData() {
    // Create markers for initial position and past location
    _markers.add(
      Marker(
        markerId: MarkerId('initial_position'),
        position: LatLng(widget.member.location.latitude, widget.member.location.longitude),
        infoWindow: InfoWindow(title: 'Current Location'),
      ),
    );
    _markers.add(
      Marker(
        markerId: MarkerId('past_location'),
        position: LatLng(widget.pastLocation.latitude, widget.pastLocation.longitude),
        infoWindow: InfoWindow(title: widget.pastLocation.name),
      ),
    );

    // Create polyline between initial position and past location
    _polylines.add(
      Polyline(
        polylineId: PolylineId('route'),
        color: Colors.blue,
        width: 5,
        points: [
          LatLng(widget.member.location.latitude, widget.member.location.longitude),
          LatLng(widget.pastLocation.latitude, widget.pastLocation.longitude),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Past Location Details'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(widget.member.location.latitude, widget.member.location.longitude),
                zoom: 12,
              ),
              markers: _markers,
              polylines: _polylines,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Member Details',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('Name: ${widget.member.name ?? "Unknown"}'),
                    Text('ID: ${widget.member.id ?? "Unknown"}'),
                    const Divider(height: 32),
                    Text(
                      'Past Location Details',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('Location: ${widget.pastLocation.name ?? "Unknown"}'),
                    Text('Entry Time: ${widget.pastLocation.entryTime ?? "Unknown"}'),
                    Text('Exit Time: ${widget.pastLocation.exitTime ?? "Unknown"}'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

