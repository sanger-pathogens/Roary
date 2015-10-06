#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;

BEGIN { unshift( @INC, './lib' ) }
$ENV{PATH} .= ":./bin";

BEGIN {
    use Test::Most;
    use_ok('Bio::Roary::GeneNamesFromGFF');
}

my $obj;

ok(
    $obj = Bio::Roary::GeneNamesFromGFF->new(
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

is_deeply(
    $obj->ids_to_gene_size,
    {
        'abc_00012' => 188,
        '1_1'       => 959,
        'abc_00004' => 716,
        'abc_00006' => 725,
        'abc_00008' => 935,
        '1_6'       => 134,
        'abc_00014' => 134,
        'abc_01705' => 1556,
        'abc_00013' => 75,
        'abc_00010' => 227,
        '1_2'       => 725,
        'abc_00011' => 947,
        'abc_00016' => 686,
        '1_3'       => 1001,
        'abc_00002' => 146,
        'abc_00003' => 197
    },
    'ids to gene lengths as expected'
);

ok(
    $obj = Bio::Roary::GeneNamesFromGFF->new(
        gff_file => 't/data/query_2.gff'
    ),
    'initialise reading another GFF file'
);
is_deeply(
    $obj->ids_to_gene_name,
    {
        '2_3'       => 'argF',
        '2_1'       => 'hly',
        '2_2'       => 'speH',
        'abc_00016' => 'yfnB',
        'abc_00008' => 'arcC1'
    },
    'ids to gene names as expected again'
);

ok(
    $obj = Bio::Roary::GeneNamesFromGFF->new(
        gff_file => 't/data/locus_tag_gffs/query_1.gff'
    ),
    'initialise a GFF file with locus tags only'
);

is_deeply(
    $obj->ids_to_gene_name,
    {
        'abc_00005' => 'speH',
        'abc_00007' => 'argF',
        'abc_00001' => 'different',
        'abc_00016' => 'yfnB',
        'abc_00008' => 'arcC1'
    },
    'ids to gene names with GFF file with locus tags only'
);

done_testing();
