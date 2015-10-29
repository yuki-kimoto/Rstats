template <class T>
static Rstats::Vector* new_vector(Rstats::Integer length, T value) {
  Rstats::Vector* v1 = new_vector<T>(length);
  for (Rstats::Integer i = 0; i < length; i++) {
    v1->set_value<T>(i, value);
  }
  return v1;
};
