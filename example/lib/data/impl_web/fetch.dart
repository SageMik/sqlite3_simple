import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart';

@JS()
external JSPromise<Response> fetch(URL resource, [RequestInit? options]);

/// 用于在 Worker 中读取结巴分词字典文件
Future<Uint8List> fetchFromBase(String url) async {
  final response = await fetch(URL(url, Uri.base.toString())).toDart;
  return (await response.bytes().toDart).toDart;
}