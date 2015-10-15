#include "Rstats.h"

// Rstats::VectorFunc
namespace Rstats {
  namespace VectorFunc {
   
    template <>
    Rstats::Character get_value<Rstats::Character>(Rstats::Vector* v1, Rstats::Integer pos) {
      Rstats::Character value = (*Rstats::VectorFunc::get_values<Rstats::Character>(v1))[pos];
      if (value == NULL) {
        return NULL;
      }
      else {
        return Rstats::pl_new_sv_sv(value);
      }
    }
    
    Rstats::Type::Enum get_type(Rstats::Vector* v1) {
      return v1->type;
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

    void delete_vector (Rstats::Vector* v1) {
      
      Rstats::Type::Enum type = Rstats::VectorFunc::get_type(v1);
      
      if (v1->values != NULL){ 
        switch (type) {
          case Rstats::Type::CHARACTER : {
            std::vector<Rstats::Character>* values = Rstats::VectorFunc::get_values<Rstats::Character>(v1);
            Rstats::Integer length = Rstats::VectorFunc::get_values<Rstats::Character>(v1)->size();
            for (Rstats::Integer i = 0; i < length; i++) {
              if ((*values)[i] != NULL) {
                SvREFCNT_dec((*values)[i]);
              }
            }
            delete values;
            break;
          }
          case Rstats::Type::COMPLEX : {
            std::vector<Rstats::Complex >* values = Rstats::VectorFunc::get_values<Rstats::Complex>(v1);
            delete values;
            break;
          }
          case Rstats::Type::DOUBLE : {
            std::vector<Rstats::Double>* values = Rstats::VectorFunc::get_values<Rstats::Double>(v1);
            delete values;
            break;
          }
          case Rstats::Type::INTEGER :
          case Rstats::Type::LOGICAL : {
            std::vector<Rstats::Integer>* values = Rstats::VectorFunc::get_values<Rstats::Integer>(v1);
            delete values;
          }
        }
      }
      
      delete v1->na_positions;
    }

    template <>
    void set_value<Rstats::Character>(Rstats::Vector* v1, Rstats::Integer pos, Rstats::Character value) {
      if (value != NULL) {
        SvREFCNT_dec((*Rstats::VectorFunc::get_values<Rstats::Character>(v1))[pos]);
      }
      
      SV* new_value = Rstats::pl_new_sv_sv(value);
      (*Rstats::VectorFunc::get_values<Rstats::Character>(v1))[pos] = SvREFCNT_inc(new_value);
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
