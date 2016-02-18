#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use Test::Files;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::Roary::AssemblyStatistics');
}

my $obj;
ok( $obj = Bio::Roary::AssemblyStatistics->new( spreadsheet => 't/data/input_block_spreadsheet.csv' ), 'initialise spreadsheet' );

my @genes = sort keys %{ $obj->_genes_to_rows };
is_deeply(
    \@genes,
    [
        'SBOV29371', 'SBOV38871', 'SBOV43201',  'STY3593',    'STY4162',    'bcsC_1',     'betC_2',     'comM_2',
        'dmsA4_1',   'dosC',      'dsbA_3',     'fadH_1',     'fimD_3',     'fliB_2',     'fliF',       'ftsN',
        'gatY_1',    'glfT2',     'group_1000', 'group_1001', 'group_1004', 'group_1006', 'group_1009', 'group_220',
        'group_277', 'group_281', 'group_283',  'group_284',  'group_288',  'hemD',       'hsrA_2',     'icsA',
        'kdpD',      'ligB_1',    'marT_1',     'nepI',       'rffH',       'rpoS',       'selA_1',     'speC_3',
        'sptP',      'srgB',      'stp',        'tmcA',       'tub',        'yadA',       'ybbW_1',     'yhaO_2',
        'yicJ_1',    'yigZ'
    ],
    'all gene rows available'
);

is_deeply(
    $obj->ordered_genes,
    [
        'dmsA4_1',    'group_1000', 'group_1001', 'SBOV43201', 'dosC',      'stp',    'fliB_2', 'fliF',
        'dsbA_3',     'srgB',       'fimD_3',     'betC_2',    'tmcA',      'tub',    'rffH',   'hemD',
        'group_1006', 'STY3593',    'group_1004', 'yigZ',      'group_220', 'glfT2',  'kdpD',   'speC_3',
        'ybbW_1',     'sptP',       'SBOV29371',  'rpoS',      'fadH_1',    'yhaO_2', 'bcsC_1', 'STY4162',
        'yadA',       'ligB_1',     'icsA',       'marT_1',    'selA_1',    'nepI',   'gatY_1', 'SBOV38871',
        'group_288',  'hsrA_2',     'group_281',  'group_283', 'group_284', 'yicJ_1', 'ftsN',   'group_277',
        'group_1009', 'comM_2'
    ],
    'ordered genes'
);

is_deeply(
    $obj->sample_names_to_column_index,
    {
        'threeblocks'          => 18,
        'nocontigs'            => 17,
        'contigwithgaps'       => 16,
        'oneblock'             => 14,
        'threeblocksinversion' => 19,
        'oneblockrev'          => 15
    },
    'sample names to column index'
);

is_deeply( $obj->_sample_statistics('oneblock'),    { num_blocks => 1, largest_block_size => 50 }, 'one block' );
is_deeply( $obj->_sample_statistics('oneblockrev'), { num_blocks => 1, largest_block_size => 50 }, 'one block reversed' );
is_deeply(
    $obj->_sample_statistics('contigwithgaps'),
    { num_blocks => 1, largest_block_size => 50 },
    'one block where there are gaps everywhere'
);
is_deeply( $obj->_sample_statistics('nocontigs'),   { num_blocks => 50, largest_block_size => 1 },  'no contiguous blocks' );
is_deeply( $obj->_sample_statistics('threeblocks'), { num_blocks => 3,  largest_block_size => 21 }, 'three blocks' );
is_deeply(
    $obj->_sample_statistics('threeblocksinversion'),
    { num_blocks => 3, largest_block_size => 20 },
    'three blocks with an inversion in the middle'
);
is_deeply( $obj->gene_category_count, { core => 50 }, 'Gene category counts' );

# t/data/gene_category_count.csv
ok( $obj = Bio::Roary::AssemblyStatistics->new( spreadsheet => 't/data/gene_category_count.csv' ),
    'initialise spreadsheet with variable numbers of genes in samples' );
is_deeply(
    $obj->gene_category_count,
    {
        'core'      => 1,
        'cloud'     => 4,
        'soft_core' => 1,
        'shell'     => 24
    },
    'Categories as expected'
);
ok($obj->create_summary_output, 'create output file');
compare_ok('summary_statistics.txt', 't/data/expected_summary_statistics.txt', 'summary statistics as expected');


# t/data/gene_category_count.csv
ok( $obj = Bio::Roary::AssemblyStatistics->new( spreadsheet => 't/data/gene_category_count.csv', core_definition => 0.9667 ),
    'initialise spreadsheet with core of 96.67%' );
is_deeply(
    $obj->gene_category_count,
    {
        'core'      => 1,
		'soft_core' => 1,
        'cloud'     => 4,
        'shell'     => 24
    },
    'Categories as expected with cd of 96.67%'
);

# t/data/gene_category_count.csv
ok( $obj = Bio::Roary::AssemblyStatistics->new( spreadsheet => 't/data/gene_category_count.csv', core_definition => 0.9666 ),
    'initialise spreadsheet with core of 96.66%' );
is_deeply(
    $obj->gene_category_count,
    {
        'core'      => 2,
        'cloud'     => 4,
        'shell'     => 24
    },
    'Categories as expected with cd of 96.66%'
);


unlink('summary_statistics.txt');
done_testing();
