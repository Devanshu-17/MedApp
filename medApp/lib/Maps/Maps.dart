import 'dart:async';
import 'dart:convert';
import 'package:custom_marker/marker_icon.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:medApp/Maps/mapPinPointsInfo.dart';
import 'package:medApp/Maps/nearby_response.dart';
import 'package:medApp/Maps/pin_info.dart';

import 'package:url_launcher/url_launcher.dart';

class Maps extends StatefulWidget {
  const Maps({Key? key}) : super(key: key);

  @override
  _MapsState createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController mapController;
  //

  //
  final LatLng _center = const LatLng(45.521563, -122.677433);
  double pinPillPosition = -100;
  String lat = "20.42796133580664";
  String lng = "80.885749655962";
  String radius = "2000";
  NearbyPlacesResponse nearbyPlacesResponse = NearbyPlacesResponse();

  PinInformation currentlySelectedPin = PinInformation(
      pinPath: '',
      avatarPath: '',
      location: LatLng(0, 0),
      locationName: '',
      labelColor: Colors.grey);

  String apiKeyCur = "AIzaSyCBuHO7XMbaOfloGh0hp8JjEpW2Jhcwk0g";
  // on below line we have specified camera position
  static final CameraPosition _kGoogle = const CameraPosition(
    target: LatLng(20.42796133580664, 80.885749655962),
    zoom: 14.4746,
  );

  // on below line we have created the list of markers
  final List<Marker> _markers = <Marker>[
    Marker(
        markerId: MarkerId('1'),
        position: LatLng(20.42796133580664, 75.885749655962),
        infoWindow: InfoWindow(
          title: 'My Position',
        )),
  ];

  // created method for getting user current location
  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      print("ERROR" + error.toString());
    });
    return await Geolocator.getCurrentPosition();
  }

  void getNearbyPlaces() async {
    var url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?keyword=hospital&type=hospital&keyword=medical&type=medical&location=' +
            lat +
            ',' +
            lng.toString() +
            '&radius=' +
            radius +
            '&key=' +
            apiKeyCur);

    var response = await http.post(url);

    nearbyPlacesResponse =
        NearbyPlacesResponse.fromJson(jsonDecode(response.body));
    print("Ressss " + response.toString());

    setState(() {});
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Scaffold(
        body: Container(
          child: Scaffold(
            body: Container(
              child: SafeArea(
                // on below line creating google maps
                child: Stack(
                  children: [
                    GoogleMap(
                      // on below line setting camera position
                      initialCameraPosition: _kGoogle,
                      // on below line we are setting markers on the map
                      markers: Set<Marker>.of(_markers),
                      // on below line specifying map type.
                      mapType: MapType.normal,
                      // on below line setting user location enabled.
                      myLocationEnabled: true,
                      // on below line setting compass enabled.
                      compassEnabled: true,
                      // on below line specifying controller on map complete.
                      onMapCreated: (GoogleMapController controller) {
                        //controller = mapController;
                        _controller.complete(controller);
                      },
                    ),
                    MapPinPillComponent(
                      pinPillPosition: pinPillPosition,
                      currentlySelectedPin: currentlySelectedPin,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // on pressing floating action button the camera will take to user current location
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            getUserCurrentLocation().then((value) async {
              print(
                  value.latitude.toString() + " " + value.longitude.toString());
              lat = value.latitude.toString();
              lng = value.longitude.toString();
              getNearbyPlaces();
              // marker added for current users location
              _markers.add(
                Marker(
                  markerId: MarkerId("2"),
                  position: LatLng(value.latitude, value.longitude),
                  infoWindow: InfoWindow(
                    title: 'My Current Location',
                  ),
                ),
              );
              if (nearbyPlacesResponse.results != null)
                for (int i = 0; i < nearbyPlacesResponse.results!.length; i++)
                  nearbyMarker(nearbyPlacesResponse.results![i], i + 3);

              // specified current users location
              CameraPosition cameraPosition = new CameraPosition(
                target: LatLng(value.latitude, value.longitude),
                zoom: 14,
              );

              final GoogleMapController controller = await _controller.future;
              controller.animateCamera(
                  CameraUpdate.newCameraPosition(cameraPosition));
              setState(() {});
            });
          },
          child: Icon(Icons.local_activity),
        ),
      ),
    );
  }

  Widget bankView(Results results) {
    return Positioned(
      left: MediaQuery.of(context).size.width * 0.1,
      top: MediaQuery.of(context).size.height * 0.5,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.1,
          color: Colors.blue.withOpacity(0.3),
          child: Material(
            color: Colors.transparent,
            child: Text('I will disappear in 5 seconds',
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.03,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
        ),
      ),
    );
  }

  nearbyMarker(Results results, int id) async {
    _markers.add(
      Marker(
        //icon: BitmapDescriptor.fromBytes(Icon(Icons.monetization_on)),
        markerId: MarkerId(id.toString()),
        position: LatLng(results.geometry!.location!.lat!.toDouble(),
            results.geometry!.location!.lng!.toDouble()),
        infoWindow: InfoWindow(
          title: results.name,
          snippet: results.businessStatus,
          onTap: () => MapUtils._(),
        ),
        //icon: Image.network(results.icon)
      ),
    );
  }
}

class MapUtils {
  MapUtils._();

  static Future<void> openMap(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }
  //theme
}
