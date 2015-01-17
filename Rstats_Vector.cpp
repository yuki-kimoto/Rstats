#include "Rstats.h"

Rstats::Vector::~Vector () {
  IV length = Rstats::VectorFunc::get_length(this);
  
  Rstats::VectorType::Enum type = Rstats::VectorFunc::get_type(this);
  switch (type) {
    case Rstats::VectorType::CHARACTER : {
      std::vector<SV*>* values = Rstats::VectorFunc::get_character_values(this);
      for (IV i = 0; i < length; i++) {
        if ((*values)[i] != NULL) {
          SvREFCNT_dec((*values)[i]);
        }
      }
      delete values;
      break;
    }
    case Rstats::VectorType::COMPLEX : {
      std::vector<std::complex<NV> >* values = Rstats::VectorFunc::get_complex_values(this);
      delete values;
      break;
    }
    case Rstats::VectorType::DOUBLE : {
      std::vector<NV>* values = Rstats::VectorFunc::get_double_values(this);
      delete values;
      break;
    }
    case Rstats::VectorType::INTEGER :
    case Rstats::VectorType::LOGICAL : {
      std::vector<IV>* values = Rstats::VectorFunc::get_integer_values(this);
      delete values;
    }
  }
  delete na_positions;
}

