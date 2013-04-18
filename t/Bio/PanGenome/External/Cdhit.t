#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use Cwd;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::PanGenome::External::Cdhit');
}

my $cwd = getcwd();
my $obj;

ok($obj = Bio::PanGenome::External::Cdhit->new(
  input_file   => 't/data/some_fasta_file.fa',
  output_base  => 'output',
  exec         =>  $cwd.'/t/bin/dummy_cd-hit',
),'initialise object');

is($obj->_command_to_run, $cwd.'/t/bin/dummy_cd-hit -i t/data/some_fasta_file.fa -o output -T 1 -M 1000 -g 1 -s 0.9 -c 0.95 2> /dev/null', 'Command constructed as expected');
ok($obj->run(), 'run dummy command');
unlink('output');
unlink('output.clstr');
unlink('output.bak.clstr');

done_testing();
