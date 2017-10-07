namespace Rstats {

  template <class T>
  void Vector<T>::init_na_positions() {
    if (this->na_positions != NULL) {
      croak("na_postiions is already initialized");
    }
    if (this->get_length()) {
      int32_t length = this->get_na_positions_length();
      this->na_positions = new Rstats::NaPosition[length];
      std::fill_n(this->na_positions, length, 0);
    }
  }
  
  template <class T>
  int32_t Vector<T>::get_na_positions_length() {
    if (this->get_length() == 0) {
      return 0;
    }
    else {
      return ((this->get_length() - 1) / Rstats::NA_POSITION_BIT_LENGTH) + 1;
    }
  }

  template <class T>
  void Vector<T>::add_na_position(int32_t position) {
    if (this->get_na_positions() == NULL) {
      this->init_na_positions();
    }
    
    *(this->get_na_positions() + (position / Rstats::NA_POSITION_BIT_LENGTH))
      |= (1 << (position % Rstats::NA_POSITION_BIT_LENGTH));
  }

  template <class T>
  void Vector<T>::merge_na_positions(Rstats::NaPosition* na_positions) {
    
    if (na_positions == NULL) {
      return;
    }
    
    if (this->na_positions == NULL) {
      this->init_na_positions();
    }
    
    if (this->get_length()) {
      for (int32_t i = 0; i < this->get_na_positions_length(); i++) {
        *(this->get_na_positions() + i) |= *(na_positions + i);
      }
    }
  }

  template <class T>
  int32_t Vector<T>::exists_na_position(int32_t position) {
    if (this->get_na_positions() == NULL) {
      return 0;
    }

    return (*(this->get_na_positions() + (position / Rstats::NA_POSITION_BIT_LENGTH))
      & (1 << (position % Rstats::NA_POSITION_BIT_LENGTH)))
      ? 1 : 0;
  }

  template <class T>
  Rstats::NaPosition* Vector<T>::get_na_positions() {
    return this->na_positions;
  }

  template <class T>
  int32_t Vector<T>::get_length() {
    return this->length;
  }

  template <class T>
  void Vector<T>::initialize(int32_t length) {
    this->values = new T[length];
    this->length = length;
    this->na_positions = NULL;
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
    delete[] this->get_na_positions();
  }
}
