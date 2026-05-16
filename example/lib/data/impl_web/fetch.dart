import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart';

@JS("fetch")
external JSPromise<Response> jsFetch(URL resource, [RequestInit? options]);

Future<Uint8List> fetch(String url, [String? base]) async {
  final jsURL = base != null ? URL(url, base) : URL(url);
  final response = await jsFetch(jsURL).toDart;
  return (await response.bytes().toDart).toDart;
}

Future<Uint8List> fetchFromBase(String url) => fetch(url, Uri.base.toString());
