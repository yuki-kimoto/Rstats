namespace Rstats {
  // Rstats::PerlAPI
  namespace PerlAPI {
    
    REGEXP* new_pregcomp (SV* sv_re, IV flag) {
      return (REGEXP*)sv_2mortal((SV*)pregcomp(sv_re, flag));
    }
    
    IV pregexec_simple (SV* sv_str, REGEXP* sv_re) {
      char* str = SvPV_nolen(sv_str);
      
      return pregexec(
        sv_re,
        str,
        str + strlen(str),
        str,
        0,
        sv_str,
        0
      );
    }
    
    SV* new_ref(SV* sv) {
      return sv_2mortal(newRV_inc(sv));
    }

    SV* new_ref(AV* av) {
      return sv_2mortal(newRV_inc((SV*)av));
    }

    SV* new_ref(HV* hv) {
      return sv_2mortal(newRV_inc((SV*)hv));
    }

    SV* new_sv(SV* sv) {
      return sv_2mortal(newSVsv(sv));
    }

    SV* new_sv(const char* pv) {
      return sv_2mortal(newSVpv(pv, 0));
    }
    
    SV* new_sv_iv(IV iv) {
      return sv_2mortal(newSViv(iv));
    }

    SV* new_sv_uv(UV uv) {
      return sv_2mortal(newSVuv(uv));
    }
    
    SV* new_sv_nv(NV nv) {
      return sv_2mortal(newSVnv(nv));
    }
    
    AV* new_av() {
      return (AV*)sv_2mortal((SV*)newAV());
    }
    
    SV* new_av_ref() {
      return sv_2mortal(newRV_inc((SV*)new_av()));
    }
    
    HV* new_hv() {
      return (HV*)sv_2mortal((SV*)newHV());
    }

    SV* new_hv_ref() {
      return sv_2mortal(newRV_inc((SV*)new_hv()));
    }

    SV* deref_sv(SV* ref) {
      if (SvROK(ref)) {
        return SvRV(ref);
      }
      else {
        croak("Can't derefernce");
      }
    }
    
    AV* deref_av(SV* ref) {
      if (SvROK(ref)) {
        return (AV*)SvRV(ref);
      }
      else {
        croak("Can't derefernce");
      }
    }
    
    void extend_av(AV* av, IV key) {
      return av_extend(av, key);
    }

    void extend_av(SV* av_ref, IV key) {
      AV* av = deref_av(av_ref);
      return av_extend(av, key);
    }
    
    IV length_av (AV* av) {
      return av_len(av) + 1;
    }

    IV length_av (SV* av_ref) {
      return av_len(deref_av(av_ref)) + 1;
    }
    
    SV* fetch_av(AV* av, IV pos) {
      SV** const element_ptr = av_fetch(av, pos, FALSE);
      SV* const element = element_ptr ? *element_ptr : &PL_sv_undef;
      
      return element;
    }
    
    SV* fetch_av(SV* av_ref, IV pos) {
      AV* av = deref_av(av_ref);
      SV** const element_ptr = av_fetch(av, pos, FALSE);
      SV* const element = element_ptr ? *element_ptr : &PL_sv_undef;
      
      return element;
    }

    HV* deref_hv(SV* ref) {
      if (SvROK(ref)) {
        return (HV*)SvRV(ref);
      }
      else {
        croak("Can't derefernce");
      }
    }
    
    SV* fetch_hv(HV* hv, const char* key) {
      SV** const element_ptr = hv_fetch(hv, key, strlen(key), FALSE);
      SV* const element = element_ptr ? *element_ptr : &PL_sv_undef;
      
      return element;
    }

    SV* fetch_hv(HV* hv, SV* sv_key) {
      return fetch_hv(hv, SvPV_nolen(sv_key));
    }
    
    SV* fetch_hv(SV* hv_ref, const char* key) {
      HV* hv = deref_hv(hv_ref);
      SV** const element_ptr = hv_fetch(hv, key, strlen(key), FALSE);
      SV* const element = element_ptr ? *element_ptr : &PL_sv_undef;
      
      return element;
    }

    SV* fetch_hv(SV* hv_ref, SV* sv_key) {
      return fetch_hv(hv_ref, SvPV_nolen(sv_key));
    }
    
    void store_av(AV* av, IV pos, SV* element) {
      av_store(av, pos, SvREFCNT_inc(element));
    }
    
    void store_av(SV* av_ref, IV pos, SV* element) {
      AV* av = deref_av(av_ref);
      av_store(av, pos, SvREFCNT_inc(element));
    }

    SV* copy_av(SV* sv_av_ref) {
      SV* sv_new_av_ref = new_av_ref();
      
      for (IV i = 0; i < length_av(sv_av_ref); i++) {
        store_av(sv_new_av_ref, i, new_sv(fetch_av(sv_av_ref, i)));
      }
      
      return sv_new_av_ref;
    }
    
    void store_hv(HV* hv, const char* key, SV* element) {
      hv_store(hv, key, strlen(key), SvREFCNT_inc(element), FALSE);
    }

    void store_hv(SV* hv_ref, const char* key, SV* element) {
      HV* hv = deref_hv(hv_ref);
      hv_store(hv, key, strlen(key), SvREFCNT_inc(element), FALSE);
    }
    
    void push_av(AV* av, SV* sv) {
      av_push(av, SvREFCNT_inc(sv));
    }
    
    void push_av(SV* av_ref, SV* sv) {
      av_push(deref_av(av_ref), SvREFCNT_inc(sv));
    }

    void unshit_av(AV* av, SV* sv) {
      av_unshift(av, 1);
      store_av(av, (IV)0, SvREFCNT_inc(sv));
    }
    
    void unshit_av(SV* av_ref, SV* sv) {
      av_unshift(deref_av(av_ref), 1);
      store_av(deref_av(av_ref), 0, SvREFCNT_inc(sv));
    }

    template <class X> X to_c_obj(SV* perl_obj_ref) {
      SV* perl_obj = SvROK(perl_obj_ref) ? SvRV(perl_obj_ref) : perl_obj_ref;
      IV obj_addr = SvIV(perl_obj);
      X c_obj = INT2PTR(X, obj_addr);
      
      return c_obj;
    }

    template <class X> SV* to_perl_obj(X c_obj, const char* class_name) {
      IV obj_addr = PTR2IV(c_obj);
      SV* sv_obj_addr = new_sv_iv(obj_addr);
      SV* sv_obj_addr_ref = new_ref(sv_obj_addr);
      SV* perl_obj = sv_bless(sv_obj_addr_ref, gv_stashpv(class_name, 1));
      
      return perl_obj;
    }
  };
  
  // Rstats::ElementsType
  namespace ElementsType {
    enum Enum {
      NULL_TYPE = 0,
      LOGICAL = 1,
      INTEGER = 2,
      DOUBLE = 4,
      COMPLEX = 8,
      CHARACTER = 16
    };
  }
  
  namespace Values {
    // Rstats::Values::Character
    typedef std::vector<SV*> Character;
    
    // Rstats::Values::Complex
    typedef std::vector<std::complex<NV> > Complex;
    
    // Rstats::Values::Double
    typedef std::vector<NV> Double;
    
    // Rstats::Values::Integer
    typedef std::vector<IV> Integer;
  }

  // Rstats::Elements
  class Elements {
    private:
    Rstats::ElementsType::Enum type;
    std::map<IV, IV> na_positions;
    void* values;
    
    public:
    
    ~Elements () {
      IV length = this->get_length();
    
      if (this->is_integer_type() || this->is_logical_type()) {
        Rstats::Values::Integer* values = this->get_integer_values();
        delete values;
      }
      else if (this->is_double_type()) {
        Rstats::Values::Double* values = this->get_double_values();
        delete values;
      }
      else if (this->is_complex_type()) {
        Rstats::Values::Complex* values = this->get_complex_values();
        delete values;
      }
      else if (this->is_character_type()) {
        Rstats::Values::Character* values = this->get_character_values();
        for (IV i = 0; i < length; i++) {
          if ((*values)[i] != NULL) {
            SvREFCNT_dec((*values)[i]);
          }
        }
        delete values;
      }
    }

    bool is_null_type () { return this->get_type() == Rstats::ElementsType::NULL_TYPE; }
    bool is_integer_type () { return this->get_type() == Rstats::ElementsType::INTEGER; }
    bool is_logical_type () { return this->get_type() == Rstats::ElementsType::LOGICAL; }
    bool is_double_type () { return this->get_type() == Rstats::ElementsType::DOUBLE; }
    bool is_complex_type () { return this->get_type() == Rstats::ElementsType::COMPLEX; }
    bool is_character_type () { return this->get_type() == Rstats::ElementsType::CHARACTER; }
    
    Rstats::Values::Character* get_character_values() {
      return (Rstats::Values::Character*)this->values;
    }
    
    Rstats::Values::Complex* get_complex_values() {
      return (Rstats::Values::Complex*)this->values;
    }
    
    Rstats::Values::Double* get_double_values() {
      return (Rstats::Values::Double*)this->values;
    }
    
    Rstats::Values::Integer* get_integer_values() {
      return (Rstats::Values::Integer*)this->values;
    }
    
    Rstats::ElementsType::Enum get_type() {
      return this->type;
    }
    
    void add_na_position (IV position) {
      this->na_positions[position] = 1;
    }

    bool exists_na_position (IV position) {
      return this->na_positions.count(position);
    }
    
    void merge_na_positions (Rstats::Elements* elements) {
      for(std::map<IV, IV>::iterator it = elements->na_positions.begin(); it != elements->na_positions.end(); ++it) {
        this->add_na_position(it->first);
      }
    }
    
    IV get_length () {
      if (this->values == NULL) {
        return 0;
      }
      else if (this->is_character_type()) {
        return this->get_character_values()->size();
      }
      else if (this->is_complex_type()) {
        return this->get_complex_values()->size();
      }
      else if (this->is_double_type()) {
        return this->get_double_values()->size();
      }
      else if (this->is_integer_type() || this->is_logical_type()) {
        return this->get_integer_values()->size();
      }
    }

    static Rstats::Elements* new_character(IV length, SV* sv_str) {

      Rstats::Elements* elements = Rstats::Elements::new_character(length);
      for (IV i = 0; i < length; i++) {
        elements->set_character_value(i, sv_str);
      }
      elements->type = Rstats::ElementsType::CHARACTER;
      
      return elements;
    }

    static Rstats::Elements* new_character(IV length) {

      Rstats::Elements* elements = new Rstats::Elements;
      elements->values = new Rstats::Values::Character(length);
      elements->type = Rstats::ElementsType::CHARACTER;
      
      return elements;
    }

    SV* get_character_value(IV pos) {
      SV* value = (*this->get_character_values())[pos];
      if (value == NULL) {
        return NULL;
      }
      else {
        return Rstats::PerlAPI::new_sv(value);
      }
    }
    
    void set_character_value(IV pos, SV* value) {
      if (value != NULL) {
        SvREFCNT_dec((*this->get_character_values())[pos]);
      }
      
      SV* new_value = Rstats::PerlAPI::new_sv(value);
      (*this->get_character_values())[pos] = SvREFCNT_inc(new_value);
    }

    static Rstats::Elements* new_complex(IV length) {
      
      Rstats::Elements* elements = new Rstats::Elements;
      elements->values = new Rstats::Values::Complex(length, std::complex<NV>(0, 0));
      elements->type = Rstats::ElementsType::COMPLEX;
      
      return elements;
    }
        
    static Rstats::Elements* new_complex(IV length, std::complex<NV> z) {
      
      Rstats::Elements* elements = new Rstats::Elements;
      elements->values = new Rstats::Values::Complex(length, z);
      elements->type = Rstats::ElementsType::COMPLEX;
      
      return elements;
    }

    std::complex<NV> get_complex_value(IV pos) {
      return (*this->get_complex_values())[pos];
    }
    
    void set_complex_value(IV pos, std::complex<NV> value) {
      (*this->get_complex_values())[pos] = value;
    }
    
    static Rstats::Elements* new_double(IV length) {
      Rstats::Elements* elements = new Rstats::Elements;
      elements->values = new Rstats::Values::Double(length);
      elements->type = Rstats::ElementsType::DOUBLE;
      
      return elements;
    }

    static Rstats::Elements* new_double(IV length, NV value) {
      Rstats::Elements* elements = new Rstats::Elements;
      elements->values = new Rstats::Values::Double(length, value);
      elements->type = Rstats::ElementsType::DOUBLE;
      
      return elements;
    }
    
    NV get_double_value(IV pos) {
      return (*this->get_double_values())[pos];
    }
    
    void set_double_value(IV pos, NV value) {
      (*this->get_double_values())[pos] = value;
    }

    static Rstats::Elements* new_integer(IV length) {
      
      Rstats::Elements* elements = new Rstats::Elements;
      elements->values = new Rstats::Values::Integer(length);
      elements->type = Rstats::ElementsType::INTEGER;
      
      return elements;
    }

    static Rstats::Elements* new_integer(IV length, IV value) {
      
      Rstats::Elements* elements = new Rstats::Elements;
      elements->values = new Rstats::Values::Integer(length, value);
      elements->type = Rstats::ElementsType::INTEGER;
      
      return elements;
    }

    IV get_integer_value(IV pos) {
      return (*this->get_integer_values())[pos];
    }
    
    void set_integer_value(IV pos, IV value) {
      (*this->get_integer_values())[pos] = value;
    }
    
    static Rstats::Elements* new_logical(IV length) {
      Rstats::Elements* elements = new Rstats::Elements;
      elements->values = new Rstats::Values::Integer(length);
      elements->type = Rstats::ElementsType::LOGICAL;
      
      return elements;
    }

    static Rstats::Elements* new_logical(IV length, IV value) {
      Rstats::Elements* elements = new Rstats::Elements;
      elements->values = new Rstats::Values::Integer(length, value);
      elements->type = Rstats::ElementsType::LOGICAL;
      
      return elements;
    }
    
    static Rstats::Elements* new_true() {
      return new_logical(1, 1);
    }

    static Rstats::Elements* new_false() {
      return new_logical(1, 0);
    }
    
    static Rstats::Elements* new_nan() {
      return  Rstats::Elements::new_double(1, NAN);
    }

    static Rstats::Elements* new_negative_inf() {
      return Rstats::Elements::new_double(1, -(INFINITY));
    }
    
    static Rstats::Elements* new_inf() {
      return Rstats::Elements::new_double(1, INFINITY);
    }
    
    static Rstats::Elements* new_na() {
      Rstats::Elements* elements = new Rstats::Elements;
      elements->values = new Rstats::Values::Integer(1, 0);
      elements->type = Rstats::ElementsType::LOGICAL;
      elements->add_na_position(0);
      
      return elements;
    }
    
    static Rstats::Elements* new_null() {
      Rstats::Elements* elements = new Rstats::Elements;
      elements->values = NULL;
      return elements;
    }

    Rstats::Elements* as_double() {

      IV length = this->get_length();
      Rstats::Elements* e2 = new_double(length);
      if (this->is_character_type()) {
        for (IV i = 0; i < length; i++) {
          SV* sv_value = this->get_character_value(i);
          if (looks_like_number(sv_value)) {
            NV value = SvNV(sv_value);
            e2->set_double_value(i, value);
          }
          else {
            warn("NAs introduced by coercion");
            e2->add_na_position(i);
          }
        }
      }
      else if (this->is_complex_type()) {
        warn("imaginary parts discarded in coercion");
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, this->get_complex_value(i).real());
        }
      }
      else if (this->is_double_type()) {
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, this->get_double_value(i));
        }
      }
      else if (this->is_integer_type() || this->is_logical_type()) {
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, this->get_integer_value(i));
        }
      }
      else {
        croak("unexpected type");
      }

      e2->merge_na_positions(this);
      
      return e2;
    }

    Rstats::Elements* as_integer() {

      IV length = this->get_length();
      Rstats::Elements* e2 = new_integer(length);
      if (this->is_character_type()) {
        for (IV i = 0; i < length; i++) {
          SV* sv_value = this->get_character_value(i);
          if (looks_like_number(sv_value)) {
            IV value = SvIV(sv_value);
            e2->set_integer_value(i, value);
          }
          else {
            warn("NAs introduced by coercion");
            e2->add_na_position(i);
          }
        }
      }
      else if (this->is_complex_type()) {
        warn("imaginary parts discarded in coercion");
        for (IV i = 0; i < length; i++) {
          e2->set_integer_value(i, (IV)this->get_complex_value(i).real());
        }
      }
      else if (this->is_double_type()) {
        NV value;
        for (IV i = 0; i < length; i++) {
          value = this->get_double_value(i);
          if (std::isnan(value) || std::isinf(value)) {
            e2->add_na_position(i);
          }
          else {
            e2->set_integer_value(i, (IV)value);
          }
        }
      }
      else if (this->is_integer_type() || this->is_logical_type()) {
        for (IV i = 0; i < length; i++) {
          e2->set_integer_value(i, this->get_integer_value(i));
        }
      }
      else {
        croak("unexpected type");
      }

      e2->merge_na_positions(this);
      
      return e2;
    }

    Rstats::Elements* as_logical() {

      IV length = this->get_length();
      Rstats::Elements* e2 = new_logical(length);
      if (this->is_character_type()) {
        for (IV i = 0; i < length; i++) {
          SV* sv_value = this->get_character_value(i);
          if (looks_like_number(sv_value)) {
            IV value = SvIV(sv_value);
            e2->set_integer_value(i, value);
          }
          else {
            warn("NAs introduced by coercion");
            e2->add_na_position(i);
          }
        }
      }
      else if (this->is_complex_type()) {
        warn("imaginary parts discarded in coercion");
        for (IV i = 0; i < length; i++) {
          e2->set_integer_value(i, (IV)this->get_complex_value(i).real());
        }
      }
      else if (this->is_double_type()) {
        NV value;
        for (IV i = 0; i < length; i++) {
          value = this->get_double_value(i);
          if (std::isnan(value) || std::isinf(value)) {
            e2->add_na_position(i);
          }
          else {
            e2->set_integer_value(i, (IV)value);
          }
        }
      }
      else if (this->is_integer_type() || this->is_logical_type()) {
        for (IV i = 0; i < length; i++) {
          e2->set_integer_value(i, this->get_integer_value(i));
        }
      }
      else {
        croak("unexpected type");
      }

      e2->merge_na_positions(this);
      
      return e2;
    }
  };
  
  // Rstats::ElementsFunc
  namespace ElementsFunc {
    
    Rstats::Elements* add(Rstats::Elements* e1, Rstats::Elements* e2) {
      
      if (e1->get_type() != e2->get_type()) {
        croak("Can't add different type(Rstats::ElementFunc::add())");
      }
      
      if (e1->get_length() != e2->get_length()) {
        croak("Can't add different length(Rstats::ElementFunc::add())");
      }
      
      IV length = e1->get_length();
      Rstats::Elements* e3;
      if (e1->is_character_type()) {
        croak("Error in a + b : non-numeric argument to binary operator");
      }
      else if (e1->is_complex_type()) {
        e3 = Rstats::Elements::new_complex(length);
        for (IV i = 0; i < length; i++) {
          e3->set_complex_value(i, e1->get_complex_value(i) + e2->get_complex_value(i));
        }
      }
      else if (e1->is_double_type()) {
        e3 = Rstats::Elements::new_double(length);
        for (IV i = 0; i < length; i++) {
          e3->set_double_value(i, e1->get_double_value(i) + e2->get_double_value(i));
        }
      }
      else if (e1->is_integer_type()) {
        e3 = Rstats::Elements::new_integer(length);
        for (IV i = 0; i < length; i++) {
          e3->set_integer_value(i, e1->get_integer_value(i) + e2->get_integer_value(i));
        }
      }
      else if (e1->is_logical_type()) {
        e3 = Rstats::Elements::new_logical(length);
        for (IV i = 0; i < length; i++) {
          e3->set_integer_value(i, e1->get_integer_value(i) + e2->get_integer_value(i));
        }
      }
      else {
        croak("Invalid type");
      }
      
      e3->merge_na_positions(e1);
      e3->merge_na_positions(e2);
      
      return e3;
    }

    Rstats::Elements* subtract(Rstats::Elements* e1, Rstats::Elements* e2) {
      
      if (e1->get_type() != e2->get_type()) {
        croak("Can't subtract different type(Rstats::ElementFunc::subtract())");
      }
      
      if (e1->get_length() != e2->get_length()) {
        croak("Can't subtract different length(Rstats::ElementFunc::subtract())");
      }
      
      IV length = e1->get_length();
      Rstats::Elements* e3;
      if (e1->is_character_type()) {
        croak("Error in a - b : non-numeric argument to binary operator");
      }
      else if (e1->is_complex_type()) {
        e3 = Rstats::Elements::new_complex(length);
        for (IV i = 0; i < length; i++) {
          e3->set_complex_value(i, e1->get_complex_value(i) - e2->get_complex_value(i));
        }
      }
      else if (e1->is_double_type()) {
        e3 = Rstats::Elements::new_double(length);
        for (IV i = 0; i < length; i++) {
          e3->set_double_value(i, e1->get_double_value(i) - e2->get_double_value(i));
        }
      }
      else if (e1->is_integer_type()) {
        e3 = Rstats::Elements::new_integer(length);
        for (IV i = 0; i < length; i++) {
          e3->set_integer_value(i, e1->get_integer_value(i) - e2->get_integer_value(i));
        }
      }
      else if (e1->is_logical_type()) {
        e3 = Rstats::Elements::new_logical(length);
        for (IV i = 0; i < length; i++) {
          e3->set_integer_value(i, e1->get_integer_value(i) - e2->get_integer_value(i));
        }
      }
      else {
        croak("Invalid type");
      }
      
      e3->merge_na_positions(e1);
      e3->merge_na_positions(e2);
      
      return e3;
    }

    Rstats::Elements* multiply(Rstats::Elements* e1, Rstats::Elements* e2) {
      
      if (e1->get_type() != e2->get_type()) {
        croak("Can't multiply different type(Rstats::ElementFunc::multiply())");
      }
      
      if (e1->get_length() != e2->get_length()) {
        croak("Can't multiply different length(Rstats::ElementFunc::multiply())");
      }
      
      IV length = e1->get_length();
      Rstats::Elements* e3;
      if (e1->is_character_type()) {
        croak("Error in a - b : non-numeric argument to binary operator");
      }
      else if (e1->is_complex_type()) {
        e3 = Rstats::Elements::new_complex(length);
        for (IV i = 0; i < length; i++) {
          e3->set_complex_value(i, e1->get_complex_value(i) * e2->get_complex_value(i));
        }
      }
      else if (e1->is_double_type()) {
        e3 = Rstats::Elements::new_double(length);
        for (IV i = 0; i < length; i++) {
          e3->set_double_value(i, e1->get_double_value(i) * e2->get_double_value(i));
        }
      }
      else if (e1->is_integer_type()) {
        e3 = Rstats::Elements::new_integer(length);
        for (IV i = 0; i < length; i++) {
          e3->set_integer_value(i, e1->get_integer_value(i) * e2->get_integer_value(i));
        }
      }
      else if (e1->is_logical_type()) {
        e3 = Rstats::Elements::new_logical(length);
        for (IV i = 0; i < length; i++) {
          e3->set_integer_value(i, e1->get_integer_value(i) * e2->get_integer_value(i));
        }
      }
      else {
        croak("Invalid type");
      }
      
      e3->merge_na_positions(e1);
      e3->merge_na_positions(e2);
      
      return e3;
    }

    Rstats::Elements* divide(Rstats::Elements* e1, Rstats::Elements* e2) {
      
      if (e1->get_type() != e2->get_type()) {
        croak("Can't divide different type(Rstats::ElementFunc::multiply())");
      }
      
      if (e1->get_length() != e2->get_length()) {
        croak("Can't divide different length(Rstats::ElementFunc::multiply())");
      }
      
      IV length = e1->get_length();
      Rstats::Elements* e3;
      if (e1->is_character_type()) {
        croak("Error in a - b : non-numeric argument to binary operator");
      }
      else if (e1->is_complex_type()) {
        e3 = Rstats::Elements::new_complex(length);
        for (IV i = 0; i < length; i++) {
          e3->set_complex_value(i, e1->get_complex_value(i) / e2->get_complex_value(i));
        }
      }
      else if (e1->is_double_type()) {
        e3 = Rstats::Elements::new_double(length);
        for (IV i = 0; i < length; i++) {
          e3->set_double_value(i, e1->get_double_value(i) / e2->get_double_value(i));
        }
      }
      else if (e1->is_integer_type()) {
        e3 = Rstats::Elements::new_double(length);
        for (IV i = 0; i < length; i++) {
          e3->set_double_value(i, e1->get_integer_value(i) / e2->get_integer_value(i));
        }
      }
      else if (e1->is_logical_type()) {
        e3 = Rstats::Elements::new_double(length);
        for (IV i = 0; i < length; i++) {
          e3->set_double_value(i, e1->get_integer_value(i) / e2->get_integer_value(i));
        }
      }
      else {
        croak("Invalid type");
      }
      
      e3->merge_na_positions(e1);
      e3->merge_na_positions(e2);
      
      return e3;
    }

    Rstats::Elements* raise(Rstats::Elements* e1, Rstats::Elements* e2) {
      
      if (e1->get_type() != e2->get_type()) {
        croak("Can't raise different type(Rstats::ElementFunc::multiply())");
      }
      
      if (e1->get_length() != e2->get_length()) {
        croak("Can't raise different length(Rstats::ElementFunc::multiply())");
      }
      
      IV length = e1->get_length();
      Rstats::Elements* e3;
      if (e1->is_character_type()) {
        croak("Error in a - b : non-numeric argument to binary operator");
      }
      else if (e1->is_complex_type()) {
        e3 = Rstats::Elements::new_complex(length);
        for (IV i = 0; i < length; i++) {
          e3->set_complex_value(i, pow(e1->get_complex_value(i), e2->get_complex_value(i)));
        }
      }
      else if (e1->is_double_type()) {
        e3 = Rstats::Elements::new_double(length);
        for (IV i = 0; i < length; i++) {
          e3->set_double_value(i, pow(e1->get_double_value(i), e2->get_double_value(i)));
        }
      }
      else if (e1->is_integer_type()) {
        e3 = Rstats::Elements::new_double(length);
        for (IV i = 0; i < length; i++) {
          e3->set_double_value(i, pow(e1->get_integer_value(i), e2->get_integer_value(i)));
        }
      }
      else if (e1->is_logical_type()) {
        e3 = Rstats::Elements::new_double(length);
        for (IV i = 0; i < length; i++) {
          e3->set_double_value(i, pow(e1->get_integer_value(i), e2->get_integer_value(i)));
        }
      }
      else {
        croak("Invalid type");
      }
      
      e3->merge_na_positions(e1);
      e3->merge_na_positions(e2);
      
      return e3;
    }

    Rstats::Elements* sqrt(Rstats::Elements* e1) {
      
      IV length = e1->get_length();
      Rstats::Elements* e2;
      if (e1->is_character_type()) {
        croak("Error in a - b : non-numeric argument to binary operator");
      }
      else if (e1->is_complex_type()) {
        e2 = Rstats::Elements::new_complex(length);
        std::complex<NV> value;
        for (IV i = 0; i < length; i++) {
          value = e1->get_complex_value(i);
          
          // Fix bug that clang sqrt can't right value of perfect squeres
          if (value.imag() == 0 && value.real() < 0) {
            e2->set_complex_value(
              i,
              std::complex<NV>(
                0,
                std::sqrt(-(value.real()))
              )
            );
          }
          else {
            e2->set_complex_value(i, std::sqrt(value));
          }
        }
      }
      else if (e1->is_double_type()) {
        e2 = Rstats::Elements::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::sqrt(e1->get_double_value(i)));
        }
      }
      else if (e1->is_integer_type()) {
        e2 = Rstats::Elements::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::sqrt(e1->get_integer_value(i)));
        }
      }
      else if (e1->is_logical_type()) {
        e2 = Rstats::Elements::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::sqrt(e1->get_integer_value(i)));
        }
      }
      else {
        croak("Invalid type");
      }
      
      e2->merge_na_positions(e1);
      
      return e2;
    }

    Rstats::Elements* sin(Rstats::Elements* e1) {
      
      IV length = e1->get_length();
      Rstats::Elements* e2;
      if (e1->is_character_type()) {
        croak("Error in a - b : non-numeric argument to binary operator");
      }
      else if (e1->is_complex_type()) {
        e2 = Rstats::Elements::new_complex(length);
        for (IV i = 0; i < length; i++) {
          e2->set_complex_value(i, std::sin(e1->get_complex_value(i)));
        }
      }
      else if (e1->is_double_type()) {
        e2 = Rstats::Elements::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::sin(e1->get_double_value(i)));
        }
      }
      else if (e1->is_integer_type()) {
        e2 = Rstats::Elements::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::sin(e1->get_integer_value(i)));
        }
      }
      else if (e1->is_logical_type()) {
        e2 = Rstats::Elements::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::sin(e1->get_integer_value(i)));
        }
      }
      else {
        croak("Invalid type");
      }
      
      e2->merge_na_positions(e1);
      
      return e2;
    }
    
    Rstats::Elements* cos(Rstats::Elements* e1) {
      
      IV length = e1->get_length();
      Rstats::Elements* e2;
      if (e1->is_character_type()) {
        croak("Error in a - b : non-numeric argument to binary operator");
      }
      else if (e1->is_complex_type()) {
        e2 = Rstats::Elements::new_complex(length);
        for (IV i = 0; i < length; i++) {
          e2->set_complex_value(i, std::cos(e1->get_complex_value(i)));
        }
      }
      else if (e1->is_double_type()) {
        e2 = Rstats::Elements::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::cos(e1->get_double_value(i)));
        }
      }
      else if (e1->is_integer_type()) {
        e2 = Rstats::Elements::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::cos(e1->get_integer_value(i)));
        }
      }
      else if (e1->is_logical_type()) {
        e2 = Rstats::Elements::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::cos(e1->get_integer_value(i)));
        }
      }
      else {
        croak("Invalid type");
      }
      
      e2->merge_na_positions(e1);
      
      return e2;
    }

    Rstats::Elements* tan(Rstats::Elements* e1) {
      
      IV length = e1->get_length();
      Rstats::Elements* e2;
      if (e1->is_character_type()) {
        croak("Error in a - b : non-numeric argument to binary operator");
      }
      else if (e1->is_complex_type()) {
        e2 = Rstats::Elements::new_complex(length);
        for (IV i = 0; i < length; i++) {
          e2->set_complex_value(i, std::tan(e1->get_complex_value(i)));
        }
      }
      else if (e1->is_double_type()) {
        e2 = Rstats::Elements::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::tan(e1->get_double_value(i)));
        }
      }
      else if (e1->is_integer_type()) {
        e2 = Rstats::Elements::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::tan(e1->get_integer_value(i)));
        }
      }
      else if (e1->is_logical_type()) {
        e2 = Rstats::Elements::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::tan(e1->get_integer_value(i)));
        }
      }
      else {
        croak("Invalid type");
      }
      
      e2->merge_na_positions(e1);
      
      return e2;
    }

    Rstats::Elements* sinh(Rstats::Elements* e1) {
      
      IV length = e1->get_length();
      Rstats::Elements* e2;
      if (e1->is_character_type()) {
        croak("Error in a - b : non-numeric argument to binary operator");
      }
      else if (e1->is_complex_type()) {
        e2 = Rstats::Elements::new_complex(length);
        for (IV i = 0; i < length; i++) {
          e2->set_complex_value(i, std::sinh(e1->get_complex_value(i)));
        }
      }
      else if (e1->is_double_type()) {
        e2 = Rstats::Elements::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::sinh(e1->get_double_value(i)));
        }
      }
      else if (e1->is_integer_type()) {
        e2 = Rstats::Elements::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::sinh(e1->get_integer_value(i)));
        }
      }
      else if (e1->is_logical_type()) {
        e2 = Rstats::Elements::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::sinh(e1->get_integer_value(i)));
        }
      }
      else {
        croak("Invalid type");
      }
      
      e2->merge_na_positions(e1);
      
      return e2;
    }
    
    Rstats::Elements* cosh(Rstats::Elements* e1) {
      
      IV length = e1->get_length();
      Rstats::Elements* e2;
      if (e1->is_character_type()) {
        croak("Error in a - b : non-numeric argument to binary operator");
      }
      else if (e1->is_complex_type()) {
        e2 = Rstats::Elements::new_complex(length);
        for (IV i = 0; i < length; i++) {
          e2->set_complex_value(i, std::cosh(e1->get_complex_value(i)));
        }
      }
      else if (e1->is_double_type()) {
        e2 = Rstats::Elements::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::cosh(e1->get_double_value(i)));
        }
      }
      else if (e1->is_integer_type()) {
        e2 = Rstats::Elements::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::cosh(e1->get_integer_value(i)));
        }
      }
      else if (e1->is_logical_type()) {
        e2 = Rstats::Elements::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::cosh(e1->get_integer_value(i)));
        }
      }
      else {
        croak("Invalid type");
      }
      
      e2->merge_na_positions(e1);
      
      return e2;
    }

    Rstats::Elements* tanh(Rstats::Elements* e1) {
      
      IV length = e1->get_length();
      Rstats::Elements* e2;
      if (e1->is_character_type()) {
        croak("Error in a - b : non-numeric argument to binary operator");
      }
      else if (e1->is_complex_type()) {
        e2 = Rstats::Elements::new_complex(length);
        NV e1_value_re;
        for (IV i = 0; i < length; i++) {
          e1_value_re = e1->get_complex_value(i).real();
          
          // For fix FreeBSD bug
          // FreeBAD return (NaN + NaNi) when real value is negative infinite
          if (std::isinf(e1_value_re) && e1_value_re < 0) {
            e2->set_complex_value(i, std::complex<NV>(-1, 0));
          }
          else {
            e2->set_complex_value(i, std::tanh(e1->get_complex_value(i)));
          }
        }
      }
      else if (e1->is_double_type()) {
        e2 = Rstats::Elements::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::tanh(e1->get_double_value(i)));
        }
      }
      else if (e1->is_integer_type()) {
        e2 = Rstats::Elements::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::tanh(e1->get_integer_value(i)));
        }
      }
      else if (e1->is_logical_type()) {
        e2 = Rstats::Elements::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::tanh(e1->get_integer_value(i)));
        }
      }
      else {
        croak("Invalid type");
      }
      
      e2->merge_na_positions(e1);
      
      return e2;
    }

    Rstats::Elements* abs(Rstats::Elements* e1) {
      
      IV length = e1->get_length();
      Rstats::Elements* e2;
      if (e1->is_character_type()) {
        croak("Error in a - b : non-numeric argument to binary operator");
      }
      else if (e1->is_complex_type()) {
        e2 = Rstats::Elements::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::abs(e1->get_complex_value(i)));
        }
      }
      else if (e1->is_double_type()) {
        e2 = Rstats::Elements::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::abs(e1->get_double_value(i)));
        }
      }
      else if (e1->is_integer_type()) {
        e2 = Rstats::Elements::new_integer(length);
        for (IV i = 0; i < length; i++) {
          e2->set_integer_value(i, (IV)std::abs((NV)e1->get_integer_value(i)));
        }
      }
      else if (e1->is_logical_type()) {
        e2 = Rstats::Elements::new_logical(length);
        for (IV i = 0; i < length; i++) {
          e2->set_integer_value(i, (IV)std::abs((NV)e1->get_integer_value(i)));
        }
      }
      else {
        croak("Invalid type");
      }
      
      e2->merge_na_positions(e1);
      
      return e2;
    }
    
    Rstats::Elements* log(Rstats::Elements* e1) {
      
      IV length = e1->get_length();
      Rstats::Elements* e2;
      if (e1->is_character_type()) {
        croak("Error in a - b : non-numeric argument to binary operator");
      }
      else if (e1->is_complex_type()) {
        e2 = Rstats::Elements::new_complex(length);
        for (IV i = 0; i < length; i++) {
          e2->set_complex_value(i, std::log(e1->get_complex_value(i)));
        }
      }
      else if (e1->is_double_type()) {
        e2 = Rstats::Elements::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::log(e1->get_double_value(i)));
        }
      }
      else if (e1->is_integer_type()) {
        e2 = Rstats::Elements::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::log(e1->get_integer_value(i)));
        }
      }
      else if (e1->is_logical_type()) {
        e2 = Rstats::Elements::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::log(e1->get_integer_value(i)));
        }
      }
      else {
        croak("Invalid type");
      }
      
      e2->merge_na_positions(e1);
      
      return e2;
    }

    Rstats::Elements* logb(Rstats::Elements* e1) {
      return log(e1);
    }
    
    Rstats::Elements* log10(Rstats::Elements* e1) {
      
      IV length = e1->get_length();
      Rstats::Elements* e2;
      if (e1->is_character_type()) {
        croak("Error in a - b : non-numeric argument to binary operator");
      }
      else if (e1->is_complex_type()) {
        e2 = Rstats::Elements::new_complex(length);
        for (IV i = 0; i < length; i++) {
          e2->set_complex_value(i, std::log10(e1->get_complex_value(i)));
        }
      }
      else if (e1->is_double_type()) {
        e2 = Rstats::Elements::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::log10(e1->get_double_value(i)));
        }
      }
      else if (e1->is_integer_type()) {
        e2 = Rstats::Elements::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::log10(e1->get_integer_value(i)));
        }
      }
      else if (e1->is_logical_type()) {
        e2 = Rstats::Elements::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::log10(e1->get_integer_value(i)));
        }
      }
      else {
        croak("Invalid type");
      }
      
      e2->merge_na_positions(e1);
      
      return e2;
    }

    Rstats::Elements* log2(Rstats::Elements* e1) {
      
      IV length = e1->get_length();
      Rstats::Elements* e2;
      if (e1->is_character_type()) {
        croak("Error in a - b : non-numeric argument to binary operator");
      }
      else if (e1->is_complex_type()) {
        e2 = divide(log(e1), log(Rstats::Elements::new_complex(length, std::complex<NV>(2, 0))));
      }
      else if (e1->is_double_type() || e1->is_integer_type() || e1->is_logical_type()) {
        e2 = divide(log(e1), log(Rstats::Elements::new_double(length, 2)));
      }
      else {
        croak("Invalid type");
      }
      
      e2->merge_na_positions(e1);
      
      return e2;
    }

    Rstats::Elements* exp(Rstats::Elements* e1) {
      
      IV length = e1->get_length();
      Rstats::Elements* e2;
      if (e1->is_character_type()) {
        croak("Error in a - b : non-numeric argument to binary operator");
      }
      else if (e1->is_complex_type()) {
        e2 = Rstats::Elements::new_complex(length);
        for (IV i = 0; i < length; i++) {
          e2->set_complex_value(i, std::exp(e1->get_complex_value(i)));
        }
      }
      else if (e1->is_double_type()) {
        e2 = Rstats::Elements::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::exp(e1->get_double_value(i)));
        }
      }
      else if (e1->is_integer_type()) {
        e2 = Rstats::Elements::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::exp(e1->get_integer_value(i)));
        }
      }
      else if (e1->is_logical_type()) {
        e2 = Rstats::Elements::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::exp(e1->get_integer_value(i)));
        }
      }
      else {
        croak("Invalid type");
      }
      
      e2->merge_na_positions(e1);
      
      return e2;
    }

    Rstats::Elements* equal(Rstats::Elements* e1, Rstats::Elements* e2) {
      
      if (e1->get_type() != e2->get_type()) {
        std::cerr << e1->get_type() << " " << e2->get_type();
        croak("Can't compare equal different type(Rstats::ElementFunc::equal())");
      }
      
      if (e1->get_length() != e2->get_length()) {
        croak("Can't compare equal different length(Rstats::ElementFunc::equal())");
      }
      
      IV length = e1->get_length();
      Rstats::Elements* e3 = Rstats::Elements::new_logical(length);
      if (e1->is_character_type()) {
        IV is;
        for (IV i = 0; i < length; i++) {
          if (sv_cmp(e1->get_character_value(i), e2->get_character_value(i)) == 0) {
            is = 1;
          }
          else {
            is = 0;
          }
          e3->set_integer_value(i, is);
        }
      }
      else if (e1->is_complex_type()) {
        IV is;
        for (IV i = 0; i < length; i++) {
          if (e1->get_complex_value(i) == e2->get_complex_value(i)) {
            is = 1;
          }
          else {
            is = 0;
          }
          e3->set_integer_value(i, is);
        }
      }
      else if (e1->is_double_type()) {
        IV is;
        NV e1_value;
        NV e2_value;
        for (IV i = 0; i < length; i++) {
          e1_value = e1->get_double_value(i);
          e2_value = e2->get_double_value(i);
          
          if (std::isnan(e1_value) || std::isnan(e2_value)) {
            e3->add_na_position(i);
            is = 0;
          }
          else {
            if(e1_value == e2_value) {
              is = 1;
            }
            else {
              is = 0;
            }
          }
          e3->set_integer_value(i, is);
        }
      }
      else if (e1->is_integer_type() || e1->is_logical_type()) {
        IV is;
        for (IV i = 0; i < length; i++) {
          if (e1->get_integer_value(i) == e2->get_integer_value(i)) {
            is = 1;
          }
          else {
            is = 0;
          }
          e3->set_integer_value(i, is);
        }
      }
      else {
        croak("Invalid type");
      }
      
      e3->merge_na_positions(e1);
      e3->merge_na_positions(e2);
      
      return e3;
    }

    Rstats::Elements* is_infinite(Rstats::Elements* elements) {
      
      IV length = elements->get_length();
      Rstats::Elements* rets;
      if (elements->get_type() == Rstats::ElementsType::DOUBLE) {
        rets = Rstats::Elements::new_logical(length);
        Rstats::Values::Double* values = elements->get_double_values();
        Rstats::Values::Integer* rets_values = rets->get_integer_values();
        for (IV i = 0; i < length; i++) {
          if(std::isinf((*values)[i])) {
            (*rets_values)[i] = 1;
          }
          else {
            (*rets_values)[i] = 0;
          }
        }
      }
      else {
        rets = Rstats::Elements::new_logical(length, 0);
      }
      
      return rets;
    }

    Rstats::Elements* is_nan(Rstats::Elements* elements) {
      IV length = elements->get_length();
      Rstats::Elements* rets = Rstats::Elements::new_logical(length);
      if (elements->get_type() == Rstats::ElementsType::DOUBLE) {
        Rstats::Values::Double* values = elements->get_double_values();
        Rstats::Values::Integer* rets_values = rets->get_integer_values();
        for (IV i = 0; i < length; i++) {
          if(std::isnan((*values)[i])) {
            (*rets_values)[i] = 1;
          }
          else {
            (*rets_values)[i] = 0;
          }
        }
      }
      else {
        rets = Rstats::Elements::new_logical(length, 0);
      }
      
      return rets;
    }

    Rstats::Elements* is_finite(Rstats::Elements* elements) {
      
      IV length = elements->get_length();
      Rstats::Elements* rets;
      if (elements->is_integer_type()) {
        rets = Rstats::Elements::new_logical(length, 1);
      }
      else if (elements->is_double_type()) {
        Rstats::Values::Double* values = elements->get_double_values();
        rets = Rstats::Elements::new_logical(length);
        Rstats::Values::Integer* rets_values = rets->get_integer_values();
        for (IV i = 0; i < length; i++) {
          if (std::isfinite((*values)[i])) {
            (*rets_values)[i] = 1;
          }
          else {
            (*rets_values)[i] = 0;
          }
        }
      }
      else {
        rets = Rstats::Elements::new_logical(length, 0);
      }
      
      return rets;
    }
  }
}
