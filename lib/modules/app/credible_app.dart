// AUTHOR: L. I. Jefthas
// DATE: October 2026

import 'package:flutter/material.dart';

import '../screens/card_form_screen.dart';
import '../theme/app_theme.dart';
import 'app_services.dart';

class CredibleApp extends StatelessWidget {
  const CredibleApp({super.key, required this.services});

  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Credible',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: CardFormScreen(services: services),
    );
  }
}
