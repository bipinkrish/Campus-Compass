// ignore_for_file: non_constant_identifier_names, no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';

// -----------------------------------------------------------------------------------------------

Container getMiddlePanel(
    THEME, _curRoute, _curManeuver, _nxtDuration, _nxtDistance, _translations) {
  return Container(
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
                          ? Icon(Icons.straight_rounded, color: THEME[1])
                          : _curManeuver == "straight"
                              ? Icon(Icons.straight_rounded, color: THEME[1])
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
  );
}
