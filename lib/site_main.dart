import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'site/site_app.dart';

void main() {
  // Clean URLs: /site/features, /site/how-it-works, /site/plans, /site/faq.
  // The Vercel rewrite sends every /site/* path to index.html, and the
  // strategy strips the /site base href before matching a route.
  usePathUrlStrategy();
  runApp(const MarketingSiteApp());
}