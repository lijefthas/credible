// AUTHOR: L. I. Jefthas
// DATE: October 2026
// VERSION: 0.0.2

import 'package:flutter/widgets.dart';

import 'package:credible/modules/app/app_services.dart';
import 'package:credible/modules/app/credible_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final services = await AppServices.create();
  runApp(CredibleApp(services: services));
}
