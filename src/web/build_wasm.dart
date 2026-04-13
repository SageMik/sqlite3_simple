// dart pub get && dart run build_wasm.dart --wasi-sdk=... [--binaryen=...]
// 仅支持命名参数。传入 binaryen 时将其 bin 前置到 PATH 供 cmake。需要 git、cmake。

import 'dart:io';

import 'package:args/args.dart';
import 'package:process_run/process_run.dart';

Future<void> main(List<String> argv) async {
  final parser = ArgParser()
    ..addOption('wasi-sdk',
        help:
            '用于编译 Wasm 的 WASI SDK 根目录，必填。可从 https://github.com/WebAssembly/wasi-sdk 下载')
    ..addOption('binaryen',
        help:
            '用于优化 Wasm 的 binaryen 根目录，可选。可从 https://github.com/WebAssembly/binaryen 下载');

  final BuildWasmArgs args;
  try {
    args = parser.parseAndCheck(argv);
  } on Exception catch (e) {
    stderr.writeln('${e}');
    usage(parser);
    return;
  }
  final BuildWasmArgs(:wasiSdk, :binaryen) = args;

  final sysroot = '$wasiSdk/share/wasi-sysroot';
  final clang = '$wasiSdk/bin/clang';
  final clang_xx = '$wasiSdk/bin/clang++';
  Map<String, String>? binaryenEnv;
  if (binaryen.isNotEmpty) {
    final head = '$binaryen/bin';
    final sep = Platform.isWindows ? ';' : ':';
    final tail =
        Platform.environment['PATH'] ?? Platform.environment['Path'] ?? '';
    final path = '$head$sep$tail';
    binaryenEnv = Map<String, String>.from(Platform.environment);
    if (Platform.isWindows) {
      binaryenEnv['Path'] = path;
    }
    binaryenEnv['PATH'] = path;
  }

  stdout.writeln('''
  
    wasi-sysroot    $sysroot
    clang           $clang
    clang++         $clang_xx
  ''');

  final shell = Shell(
    options: ShellOptions(
      verbose: true,
      stdout: stdout,
      stderr: stderr,
      environment: binaryenEnv,
      mode: Platform.isWindows
          ? ProcessStartMode.inheritStdio
          : ProcessStartMode.normal,
    ),
  );

  await shell.runScript(
    '''
      git apply ../sqlite3_wasm_build.patch
      git add sqlite3 sqlite3_wasm_build
    ''',
    workingDirectory: 'sqlite3.dart',
  );

  const buildDir = '.dart_tool/sqlite3_build';
  await shell.runScript(
    '''
      cmake -S ./src -B $buildDir -Dwasi_sysroot=$sysroot -Dclang=$clang -Dclangxx=$clang_xx -DSIMPLE_WITH_JIEBA=ON -DFETCHCONTENT_QUIET=OFF
      cmake --build $buildDir -t output -j
    ''',
    workingDirectory: 'sqlite3.dart/sqlite3_wasm_build',
  );
}

void usage([ArgParser? parser]) {
  stderr.writeln(
    '用法：dart run build_wasm.dart --wasi-sdk=<路径> [--binaryen=<路径>]\n'
    '${parser != null ? '\n${parser.usage}' : ''}',
  );
  exit(64);
}

class BuildWasmArgs {
  final String wasiSdk;
  final String binaryen;

  BuildWasmArgs({required this.wasiSdk, required this.binaryen});
}

extension ArgParserEx on ArgParser {
  BuildWasmArgs parseAndCheck(Iterable<String> args) {
    final ar;
    try {
      ar = parse(args);
    } on Exception catch (e) {
      throw Exception('参数解析失败：${e}');
    }
    final wasiSdkRaw = ar['wasi-sdk'] as String?;
    if (ar.rest.isNotEmpty) {
      throw Exception('无法识别的参数：${ar.rest.join(' ')}');
    }
    if (wasiSdkRaw == null || wasiSdkRaw.isEmpty) {
      throw Exception('缺少必填参数：--wasi-sdk=<路径>');
    }
    final binaryenRaw = ar['binaryen'] as String?;
    if (binaryenRaw == null || binaryenRaw.isEmpty) {
      bool onPath(String cmd) {
        if (Platform.isWindows) {
          final r = Process.runSync(
            'where',
            [cmd],
            runInShell: true,
            environment: Platform.environment,
          );
          return r.exitCode == 0;
        }
        final r = Process.runSync(
          'sh',
          ['-c', 'command -v ${cmd.replaceAll("'", "'\\''")}'],
          environment: Platform.environment,
        );
        return r.exitCode == 0;
      }

      const tools = ['wasm-opt', 'wasm-ctor-eval'];
      final missing = <String>[];
      for (final name in tools) {
        if (!onPath(name)) {
          missing.add(name);
        }
      }
      if (missing.isNotEmpty) {
        throw Exception(
          '未在 PATH 中找到 binaryen 工具：${missing.join(', ')}，\n'
          '请将 binaryen 的 bin 加入 PATH，或使用 --binaryen=<路径>',
        );
      }
    }
    return BuildWasmArgs(
      wasiSdk: wasiSdkRaw,
      binaryen: binaryenRaw == null || binaryenRaw.isEmpty ? '' : binaryenRaw,
    );
  }
}

extension ShellEx on Shell {
  /// 必须用 [Shell.run]（或带同一套 options 的 [run]），不能用包顶层 [run]，否则会新建默认 Shell，丢掉 stdout/stderr/encoding/environment。
  Future<void> runScript(String script, {String? workingDirectory}) async {
    try {
      final sh = workingDirectory != null ? cd(workingDirectory) : this;
      await sh.run(script);
    } on ShellException {}
  }
}
