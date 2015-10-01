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

ok(
    $obj = Bio::Roary::GeneNamesFromGFF->new(
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
