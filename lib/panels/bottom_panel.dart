// ignore_for_file: non_constant_identifier_names, no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';

// -----------------------------------------------------------------------------------------------

Widget _textField(
    {required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required double width,
    required Icon prefixIcon,
    required Function(String) locationCallback,
    required THEME,
    required isButtonEnabled}) {
  return SizedBox(
    width: width * 0.7,
    child: TextField(
      onChanged: (value) {
        locationCallback(value);
      },
      style: TextStyle(
        color: THEME[1],
      ),
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        labelStyle: TextStyle(
          color: THEME[3],
        ),
        filled: true,
        fillColor: THEME[0],
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
          borderSide: BorderSide(
            color: THEME[0],
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
          borderSide: BorderSide(
            color: THEME[1],
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.all(15),
        hintText: hint,
        hintStyle: TextStyle(color: THEME[3]),
        suffixIcon: isButtonEnabled
            ? GestureDetector(
                onTap: () {
                  controller.clear();
                },
                child: Icon(
                  Icons.clear,
                  color: THEME[3],
                ),
              )
            : null,
      ),
      cursorColor: THEME[3],
    ),
  );
}

FloatingActionButton getGoButton(THEME, isButtonEnabled, goButtonPressed) {
  return FloatingActionButton(
    onPressed: isButtonEnabled ? (() => goButtonPressed()) : null,
    backgroundColor: isButtonEnabled ? THEME[0] : THEME[3],
    foregroundColor: THEME[1],
    child: const Icon(
      Icons.stacked_line_chart_rounded,
    ),
  );
}

Container getBottomPanel(
    THEME,
    _translations,
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
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Destination Field
          _textField(
              label: _translations!["destination"] ?? "Destination",
              hint: _translations!["cd"] ?? "Choose destination",
              prefixIcon: Icon(
                Icons.place_rounded,
                color: THEME[1],
              ),
              controller: destinationAddressController,
              focusNode: destinationAddressFocusNode,
              width: width,
              locationCallback: (String value) {
                setDestinationAddress(value);
              },
              THEME: THEME,
              isButtonEnabled: isButtonEnabled),
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

Align getTotalsPanel(THEME, _placeDuration, _placeDistance, _translations,
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
                      ? "${_placeDuration!} ${_translations != null && _translations!["sec"] != null ? _translations!["sec"]! : "sec"}"
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
                      ? "${_placeDistance!} ${_translations != null && _translations!["km"] != null ? _translations!["km"]! : "km"}"
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
