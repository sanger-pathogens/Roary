#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use Test::Files;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::Roary::AccessoryBinaryFasta');
}

my $dummy_annotate_groups = Bio::Roary::AnnotateGroups->new(
  gff_files   => ['t/data/query_1.gff','t/data/query_2.gff','t/data/query_3.gff'],
  groups_filename => 't/data/query_groups',
);

my $dummy_analyse_groups = Bio::Roary::AnalyseGroups->new(
    fasta_files     => ['t/data/query_1.fa','t/data/query_2.fa','t/data/query_3.fa'],
    groups_filename => 't/data/query_groups'
);



ok(
    my $obj = Bio::Roary::AccessoryBinaryFasta->new(
        input_files => [ 't/abc/aaa', 't/abc/bbb', 't/abc/ccc', 't/abc/ddd' ],
        groups_to_files => 
		{
            group_1 => { 't/abc/aaa' => [1] },
            group_2 => { 't/abc/aaa' => [1], 't/abc/bbb' => [2] },
            group_3 => { 't/abc/aaa' => [1], 't/abc/bbb' => [2], 't/abc/ccc' => [3] },
            group_4 => { 't/abc/aaa' => [1], 't/abc/bbb' => [2], 't/abc/ccc' => [3], 't/abc/ddd' => [4] },
        },
		annotate_groups_obj => $dummy_annotate_groups,
		analyse_groups_obj  => $dummy_analyse_groups
    ),
    'initialise accessory binary fasta file'
);

ok( $obj->create_accessory_binary_fasta(), 'create output file' );

compare_ok( 'accessory_binary_genes.fa', 't/data/expected_accessory_binary_genes.fa','binary accessory fasta file created');


done_testing();
