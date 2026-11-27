// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

void openExternal(String url) => html.window.open(url, '_blank');

void openInternal(String url) => html.window.location.assign(url);