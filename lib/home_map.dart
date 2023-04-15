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
    show Position, Geolocator, LocationAccuracy;
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
    show getLanguage, getLanguageCode;
import 'package:campusmap/map_styles.dart' show MapStyle;
import 'package:campusmap/street_view.dart' show getFreeView;
import 'package:campusmap/left_panel.dart' show getDrawer, getMenuButton;
import 'package:campusmap/right_panel.dart'
    show getMyLoactionButton, getMapTypeButton, getMapStylesButton;
import 'package:campusmap/middle_panel.dart' show getMiddlePanel;
import 'package:campusmap/bottom_panel.dart'
    show getBottomPanel, getTotalsPanel;
import 'package:campusmap/values.dart' show sitLat, sitLng;

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  MapViewState createState() => MapViewState();
}

class MapViewState extends State<MapView> {
  final CameraPosition _initialLocation = const CameraPosition(
    target: LatLng(
      sitLat,
      sitLng,
    ),
    zoom: 18,
    tilt: 0,
    bearing: 0,
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
  Set<Polyline> polylines = <Polyline>{};
  List<LatLng> polylineCoordinates = [];

  final double _tilt = 0.0;
  final double _bearing = 0.0;
  Color polyColor = Colors.green;
  int zoomoutTime = 2;

  late FlutterTts _tts;
  List<dynamic> _directions = [];
  List<dynamic> _destinations = [];
  List<dynamic> _maneuvers = [];
  List<dynamic> _stepdurations = [];
  List<dynamic> _stepdistances = [];

  late String _language;
  String mode = 'walking';
  Map<String, String>? _translations;
  late Position _lastPosition;
  double updateDist = 5;
  bool isButtonEnabled = false;
  String snackText = "";

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

      // Use the retrieved coordinates of the current position, instead of the address if the start position is user's current position, as it results in better accuracy.
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

      // Setting Up Directions
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

      // Zoom back to my location / Current location
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

  // Decode lat lang from string
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

  // Decode polies from response
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

    polylines.add(startingConnectingPolyline);
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
    polylines.add(connectingPolyline);

    PolylineId walkingRouteId = const PolylineId('walkingRoute');
    Polyline walkingRoutePolyline = Polyline(
      polylineId: walkingRouteId,
      color: polyColor,
      width: 10,
      patterns: [PatternItem.dot, PatternItem.gap(30)],
      points: polylineCoordinates,
    );
    polylines.add(walkingRoutePolyline);

    setState(() {});
  }

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

  void _loadTranslationsAndLang() async {
    Map<String, String>? translations = await getLanguage();
    String? lang = await getLanguageCode();
    setState(() {
      _translations = translations;
      _language = lang;
    });
  }

  void _onAddressUpdated() {
    if (destinationAddressController.text.isNotEmpty != isButtonEnabled) {
      setState(() {
        isButtonEnabled = !isButtonEnabled;
      });
    }
  }

  void setChoseMapType(int value) {
    setState(() {
      _choseMapType = value;
    });
  }

  void setChoseMapStyle(int value) {
    setState(() {
      _choseMapStyle = value;
      mapController.setMapStyle(mapStyles[_choseMapStyle]);
    });
  }

  void setDestinationAddress(String value) {
    setState(() {
      _destinationAddress = value;
    });
  }

  Future<void> goButtonPressed() async {
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
        snackText = _translations!["dcs"] ?? "Distance Calculated Successfully";
        setState(() async {
          await _tts.stop();
          await _speakDirections();
        });
      } else {
        snackText = _translations!["ecd"] ?? "Error Calculating Distance";
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

  @override
  void initState() {
    super.initState();
    _loadTranslationsAndLang();
    _getCurrentLocation();
    destinationAddressController.addListener(_onAddressUpdated);
    _tts = FlutterTts();
    _tts.setSpeechRate(0.4);
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
            polylines: polylines,
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
              mapController.setMapStyle(mapStyles[_choseMapStyle]);
            },
            onTap: (tappedLatLng) {
              destinationAddressFocusNode.unfocus();
            },
          ),
          // Totals Panel
          getTotalsPanel(
            THEME,
            _placeDuration,
            _placeDistance,
            _translations,
            destinationAddressFocusNode.hasFocus,
          ),
          // Bottom Panel
          getBottomPanel(
              THEME,
              _translations,
              destinationAddressController,
              destinationAddressFocusNode,
              width,
              isButtonEnabled,
              setDestinationAddress,
              goButtonPressed,
              context),
          // Middle Panel
          getMiddlePanel(
            THEME,
            _curRoute,
            _curManeuver,
            _nxtDuration,
            _nxtDistance,
            _translations,
          ),
          // Right Panel
          Positioned(
            top: 50,
            right: 12,
            child: Column(
              children: [
                // Current Location Button
                getMyLoactionButton(
                  THEME,
                  _getCurrentLocation,
                ),
                const SizedBox(
                  height: 10,
                ),
                // Map Type Button
                getMapTypeButton(
                  THEME,
                  mapTypeIcons,
                  _choseMapType,
                  context,
                  setChoseMapType,
                ),
                const SizedBox(
                  height: 10,
                ),
                // Map Style Button
                getMapStylesButton(
                  THEME,
                  _choseMapType,
                  _choseMapStyle,
                  context,
                  setChoseMapStyle,
                ),
              ],
            ),
          ),
          // Left Panel
          Positioned(
            top: 50.0,
            left: 12.0,
            child: Builder(
              builder: (BuildContext context) {
                return Column(
                  children: [
                    // Menu Button
                    getMenuButton(
                      THEME,
                      context,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    // Street View
                    getFreeView(
                      context,
                    )
                  ],
                );
              },
            ),
          ),
        ],
      ),
      // Drawer
      drawer: getDrawer(
        THEME,
        _translations,
        context,
        _loadTranslationsAndLang,
      ),
    );
  }
}
