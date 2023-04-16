// ignore_for_file: no_leading_underscores_for_local_identifiers, depend_on_referenced_packages

import 'dart:convert' show jsonDecode;
import 'package:http/http.dart' as http show get, Response;
import 'package:campusmap/main.dart' show API_KEY;
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

Future<Map> getDirections(
  LatLng origin,
  LatLng destination,
  String mode,
  String _language, {
  String unit = "metric",
}) async {
  String url =
      "https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&mode=$mode&language=$_language&units=$unit&key=$API_KEY";
  http.Response response = await http.get(Uri.parse(url));
  return jsonDecode(response.body);
}
