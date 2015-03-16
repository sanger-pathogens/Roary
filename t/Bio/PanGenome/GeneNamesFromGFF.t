#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Slurp;

BEGIN { unshift( @INC, './lib' ) }
$ENV{PATH} .= ":./bin";

BEGIN {
    use Test::Most;
    use_ok('Bio::PanGenome::GeneNamesFromGFF');
}

my $obj;

ok(
    $obj = Bio::PanGenome::GeneNamesFromGFF->new(
        gff_file => 't/data/query_1.gff'
    ),
    'initialise reading GFF file'
);
is_deeply(
    $obj->ids_to_gene_name,
    {
        '1_3'       => 'argF',
        '1_1'       => 'different',
        '1_2'       => 'speH',
        'abc_00016' => 'yfnB',
        'abc_00008' => 'arcC1'
    },
    'ids to gene names as expected'
);

ok(
    $obj = Bio::PanGenome::GeneNamesFromGFF->new(
        gff_file => 't/data/query_2.gff'
    ),
    'initialise reading another GFF file'
);
is_deeply(
    $obj->ids_to_gene_name,
    {
              '2_3' => 'argF',
              '2_1' => 'hly',
              '2_2' => 'speH',
              'abc_00016' => 'yfnB',
              'abc_00008' => 'arcC1'
            },
    'ids to gene names as expected again'
);

done_testing();
