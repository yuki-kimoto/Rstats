use strict;
use warnings;
use ExtUtils::MakeMaker;

# Check if exists clan++ or g++ compiler
my $cc;
my $ld;
if (system("g++ --version") == 0) {
  $cc = 'g++';
  $ld = 'g++';
}
else {
  print "g++ is not exists. fallback to clang++";
  $cc = 'clang++';
  $ld = 'clang++';
}

WriteMakefile(
    NAME                => 'Rstats',
    AUTHOR              => 'Yuki Kimoto <kimoto.yuki@gmail.com>',
    VERSION_FROM        => 'lib/Rstats.pm',
    ABSTRACT_FROM       => 'lib/Rstats.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Object::Simple' => '3.10',
        'Math::Round' => '0.06',
        'Text::UnicodeTable::Simple' => '0.09'
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Rstats-*' },
    CC => $cc,
    OPTIMIZE => '-O3',
    LD => $ld,
    LIBS              => [''],
    DEFINE            => '',
    INC               => '-I.',
    OBJECT            => '$(O_FILES)',
);
