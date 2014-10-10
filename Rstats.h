#include <complex>
namespace Rstats {

  // Rstats::Elementtype
  namespace ElementType {
    enum Enum {
      NA = 0,
      LOGICAL = 1,
      INTEGER = 2,
      DOUBLE = 4,
      COMPLEX = 8,
      CHARACTER = 16,
      UNKNOWN = 32
    };
  }
  
  // Rstats::Element
  typedef struct {
    union {
      int iv;
      double dv;
      char* chv;
      void* pv;
    };
    Rstats::ElementType::Enum type;
  } Element;
  
  // Rstats::ElementFunc
  namespace ElementFunc {
    
    Rstats::Element* integer(int iv) {
      
      Rstats::Element* e1 = new Rstats::Element;
      e1->iv = iv;
      e1->type = Rstats::ElementType::INTEGER;
      
      return e1;
    }

    Rstats::ElementType::Enum check_type(const Element* e1, const Element* e2) {
      if (e1->type == e2->type) {
        return e1->type;
      }
      else {
        return Rstats::ElementType::UNKNOWN;
      }
    }
    
    void add(Element* e1, const Element* e2) {
      Rstats::ElementType::Enum type = check_type(e1, e2);
      
      if (type == Rstats::ElementType::NA) {
        e1->type = Rstats::ElementType::NA;
      }
      else if (e2->type == Rstats::ElementType::INTEGER) {
        e1->iv += e2->iv;
      }
      else if (e2->type == Rstats::ElementType::DOUBLE) {
        e1->dv += e2->dv;
      }
      else if (e2->type == Rstats::ElementType::COMPLEX) {
        *((std::complex<double>*)e1->pv) += *((std::complex<double>*)e2->pv);
      }
    }
  }
  
  // Rstats::ElementFunc
  namespace ElementsFunc {
    void process(void (*func)(Element*, const Element*), Rstats::Element* elements1, const Rstats::Element* elements2, size_t size) {
      for (int i = 0; i < size; i++) {
        (*func)(elements1 + i, elements2 + i);
      }
    }
    
    void add(Rstats::Element* elements1, const Rstats::Element* elements2, size_t size) {
      process(Rstats::ElementFunc::add, elements1, elements2, size);
    }
  }
  
  // Rstats::Util
  namespace Util {
    unsigned int index_to_pos (int* index, int index_len, int* dim_values, int dim_values_len) {
      
      int pos = 0;
      for (int i = 0; i < dim_values_len; i++) {
        if (i > 0) {
          int tmp = 1;
          for (int k = 0; k < i; k++) {
            tmp *= dim_values[k];
          }
          pos += tmp * (index[i] - 1);
        }
        else {
          pos += index[i];
        }
      }
      
      return pos - 1;
    }
  }
}
