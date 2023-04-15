const sitLat = 13.3268473;
const sitLng = 77.1261341;

const String sitFrontGate =
    "CAoSLEFGMVFpcE1lbERDTWZ6TDFxYnV1c2dmWGlzZUcxSFNVQ0Y1b1RsY3hFbHV6";
const String adminBlock =
    "CAoSLEFGMVFpcE4tLTl2NFFuQndobjdzaXhOSFpPQlhzQkcwUUxBWF9lbVdDajdJ";
const String cseDept =
    "CAoSLEFGMVFpcE5QZG1fV1c4OUlnTmh0VEh6LXRUUjdrV3AtUWYxNUVDNEVxYUJu";
const String library =
    "CAoSLEFGMVFpcE9PQ2JWaVdRbjBQWXQtbVZMUDFDM3QtZzByU2Z1NFhPRmR0TUJy";

List<String> mapAnchors = [
  sitFrontGate, //Front Gate
  adminBlock, // Admin Block
  library, // Library
  cseDept // CS Department
];

List<String> mapNames = [
  "Front Gate",
  "Admin Block",
  "Library",
  "CS Department"
];

List<double> mapAngles = [
  90, //Front Gate
  90, // Admin Block
  225, // Library
  230 // CS Department
];
