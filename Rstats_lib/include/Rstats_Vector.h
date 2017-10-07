#ifndef PERL_RSTATS_VECTOR_H
#define PERL_RSTATS_VECTOR_H

#include "Rstats_ElementFunc.h"

namespace Rstats {
  
  template <class T>
  class Vector {
    private:
    
    Rstats::NaPosition* na_positions;
    T* values;
    int32_t length;
    
    public:
    
    void initialize(int32_t);
    Vector<T>(int32_t);
    Vector<T>(int32_t, T);

    int32_t get_length();
    void init_na_positions();
    void add_na_position(int32_t);
    int32_t exists_na_position(int32_t);
    Rstats::NaPosition* get_na_positions();
    int32_t get_na_positions_length();
    
    T* get_values();
    void set_value(int32_t, T); 
    T get_value(int32_t);
    
    ~Vector();
  };
}
#include "Rstats_Vector_impl.h"

#endif
