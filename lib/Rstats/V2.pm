package Rstats::V2;
use strict;
use warnings;

use Object::Simple -base;
require Rstats::Func;
use Carp 'croak';
use Rstats::Util ();
use Digest::MD5 'md5_hex';
use Rstats::Object;

use SPVM 'Rstats::Object';
use SPVM 'Rstats::Vector';
use SPVM 'Math';

sub c {
  my ($r, $values) = @_;
  
  my $sp_object = SPVM::new_object("Rstats::Object");
  
  $sp_object->set(type => SPVM::Rstats::Object::TYPE_DOUBLE());
  
  my $sp_values = SPVM::new_double_array($values);
  
  $sp_object->set(double_values => $sp_values);
  
  return $sp_object;
}

sub sin {
  my ($r, $r_object_in) = @_;
  
  my $sp_values_in = $r_object_in->get('double_value');
  
  my $r_object_out = SPVM::new_object("Rstats::Object");
  $r_object_out->set(type => SPVM::Rstats::Object::TYPE_DOUBLE());
  
  my $sp_values_out = SPVM::Rstats::Vector::sin($sp_values_in);
  $r_object_out->set(double_values => $sp_values_out);
  
  return $r_object_out;
}

sub pi {
  my ($r, $values) = @_;
  
  my $r_object = SPVM::new_object("Rstats::Object");
  
  $r_object->set(type => SPVM::Rstats::Object::TYPE_DOUBLE());
  
  my $sp_values = SPVM::new_double_array([SPVM::Math::PI()]);
  
  $r_object->set(double_values => $sp_values);
  
  return $r_object;
}
