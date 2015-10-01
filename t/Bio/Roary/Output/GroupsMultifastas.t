#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use Test::Files;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::Roary::Output::GroupsMultifastas');
}

my $plot_groups_obj = Bio::Roary::AnalyseGroups->new(
    fasta_files     => [ 't/data/example_1.faa', 't/data/example_2.faa' ],
    groups_filename => 't/data/example_groups'
);

ok(
    my $obj = Bio::Roary::Output::GroupsMultifastas->new(
        group_names    => [ 'group_2', 'group_5' ],
        analyse_groups => $plot_groups_obj
    ),
    'initialise creating multiple fastas'
);

ok( $obj->create_files(), 'Create multiple fasta files' );

# Check that the files have been created
ok( -e $obj->output_filename_base . '_group_2.fa', $obj->output_filename_base . '_group_2.fa'.' group created' );
ok( -e $obj->output_filename_base . '_group_5.fa', $obj->output_filename_base . '_group_2.fa'.' group created' );

compare_ok( $obj->output_filename_base . '_group_2.fa' ,
    't/data/expected_output_groups_group_2_multi.fa',
    'group 2 contect as expected'
);
compare_ok( $obj->output_filename_base . '_group_5.fa' ,
    't/data/expected_output_groups_group_5_multi.fa',
    'group 5 contect as expected'
);

unlink( $obj->output_filename_base . '_group_2.fa' );
unlink( $obj->output_filename_base . '_group_5.fa' );

done_testing();
