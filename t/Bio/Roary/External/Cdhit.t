#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use Cwd;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::Roary::External::Cdhit');
}

my $cwd = getcwd();
my $obj;

ok($obj = Bio::Roary::External::Cdhit->new(
  input_file   => 't/data/some_fasta_file.fa',
  output_base  => 'output',
  exec         =>  $cwd.'/t/bin/dummy_cd-hit',
),'initialise object');

is($obj->_command_to_run, $cwd.'/t/bin/dummy_cd-hit -i t/data/some_fasta_file.fa -o output -T 1 -M 1800 -g 1 -s 1 -d 256 -c 1 > /dev/null 2>&1', 'Command constructed as expected');
ok($obj->run(), 'run dummy command');
unlink('output');
unlink('output.clstr');
unlink('output.bak.clstr');


ok($obj = Bio::Roary::External::Cdhit->new(
  input_file   => 't/data/some_fasta_file.fa',
  output_base  => 'output',
  exec         =>  $cwd.'/t/bin/dummy_cd-hit',
  cpus         => 1000
),'initialise object with lots of threads');
is($obj->_command_to_run, $cwd.'/t/bin/dummy_cd-hit -i t/data/some_fasta_file.fa -o output -T 40 -M 1800 -g 1 -s 1 -d 256 -c 1 > /dev/null 2>&1', 'number of threads capped at a lower level');


done_testing();
