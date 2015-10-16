#include "Rstats.h"

namespace Rstats {

  template<>
  Rstats::Character Vector::get_value<Rstats::Character>(IV pos) {
    Rstats::Character value = (*this->get_values<Rstats::Character>())[pos];
    if (value == NULL) {
      return NULL;
    }
    else {
      return Rstats::pl_new_sv_sv(value);
    }
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
    
    Rstats::Type::Enum type = Rstats::VectorFunc::get_type(this);
    
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
