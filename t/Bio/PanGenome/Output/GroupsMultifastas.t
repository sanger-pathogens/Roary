#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Slurp;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::PanGenome::Output::GroupsMultifastas');
}

my $plot_groups_obj = Bio::PanGenome::AnalyseGroups->new(
    fasta_files     => [ 't/data/example_1.faa', 't/data/example_2.faa' ],
    groups_filename => 't/data/example_groups'
);

ok(
    my $obj = Bio::PanGenome::Output::GroupsMultifastas->new(
        group_names    => [ 'group_2', 'group_5' ],
        analyse_groups => $plot_groups_obj
    ),
    'initialise creating multiple fastas'
);

ok( $obj->create_files(), 'Create multiple fasta files' );

# Check that the files have been created
ok( -e $obj->output_multifasta_filesoutput_filename_base . '_group_2.fa', 'group created' );
ok( -e $obj->output_filename_base . '_group_5.fa', 'group created' );

is(
    read_file( $obj->output_filename_base . '_group_2.fa' ),
    read_file('t/data/expected_output_groups_group_2_multi.fa'),
    'group 2 contect as expected'
);
is(
    read_file( $obj->output_filename_base . '_group_5.fa' ),
    read_file('t/data/expected_output_groups_group_5_multi.fa'),
    'group 5 contect as expected'
);

#unlink( $obj->output_filename_base . '_group_2.fa' );
#unlink( $obj->output_filename_base . '_group_5.fa' );

done_testing();
