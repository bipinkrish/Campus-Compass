// ignore_for_file: non_constant_identifier_names, no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;
import 'package:campusmap/views/search_page.dart' show SearchPage;

// -----------------------------------------------------------------------------------------------

FloatingActionButton getGoButton(THEME, isButtonEnabled, goButtonPressed) {
  return FloatingActionButton(
    onPressed: isButtonEnabled ? (() => goButtonPressed()) : null,
    backgroundColor: isButtonEnabled ? THEME[0] : THEME[3],
    foregroundColor: THEME[1],
    child: isButtonEnabled
        ? Image.asset(
            "assets/logos/logoanim.gif",
            width: 35,
          )
        : SvgPicture.asset(
            "assets/logos/logo.svg",
            width: 42,
          ),
  );
}

Container getBottomPanel(
    THEME,
    translations,
    destinationAddressController,
    destinationAddressFocusNode,
    width,
    isButtonEnabled,
    setDestinationAddress,
    goButtonPressed,
    BuildContext context) {
  return Container(
    alignment: Alignment.bottomCenter,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Destination Field
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchPage(
                    controller: destinationAddressController,
                    focusNode: destinationAddressFocusNode,
                    locationCallback: (String value, double lat, double lng) {
                      setDestinationAddress(value, lat, lng);
                    },
                    THEME: THEME,
                    translations: translations,
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: width * 0.7,
                height: destinationAddressController.text.isEmpty ||
                        destinationAddressController.text.length <= 40
                    ? 50
                    : 60,
                color: THEME[0],
                child: ListTile(
                  dense: true,
                  // leading: Icon(
                  //   Icons.place_rounded,
                  //   color: THEME[1],
                  // ),
                  title: destinationAddressController.text.isEmpty
                      ? Text(
                          translations!["destination"] ?? "Destination",
                          style: TextStyle(
                            color: THEME[3],
                            fontSize: 16,
                          ),
                        )
                      : Text(
                          destinationAddressController.text,
                          style: TextStyle(
                            color: THEME[1],
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ),
          // Go button
          getGoButton(
            THEME,
            isButtonEnabled,
            goButtonPressed,
          )
        ],
      ),
    ),
  );
}

// -----------------------------------------------------------------------------------------------

Align getTotalsPanel(THEME, _placeDuration, _placeDistance, translations,
    destinationAddressFocus) {
  return Align(
    alignment: const Alignment(0, 0.8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Total Duration
        Visibility(
          visible: (_placeDuration != null) && (!destinationAddressFocus),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: ColoredBox(
              color: THEME[0],
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _placeDuration != null
                      ? "${_placeDuration!} ${translations != null && translations!["sec"] != null ? translations!["sec"]! : "sec"}"
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
        // Total Distance
        Visibility(
          visible: (_placeDistance != null) && (!destinationAddressFocus),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: ColoredBox(
              color: THEME[0],
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _placeDistance != null
                      ? "${_placeDistance!} ${translations != null && translations!["km"] != null ? translations!["km"]! : "km"}"
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
  );
}
