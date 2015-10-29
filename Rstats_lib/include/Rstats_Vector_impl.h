namespace Rstats {

  template <class T>
  Rstats::Vector* Vector::new_vector(Rstats::Integer length, T value) {
    Rstats::Vector* v1 = new_vector<T>(length);
    for (Rstats::Integer i = 0; i < length; i++) {
      v1->set_value<T>(i, value);
    }
    return v1;
  };

  template<class T>
  void Vector::set_value(Rstats::Integer pos, T value) {
    *(this->get_values<T>() + pos) = value;
  }

  template<class T>
  T* Vector::get_values() {
    return (T*)this->values;
  }
  
  template <class T>
  T Vector::get_value(Rstats::Integer pos) {
    return *(this->get_values<T>() + pos);
  }

  template <class T>
  void Vector::delete_vector() {
    T* values = this->get_values<T>();
    delete[] values;
    delete[] this->na_positions;
  }
}
