#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use Cwd;


BEGIN { unshift( @INC, './lib' ) }
use Bio::Roary::External::Makeblastdb;
BEGIN {
    use Test::Most;
    use_ok('Bio::Roary::External::Blastp');
}

my $cwd = getcwd();
my $obj;

ok($obj = Bio::Roary::External::Blastp->new(
  fasta_file      => 't/data/some_fasta_file.fa',
  blast_database  => 'some_blast_database',
  exec            => $cwd.'/t/bin/dummy_blastp',
),'initialise object');

is($obj->_command_to_run, $cwd.'/t/bin/dummy_blastp -query t/data/some_fasta_file.fa -db some_blast_database -evalue 1e-06 -num_threads 1 -outfmt 6 -max_target_seqs 2000  | awk \'{ if ($3 > 98) print $0;}\' 2> /dev/null 1>  results.out', 'Command constructed as expected');
ok($obj->run(), 'run dummy command');
unlink('results.out');

done_testing();
















