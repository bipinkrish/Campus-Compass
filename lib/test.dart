// import 'dart:convert';
// import 'package:http/http.dart' as http;

// const API_KEY = "AIzaSyCmyfqPois80RK7UTuXlL8s0RSGXxzA7g8";

// https://maps.googleapis.com/maps/api/geocode/json?address=tumkur&language=kn&key=AIzaSyCmyfqPois80RK7UTuXlL8s0RSGXxzA7g8
// https://maps.googleapis.com/maps/api/geocode/json?latlng=40.714224,-73.961452&language=kn&key=AIzaSyCmyfqPois80RK7UTuXlL8s0RSGXxzA7g8

// Future<void> searchPlaces(String input) async {
//   const baseUrl = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
//   final query = '?input=${Uri.encodeQueryComponent(input)}&key=$API_KEY';
//   final url = baseUrl + query;
//   final response = await http.get(Uri.parse(url));
//   final data = jsonDecode(response.body);
//   final results = List<Map<String, dynamic>>.from(data['results']);

//   print(data);
// }

// Future<String> fetchPlaces(
//     double lat, double lng, int radius) async {
//   final response = await http.get(
//       Uri.parse('https://maps.googleapis.com/maps/api/place/nearbysearch/json?'
//           'location=$lat,$lng'
//           '&radius=$radius'
//           '&key=$API_KEY'));

//     return response.body;
//     return jsonDecode(response.body);
// }

// void main() {
//   fetchPlaces(13.3268473, 77.1261341, 2).then((value) => print(value));
// }
