#ifndef PERL_RSTATS_VECTOR_H
#define PERL_RSTATS_VECTOR_H

#include "Rstats_ElementFunc.h"

namespace Rstats {
  class Vector {
    private:
    
    Rstats::Type::Enum type;
    Rstats::NaPosition* na_positions;
    void* values;
    Rstats::Integer length;
    
    public:

    template<class T>
    static Rstats::Vector* new_vector(Rstats::Integer);
    
    template <class T>
    static Rstats::Vector* new_vector(Rstats::Integer length, T value) {
      Rstats::Vector* v1 = new_vector<T>(length);
      for (Rstats::Integer i = 0; i < length; i++) {
        v1->set_value<T>(i, value);
      }
      return v1;
    };
        
    Rstats::Integer get_length();
    
    template<class T>
    T* get_values() {
      return (T*)this->values;
    }

    template<class T>
    void set_value(Rstats::Integer pos, T value) {
      *(this->get_values<T>() + pos) = value;
    } // Rstats::Character is specialized

    template <class T>
    T get_value(Rstats::Integer pos) {
      return *(this->get_values<T>() + pos);
    }
    
    void init_na_positions();
    void add_na_position(Rstats::Integer);
    Rstats::Logical exists_na_position(Rstats::Integer position);
    void merge_na_positions(Rstats::NaPosition*);
    Rstats::NaPosition* get_na_positions();
    Rstats::Integer get_na_positions_length();
    
    ~Vector();

    template <class T>
    void delete_vector() {
      T* values = this->get_values<T>();
      delete values;
      delete this->na_positions;
    }
  };
  template <>
  void Vector::set_value<Rstats::Character>(Rstats::Integer pos, Rstats::Character value);
  template<>
  Rstats::Vector* Vector::new_vector<Rstats::Double>(Rstats::Integer);
  template<>
  Rstats::Vector* Vector::new_vector<Rstats::Integer>(Rstats::Integer);
  template<>
  Rstats::Vector* Vector::new_vector<Rstats::Complex>(Rstats::Integer);
  template<>
  Rstats::Vector* Vector::new_vector<Rstats::Character>(Rstats::Integer);
  template<>
  Rstats::Vector* Vector::new_vector<Rstats::Logical>(Rstats::Integer);

  template <>
  void Vector::delete_vector<Rstats::Character>();
}

#endif
