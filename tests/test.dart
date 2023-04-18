// ignore_for_file: depend_on_referenced_packages, unused_import, avoid_print, constant_identifier_names

import 'dart:convert';
import 'package:http/http.dart' as http;

const API_KEY = "AIzaSyCmyfqPois80RK7UTuXlL8s0RSGXxzA7g8";

// https://maps.googleapis.com/maps/api/geocode/json?address=tumkur&language=kn&key=AIzaSyCmyfqPois80RK7UTuXlL8s0RSGXxzA7g8
// https://maps.googleapis.com/maps/api/geocode/json?latlng=40.714224,-73.961452&language=kn&key=AIzaSyCmyfqPois80RK7UTuXlL8s0RSGXxzA7g8

Future<String> fetchPlaces(double lat, double lng, String lang) async {
  final response = await http.get(Uri.parse(
      'https://maps.googleapis.com/maps/api/streetview/metadata?location=$lat,$lng&key=$API_KEY'));

  return response.body;
}

getLatLngFromPanoId(String panoId) async {
  final response = await http.get(Uri.parse(
      'https://maps.googleapis.com/maps/api/streetview/metadata?pano=$panoId&key=$API_KEY'));

  return response.body;
}

void main() {
  //fetchPlaces(13.3268473, 77.1261341, "en").then((value) => print(value));
  getLatLngFromPanoId("CAoSLEFGMVFpcE5QZG1fV1c4OUlnTmh0VEh6LXRUUjdrV3AtUWYxNUVDNEVxYUJu").then((value) => print(value));
}

// 13.3268473,77.1261341
// 13.326851970613,77.126127154089
// 13.326791191011,77.125909069491
// 13.326784769749,77.12599376083
// 13.326825305395,77.12607079511299