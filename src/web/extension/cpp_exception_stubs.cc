#include <cstddef>
#include <cstdlib>

extern "C" void *__cxa_allocate_exception(size_t thrown_size) { return malloc(thrown_size); }

extern "C" void __cxa_free_exception(void *thrown_exception) { free(thrown_exception); }

extern "C" void __cxa_throw(void *, void *, void (*)(void *)) { abort(); }
