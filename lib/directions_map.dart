// ignore_for_file: depend_on_referenced_packages, avoid_print

import 'dart:convert' show jsonDecode;
import 'dart:math' show cos, sqrt, asin;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http show get, Response;
import 'package:flutter_tts/flutter_tts.dart' show FlutterTts;
import 'package:flutter_polyline_points/flutter_polyline_points.dart'
    show PolylinePoints, PolylineResult, PointLatLng, TravelMode;
import 'package:geocoding/geocoding.dart'
    show Placemark, placemarkFromCoordinates, Location, locationFromAddress;
import 'package:geolocator/geolocator.dart'
    show Position, Geolocator, LocationAccuracy, LocationPermission;
import 'package:google_maps_flutter/google_maps_flutter.dart'
    show
        CameraPosition,
        LatLng,
        GoogleMapController,
        Marker,
        PolylineId,
        Polyline,
        PatternItem,
        CameraUpdate,
        MarkerId,
        InfoWindow,
        BitmapDescriptor,
        LatLngBounds,
        GoogleMap,
        MapType;

import 'package:campusmap/main.dart' show THEME, API_KEY;
import 'package:campusmap/language_texts.dart'
    show getLanguageCode, getLanguage;

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  MapViewState createState() => MapViewState();
}

class MapViewState extends State<MapView> {
  final CameraPosition _initialLocation = const CameraPosition(
    target: LatLng(
      13.3268473,
      77.1261341,
    ),
    zoom: 18,
    tilt: 0.0,
    bearing: 0.0,
  );

  late GoogleMapController mapController;
  late Position _currentPosition;
  String _currentAddress = '';

  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();

  final startAddressFocusNode = FocusNode();
  final destinationAddressFocusNode = FocusNode();

  String _startAddress = '';
  String _destinationAddress = '';
  String? _placeDistance;
  String? _curRoute;

  Set<Marker> markers = {};

  late PolylinePoints polylinePoints;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  double _tilt = 0.0;
  double _bearing = 0.0;

