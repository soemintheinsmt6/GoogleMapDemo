import 'package:flutter/material.dart';

// ignore: constant_identifier_names
const String google_api_key = "AIzaSyAxUxCsmzFbu41bu6NTVNiNQeMBVHia948";

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
