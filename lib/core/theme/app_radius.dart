import 'package:flutter/material.dart';

abstract class AppRadius {
  // From Figma
  static const double xs = 4;
  static const double sm = 8;
  static const double input = 12;    // input fields
  static const double card = 16;     // general cards
  static const double cardLarge = 20; // balance card on home
  static const double sheet = 24;    // bottom sheets, main content card on sign up
  static const double screen = 32;   // screen-level frame radius in Figma
  static const double full = 100;    // buttons (stadium), pills, tags

  static const BorderRadius radiusXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius radiusInput = BorderRadius.all(Radius.circular(input));
  static const BorderRadius radiusCard = BorderRadius.all(Radius.circular(card));
  static const BorderRadius radiusCardLarge = BorderRadius.all(Radius.circular(cardLarge));
  static const BorderRadius radiusSheet = BorderRadius.all(Radius.circular(sheet));
  static const BorderRadius radiusFull = BorderRadius.all(Radius.circular(full));

  static const BorderRadius radiusSheetTop = BorderRadius.vertical(
    top: Radius.circular(sheet),
  );
}
