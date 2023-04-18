// ignore_for_file: depend_on_referenced_packages, avoid_print, use_build_context_synchronously, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart' show FlutterTts;
import 'package:geolocator/geolocator.dart' show Position, Geolocator;
import 'package:google_maps_flutter/google_maps_flutter.dart'
    show
        CameraPosition,
        LatLng,
        GoogleMapController,
        Marker,
        PolylineId,
        Polyline,
        Polygon,
        PolygonId,
        PatternItem,
        CameraUpdate,
        MarkerId,
        InfoWindow,
        BitmapDescriptor,
        LatLngBounds,
        GoogleMap,
        MapType;

import 'package:campusmap/main.dart' show THEME;
import 'package:campusmap/presets/language_texts.dart'
    show getLanguage, getLanguageCode, TRANSLATIONS;
import 'package:campusmap/presets/map_styles.dart' show MapStyle;
import 'package:campusmap/views/street_view.dart' show getFreeView;
import 'package:campusmap/panels/left_panel.dart'
    show getDrawer, getMenuButton, getClearButton;
import 'package:campusmap/panels/right_panel.dart'
    show getMyLoactionButton, getMapTypeButton, getMapStylesButton;
import 'package:campusmap/panels/middle_panel.dart' show getMiddlePanel;
import 'package:campusmap/panels/bottom_panel.dart'
    show getBottomPanel, getTotalsPanel;
import 'package:campusmap/presets/values.dart'
    show sitLat, sitLng, collegeBoundaryD, Destinations;
import 'package:campusmap/requests.dart' show getDirections;
import 'package:campusmap/computations.dart'
    show decodePolylineFromJson, isPointInPolygon, findNearestPlaceName;

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  MapViewState createState() => MapViewState();
}

class MapViewState extends State<MapView> {
  late GoogleMapController mapController;
  late Position _currentPosition;
  bool curPosIsInit = false;
  // late double _startLat, _startLng, _destLat, _desLng;

  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();

  final startAddressFocusNode = FocusNode();
  final destinationAddressFocusNode = FocusNode();

  // String _startAddress = '';
  // String _destinationAddress = '';
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

  String _language = "en";
  String mode = 'walking';
  Map<String, String> translations = TRANSLATIONS["en"]!;
  late Position _lastPosition;
  double updateDist = 5;
  bool isButtonEnabled = false;
  String snackText = "";
  bool _reload = false;

  late double _destinationLatitude;
  late double _destinationLongitude;

  Set<Polygon> collegeBoundary = {
    Polygon(
      polygonId: const PolygonId('SIT'),
      points: collegeBoundaryD.map((list) => LatLng(list[1], list[0])).toList(),
      strokeWidth: 1,
      strokeColor: Colors.blue,
      fillColor: Colors.blue.withOpacity(0.1),
      geodesic: true,
    )
  };

