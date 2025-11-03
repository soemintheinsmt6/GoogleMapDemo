import 'package:flutter/material.dart';

const kDefaultThemeColor = Colors.deepPurple;

const kUnderlineColor = Colors.deepPurple;

const kTextFieldUnderlineDecoration = InputDecoration(
  hintText: 'Enter a value',
  border: UnderlineInputBorder(
    borderSide: BorderSide(
      color: kUnderlineColor,
    ),
  ),
  enabledBorder: UnderlineInputBorder(
    borderSide: BorderSide(
      color: kUnderlineColor,
    ),
  ),
  focusedBorder: UnderlineInputBorder(
    borderSide: BorderSide(
      color: kUnderlineColor,
    ),
  ),
);


