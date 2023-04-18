// ignore_for_file: non_constant_identifier_names

import 'dart:math' show sqrt, pow;
import 'package:flutter_polyline_points/flutter_polyline_points.dart'
    show PointLatLng;
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

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
List<LatLng> decodePolylineFromJson(Map<dynamic, dynamic> json) {
  List<PointLatLng> points = [];

  List<dynamic> steps = json['routes'][0]['legs'][0]['steps'];

  for (int i = 0; i < steps.length; i++) {
    String encodedPolyline = steps[i]['polyline']['points'];
    List<PointLatLng> decodedPoints = decodePolyline(encodedPolyline);
    points.addAll(decodedPoints);
  }

  return points.map((point) {
    return LatLng(point.latitude, point.longitude);
  }).toList();
}

// is point in boundry
bool isPointInPolygon(List<List<double>> polygon, double x, double y) {
  int i, j;
  bool c = false;
  int n = polygon.length;
  j = n - 1;
  for (i = 0; i < n; j = i++) {
    if (((polygon[i][1] > y) != (polygon[j][1] > y)) &&
        (x <
            (polygon[j][0] - polygon[i][0]) *
                    (y - polygon[i][1]) /
                    (polygon[j][1] - polygon[i][1]) +
                polygon[i][0])) {
      c = !c;
    }
  }
  return c;
}

// find nearest place
Map<String, dynamic> findNearestPlaceName(
  List<Map<String, dynamic>> Destinations,
  double lat,
  double lng,
) {
  Map<String, dynamic>? nearestPlace;
  double minDistance = double.infinity;

  for (var place in Destinations) {
    double distance = sqrt(pow(place['coordinates'][1] - lat, 2) +
        pow(place['coordinates'][0] - lng, 2));

    if (distance < minDistance) {
      minDistance = distance;
      nearestPlace = place;
    }
  }

  return nearestPlace!;
}
