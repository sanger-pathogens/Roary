#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use Cwd;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::Roary::External::Makeblastdb');
}

my $cwd = getcwd();
my $obj;

ok($obj = Bio::Roary::External::Makeblastdb->new(
  fasta_file      => 't/data/some_fasta_file.fa',
  exec            => $cwd.'/t/bin/dummy_makeblastdb',
  mask_data       => 'masking_data_file'
),'initialise object');

is($obj->_command_to_run, $cwd.'/t/bin/dummy_makeblastdb -in t/data/some_fasta_file.fa -dbtype prot -out '.$obj->_working_directory->dirname().'/output_contigs -logfile /dev/null', 'Command constructed as expected');
ok($obj->run(), 'run dummy command');

unlink("output_contigs.phr");
unlink("output_contigs.pin");
unlink("output_contigs.psq");

1;

done_testing();
