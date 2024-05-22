import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

FirebaseFirestore db = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;

class DriverHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return (MaterialApp(
      home: Scaffold(
        body: Map(),
        appBar: AppBar(
          title: const Text('Driver Map'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () =>
                {FirebaseAuth.instance.signOut(), Navigator.pop(context)},
          ),
        ),
      ),
    ));
  }
}

class Map extends StatefulWidget {
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  Completer<GoogleMapController> controller1 = Completer();

  // static LatLng _center = LatLng(-15.4630239974464, 28.363397732282127);
  static LatLng _initialPosition =
      const LatLng(23.93326457544187, 91.33834812371511);
  final Set<Marker> _markers = {};
  static LatLng _lastMapPosition = _initialPosition;
  late GeoPoint currentLocation;
  bool locationShared = false;

  @override
  void initState() {
    super.initState();
    // _getUserLocation();
    // _updateUserLocation();
  }

  void _updateUserLocation() async {
    /* StreamSubscription stream =*/ Geolocator.getPositionStream()
        .listen((Position position) {
      currentLocation = GeoPoint(position.latitude, position.longitude);
      print('location: $currentLocation');
      db
          .collection('UserLocation')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .update({"Location": currentLocation});
    });
    // stream.cancel();
  }

  void _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    // List<Placemark> placemark = await Geolocator()
    //     .placemarkFromCoordinates(position.latitude, position.longitude);
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
      // print('${placemark[0].name}');
    });
  }

  _onMapCreated(GoogleMapController controller) {
    setState(() {
      controller1.complete(controller);
    });
  }

  MapType _currentMapType = MapType.normal;

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  _onAddMarkerButtonPressed() {
    setState(() {
      _markers.add(Marker(
          markerId: MarkerId(_lastMapPosition.toString()),
          position: _lastMapPosition,
          infoWindow: InfoWindow(
              title: "Pizza Parlour",
              snippet: "This is a snippet",
              onTap: () {}),
          onTap: () {},
          icon: BitmapDescriptor.defaultMarker));
    });
  }

  Widget mapButton(void Function() function, Icon icon, Color color) {
    return RawMaterialButton(
      onPressed: function,
      child: icon,
      shape: new CircleBorder(),
      elevation: 2.0,
      fillColor: color,
      padding: const EdgeInsets.all(7.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _initialPosition == null
          ? Container(
              child: Center(
                child: Text(
                  'loading map..',
                  style: TextStyle(
                      fontFamily: 'Avenir-Medium', color: Colors.grey[400]),
                ),
              ),
            )
          : Container(
              child:
                  Stack(alignment: Alignment.bottomCenter, children: <Widget>[
                GoogleMap(
                  // markers: _markers,

                  mapType: _currentMapType,
                  initialCameraPosition: CameraPosition(
                    target: _initialPosition,
                    zoom: 14.4746,
                  ),
                  markers: <Marker>{
                    const Marker(
                      markerId: MarkerId("1"),
                      position: LatLng(23.934615848921727, 91.34118401245566),
                    ),
                    const Marker(
                      markerId: MarkerId("2"),
                      position: LatLng(23.932281939676507, 91.33993946752913),
                    ),
                    const Marker(
                      markerId: MarkerId("3"),
                      position: LatLng(23.93358618827972, 91.3373430893203),
                    ),
                    const Marker(
                      markerId: MarkerId("4"),
                      position: LatLng(23.93071290133999, 91.3376327678808),
                    ),
                    const Marker(
                      markerId: MarkerId("5"),
                      position: LatLng(23.929977408055546, 91.33566939097084),
                    ),
                  },
                  onMapCreated: _onMapCreated,
                  zoomGesturesEnabled: true,
                  onCameraMove: _onCameraMove,
                  myLocationEnabled: true,
                  compassEnabled: true,
                  myLocationButtonEnabled: false,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Column(
                                children: [
                                  Text(locationShared
                                      ? "Your live location is getting shared now"
                                      : "Location sharing is stopped"),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Okay"),
                                  )
                                ],
                              ),
                            );
                          },
                        );
                        setState(() {
                          locationShared = !locationShared;
                        });
                      },
                      child: Text(locationShared
                          ? "Stop Sharing Location"
                          : "Share Live Location")),
                )
              ]),
            ),
    );
  }
}
