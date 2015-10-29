#include "Rstats_Vector.h"

namespace Rstats {

  template <>
  void Vector::initialize<Rstats::Double>(Rstats::Integer length) {
    this->values = new Rstats::Double[length];
    this->type = Rstats::Type::DOUBLE;
    this->length = length;
    this->na_positions = NULL;
  };

  template <>
  void Vector::initialize<Rstats::Integer>(Rstats::Integer length) {
    this->values = new Rstats::Integer[length];
    this->type = Rstats::Type::INTEGER;
    this->length = length;
    this->na_positions = NULL;
  }

  template <>
  void Vector::initialize<Rstats::Complex>(Rstats::Integer length) {
    this->values = new Rstats::Complex[length];
    this->type = Rstats::Type::COMPLEX;
    this->length = length;
    this->na_positions = NULL;
  }

  template <>
  void Vector::initialize<Rstats::Character>(Rstats::Integer length) {
    this->values = new Rstats::Character[length];
    for (Rstats::Integer i = 0; i < length; i++) {
      SV** value_ptr = (SV**)this->values;
      *(value_ptr + i) = &PL_sv_undef;
    }
    this->type = Rstats::Type::CHARACTER;
    this->length = length;
    this->na_positions = NULL;
  }

  template <>
  void Vector::initialize<Rstats::Logical>(Rstats::Integer length) {
    this->values = new Rstats::Logical[length];
    this->type = Rstats::Type::LOGICAL;
    this->length = length;
    this->na_positions = NULL;
  }
  
  template <>
  Rstats::Vector* Vector::new_vector<Rstats::Double>(Rstats::Integer length) {
    Rstats::Vector* v1 = new Rstats::Vector;
    v1->values = new Rstats::Double[length];
    v1->type = Rstats::Type::DOUBLE;
    v1->length = length;
    v1->na_positions = NULL;
    
    return v1;
  }
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
  
  void Vector::init_na_positions() {
    if (this->na_positions != NULL) {
      croak("na_postiions is already initialized");
    }
    if (this->get_length()) {
      Rstats::Integer length = this->get_na_positions_length();
      this->na_positions = new Rstats::NaPosition[length];
      std::fill_n(this->na_positions, length, 0);
    }
  }
  
  Rstats::Integer Vector::get_na_positions_length() {
    if (this->get_length() == 0) {
      return 0;
    }
    else {
      return ((this->get_length() - 1) / Rstats::NA_POSITION_BIT_LENGTH) + 1;
    }
  }

  void Vector::add_na_position(Rstats::Integer position) {
    if (this->get_na_positions() == NULL) {
      this->init_na_positions();
    }
    
    *(this->get_na_positions() + (position / Rstats::NA_POSITION_BIT_LENGTH))
      |= (1 << (position % Rstats::NA_POSITION_BIT_LENGTH));
  }

  Rstats::Logical Vector::exists_na_position(Rstats::Integer position) {
    if (this->get_na_positions() == NULL) {
      return 0;
    }
    
    return (*(this->get_na_positions() + (position / Rstats::NA_POSITION_BIT_LENGTH))
      & (1 << (position % Rstats::NA_POSITION_BIT_LENGTH)))
      ? 1 : 0;
  }

  void Vector::merge_na_positions(Rstats::NaPosition* na_positions) {
    
    if (na_positions == NULL) {
      return;
    }
    
    if (this->na_positions == NULL) {
      this->init_na_positions();
    }
    
    if (this->get_length()) {
      for (Rstats::Integer i = 0; i < this->get_na_positions_length(); i++) {
        *(this->get_na_positions() + i) |= *(na_positions + i);
      }
    }
  }

  Rstats::NaPosition* Vector::get_na_positions() {
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
    delete[] values;
    delete[] this->na_positions;
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
