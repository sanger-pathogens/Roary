#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use Moose;
use Test::Files;
use File::Slurper qw(read_lines);
BEGIN { unshift( @INC, './t/lib' ) }
with 'TestHelper';

BEGIN { unshift( @INC, './lib' ) }
$ENV{PATH} .= ":./bin";

BEGIN {
    use Test::Most;
    use_ok('Bio::Roary::AnnotateGroups');
}

my $obj;

ok(
    $obj = Bio::Roary::AnnotateGroups->new(
        gff_files       => [ 't/data/query_1.gff', 't/data/query_2.gff', 't/data/query_3.gff' ],
        groups_filename => 't/data/query_groups',
    ),
    'initalise'
);

ok( $obj->reannotate, 'reannotate' );
is_deeply(
    $obj->_ids_to_gene_size,
    {
        'abc_00012' => 188,
        '2_3'       => 1001,
        '1_1'       => 959,
        'abc_00004' => 716,
        '3_3'       => 1001,
        '3_2'       => 725,
        '2_2'       => 725,
        'abc_00006' => 725,
        'abc_00008' => 935,
        '1_6'       => 134,
        'abc_00015' => 134,
        '3_1'       => 959,
        'abc_00014' => 134,
        'abc_01705' => 1556,
        'abc_00013' => 75,
        'abc_00010' => 227,
        '1_2'       => 725,
        'abc_00011' => 947,
        'abc_00016' => 686,
        '2_7'       => 134,
        '1_3'       => 1001,
        '2_1'       => 959,
        '3_5'       => 686,
        'abc_00002' => 146,
        'abc_00003' => 197
    },
    'gene lengths as expected'
);

is_deeply(
    $obj->group_nucleotide_lengths,
    {
        'group_3' => {
            'average' => 1001,
            'min'     => 1001,
            'max'     => 1001
        },
        'group_5' => {
            'average' => 686,
            'min'     => 686,
            'max'     => 686
        },
        'group_7' => {
            'average' => 134,
            'min'     => 134,
            'max'     => 134
        },
        'group_1' => {
            'average' => 959,
            'min'     => 959,
            'max'     => 959
        },
        'group_6' => {
            'average' => 134,
            'min'     => 134,
            'max'     => 134
        },
        'group_2' => {
            'average' => 725,
            'min'     => 725,
            'max'     => 725
        }
    },
    'group lengths'
);

compare_files( 'reannotated_groups_file', 't/data/expected_reannotated_groups_file', 'groups reannotated as expected' );

unlink('reannotated_groups_file');


ok(
    $obj = Bio::Roary::AnnotateGroups->new(
        gff_files       => [ 't/data/gene_name_field/annotation_1.gff', 't/data/gene_name_field/annotation_2.gff' ],
        groups_filename => 't/data/gene_name_field/groups',
    ),
    'initalise where gene key is replaced by Name'
);
ok( $obj->reannotate, 'reannotate' );
compare_files('reannotated_groups_file',
    't/data/gene_name_field/expected_reannotated_groups_file',
    'Reannoated groups file has the gene names transferred'
);
unlink('reannotated_groups_file');

done_testing();

