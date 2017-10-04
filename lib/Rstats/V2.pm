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
use SPVM 'Math';

sub c {
  my ($r, $values) = @_;
  
  my $r_data = SPVM::new_object("Rstats::Object");
  
  $r_data->set(type => SPVM::Rstats::Object::TYPE_DOUBLE());
  
  my $sp_values = SPVM::new_double_array($values);
  
  $r_data->set(double_values => $sp_values);
  
  return $r_data;
}

sub pi {
  my ($r, $values) = @_;
  
  my $r_data = SPVM::new_object("Rstats::Object");
  
  $r_data->set(type => SPVM::Rstats::Object::TYPE_DOUBLE());
  
  my $sp_values = SPVM::new_double_array([SPVM::Math::PI()]);
  
  $r_data->set(double_values => $sp_values);
  
  return $r_data;
}
