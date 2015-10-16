#include "Rstats.h"

namespace Rstats {

  Rstats::Type::Enum get_type {
    return this->type;
  }
  
  Rstats::Integer Vector::get_length() {
    if (this->values == NULL) {
      return 0;
    }
    
    Rstats::Type::Enum type = this->get_type();
    switch (type) {
      case Rstats::Type::CHARACTER :
        return this->get_values<Rstats::Character>->size();
      case Rstats::Type::COMPLEX :
        return this->get_values<Rstats::Complex>->size();
      case Rstats::Type::DOUBLE :
        return this->get_values<Rstats::Double>->size();
      case Rstats::Type::INTEGER :
      case Rstats::Type::LOGICAL :
        return this->get_values<Rstats::Integer>->size();
    }
  }
}
