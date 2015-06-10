#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Slurp::Tiny qw(read_file write_file);
use Test::Files;

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


ok( $obj = Bio::Roary::SortFasta->new(
  input_filename   => 't/data/uneven_sequences.fa',
  make_multiple_of_three => 1,
), 'initalise object with uneven sequences');

ok($obj->sort_fasta, 'sort the fasta file');
compare_ok($obj->output_filename, 't/data/expected_uneven_sequences.fa', "output sequences are now divisible by three");


done_testing();
