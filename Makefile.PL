use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => 'Mojolicious::Plugin::Mojocron',
  VERSION_FROM => 'lib/Mojolicious/Plugin/Mojocron.pm',
  AUTHOR       => 'A Good Programmer <nospam@cpan.org>',
  PREREQ_PM    => {'Mojolicious' => '7.85'},
  test         => {TESTS => 't/*.t'}
);
