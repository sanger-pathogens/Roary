#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Slurp;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::PanGenome::FilterFullClusters');
}

ok(my $filter_clusters = Bio::PanGenome::FilterFullClusters->new(
    clusters_filename        => 't/data/clusters_to_inflate',
    fasta_file           =>  't/data/clusters_input.fa',
    number_of_input_files => 5,
    output_file => 'output_filtered.fa'
  ),'initialise object');
ok($filter_clusters->filter_full_clusters_from_fasta(),'filter the clusters');

is(read_file('output_filtered.fa'), read_file('t/data/expected_output_filtered.fa'), 'content as expected');


unlink('output_filtered.fa');

done_testing();
