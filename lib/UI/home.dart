import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import './login.dart';

FirebaseFirestore db = FirebaseFirestore.instance;
// final geo = Geoflutterfire();
int dropdownValue = 1;

class Home extends StatelessWidget {
  final GeoPoint geoPoint = const GeoPoint(0, 0);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              bottom: 50,
              left: 0,
              right: 0,
              child: Map(),
            ),
            DraggableScrollableSheet(
              initialChildSize: 0.1,
              minChildSize: 0.1,
              maxChildSize: 0.75,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Container(
                  color: Colors.white,
                  child: Center(
                    child: DropDown(),
                  ),
                );
              },
            )
          ],
        ),
        appBar: AppBar(
          title: const Text('Bus Tracker'),
        ),
        drawer: Drawer(
          child: Column(
            children: <Widget>[
              Container(
                height: 130.0,
                child: const DrawerHeader(
                  margin: EdgeInsets.only(bottom: 8.0),
                  padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                  decoration: BoxDecoration(color: Colors.deepPurple),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Profile",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.account_circle_outlined),
                      ]),
                ),
              ),
              ListTile(
                title: const Text('Settings', style: TextStyle(fontSize: 16)),
                onTap: () => {},
                leading: const Icon(Icons.settings),
              ),
              const ListTile(
                title: Text('About', style: TextStyle(fontSize: 16)),
                leading: Icon(Icons.people), //add on-tap functions
              ),
              Expanded(child: Container()),
              Card(
                child: ListTile(
                  title: const Text('Log Out', style: TextStyle(fontSize: 16)),
                  onTap: () => {
                    handleSignOut(),
                    Navigator.pop(context)
                  }, //add on-tap functions
                  leading: const Icon(Icons.logout),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DropDown extends StatefulWidget {
  // const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<DropDown> createState() => _DropDownState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _DropDownState extends State<DropDown> {
  int dropdownValue = 1;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<int>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (int? newValue) {
        if (newValue != null) {
          setState(() {
            dropdownValue = newValue;
          });
        }
      },
      items: <int>[1, 2, 3, 4].map<DropdownMenuItem<int>>((int value) {
        return DropdownMenuItem<int>(
          value: value,
          child: Text(value.toString()),
        );
      }).toList(),
    );
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
  late GeoPoint geoPoint;
  int _markerIdCounter = 0;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _getDriverLocation();
  }

  void _setMarkers(LatLng point) async {
    final String markerIdVal = 'marker_id:$_markerIdCounter';
    _markers.clear();
    _markerIdCounter++;
    setState(() {
      _markers.add(
        Marker(markerId: MarkerId(markerIdVal), position: point),
      );
    });
  }

  void _getDriverLocation() async {
    var status = await Permission.location.status;
    if (status.isDenied) {
      // We haven't asked for permission yet or the permission has been denied before, but not permanently.
    } else {
      const GeoPoint driverPosition =
          GeoPoint(23.833455461314042, 91.28517480174166);
    }
    // await db
    //     .collection('UserLocation')
    //     .doc('U6PG3P3oChRJHr03xoVLKJjRLF83')
    //     .get()
    //     .then((value) =>
    //         {geoPoint = value.data()?.values.first, print(geoPoint.latitude)});

    // Stream<List<DocumentSnapshot>> stream =
    //     geo.collection(collectionRef: db.collection('UserLocation')).data('1');
    // stream.listen((List<DocumentSnapshot> documentList) {
    //   // _markers.clear();
    //
    //   geoPoint =
    //       documentList.elementAt(0).data()?.values.first; //elementAt(busNo - 1)
    //   LatLng pos = LatLng(geoPoint.latitude, geoPoint.longitude);
    //   print('position: $pos');
    //   _setMarkers(pos);
    // });
    LatLng pos = LatLng(geoPoint.latitude, geoPoint.longitude);
    print('position: $pos');
    _markers.add(Marker(markerId: const MarkerId('1'), position: pos));
    // _setMarkers(pos);
  }

  void _getUserLocation() async {
    var status = await Permission.location.status;
    if (status.isDenied) {
      // We haven't asked for permission yet or the permission has been denied before, but not permanently.
    } else {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      // List placemark = await Geolocator
      //     .placemarkFromCoordinates(position.latitude, position.longitude);
      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
        // print('${placemark[0].name}');
      });
    }
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
              child: Stack(children: <Widget>[
                GoogleMap(
                  markers: _markers,
                  mapType: _currentMapType,
                  initialCameraPosition: CameraPosition(
                    target: _initialPosition,
                    zoom: 14.4746,
                  ),
                  onMapCreated: _onMapCreated,
                  zoomGesturesEnabled: true,
                  onCameraMove: _onCameraMove,
                  myLocationEnabled: true,
                  compassEnabled: true,
                  myLocationButtonEnabled: true,
                ),
              ]),
            ),
    );
  }
}
