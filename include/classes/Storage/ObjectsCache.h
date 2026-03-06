#ifndef __MQL__
#pragma once
#endif

#include "../DictStruct.mqh"

template <typename K, typename V>
class DictStructDestructable : public DictStruct<K, V*> {
 public:
  ~DictStructDestructable() {
    for (DictStructIterator<K, V*> iter = Begin(); iter.IsValid(); ++iter) {
      delete iter.Value();
    }
  }
};

template <typename C>
class ObjectsCache {
 public:
  static bool TryGet(string& key, C*& out_ptr) {
    static DictStructDestructable<string, C> objects;
    out_ptr = objects.GetByKey(key);
    return (out_ptr != NULL);
  }

  static C* Set(string& key, C* ptr) {
    static DictStructDestructable<string, C> objects;
    objects.Set(key, ptr);
    return ptr;
  }
};
