import 'package:flutter/material.dart';

const kDefaultThemeColor = Colors.deepPurple;

const kDefaultZoom = 14.0;

const _kUnderlineBorder = UnderlineInputBorder(
  borderSide: BorderSide(color: kDefaultThemeColor),
);

const kTextFieldUnderlineDecoration = InputDecoration(
  hintText: 'Enter a value',
  border: _kUnderlineBorder,
  enabledBorder: _kUnderlineBorder,
  focusedBorder: _kUnderlineBorder,
);
