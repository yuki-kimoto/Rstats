#include "Rstats.h"

namespace Rstats {

  template <>
  Rstats::Vector* Vector::new_vector<Rstats::Double>(Rstats::Integer length) {
    Rstats::Vector* v1 = new Rstats::Vector;
    v1->values = new Rstats::Double[length];
    v1->type = Rstats::Type::DOUBLE;
    v1->length = length;
    v1->na_positions = NULL;
    
    return v1;
  };

  template <>
  Rstats::Vector* Vector::new_vector<Rstats::Integer>(Rstats::Integer length) {
    Rstats::Vector* v1 = new Rstats::Vector;
    v1->values = new Rstats::Integer[length];
    v1->type = Rstats::Type::INTEGER;
    v1->length = length;
    v1->na_positions = NULL;
    
    return v1;
  }

  template <>
  Rstats::Vector* Vector::new_vector<Rstats::Complex>(Rstats::Integer length) {
    Rstats::Vector* v1 = new Rstats::Vector;
    v1->values = new Rstats::Complex[length];
    v1->type = Rstats::Type::COMPLEX;
    v1->length = length;
    v1->na_positions = NULL;
    
    return v1;
  }

  template <>
  Rstats::Vector* Vector::new_vector<Rstats::Character>(Rstats::Integer length) {
    Rstats::Vector* v1 = new Rstats::Vector;
    v1->values = new Rstats::Character[length];
    for (Rstats::Integer i = 0; i < length; i++) {
      SV** value_ptr = (SV**)v1->values;
      *(value_ptr + i) = &PL_sv_undef;
    }
    v1->type = Rstats::Type::CHARACTER;
    v1->length = length;
    v1->na_positions = NULL;
    
    return v1;
  }

  template <>
  Rstats::Vector* Vector::new_vector<Rstats::Logical>(Rstats::Integer length) {
    Rstats::Vector* v1 = new Rstats::Vector;
    v1->values = new Rstats::Logical[length];
    v1->type = Rstats::Type::LOGICAL;
    v1->length = length;
    v1->na_positions = NULL;
    
    return v1;
  }
    
  void Vector::add_na_position(Rstats::Integer position) {
    
    if (this->na_positions == NULL) {
      this->na_positions = new Rstats::NaPositions;
    }
    this->na_positions->insert(position);
  }

  Rstats::Logical Vector::exists_na_position(Rstats::Integer position) {
    if (this->na_positions == NULL) {
      return 0;
    }
    
    return this->na_positions->count(position);
  }

  void Vector::merge_na_positions(Rstats::NaPositions* na_positions) {
    
    if (na_positions == NULL) {
      return;
    }
    
    if (this->na_positions == NULL) {
      this->na_positions = new Rstats::NaPositions;
    }
    
    for(Rstats::NaPositions::iterator it = na_positions->begin(); it != na_positions->end(); ++it) {
      this->add_na_position(*it);
    }
  }

  Rstats::NaPositions* Vector::get_na_positions() {
    return this->na_positions;
  }

  template <>
  void Vector::set_value<Rstats::Character>(Rstats::Integer pos, Rstats::Character value) {
    SV* current_value = *(this->get_values<Rstats::Character>() + pos);
    
    if (SvOK(current_value)) {
      SvREFCNT_dec(current_value);
    }
    
    *(this->get_values<Rstats::Character>() + pos) = SvREFCNT_inc(value);
  }

  Rstats::Integer Vector::get_length() {
    return this->length;
  }
  
  template<>
  void Vector::delete_vector<Rstats::Character>() {

    Rstats::Character* values = this->get_values<Rstats::Character>();
    Rstats::Integer length = this->get_length();
    for (Rstats::Integer i = 0; i < length; i++) {
      if (*(values + i) != NULL) {
        SvREFCNT_dec(*(values + i));
      }
    }
    delete values;
    delete this->na_positions;
  }
  
  Vector::~Vector() {
    
    Rstats::Type::Enum type = this->type;
    
    switch (type) {
      case Rstats::Type::CHARACTER : {
        this->delete_vector<Rstats::Character>();
        break;
      }
      case Rstats::Type::COMPLEX : {
        this->delete_vector<Rstats::Complex>();
        break;
      }
      case Rstats::Type::DOUBLE : {
        this->delete_vector<Rstats::Double>();
        break;
      }
      case Rstats::Type::INTEGER : {
        this->delete_vector<Rstats::Integer>();
        break;
      }
      case Rstats::Type::LOGICAL : {
        this->delete_vector<Rstats::Logical>();
        break;
      }
    }
  }
}
