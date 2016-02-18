#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;

BEGIN { unshift( @INC, './lib' ) }
$ENV{PATH} .= ":./bin";

BEGIN {
    use Test::Most;
    use_ok('Bio::Roary::ContigsToGeneIDsFromGFF');
}

ok(
    my $obj = Bio::Roary::ContigsToGeneIDsFromGFF->new(
        gff_file => 't/data/query_1.gff'
    ),
    'Initialise contigs to gene ids obj'
);

is_deeply(
    $obj->contig_to_ids,
    {
        'abc|SC|contig000001' => [
            '1_1',       'abc_00002', 'abc_00003', 'abc_00004', '1_2',       'abc_00006', '1_3', 'abc_00008',
            'abc_01705', 'abc_00010', 'abc_00011', 'abc_00012', 'abc_00013', 'abc_00014', '1_6', 'abc_00016'
        ]
    },
    'Contigs match expected with standard output'
);

ok(
    $obj = Bio::Roary::ContigsToGeneIDsFromGFF->new(
        gff_file => 't/data/query_1_alternative_patterns.gff'
    ),
    'Initialise contigs to gene ids obj with alternative ID patterns'
);
is_deeply(
    $obj->contig_to_ids,
    {
        'abc|SC|contig000001' => [ '1_1', 'abc_00002', 'abc_00003', 'abc_00004', '1_2', 'abc_00006' ]
    },
    'Contigs match expected with alternative output'
);

is_deeply(
    $obj->_genes_annotation,
    [
        {
            'database_annotation_exists' => 1,
            'product'                    => 'superantigen-like protein',
            'end'                        => '3337',
            'start'                      => '2621',
            'contig'                     => 'abc|SC|contig000001',
            'id_name'                    => 'abc_00004'
        },
        {
            'database_annotation_exists' => 1,
            'product'                    => 'hypothetical protein',
            'end'                        => '4170',
            'start'                      => '3445',
            'contig'                     => 'abc|SC|contig000001',
            'id_name'                    => '1_2'
        },
        {
            'database_annotation_exists' => 1,
            'product'                    => 'superantigen-like protein',
            'end'                        => '4990',
            'start'                      => '4265',
            'contig'                     => 'abc|SC|contig000001',
            'id_name'                    => 'abc_00006'
        }
    ],
    'Product annotation with non standard format'
);
done_testing();
