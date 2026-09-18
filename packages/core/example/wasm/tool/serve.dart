import 'dart:io';

Future<void> main() async {
  final root = File(Platform.script.toFilePath()).parent.parent.path;
  final web = Directory('$root${Platform.pathSeparator}web');

  final compile = await Process.run(
    Platform.resolvedExecutable,
    ['compile', 'js', 'web/main.dart', '-o', 'web/main.dart.js', '-O4'],
    workingDirectory: root,
  );
  if (compile.exitCode != 0) {
    stderr.write('${compile.stderr}\n编译失败（exit code ${compile.exitCode}）');
    exit(compile.exitCode);
  }

  var port = 8000;
  HttpServer? server;
  while (server == null && port < 8100) {
    try {
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    } on SocketException {
      port++; // 端口被占用，试下一个
    }
  }
  if (server == null) {
    stderr.writeln('8000 ~ 8099 均被占用');
    exit(1);
  }
  stdout.writeln('  http://localhost:${server.port}');

  await for (final request in server) {
    final response = request.response;
    final path = request.uri.path == '/' ? '/index.html' : request.uri.path;
    final file = File('${web.path}$path');
    if (!file.path.startsWith(web.path) || !file.existsSync()) {
      response.statusCode = HttpStatus.notFound;
      await response.close();
      continue;
    }
    response.headers.set(
      'Content-Type',
      switch (file.path.split('.').last) {
        'wasm' => 'application/wasm',
        'js' => 'text/javascript; charset=utf-8',
        'css' => 'text/css; charset=utf-8',
        'html' => 'text/html; charset=utf-8',
        _ => 'application/octet-stream',
      },
    );
    await response.addStream(file.openRead());
    await response.close();
  }
}
