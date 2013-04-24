#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Slurp;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::PanGenome::PlotGroups');
}

ok(
    my $plot_groups_obj = Bio::PanGenome::PlotGroups->new(
        fasta_files     => [ 't/data/example_1.faa', 't/data/example_2.faa' ],
        groups_filename => 't/data/example_groups'
    ),
    'initialise with two fasta files'
);

is( $plot_groups_obj->_number_of_isolates, 2, 'Number of isolates' );
is_deeply(
    $plot_groups_obj->_number_of_genes_per_file,
    { 't/data/example_1.faa' => 6, 't/data/example_2.faa' => 3 },
    'Number of genes per file'
);

is_deeply(
    $plot_groups_obj->_genes_to_file,
    {
        '1234#10_00003' => 't/data/example_1.faa',
        '1234#10_00017' => 't/data/example_2.faa',
        '1234#10_00001' => 't/data/example_1.faa',
        '1234#10_00016' => 't/data/example_2.faa',
        '1234#10_00007' => 't/data/example_1.faa',
        '1234#10_00006' => 't/data/example_1.faa',
        '1234#10_00018' => 't/data/example_2.faa',
        '1234#10_00005' => 't/data/example_1.faa',
        '1234#10_00002' => 't/data/example_1.faa'
    },
    'genes map to the correct files'
);

is_deeply( $plot_groups_obj->_freq_groups_per_genome, [ 2, 1, 1, 1, 1, 1 ], 'frequency of groups uniqued by genome' );

done_testing();
