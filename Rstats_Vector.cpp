#include "Rstats.h"

namespace Rstats {

  template <>
  Rstats::Vector* Vector::new_vector<Rstats::Double>(Rstats::Integer length) {
    Rstats::Vector* v1 = new Rstats::Vector;
    v1->na_positions = new Rstats::NaPositions;
    v1->values = new std::vector<Rstats::Double>(length);
    v1->type = Rstats::Type::DOUBLE;
    
    return v1;
  };

  template <>
  Rstats::Vector* Vector::new_vector<Rstats::Integer>(Rstats::Integer length) {
    Rstats::Vector* v1 = new Rstats::Vector;
    v1->na_positions = new Rstats::NaPositions;
    v1->values = new std::vector<Rstats::Integer>(length);
    v1->type = Rstats::Type::INTEGER;
    
    return v1;
  }

  template <>
  Rstats::Vector* Vector::new_vector<Rstats::Complex>(Rstats::Integer length) {
    Rstats::Vector* v1 = new Rstats::Vector;
    v1->na_positions = new Rstats::NaPositions;
    v1->values = new std::vector<Rstats::Complex>(length);
    v1->type = Rstats::Type::COMPLEX;
    
    return v1;
  }

  template <>
  Rstats::Vector* Vector::new_vector<Rstats::Character>(Rstats::Integer length) {
    Rstats::Vector* v1 = new Rstats::Vector;
    v1->na_positions = new Rstats::NaPositions;
    v1->values = new std::vector<Rstats::Character>(length, &PL_sv_undef);
    v1->type = Rstats::Type::CHARACTER;
    
    return v1;
  }

  template <>
  Rstats::Vector* Vector::new_vector<Rstats::Logical>(Rstats::Integer length) {
    Rstats::Vector* v1 = new Rstats::Vector;
    v1->na_positions = new Rstats::NaPositions;
    v1->values = new std::vector<Rstats::Logical>(length);
    v1->type = Rstats::Type::LOGICAL;
    
    return v1;
  }
    
  void Vector::add_na_position(Rstats::Integer position) {
    this->na_positions->insert(position);
  }

  Rstats::Logical Vector::exists_na_position(Rstats::Integer position) {
    return this->na_positions->count(position);
  }

  void Vector::merge_na_positions(Rstats::NaPositions* na_positions) {
    for(Rstats::NaPositions::iterator it = na_positions->begin(); it != na_positions->end(); ++it) {
      this->add_na_position(*it);
    }
  }

  Rstats::NaPositions* Vector::get_na_positions() {
    return this->na_positions;
  }

  template <>
  void Vector::set_value<Rstats::Character>(Rstats::Integer pos, Rstats::Character value) {
    SV* current_value = (*this->get_values<Rstats::Character>())[pos];
    
    if (SvOK(current_value)) {
      SvREFCNT_dec(current_value);
    }
    
    (*this->get_values<Rstats::Character>())[pos] = SvREFCNT_inc(value);
  }

  Rstats::Type::Enum Vector::get_type() {
    return this->type;
  }
  
  Rstats::Integer Vector::get_length() {
    if (this->values == NULL) {
      return 0;
    }
    
    Rstats::Type::Enum type = this->get_type();
    switch (type) {
      case Rstats::Type::CHARACTER :
        return this->get_values<Rstats::Character>()->size();
      case Rstats::Type::COMPLEX :
        return this->get_values<Rstats::Complex>()->size();
      case Rstats::Type::DOUBLE :
        return this->get_values<Rstats::Double>()->size();
      case Rstats::Type::INTEGER :
      case Rstats::Type::LOGICAL :
        return this->get_values<Rstats::Integer>()->size();
    }
  }

  Vector::~Vector() {
    
    Rstats::Type::Enum type = this->get_type();
    
    if (this->values != NULL){ 
      switch (type) {
        case Rstats::Type::CHARACTER : {
          std::vector<Rstats::Character>* values = this->get_values<Rstats::Character>();
          Rstats::Integer length = this->get_values<Rstats::Character>()->size();
          for (Rstats::Integer i = 0; i < length; i++) {
            if ((*values)[i] != NULL) {
              SvREFCNT_dec((*values)[i]);
            }
          }
          delete values;
          break;
        }
        case Rstats::Type::COMPLEX : {
          std::vector<Rstats::Complex >* values = this->get_values<Rstats::Complex>();
          delete values;
          break;
        }
        case Rstats::Type::DOUBLE : {
          std::vector<Rstats::Double>* values = this->get_values<Rstats::Double>();
          delete values;
          break;
        }
        case Rstats::Type::INTEGER :
        case Rstats::Type::LOGICAL : {
          std::vector<Rstats::Integer>* values = this->get_values<Rstats::Integer>();
          delete values;
        }
      }
    }
    
    delete this->na_positions;
  }
}
