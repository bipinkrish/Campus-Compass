// ignore_for_file: non_constant_identifier_names, no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' show Geolocator, LocationPermission;
import 'package:cached_network_image/cached_network_image.dart'
    show CachedNetworkImageProvider;

// -----------------------------------------------------------------------------------------------

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

FloatingActionButton getMyLoactionButton(THEME, moveToCurrentLocation) {
  return FloatingActionButton(
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
        moveToCurrentLocation();
      }
    },
  );
}

// ---------------------------------------------------------------------------------------

FloatingActionButton getMapTypeButton(
    THEME, mapTypeIcons, _choseMapType, BuildContext context, setChoseMapType) {
  return FloatingActionButton(
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
                for (var entry
                    in ["Normal", "Satellite", "Terrain"].asMap().entries)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FloatingActionButton(
                        backgroundColor: THEME[0],
                        onPressed: () {
                          if (_choseMapType != entry.key) {
                            Navigator.pop(context);
                            setChoseMapType(entry.key);
                          }
                        },
                        shape: _choseMapType == entry.key
                            ? RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(width: 2, color: THEME[3]),
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
  );
}

// ------------------------------------------------------------------------------------------

Expanded _buildMapStyleButton(String label, int index, _choseMapStyle, THEME,
    BuildContext context, setChoseMapStyle) {
  return Expanded(
    child: InkWell(
      onTap: () {
        if (_choseMapStyle != index) {
          Navigator.pop(context);
          setChoseMapStyle(index);
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: _choseMapStyle == index ? THEME[3] : Colors.transparent,
                width: 2,
              ),
            ),
            child: Padding(
              padding: _choseMapStyle == index
                  ? const EdgeInsets.all(2)
                  : EdgeInsets.zero,
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
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: THEME[1],
              fontWeight:
                  _choseMapStyle == index ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    ),
  );
}

Visibility getMapStylesButton(THEME, _choseMapType, _choseMapStyle,
    BuildContext context, setChoseMapStyle) {
  return Visibility(
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
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (var entry in [
                        "Standard",
                        "Silver",
                        "Retro",
                      ].asMap().entries)
                        _buildMapStyleButton(entry.value, entry.key,
                            _choseMapStyle, THEME, context, setChoseMapStyle),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (var entry in [
                        "Dark",
                        "Night",
                        "Aubergine",
                      ].asMap().entries)
                        _buildMapStyleButton(entry.value, entry.key + 3,
                            _choseMapStyle, THEME, context, setChoseMapStyle),
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
  );
}
