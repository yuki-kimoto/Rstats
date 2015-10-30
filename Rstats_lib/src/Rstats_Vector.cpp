#include "Rstats_Vector.h"

namespace Rstats {
  template <>
  Rstats::Vector<Rstats::Character>* Vector<Rstats::Character>::new_vector(Rstats::Integer length) {
    Rstats::Vector* v1 = new Rstats::Vector;
    v1->values = new Rstats::Character[length];
    for (Rstats::Integer i = 0; i < length; i++) {
      SV** value_ptr = (SV**)v1->values;
      *(value_ptr + i) = &PL_sv_undef;
    }
    v1->length = length;
    v1->na_positions = NULL;
    
    return v1;
  }

  template <>
  void Vector<Rstats::Character>::set_value(Rstats::Integer pos, Rstats::Character value) {
    SV* current_value = *(this->get_values() + pos);
    
    if (SvOK(current_value)) {
      SvREFCNT_dec(current_value);
    }
    
    *(this->get_values() + pos) = SvREFCNT_inc(value);
  }

  template<>
  Vector<Rstats::Character>::~Vector() {

    Rstats::Character* values = this->get_values();
    Rstats::Integer length = this->get_length();
    for (Rstats::Integer i = 0; i < length; i++) {
      if (*(values + i) != NULL) {
        SvREFCNT_dec(*(values + i));
      }
    }
    delete[] values;
    delete[] this->na_positions;
  }
  

}
