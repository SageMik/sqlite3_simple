#ifndef CSIMPLE_H
#define CSIMPLE_H

#ifdef __cplusplus
extern "C" {
#endif

int sqlite3_simple_init(void *db, char **pzErrMsg, const void *pApi);

#ifdef __cplusplus
}
#endif

#endif
