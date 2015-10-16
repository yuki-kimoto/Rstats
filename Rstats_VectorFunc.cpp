#include "Rstats.h"

// Rstats::VectorFunc
namespace Rstats {
  namespace VectorFunc {

    Rstats::Integer get_length (Rstats::Vector* v1) {
      if (v1->values == NULL) {
        return 0;
      }
      
      Rstats::Type::Enum type = v1->get_type();
      switch (type) {
        case Rstats::Type::CHARACTER :
          return v1->get_values<Rstats::Character>()->size();
        case Rstats::Type::COMPLEX :
          return v1->get_values<Rstats::Complex>()->size();
        case Rstats::Type::DOUBLE :
          return v1->get_values<Rstats::Double>()->size();
        case Rstats::Type::INTEGER :
        case Rstats::Type::LOGICAL :
          return v1->get_values<Rstats::Integer>()->size();
      }
    }

    void add_na_position(Rstats::Vector* v1, Rstats::Integer position) {
      (*v1->na_positions)[position] = 1;
    }

    bool exists_na_position(Rstats::Vector* v1, Rstats::Integer position) {
      return v1->na_positions->count(position);
    }

    void merge_na_positions(Rstats::Vector* v2, Rstats::Vector* v1) {
      for(std::map<Rstats::Integer, Rstats::Integer>::iterator it = v1->na_positions->begin(); it != v1->na_positions->end(); ++it) {
        Rstats::VectorFunc::add_na_position(v2, it->first);
      }
    }

    std::map<Rstats::Integer, Rstats::Integer>* get_na_positions(Rstats::Vector* v1) {
      return v1->na_positions;
    }

    Rstats::Vector* new_empty_vector() {
      Rstats::Vector* v1 = new Rstats::Vector;
      v1->na_positions = new std::map<Rstats::Integer, Rstats::Integer>;
      
      return v1;
    }

    template <>
    Rstats::Vector* new_vector<Rstats::Double>(Rstats::Integer length) {
      Rstats::Vector* v1 = new_empty_vector();
      v1->values = new std::vector<Rstats::Double>(length);
      v1->type = Rstats::Type::DOUBLE;
      
      return v1;
    };

    template <>
    Rstats::Vector* new_vector<Rstats::Integer>(Rstats::Integer length) {
      Rstats::Vector* v1 = new_empty_vector();
      v1->values = new std::vector<Rstats::Integer>(length);
      v1->type = Rstats::Type::INTEGER;
      
      return v1;
    }

    template <>
    Rstats::Vector* new_vector<Rstats::Complex>(Rstats::Integer length) {
      Rstats::Vector* v1 = new_empty_vector();
      v1->values = new std::vector<Rstats::Complex>(length);
      v1->type = Rstats::Type::COMPLEX;
      
      return v1;
    }

    template <>
    Rstats::Vector* new_vector<Rstats::Character>(Rstats::Integer length) {
      Rstats::Vector* v1 = new_empty_vector();
      v1->values = new std::vector<Rstats::Character>(length);
      v1->type = Rstats::Type::CHARACTER;
      
      return v1;
    }

    template <>
    Rstats::Vector* new_vector<Rstats::Logical>(Rstats::Integer length) {
      Rstats::Vector* v1 = new_empty_vector();
      v1->values = new std::vector<Rstats::Logical>(length);
      v1->type = Rstats::Type::LOGICAL;
      
      return v1;
    }
  }
}
