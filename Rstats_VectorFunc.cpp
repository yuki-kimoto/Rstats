#include "Rstats.h"

// Rstats::VectorFunc
namespace Rstats {
  namespace VectorFunc {

    template <>
    Rstats::Vector* new_vector<Rstats::Double>(Rstats::Size length) {
      Rstats::Vector* v1 = new Rstats::Vector;
      v1->na_positions = new std::map<Rstats::Size, Rstats::Integer>;
      v1->values = new std::vector<Rstats::Double>(length);
      v1->type = Rstats::Type::DOUBLE;
      
      return v1;
    };

    template <>
    Rstats::Vector* new_vector<Rstats::Integer>(Rstats::Size length) {
      Rstats::Vector* v1 = new Rstats::Vector;
      v1->na_positions = new std::map<Rstats::Size, Rstats::Integer>;
      v1->values = new std::vector<Rstats::Integer>(length);
      v1->type = Rstats::Type::INTEGER;
      
      return v1;
    }

    template <>
    Rstats::Vector* new_vector<Rstats::Complex>(Rstats::Size length) {
      Rstats::Vector* v1 = new Rstats::Vector;
      v1->na_positions = new std::map<Rstats::Size, Rstats::Integer>;
      v1->values = new std::vector<Rstats::Complex>(length);
      v1->type = Rstats::Type::COMPLEX;
      
      return v1;
    }

    template <>
    Rstats::Vector* new_vector<Rstats::Character>(Rstats::Size length) {
      Rstats::Vector* v1 = new Rstats::Vector;
      v1->na_positions = new std::map<Rstats::Size, Rstats::Integer>;
      v1->values = new std::vector<Rstats::Character>(length);
      v1->type = Rstats::Type::CHARACTER;
      
      return v1;
    }

    template <>
    Rstats::Vector* new_vector<Rstats::Logical>(Rstats::Size length) {
      Rstats::Vector* v1 = new Rstats::Vector;
      v1->na_positions = new std::map<Rstats::Size, Rstats::Integer>;
      v1->values = new std::vector<Rstats::Logical>(length);
      v1->type = Rstats::Type::LOGICAL;
      
      return v1;
    }
  }
}
