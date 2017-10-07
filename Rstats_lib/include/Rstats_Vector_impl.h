namespace Rstats {

  template <class T>
  int32_t Vector<T>::get_length() {
    return this->length;
  }

  template <class T>
  void Vector<T>::initialize(int32_t length) {
    this->values = new T[length];
    this->length = length;
  }

  template <class T>
  Vector<T>::Vector(int32_t length) {
    this->initialize(length);
  };
  
  template <class T>
  Vector<T>::Vector(int32_t length, T value) {
    this->initialize(length);
    
    for (int32_t i = 0; i < length; i++) {
      this->set_value(i, value);
    }
  };

  template<class T>
  void Vector<T>::set_value(int32_t pos, T value) {
    *(this->get_values() + pos) = value;
  }

  template<class T>
  T* Vector<T>::get_values() {
    return this->values;
  }
  
  template <class T>
  T Vector<T>::get_value(int32_t pos) {
    return *(this->get_values() + pos);
  }

  template <class T>
  Vector<T>::~Vector() {
    delete[] this->get_values();
  }
}
