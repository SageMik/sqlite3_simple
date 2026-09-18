import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';

import 'src/source/source.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (!input.config.buildCodeAssets) return;
    await SimpleSource.fromBuild(input, output).build();
  });
}
