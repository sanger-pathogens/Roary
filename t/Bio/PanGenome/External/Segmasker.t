#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use Cwd;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::PanGenome::External::Segmasker');
}

my $cwd = getcwd();
my $obj;

ok($obj = Bio::PanGenome::External::Segmasker->new(
  fasta_file      => 't/data/some_fasta_file.fa',
  exec            => $cwd.'/t/bin/dummy_segmasker',
),'initialise object');

is($obj->_command_to_run, $cwd.'/t/bin/dummy_segmasker -in t/data/some_fasta_file.fa -infmt fasta -parse_seqids -outfmt maskinfo_asn1_bin -out database_masking.asnb', 'Command constructed as expected');
ok($obj->run(), 'run dummy command');

ok(-e 'database_masking.asnb' ,'output file exists');
unlink('database_masking.asnb');

1;

done_testing();
