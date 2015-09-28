#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
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

compare_ok('t/data/out_of_order_fasta.fa.sorted.fa', 't/data/expected_out_of_order_fasta.fa.sorted.fa', 'check order of sorted fasta');


ok( $obj = Bio::Roary::SortFasta->new(
  input_filename   => 't/data/uneven_sequences.fa',
  make_multiple_of_three => 1,
), 'initalise object with uneven sequences');

ok($obj->sort_fasta, 'sort the fasta file');
compare_ok($obj->output_filename, 't/data/expected_uneven_sequences.fa', "output sequences are now divisible by three");

ok( $obj = Bio::Roary::SortFasta->new(
  input_filename   => 't/data/nnn_at_end.fa',
  remove_nnn_from_end => 1,
), 'initalise object with alignment with nnn at end ');
ok($obj->sort_fasta, 'sort the fasta file and remove nnn at end');
compare_ok($obj->output_filename, 't/data/expected_nnn_at_end.fa', "output sequences are now divisible by three");

ok( $obj = Bio::Roary::SortFasta->new(
  input_filename   => 't/data/uneven_sequences.fa',
  make_multiple_of_three => 1,
  remove_nnn_from_end => 1,
), 'initalise object with uneven sequences and remove nnn from end but nothing to remove');
ok($obj->sort_fasta, 'sort the fasta file');
compare_ok($obj->output_filename, 't/data/expected_uneven_sequences.fa', "output sequences are now divisible by three and no nnn removed");


is(0,$obj->_percentage_similarity("AAA","BBB"), 'totally different');
is(1,$obj->_percentage_similarity("AAA","AAA"), 'all the same');
is(0.5,$obj->_percentage_similarity("AAAA","AABB"), 'half different');
is(1,$obj->_percentage_similarity("AAAA","AAAABB"), 'first half the same');

done_testing();