  // Method for retrieving the current location
  Future<void> _getCurrentLocation() async {
    // able to reduce battery if forceAndroidLocationManager is used
    _currentPosition = await Geolocator.getCurrentPosition();
    setState(() {
      curPosIsInit = true;
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target:
                LatLng(_currentPosition.latitude, _currentPosition.longitude),
            zoom: 20,
            tilt: _tilt,
            bearing: _bearing,
          ),
        ),
      );
    });
  }

  Future<bool> _getDirections() async {
    try {
      double startLatitude = _currentPosition.latitude;
      double startLongitude = _currentPosition.longitude;

      double destinationLatitude = _destinationLatitude;
      double destinationLongitude = _destinationLongitude;

      // String startCoordinatesString = '($startLatitude, $startLongitude)';
      String destinationCoordinatesString =
          '($destinationLatitude, $destinationLongitude)';

      // Destination Location Marker
      Marker destinationMarker = Marker(
        markerId: MarkerId(destinationCoordinatesString),
        position: LatLng(destinationLatitude, destinationLongitude),
        infoWindow: InfoWindow(
          title: 'Destination $destinationCoordinatesString',
        ),
        icon: BitmapDescriptor.defaultMarker,
      );
      markers.add(destinationMarker);

      // _startLat = startLatitude;
      // _startLng = startLongitude;
      // _destLat = destinationLatitude;
      // _desLng = destinationLongitude;

      // getting accurate route
      LatLng origin = LatLng(startLatitude, startLongitude);
      LatLng destination = LatLng(destinationLatitude, destinationLongitude);

      var values = await getDirections(origin, destination, mode, _language);

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
      debugPrint(e.toString());
    }
    return false;
  }

  // Create the polylines for showing the route between two places
  Future<void> _createPolylines(
      Map values,
      double startLatitude,
      double startLongitude,
      double destinationLatitude,
      double destinationLongitude) async {
    List<LatLng> polylineCoordinates = decodePolylineFromJson(values);

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
        _currentPosition = await Geolocator.getCurrentPosition();

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
    Map<String, String> transl = await getLanguage();
    String? lang = await getLanguageCode();
    setState(() {
      translations = transl;
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

  void setDestinationAddress(String value, double lat, double lng) {
    setState(() {
      destinationAddressController.text = value;
      _destinationLatitude = lat;
      _destinationLongitude = lng;
    });
  }

  void clearAll(bool all) async {
    setState(() {
      isButtonEnabled = false;
      // startAddressFocusNode.unfocus();
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
      if (_directions.isEmpty) {
        _directions.clear();
      }
      if (_destinations.isEmpty) {
        _destinations.clear();
      }
      _curRoute = null;
      _curManeuver = null;
      _nxtDistance = null;
      _nxtDuration = null;
      _placeDistance = null;
      _placeDuration = null;
    });
    await _tts.stop();
    if (all) {
      setState(() {
        setDestinationAddress("", 0, 0);
        _reload = false;
      });
    }
  }

  Future<void> goButtonPressed() async {
    clearAll(false);

    if (!curPosIsInit) {
      await _getCurrentLocation();
    }
    _getDirections().then((isDone) {
      if (isDone) {
        snackText = translations["dfs"] ?? "Direction Found Successfully";  // Distance Calculated Sucessfully
        setState(() async {
          _reload = true;
          await _speakDirections();
        });
      } else {
        snackText = translations["efd"] ?? "Error Finding Direction";
        setState(() {
          isButtonEnabled = true; // Enable the button
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
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
    // double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Map View
          GoogleMap(
              markers: Set<Marker>.from(markers),
              initialCameraPosition: const CameraPosition(
                target: LatLng(
                  sitLat - 0.001,
                  sitLng + 0.001,
                ),
                zoom: 16,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
              mapType: mapTypes[_choseMapType],
              zoomControlsEnabled: false,
              indoorViewEnabled: true,
              compassEnabled: false,
              polylines: polylines,
              polygons: collegeBoundary,
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
                mapController.setMapStyle(mapStyles[_choseMapStyle]);
                Future.delayed(
                  const Duration(milliseconds: 1000),
                  () => mapController.animateCamera(
                    CameraUpdate.newCameraPosition(
                      const CameraPosition(
                        target: LatLng(
                          sitLat,
                          sitLng,
                        ),
                        zoom: 18,
                      ),
                    ),
                  ),
                );
              },
              onTap: (tappedLatLng) async {
                if (destinationAddressController.text.isEmpty &&
                    isPointInPolygon(collegeBoundaryD, tappedLatLng.longitude,
                        tappedLatLng.latitude)) {
                  Map<String, dynamic> place = findNearestPlaceName(Destinations,
                      tappedLatLng.latitude, tappedLatLng.longitude);
                  setState(() {
                    setDestinationAddress(
                      place["name"],
                      place['coordinates'][1],
                      place['coordinates'][0],
                    );
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Center(
                        child: Text(
                          translations["du"] ?? 'Destination Updated',
                          style: TextStyle(color: THEME[1]),
                        ),
                      ),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                      showCloseIcon: true,
                      closeIconColor: THEME[1],
                      backgroundColor: THEME[0],
                    ),
                  );
                }
                destinationAddressFocusNode.unfocus();
              }),
          // Totals Panel
          getTotalsPanel(
            THEME,
            _placeDuration,
            _placeDistance,
            translations,
            destinationAddressFocusNode.hasFocus,
          ),
          // Bottom Panel
          getBottomPanel(
            THEME,
            translations,
            destinationAddressController,
            destinationAddressFocusNode,
            width,
            isButtonEnabled,
            setDestinationAddress,
            goButtonPressed,
            context,
          ),
          // Middle Panel
          getMiddlePanel(
            THEME,
            _curRoute,
            _curManeuver,
            _nxtDuration,
            _nxtDistance,
            translations,
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
                      THEME,
                      translations,
                      context,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    // Clear Button
                    getClearButton(
                      THEME,
                      clearAll,
                      _reload,
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
        translations,
        context,
        _loadTranslationsAndLang,
      ),
    );
  }
}
