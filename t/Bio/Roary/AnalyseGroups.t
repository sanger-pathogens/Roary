#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;

BEGIN { unshift( @INC, './lib' ) }
$ENV{PATH} .= ":./bin";

BEGIN {
    use Test::Most;
    use_ok('Bio::Roary::AnalyseGroups');
}

ok(
    my $plot_groups_obj = Bio::Roary::AnalyseGroups->new(
        fasta_files     => [ 't/data/example_1.faa', 't/data/example_2.faa' ],
        groups_filename => 't/data/example_groups'
    ),
    'initialise with two fasta files'
);

is( $plot_groups_obj->_number_of_isolates, 2, 'Number of isolates' );

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


is_deeply(
    $plot_groups_obj->_groups_to_genes,
    {
        'group_3' => [ '1234#10_00005', '1234#10_00005' ],
        'group_5' => [ '1234#10_00016' ],
        'group_4' => [ '1234#10_00006', '1234#10_00007' ],
        'group_6' => [ '1234#10_00017' ],
        'group_1' => [ '1234#10_00001', '1234#10_00002' ],
        'group_2' => [ '1234#10_00003', '1234#10_00018', '1234#10_00005' ]
    },
    'Groups to genes hash'
);

is_deeply(
    $plot_groups_obj->_genes_to_groups,
    {
        '1234#10_00003' => 'group_2',
        '1234#10_00017' => 'group_6',
        '1234#10_00001' => 'group_1',
        '1234#10_00016' => 'group_5',
        '1234#10_00007' => 'group_4',
        '1234#10_00006' => 'group_4',
        '1234#10_00018' => 'group_2',
        '1234#10_00005' => 'group_3',
        '1234#10_00002' => 'group_1'
    },
    'genes to groups hash'
);

done_testing();
