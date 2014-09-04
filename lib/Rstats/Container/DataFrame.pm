package Rstats::Container::DataFrame;
use Rstats::Container::List -base;

use overload '""' => \&to_string,
  fallback => 1;

use Rstats::Func;

use Text::UnicodeTable::Simple;
{
  package Text::UnicodeTable::Simple;
  no warnings 'redefine';
  sub _decide_alignment {
    # always ALIGN_RIGHT;
    return 2;
  }
}

sub to_string {
  my $self = shift;

  my $t = Text::UnicodeTable::Simple->new(border => 0);
  
  # Names
  my $names = $self->names->values;
  $t->set_header('', @$names);
  
  # columns
  my $columns = [];
  for (my $i = 1; $i <= @$names; $i++) {
    push @$columns, $self->get($i)->elements;
  }
  
  my $col_count = @{$columns};
  my $row_count = @{$columns->[0]};
  
  for (my $i = 0; $i < $row_count; $i++) {
    my @row;
    push @row, $i + 1;
    for (my $k = 0; $k < $col_count; $k++) {
      push @row, $columns->[$k][$i];
    }
    $t->add_row(@row);
  }
  
  return "$t";
}

1;
