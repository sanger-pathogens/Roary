#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Slurp::Tiny qw(read_file write_file);

BEGIN { unshift( @INC, './lib' ) }
$ENV{PATH} .= ":./bin";

BEGIN {
    use Test::Most;
    use_ok('Bio::Roary::FilterFullClusters');
}

ok(my $filter_clusters = Bio::Roary::FilterFullClusters->new(
    clusters_filename        => 't/data/clusters_to_inflate',
    fasta_file           =>  't/data/clusters_input.fa',
    number_of_input_files => 6,
    output_file => 'output_filtered.fa',
    _greater_than_or_equal => 1,
    cdhit_input_fasta_file => 't/data/clusters_to_inflate_original_input.fa',
    cdhit_output_fasta_file => 'filtered_original_input.fa',
    output_groups_file => 'output_groups',
  ),'initialise object');
ok($filter_clusters->filter_full_clusters_from_fasta(),'filter the clusters');
ok($filter_clusters->filter_complete_cluster_from_original_fasta(),'filter original input and save full groups');


is(read_file('output_filtered.fa'), read_file('t/data/expected_output_filtered.fa'), 'content as expected');

is(read_file('output_groups'), read_file('t/data/expected_output_groups_cdhit'), 'content as expected');
is(read_file('filtered_original_input.fa'), read_file('t/data/expected_filtered_original_input.fa'), 'content as expected');

unlink('output_groups');
unlink('filtered_original_input.fa');
unlink('output_filtered.fa');

done_testing();
