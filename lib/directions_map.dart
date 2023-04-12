// ignore_for_file: depend_on_referenced_packages, avoid_print, use_build_context_synchronously

import 'dart:convert' show jsonDecode;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http show get, Response;
import 'package:flutter_tts/flutter_tts.dart' show FlutterTts;
import 'package:flutter_polyline_points/flutter_polyline_points.dart'
    show PolylinePoints, PointLatLng;
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
import 'package:cached_network_image/cached_network_image.dart'
    show CachedNetworkImageProvider;

import 'package:campusmap/main.dart' show THEME, API_KEY;
import 'package:campusmap/language_texts.dart'
    show getLanguageCode, getLanguage;
import 'package:campusmap/map_styles.dart' show MapStyle;

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
  // late double _startLat, _startLng, _destLat, _desLng;
  String _currentAddress = '';

  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();

  final startAddressFocusNode = FocusNode();
  final destinationAddressFocusNode = FocusNode();

  String _startAddress = '';
  String _destinationAddress = '';
  String? _placeDistance;
  String? _nxtDistance;
  String? _nxtDuration;
  String? _placeDuration;
  String? _curRoute;
  String? _curManeuver;

  Set<Marker> markers = {};

  List<MapType> mapTypes = [MapType.normal, MapType.hybrid, MapType.terrain];
  List<IconData> mapTypeIcons = [
    Icons.width_normal_rounded,
    Icons.satellite_alt_rounded,
    Icons.terrain_rounded
  ];
  int _choseMapType = 0;

  List<String> mapStyles = [
    MapStyle.standard,
    MapStyle.silver,
    MapStyle.retro,
    MapStyle.dark,
    MapStyle.night,
    MapStyle.aubergine
  ];
  List<IconData> mapStyleIcons = [];
  int _choseMapStyle = 4;

  late PolylinePoints polylinePoints;
  Set<Polyline> _polylines = <Polyline>{};
  List<LatLng> polylineCoordinates = [];

  final double _tilt = 0.0;
  final double _bearing = 0.0;
  Color polyColor = Colors.green;
  int zoomoutTime = 2;

  Widget _textField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required double width,
    required Icon prefixIcon,
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
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          labelStyle: TextStyle(
            color: THEME[3],
          ),
          filled: true,
          fillColor: THEME[0],
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              Radius.circular(10),
            ),
            borderSide: BorderSide(
              color: THEME[0],
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              Radius.circular(10),
            ),
            borderSide: BorderSide(
              color: THEME[1],
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.all(15),
          hintText: hint,
          hintStyle: TextStyle(color: THEME[3]),
          suffixIcon: isButtonEnabled
              ? GestureDetector(
                  onTap: () {
                    controller.clear();
                  },
                  child: Icon(
                    Icons.clear,
                    color: THEME[3],
                  ),
                )
              : null,
        ),
        cursorColor: THEME[3],
      ),
    );
  }

  Widget _buildMapStyleButton(String label, int index) {
    return Expanded(
      child: InkWell(
        onTap: () {
          if (_choseMapStyle != index) {
            Navigator.pop(context);
            setState(() {
              _choseMapStyle = index;
              mapController.setMapStyle(mapStyles[_choseMapStyle]);
            });
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color:
                      _choseMapStyle == index ? THEME[3] : Colors.transparent,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image(
                  width: _choseMapStyle == index ? 60 : 50,
                  image: CachedNetworkImageProvider(
                    'https://archive.org/download/googlemapstyles/${label.toLowerCase()}.png',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: THEME[1],
                fontWeight: _choseMapStyle == index
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method for retrieving the current location
  Future<void> _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        _currentPosition = position;
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
  Future<void> _getAddress() async {
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

  Future<bool> _getDirections() async {
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

      // String startCoordinatesString = '($startLatitude, $startLongitude)';
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

      // _startLat = startLatitude;
      // _startLng = startLongitude;
      // _destLat = destinationLatitude;
      // _desLng = destinationLongitude;

      // getting accurate route
      LatLng origin = LatLng(startLatitude, startLongitude);
      LatLng destination = LatLng(destinationLatitude, destinationLongitude);
      String url =
          "https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&mode=$mode&key=$API_KEY&language=$_language&units=metric";
      http.Response response = await http.get(Uri.parse(url));
      Map values = jsonDecode(response.body);

      double southWestLatitude =
          values["routes"][0]["bounds"]["southwest"]["lat"];
      double southWestLongitude =
          values["routes"][0]["bounds"]["southwest"]["lng"];

      double northEastLatitude =
          values["routes"][0]["bounds"]["northeast"]["lat"];
      double northEastLongitude =
          values["routes"][0]["bounds"]["northeast"]["lng"];

      // zoom out to show both points
      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            northeast: LatLng(northEastLatitude, northEastLongitude),
            southwest: LatLng(southWestLatitude, southWestLongitude),
          ),
          100.0,
        ),
      );

      await _createPolylines(values, startLatitude, startLongitude,
          destinationLatitude, destinationLongitude);

      // setting up directions
      List steps = values["routes"][0]["legs"][0]["steps"];
      _directions = steps
          .map((step) =>
              step["html_instructions"].replaceAll(RegExp(r"<[^>]*>"), ""))
          .toList();
      _destinations = steps
          .map((step) =>
              LatLng(step["end_location"]["lat"], step["end_location"]["lng"]))
          .toList();
      _maneuvers = steps.map((step) => step["maneuver"] ?? "straight").toList();
      _stepdistances = steps
          .map((step) => (step["distance"]["value"] / 1000).toStringAsFixed(2))
          .toList();
      _stepdurations =
          steps.map((step) => (step["duration"]["value"]).toString()).toList();

      double totalDistance =
          values["routes"][0]["legs"][0]["distance"]["value"] / 1000;
      int totalDuration = values["routes"][0]["legs"][0]["duration"]["value"];

      // zoom back to my location / current location
      await Future.delayed(Duration(seconds: zoomoutTime));
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(startLatitude, startLongitude),
          20,
        ),
      );

      setState(() {
        _lastPosition = _currentPosition;
        _placeDistance = totalDistance.toStringAsFixed(2);
        _placeDuration = totalDuration.toString();
      });

      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  // decode lat lang from string
  List<PointLatLng> decodePolyline(String encoded) {
    List<PointLatLng> points = <PointLatLng>[];
    int index = 0, lat = 0, lng = 0;

    while (index < encoded.length) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(PointLatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  // decode polies from response
  List<PointLatLng> decodePolylineFromJson(Map<dynamic, dynamic> json) {
    List<PointLatLng> points = [];

    List<dynamic> steps = json['routes'][0]['legs'][0]['steps'];

    for (int i = 0; i < steps.length; i++) {
      String encodedPolyline = steps[i]['polyline']['points'];
      List<PointLatLng> decodedPoints = decodePolyline(encodedPolyline);
      points.addAll(decodedPoints);
    }

    return points;
  }

  // Create the polylines for showing the route between two places
  Future<void> _createPolylines(
      Map values,
      double startLatitude,
      double startLongitude,
      double destinationLatitude,
      double destinationLongitude) async {
    List<PointLatLng> result = decodePolylineFromJson(values);

    List<LatLng> polylineCoordinates = result.map((point) {
      return LatLng(point.latitude, point.longitude);
    }).toList();

    PolylineId startingConnectingLineId =
        const PolylineId('startingConnectingLine');
    Polyline startingConnectingPolyline = Polyline(
      polylineId: startingConnectingLineId,
      color: Colors.grey,
      width: 5,
      patterns: [PatternItem.dot, PatternItem.gap(30)],
      points: [
        polylineCoordinates.first,
        LatLng(startLatitude, startLongitude),
      ],
    );

    _polylines.add(startingConnectingPolyline);
    PolylineId connectingLineId = const PolylineId('connectingLine');
    Polyline connectingPolyline = Polyline(
      polylineId: connectingLineId,
      color: Colors.grey,
      width: 5,
      patterns: [PatternItem.dot, PatternItem.gap(30)],
      points: [
        polylineCoordinates.last,
        LatLng(destinationLatitude, destinationLongitude),
      ],
    );
    _polylines.add(connectingPolyline);

    PolylineId walkingRouteId = const PolylineId('walkingRoute');
    Polyline walkingRoutePolyline = Polyline(
      polylineId: walkingRouteId,
      color: polyColor,
      width: 10,
      patterns: [PatternItem.dot, PatternItem.gap(30)],
      points: polylineCoordinates,
    );
    _polylines.add(walkingRoutePolyline);

    setState(() {});
  }

  late FlutterTts _tts;
  List<dynamic> _directions = [];
  List<dynamic> _destinations = [];
  List<dynamic> _maneuvers = [];
  List<dynamic> _stepdurations = [];
  List<dynamic> _stepdistances = [];

  Future<void> _updatePolylines() async {
    // Calculate the distance between the current position and the last position of the user
    double distance = Geolocator.distanceBetween(
        _lastPosition.latitude,
        _lastPosition.longitude,
        _currentPosition.latitude,
        _currentPosition.longitude);

    // Remove the oldest point(s) from the list if the distance is greater than a certain threshold value and update
    if (distance > updateDist) {
      int index = 0;
      while (index < polylineCoordinates.length - 1 &&
          Geolocator.distanceBetween(
                  polylineCoordinates[index].latitude,
                  polylineCoordinates[index].longitude,
                  _currentPosition.latitude,
                  _currentPosition.longitude) >
              updateDist) {
        polylineCoordinates.removeAt(0);
        index++;
      }
      setState(() {
        _lastPosition = _currentPosition;
      });
    }
  }

  Future<void> _speakDirections() async {
    for (int i = 0; i < _directions.length; i++) {
      String direction = _directions[i];
      await _tts.speak(direction);
      setState(() {
        _curManeuver = _maneuvers[i];
        _curRoute = direction;
        _nxtDistance = _stepdistances[i];
        _nxtDuration = _stepdurations[i];
      });

      LatLng destination = _destinations[i];
      while (true) {
        await Future.delayed(const Duration(seconds: 1));
        _currentPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);

        _updatePolylines();

        if (Geolocator.distanceBetween(
                _currentPosition.latitude,
                _currentPosition.longitude,
                destination.latitude,
                destination.longitude) <
            updateDist * 2) {
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
  String mode = 'walking';

  void _loadLangs() async {
    String? lang = await getLanguageCode();
    setState(() {
      _language = lang;
    });
  }

  Map<String, String>? _translations;
  late Position _lastPosition;
  double updateDist = 5;

  void _loadTranslations() async {
    Map<String, String>? translations = await getLanguage();
    setState(() {
      _translations = translations;
    });
  }

  bool isButtonEnabled = false;
  String snackText = "";

  void _onAddressUpdated() {
    if (destinationAddressController.text.isNotEmpty != isButtonEnabled) {
      setState(() {
        isButtonEnabled = !isButtonEnabled;
      });
    }
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
            mapType: mapTypes[_choseMapType],
            zoomControlsEnabled: false,
            indoorViewEnabled: true,
            compassEnabled: false,
            polylines: _polylines,
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
              mapController.setMapStyle(mapStyles[_choseMapStyle]);
            },
          ),
          // totals
          Align(
            alignment: const Alignment(0, 0.8),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // total duration
                  Visibility(
                    visible: _placeDuration == null ? false : true,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: ColoredBox(
                        color: THEME[0],
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            _placeDuration != null
                                ? "${_placeDuration!} ${_translations != null && _translations!["sec"] != null ? _translations!["sec"]! : "sec"}"
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
                  // total distance
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
                ]),
          ),
          // Show the place input fields & go button
          Container(
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
                        Icons.place_rounded,
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
                              if (_polylines.isNotEmpty) {
                                _polylines.clear();
                              }
                              if (polylineCoordinates.isNotEmpty) {
                                polylineCoordinates.clear();
                              }
                              _curRoute = null;
                              _curManeuver = null;
                              _nxtDistance = null;
                              _nxtDuration = null;
                              _placeDistance = null;
                              _placeDuration = null;
                            });
                            if (startAddressController.text.isEmpty) {
                              await _getCurrentLocation();
                            }
                            _getDirections().then((isDone) {
                              if (isDone) {
                                snackText = _translations!["dcs"] ??
                                    "Distance Calculated Successfully";
                                setState(() async {
                                  await _tts.stop();
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
            padding: const EdgeInsets.only(top: 50, left: 80, right: 80),
            child: Column(
              children: [
                // cur route
                Visibility(
                  visible: _curRoute == null ? false : true,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: ColoredBox(
                      color: THEME[0],
                      child: Padding(
                        padding: const EdgeInsets.all(8),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // maneuver
                    Visibility(
                      visible: _curManeuver == null ? false : true,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: ColoredBox(
                          color: THEME[0],
                          child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: _curManeuver == null
                                  ? Icon(Icons.straight_rounded,
                                      color: THEME[1])
                                  : _curManeuver == "straight"
                                      ? Icon(Icons.straight_rounded,
                                          color: THEME[1])
                                      : _curManeuver!.contains("left")
                                          ? Icon(Icons.turn_left_rounded,
                                              color: THEME[1])
                                          : Icon(Icons.turn_right_rounded,
                                              color: THEME[1])),
                        ),
                      ),
                    ),
                    // next duration
                    Visibility(
                      visible: _nxtDuration == null ? false : true,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: ColoredBox(
                          color: THEME[0],
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              _nxtDuration != null
                                  ? "${_nxtDuration!} ${_translations != null && _translations!["sec"] != null ? _translations!["sec"]! : "sec"}"
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
                    // next distance
                    Visibility(
                      visible: _nxtDistance == null ? false : true,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: ColoredBox(
                          color: THEME[0],
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              _nxtDistance != null
                                  ? "${_nxtDistance!} ${_translations != null && _translations!["km"] != null ? _translations!["km"]! : "km"}"
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
              ],
            ),
          ),
          Positioned(
            top: 50,
            right: 12,
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
                      _getCurrentLocation();
                    }
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                // Show map type Button
                FloatingActionButton(
                  backgroundColor: THEME[0],
                  foregroundColor: THEME[1],
                  child: const SizedBox(
                    width: 56,
                    height: 56,
                    child: Icon(Icons.camera_rounded),
                  ),
                  onPressed: () {
                    showModalBottomSheet<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          color: THEME[2],
                          height: 120,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              for (var entry in [
                                "Normal",
                                "Satellite",
                                "Terrain"
                              ].asMap().entries)
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    FloatingActionButton(
                                      backgroundColor: THEME[0],
                                      onPressed: () {
                                        if (_choseMapType != entry.key) {
                                          Navigator.pop(context);
                                          setState(() {
                                            _choseMapType = entry.key;
                                          });
                                        }
                                      },
                                      shape: _choseMapType == entry.key
                                          ? RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              side: BorderSide(
                                                  width: 2, color: THEME[3]),
                                            )
                                          : null,
                                      child: Icon(
                                        mapTypeIcons[entry.key],
                                        color: THEME[1],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      entry.value,
                                      style: TextStyle(
                                        color: THEME[1],
                                        fontWeight: _choseMapType == entry.key
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                Visibility(
                  visible: _choseMapType == 0,
                  child: FloatingActionButton(
                    backgroundColor: THEME[0],
                    onPressed: () {
                      showModalBottomSheet<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            color: THEME[2],
                            padding: const EdgeInsets.only(top: 40, bottom: 20),
                            height: 240,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    for (var entry in [
                                      "Standard",
                                      "Silver",
                                      "Retro",
                                    ].asMap().entries)
                                      _buildMapStyleButton(
                                          entry.value, entry.key),
                                  ],
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    for (var entry in [
                                      "Dark",
                                      "Night",
                                      "Aubergine",
                                    ].asMap().entries)
                                      _buildMapStyleButton(
                                          entry.value, entry.key + 3),
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Icon(
                      Icons.style_rounded,
                      color: THEME[1],
                    ),
                  ),
                )
              ],
            ),
          ),
          // Show Back Button
          Positioned(
            top: 50.0,
            left: 12.0,
            child: FloatingActionButton(
              onPressed: () async {
                await _tts.stop();
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
