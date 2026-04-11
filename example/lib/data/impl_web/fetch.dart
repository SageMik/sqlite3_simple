import 'dart:js_interop';

import 'package:web/web.dart';

@JS()
external JSPromise<Response> fetch(URL resource, [RequestInit? options]);
