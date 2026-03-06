#ifndef __MQL__
#pragma once
#endif

#include "../DictStruct.mqh"

/**
 * Stores objects to be reused using a string-based key (non-owning).
 *
 * MetaEditor build 5660 limitations:
 * - references '&' are not allowed in templates in this project configuration
 * - calling methods through pointers may break parsing
 * So we keep the static DictStruct as a local static object inside each method.
 */
template <typename C>
class Objects {
 public:
  static bool TryGet(string& key, C*& out_ptr) {
    static DictStruct<string, C*> objects;
    out_ptr = objects.GetByKey(key);
    return (out_ptr != NULL);
  }

  static C* Set(string& key, C* ptr) {
    static DictStruct<string, C*> objects;
    objects.Set(key, ptr);
    return ptr;
  }
};
