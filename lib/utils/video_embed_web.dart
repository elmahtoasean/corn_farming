import 'dart:html' as html;
import 'package:flutter/widgets.dart';
// Remove this import: import 'dart:ui' as ui;
// Add this import instead:
import 'dart:ui_web' as ui_web;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

Widget buildYoutubeEmbed(String videoId) {
  final viewType = 'youtube-embed-$videoId-${DateTime.now().microsecondsSinceEpoch}';

  // Use ui_web.platformViewRegistry instead of ui.platformViewRegistry
  ui_web.platformViewRegistry.registerViewFactory(viewType, (int _) {
    final iframe = html.IFrameElement()
      ..width = '100%'
      ..height = '100%'
      ..src = 'https://www.youtube.com/embed/$videoId?autoplay=0&enablejsapi=1'
      ..style.border = '0'
      ..allow =
          'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share'
      ..allowFullscreen = true;
    return iframe;
  });

  return HtmlElementView(viewType: viewType);
}