library;

export 'impl/kind.dart'
    if (dart.library.html) 'impl_web/kind.dart'; // 非 Web 和 Web 实现不同，在导入时进行区分
import 'db_manager.dart';
import 'impl/kind.dart' if (dart.library.html) 'impl_web/kind.dart';

extension DbManagerFactory on DbManagerKind {
  DbManager create() => createDbManager(this);
}
