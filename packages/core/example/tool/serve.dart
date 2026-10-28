import 'dart:io';

/// URL 首段挂载到 web 根之外的目录（monorepo 内共享资产）。
const _mounts = {'cpp_jieba_dict': '../../flutter/assets/cpp_jieba_dict'};

const _contentTypes = {
  'wasm': 'application/wasm',
  'js': 'text/javascript; charset=utf-8',
  'css': 'text/css; charset=utf-8',
  'html': 'text/html; charset=utf-8',
};

Future<void> main() async {
  final root = File(Platform.script.toFilePath()).parent.parent.path;

  final compile = await Process.run(
    Platform.resolvedExecutable,
    ['compile', 'js', 'web/main.dart', '-o', 'web/main.dart.js', '-O4'],
    workingDirectory: root,
  );
  if (compile.exitCode != 0) {
    stderr.write('${compile.stderr}\n编译失败（exit code ${compile.exitCode}）');
    exit(compile.exitCode);
  }

  final bases = {
    '': Directory('$root/web').resolveSymbolicLinksSync(),
    for (final MapEntry(key: mount, value: target) in _mounts.entries)
      mount: Directory('$root/$target').resolveSymbolicLinksSync(),
  };
  final server = await _bind();
  stdout.writeln('  http://localhost:${server.port}');

  await for (final request in server) {
    try {
      await _serve(request, bases);
    } on IOException {
      // 客户端提前断开等 IO 错误，不中断服务
    }
  }
}

Future<HttpServer> _bind() async {
  for (var port = 8000; port < 8100; port++) {
    try {
      return await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    } on SocketException {
      // 端口被占用，试下一个
    }
  }
  stderr.writeln('8000 ~ 8099 均被占用');
  exit(1);
}

Future<void> _serve(HttpRequest request, Map<String, String> bases) async {
  final response = request.response;
  if (request.method != 'GET' && request.method != 'HEAD') {
    response.statusCode = HttpStatus.methodNotAllowed;
    await response.close();
    return;
  }

  final segments = _normalize(request.uri.pathSegments);
  if (segments == null) {
    response.statusCode = HttpStatus.badRequest;
    await response.close();
    return;
  }

  // 首段命中挂载表时从挂载目录取文件，其余从 web 根取
  final mount = segments.isNotEmpty && _mounts.containsKey(segments.first) ? segments.first : '';
  final rest = mount.isEmpty ? segments : segments.sublist(1);
  final file = File([
    bases[mount]!,
    if (rest.isEmpty) 'index.html' else ...rest,
  ].join(Platform.pathSeparator));

  if (FileSystemEntity.typeSync(file.path) != FileSystemEntityType.file) {
    response.statusCode = HttpStatus.notFound;
    await response.close();
    return;
  }

  response.headers
      .set('Content-Type', _contentTypes[file.path.split('.').last] ?? 'application/octet-stream');
  response.contentLength = file.lengthSync();
  if (request.method == 'GET') {
    await response.addStream(file.openRead());
  }
  await response.close();
}

List<String>? _normalize(List<String> segments) {
  final result = <String>[];
  for (final segment in segments) {
    if (segment.isEmpty || segment == '.') continue;
    if (segment == '..') {
      if (result.isEmpty) return null;
      result.removeLast();
    } else if (segment.contains('/') || segment.contains('\\')) {
      return null;
    } else {
      result.add(segment);
    }
  }
  return result;
}
