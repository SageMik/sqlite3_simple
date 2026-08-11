#include <CSimple/CSimple.h>

// 由于编译期没有 Swift/ObjC 代码调用 Simple 原生库，
// 链接器会将 `sqlite3_simple_init` 视为未使用而进行 dead-strip，导致 Flutter 层 SQLite 无法加载 Simple 扩展。
// 为此，强制链接器从拉取 sqlite3_simple_init，保证即使是 Release 模式也不会 dead-strip 。
__attribute__((used, visibility("default")))
void *const sqlite3_simple_init_anchor = (void *)&sqlite3_simple_init;
