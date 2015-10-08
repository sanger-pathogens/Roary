#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use Test::Files;

BEGIN { unshift( @INC, './lib' ) }
$ENV{PATH} .= ":./bin";

BEGIN {
    use Test::Most;
    use_ok('Bio::Roary::PresenceAbsenceMatrix');
    use Bio::Roary::AnnotateGroups;
}
my $obj;
my $annotate_groups = Bio::Roary::AnnotateGroups->new(
    gff_files       => [ 't/data/query_1.gff', 't/data/query_2.gff', 't/data/query_3.gff' ],
    groups_filename => 't/data/query_groups',
);

my $sorted_file_names = [ 't/data/query_1.fa', 't/data/query_2.fa', 't/data/query_3.fa' ];
my $groups_to_files = {
    'group_3' => {
        't/data/query_1.fa' => [ '1_3' ],
        't/data/query_3.fa' => [ '3_3' ]
    },
    'group_5' => {
        't/data/query_3.fa' => [ '3_5' ]
    },
    'group_7' => {
        't/data/query_2.fa' => [ '2_7' ]
    },
    'group_4' => {
        't/data/query_3.fa' => [ '3_4' ],
        't/data/query_2.fa' => [ '2_4' ]
    },
    'group_1' => {
        't/data/query_1.fa' => [ '1_1' ],
        't/data/query_3.fa' => [ '3_1' ],
        't/data/query_2.fa' => [ '2_1' ]
    },
    'group_6' => {
        't/data/query_1.fa' => [ '1_6' ]
    },
    'group_2' => {
        't/data/query_1.fa' => [ '1_2' ],
        't/data/query_2.fa' => [ '2_2' ]
    }
};
my $num_files_in_groups = {
    'group_3' => 2,
    'group_5' => 1,
    'group_7' => 1,
    'group_4' => 2,
    'group_1' => 3,
    'group_6' => 1,
    'group_2' => 2
};
my $sample_headers = [ 'query_1.fa', 'query_2.fa', 'query_3.fa' ];

ok(
    $obj = Bio::Roary::PresenceAbsenceMatrix->new(
        annotate_groups_obj => $annotate_groups,
        output_filename     => 'test_gene_presence_absence.Rtab',
        sorted_file_names   => $sorted_file_names,
        groups_to_files     => $groups_to_files,
        num_files_in_groups => $num_files_in_groups,
        sample_headers      => $sample_headers,
    ),
    'initialise object'
);

ok( $obj->create_matrix_file,             'create matrix file' );
ok( -e 'test_gene_presence_absence.Rtab', 'matrix file exists' );
compare_ok( 'test_gene_presence_absence.Rtab', 't/data/expected_gene_presence_and_absence.Rtab', 'Rtab matrix content as expected' );

# one gene one group
$groups_to_files = {'group_1' => {'t/data/query_1.fa' => [ '1_1' ]}};
$num_files_in_groups = {'group_1' => 1};

ok(
    $obj = Bio::Roary::PresenceAbsenceMatrix->new(
        annotate_groups_obj => $annotate_groups,
        output_filename     => 'test_gene_presence_absence.Rtab',
        sorted_file_names   => $sorted_file_names,
        groups_to_files     => $groups_to_files,
        num_files_in_groups => $num_files_in_groups,
        sample_headers      => $sample_headers,
    ),
    'initialise object one gene one group'
);

ok( $obj->create_matrix_file,             'create matrix file one gene one group' );
compare_ok( 'test_gene_presence_absence.Rtab', 't/data/expected_one_gene_presence_and_absence.Rtab', 'Rtab matrix content as expected for one gene one group' );

unlink('test_gene_presence_absence.Rtab');
done_testing();
