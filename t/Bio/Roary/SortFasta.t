#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Slurp::Tiny qw(read_file write_file);

BEGIN { unshift( @INC, './lib' ) }
$ENV{PATH} .= ":./bin";

BEGIN {
    use Test::Most;
    use_ok('Bio::Roary::SortFasta');
}

my $obj;


ok( $obj = Bio::Roary::SortFasta->new(
  input_filename   => 't/data/out_of_order_fasta.fa',
), 'initalise object');


ok($obj->sort_fasta, 'sort the fasta file');
ok(-e 't/data/out_of_order_fasta.fa.sorted.fa', 'the new file exists');

is(read_file('t/data/out_of_order_fasta.fa.sorted.fa'), read_file('t/data/expected_out_of_order_fasta.fa.sorted.fa'), 'check order of sorted fasta');



done_testing();