  Widget _textField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required double width,
    required Icon prefixIcon,
    Widget? suffixIcon,
    required Function(String) locationCallback,
  }) {
    return SizedBox(
      width: width * 0.7,
      child: TextField(
        onChanged: (value) {
          locationCallback(value);
        },
        style: TextStyle(
          color: THEME[1],
        ),
        controller: controller,
        focusNode: focusNode,
        decoration: InputDecoration(
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          labelStyle: TextStyle(
            color: THEME[3],
          ),
          filled: true,
          fillColor: THEME[0],
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: THEME[0],
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: THEME[1],
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.all(15),
          hintText: hint,
          hintStyle: TextStyle(color: THEME[3]),
        ),
        cursorColor: THEME[3],
      ),
    );
  }

  // Method for retrieving the current location
  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        _currentPosition = position;
        print('CURRENT POS: $_currentPosition');
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 20,
              tilt: _tilt,
              bearing: _bearing,
            ),
          ),
        );
      });
      await _getAddress();
    }).catchError((e) {
      print(e);
    });
  }

  // Method for retrieving the address
  _getAddress() async {
    try {
      List<Placemark> p = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
            "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
        startAddressController.text = _currentAddress;
        _startAddress = _currentAddress;
      });
    } catch (e) {
      print(e);
    }
  }

  // Method for calculating the distance between two places
  Future<bool> _calculateDistance() async {
    try {
      // Retrieving placemarks from addresses
      List<Location>? startPlacemark = await locationFromAddress(_startAddress);
      List<Location>? destinationPlacemark =
          await locationFromAddress(_destinationAddress);

      // Use the retrieved coordinates of the current position,
      // instead of the address if the start position is user's
      // current position, as it results in better accuracy.
      double startLatitude = _startAddress == _currentAddress
          ? _currentPosition.latitude
          : startPlacemark[0].latitude;

      double startLongitude = _startAddress == _currentAddress
          ? _currentPosition.longitude
          : startPlacemark[0].longitude;

      double destinationLatitude = destinationPlacemark[0].latitude;
      double destinationLongitude = destinationPlacemark[0].longitude;

      String startCoordinatesString = '($startLatitude, $startLongitude)';
      String destinationCoordinatesString =
          '($destinationLatitude, $destinationLongitude)';

      // Destination Location Marker
      Marker destinationMarker = Marker(
        markerId: MarkerId(destinationCoordinatesString),
        position: LatLng(destinationLatitude, destinationLongitude),
        infoWindow: InfoWindow(
          title: 'Destination $destinationCoordinatesString',
          snippet: _destinationAddress,
        ),
        icon: BitmapDescriptor.defaultMarker,
      );

      // Adding the markers to the list
      markers.add(destinationMarker);

      print(
        'START COORDINATES: ($startLatitude, $startLongitude)',
      );
      print(
        'DESTINATION COORDINATES: ($destinationLatitude, $destinationLongitude)',
      );

      // Calculating to check that the position relative
      // to the frame, and pan & zoom the camera accordingly.
      double miny = (startLatitude <= destinationLatitude)
          ? startLatitude
          : destinationLatitude;
      double minx = (startLongitude <= destinationLongitude)
          ? startLongitude
          : destinationLongitude;
      double maxy = (startLatitude <= destinationLatitude)
          ? destinationLatitude
          : startLatitude;
      double maxx = (startLongitude <= destinationLongitude)
          ? destinationLongitude
          : startLongitude;

      double southWestLatitude = miny;
      double southWestLongitude = minx;

      double northEastLatitude = maxy;
      double northEastLongitude = maxx;

      // Accommodate the two locations within the
      // camera view of the map
      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            northeast: LatLng(northEastLatitude, northEastLongitude),
            southwest: LatLng(southWestLatitude, southWestLongitude),
          ),
          100.0,
        ),
      );

      // Calculating the distance between the start and the end positions
      // with a straight path, without considering any route
      // double distanceInMeters = await Geolocator().bearingBetween(
      //   startCoordinates.latitude,
      //   startCoordinates.longitude,
      //   destinationCoordinates.latitude,
      //   destinationCoordinates.longitude,
      // );

      await _createPolylines(startLatitude, startLongitude, destinationLatitude,
          destinationLongitude);

      double totalDistance = 0.0;

      // Calculating the total distance by adding the distance
      // between small segments
      for (int i = 0; i < polylineCoordinates.length - 1; i++) {
        totalDistance += _coordinateDistance(
          polylineCoordinates[i].latitude,
          polylineCoordinates[i].longitude,
          polylineCoordinates[i + 1].latitude,
          polylineCoordinates[i + 1].longitude,
        );
      }

      setState(() {
        _placeDistance = totalDistance.toStringAsFixed(2);
        print('DISTANCE: $_placeDistance km');
      });

      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(startLatitude, startLongitude),
          20,
        ),
      );

      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  // Formula for calculating distance between two coordinates
  // https://stackoverflow.com/a/54138876/11910277
  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  // Create the polylines for showing the route between two places
  _createPolylines(
    double startLatitude,
    double startLongitude,
    double destinationLatitude,
    double destinationLongitude,
  ) async {
    polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      API_KEY,
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(destinationLatitude, destinationLongitude),
      travelMode: TravelMode.walking,
    );

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }

    PolylineId walkingRouteId = const PolylineId('walkingRoute');
    Polyline walkingRoutePolyline = Polyline(
      polylineId: walkingRouteId,
      color: Colors.blue,
      width: 10,
      patterns: [PatternItem.dot, PatternItem.gap(30)],
      points: polylineCoordinates,
    );
    polylines[walkingRouteId] = walkingRoutePolyline;

    PolylineId connectingLineId = const PolylineId('connectingLine');
    Polyline connectingPolyline = Polyline(
      polylineId: connectingLineId,
      color: Colors.grey,
      width: 5,
      patterns: [PatternItem.dot, PatternItem.gap(30)],
      points: [
        polylineCoordinates.last,
        LatLng(destinationLatitude, destinationLongitude)
      ],
    );
    polylines[connectingLineId] = connectingPolyline;
  }

  late FlutterTts _tts;
  List<dynamic> _directions = [];
  List<dynamic> _destinations = [];

  _setNewValues() async {
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            _currentPosition.latitude,
            _currentPosition.longitude,
          ),
          zoom: await mapController.getZoomLevel(),
          tilt: _tilt,
          bearing: _bearing,
        ),
      ),
    );
  }

  _getDirections() async {
    List<Location>? startPlacemark = await locationFromAddress(_startAddress);
    List<Location>? destinationPlacemark =
        await locationFromAddress(_destinationAddress);

    double startLatitude = _startAddress == _currentAddress
        ? _currentPosition.latitude
        : startPlacemark[0].latitude;

    double startLongitude = _startAddress == _currentAddress
        ? _currentPosition.longitude
        : startPlacemark[0].longitude;

    double destinationLatitude = destinationPlacemark[0].latitude;
    double destinationLongitude = destinationPlacemark[0].longitude;

    LatLng origin = LatLng(startLatitude, startLongitude);
    LatLng destination = LatLng(destinationLatitude, destinationLongitude);

    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$API_KEY&language=$_language";
    http.Response response = await http.get(Uri.parse(url));
    Map values = jsonDecode(response.body);
    List steps = values["routes"][0]["legs"][0]["steps"];
    _directions = steps
        .map((step) =>
            step["html_instructions"].replaceAll(RegExp(r"<[^>]*>"), ""))
        .toList();
    _destinations = steps
        .map((step) =>
            LatLng(step["end_location"]["lat"], step["end_location"]["lng"]))
        .toList();
  }

  _speakDirections() async {
    for (int i = 0; i < _directions.length; i++) {
      String direction = _directions[i];
      await _tts.speak(direction);
      setState(() {
        _curRoute = direction;
        print(_curRoute);
      });

      // Wait for the person to reach the destination before speaking the next direction
      LatLng destination = _destinations[i];
      while (true) {
        await Future.delayed(const Duration(seconds: 1));
        Position currentLocation = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);

        if (currentLocation.latitude == destination.latitude &&
            currentLocation.longitude == destination.longitude) {
          break;
        }
      }
    }
  }

  Future<bool> _requestPermission() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  late String _language;

  void _loadLangs() async {
    String? lang = await getLanguageCode();
    setState(() {
      _language = lang;
    });
  }

  Map<String, String>? _translations;

  void _loadTranslations() async {
    Map<String, String>? translations = await getLanguage();
    setState(() {
      _translations = translations;
    });
  }

  bool isButtonEnabled = false;
  String snackText = "";

  void _onAddressUpdated() {
    setState(() {
      isButtonEnabled = destinationAddressController.text.isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadLangs();
    _loadTranslations();
    _tts = FlutterTts();
    // _tts.setLanguage("en-US");
    _tts.setSpeechRate(0.4);
    _getCurrentLocation();
    // startAddressController.addListener(_onAddressUpdated);
    destinationAddressController.addListener(_onAddressUpdated);
  }

  @override
  Widget build(BuildContext context) {
    // var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Map View
          GoogleMap(
            markers: Set<Marker>.from(markers),
            initialCameraPosition: _initialLocation,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            mapToolbarEnabled: false,
            mapType: MapType.hybrid,
            zoomControlsEnabled: false,
            indoorViewEnabled: true,
            compassEnabled: false,
            polylines: Set<Polyline>.of(polylines.values),
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
          ),
          // Show the place input fields & button for showing the route
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Destination field
                  _textField(
                      label: _translations!["destination"] ?? "Destination",
                      hint: _translations!["cd"] ?? "Choose destination",
                      prefixIcon: Icon(
                        Icons.stop_rounded,
                        color: THEME[1],
                      ),
                      controller: destinationAddressController,
                      focusNode: destinationAddressFocusNode,
                      width: width,
                      locationCallback: (String value) {
                        setState(() {
                          _destinationAddress = value;
                        });
                      }),
                  // Go button
                  FloatingActionButton(
                    onPressed: isButtonEnabled
                        ? () async {
                            setState(() {
                              isButtonEnabled = false;
                              startAddressFocusNode.unfocus();
                              destinationAddressFocusNode.unfocus();
                              if (markers.isNotEmpty) {
                                markers.clear();
                              }
                              if (polylines.isNotEmpty) {
                                polylines.clear();
                              }
                              if (polylineCoordinates.isNotEmpty) {
                                polylineCoordinates.clear();
                              }
                              _placeDistance = null;
                            });
                            if (startAddressController.text.isEmpty) {
                              await _getCurrentLocation();
                            }
                            _calculateDistance().then((isCalculated) {
                              if (isCalculated) {
                                snackText = _translations!["dcs"] ??
                                    "Distance Calculated Successfully";
                                setState(() async {
                                  await _getDirections();
                                  await _speakDirections();
                                });
                              } else {
                                snackText = _translations!["ecd"] ??
                                    "Error Calculating Distance";
                                setState(() {
                                  isButtonEnabled = true; // Enable the button
                                });
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  showCloseIcon: true,
                                  closeIconColor: THEME[1],
                                  backgroundColor: THEME[0],
                                  content: Center(
                                    child: Text(
                                      snackText,
                                      style: TextStyle(color: THEME[1]),
                                    ),
                                  ),
                                ),
                              );
                            });
                          }
                        : null,
                    backgroundColor: isButtonEnabled ? THEME[0] : THEME[3],
                    foregroundColor: THEME[1],
                    child: const Icon(
                      Icons.stacked_line_chart_rounded,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // route
          Container(
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: 50.0, left: 80, right: 80),
            child: Column(
              children: [
                Visibility(
                  visible: _curRoute == null ? false : true,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: ColoredBox(
                      color: THEME[0],
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _curRoute ?? "",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: THEME[1],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                // distance
                Visibility(
                  visible: _placeDistance == null ? false : true,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: ColoredBox(
                      color: THEME[0],
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _placeDistance != null
                              ? "${_placeDistance!} ${_translations != null && _translations!["km"] != null ? _translations!["km"]! : "km"}"
                              : "",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: THEME[1]),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 50.0,
            right: 12.0,
            child: Column(
              children: [
                // Show current location button
                FloatingActionButton(
                  backgroundColor: THEME[0],
                  foregroundColor: THEME[1],
                  child: const SizedBox(
                    width: 56,
                    height: 56,
                    child: Icon(Icons.my_location),
                  ),
                  onPressed: () async {
                    bool permission = await _requestPermission();
                    if (permission) {
                      _setNewValues();
                      _getCurrentLocation();
                    }
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                // Show Tilt Button
                FloatingActionButton(
                  backgroundColor: THEME[0],
                  foregroundColor: THEME[1],
                  child: const SizedBox(
                    width: 56,
                    height: 56,
                    child: Icon(Icons.filter_tilt_shift),
                  ),
                  onPressed: () {
                    setState(() {
                      _tilt = _tilt == 0.0 ? 90.0 : 0.0;
                      _setNewValues();
                    });
                  },
                ),
              ],
            ),
          ),
          // Show Back Button
          Positioned(
            top: 50.0,
            left: 12.0,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              backgroundColor: THEME[0],
              foregroundColor: THEME[1],
              child: const Icon(
                Icons.arrow_back,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
