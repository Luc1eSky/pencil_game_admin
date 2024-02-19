import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

/// converter to save DateTime objects as Timestamps in JSON
class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) {
    return timestamp.toDate();
  }

  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDate(date);
}

/// helper function to generate a random 6 letter/digit code
String generateRandomCode({bool isUserCode = false}) {
  Random random = Random();

  // user codes only have letters; all other codes have 1 to 3 digits
  final digitCount = isUserCode ? 0 : random.nextInt(2) + 1;
  final letterCount = 6 - digitCount;

  // Generate random letters (using ASCII code for uppercase letters)
  String letters = String.fromCharCodes(List.generate(letterCount, (_) => random.nextInt(26) + 65));

  // Generate random digits (using ASCII code for digits)
  String digits = String.fromCharCodes(List.generate(digitCount, (_) => random.nextInt(10) + 48));

  // Combine letters and digits
  String randomCode = letters + digits;

  return randomCode;
}
