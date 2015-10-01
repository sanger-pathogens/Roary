#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Slurper 'read_text';
use Test::Files;

BEGIN { unshift( @INC, './lib' ) }
$ENV{PATH} .= ":./bin";

BEGIN {
    use Test::Most;
    use_ok('Bio::Roary::OrderGenes');
    use Bio::Roary::AnalyseGroups;
}

my $no_accessory_100 = order_genes_obj( 't/data/accessory_graphs/no_accessory', 1 );
my $no_accessory_50  = order_genes_obj( 't/data/accessory_graphs/no_accessory', 0.5 );

my $one_bubble_100 = order_genes_obj( 't/data/accessory_graphs/one_bubble', 1 );
my $one_bubble_50  = order_genes_obj( 't/data/accessory_graphs/one_bubble', 0.5 );

my $one_branch_100 = order_genes_obj( 't/data/accessory_graphs/one_branch', 1 );
my $one_branch_50  = order_genes_obj( 't/data/accessory_graphs/one_branch', 0.5 );

my $two_graphs_100 = order_genes_obj( 't/data/accessory_graphs/two_graphs', 1 );
my $two_graphs_50  = order_genes_obj( 't/data/accessory_graphs/two_graphs', 0.5 );

my $single_gene_100 = order_genes_obj( 't/data/accessory_graphs/single_gene_contig', 1 );
my $single_gene_50  = order_genes_obj( 't/data/accessory_graphs/single_gene_contig', 0.5 );

my $core_deletion_100 = order_genes_obj( 't/data/accessory_graphs/core_deletion', 1 );
my $core_deletion_50  = order_genes_obj( 't/data/accessory_graphs/core_deletion', 0.5 );

my $core_island_100 = order_genes_obj( 't/data/accessory_graphs/core_island', 1 );
my $core_island_50  = order_genes_obj( 't/data/accessory_graphs/core_island', 0.5 );

cleanup();
my $analyse_groups = Bio::Roary::AnalyseGroups->new(
    fasta_files     => [ 't/data/accessory_graphs/file_1.fa', 't/data/accessory_graphs/file_2.fa', 't/data/accessory_graphs/file_3.fa' ],
    groups_filename => 't/data/accessory_graphs/core_island'
);

ok(
    my $obj = Bio::Roary::OrderGenes->new(
        analyse_groups_obj => $analyse_groups,
        gff_files => [ 't/data/accessory_graphs/file_1.gff', 't/data/accessory_graphs/file_2.gff', 't/data/accessory_graphs/file_3.gff' ],
        core_definition => 1,
        sample_weights  => { 'file_1' => 0.5, 'file_2' => 1, 'file_3' => 0.1 }
    ),
    "Initialise order genes object for sample weights"
);
ok( $obj->groups_to_contigs,       'build the graph for sample weights' );
ok( -e 'core_accessory_graph.dot', 'core accessory graph created for sample weights' );
ok( -e 'accessory_graph.dot',      'accessory graph created for sample weights' );

my $actual_graph = read_text('accessory_graph.dot');
$actual_graph =~ s/group_[\w]/group_X/gi;
is_deeply( $actual_graph, read_text('t/data/expected_sample_weights_accessory_graph.dot'), 'graph weights changed' );

# Check how the final graphs get reordered.

$obj = Bio::Roary::OrderGenes->new(
    analyse_groups_obj => $analyse_groups,
    gff_files       => [ 't/data/accessory_graphs/file_1.gff', 't/data/accessory_graphs/file_2.gff', 't/data/accessory_graphs/file_3.gff' ],
    core_definition => 1,
    sample_weights      => { 'file_1' => 0.5,  'file_2' => 1,    'file_3' => 0.1 },
    samples_to_clusters => { 's1'     => 'c1', 's2'     => 'c1', 's3'     => 'c2', 's4' => 'c2' },
);

my @paths_and_weights = (
    {
        path           => [ 'g1', 'g2' ],
        average_weight => 3,
        sample_names   => [ 's1', 's2' ]
    },
    {
        path           => [ 'g5', 'g6' ],
        average_weight => 2,
        sample_names   => [ 's3', 's4' ]
    },
    {
        path           => [ 'g3', 'g4' ],
        average_weight => 1,
        sample_names   => [ 's1', 's2' ]
    }
);
my @expected_path_order = ( [ 'g1', 'g2' ], [ 'g3', 'g4' ], [ 'g5', 'g6' ] );
is_deeply( $obj->_order_by_samples_and_weights( \@paths_and_weights ), \@expected_path_order, 'graphs reordered as expected' );

cleanup();
done_testing();

sub order_genes_obj {
    my ( $groups_filename, $core_definition ) = @_;

    cleanup();
    my $analyse_groups = Bio::Roary::AnalyseGroups->new(
        fasta_files => [ 't/data/accessory_graphs/file_1.fa', 't/data/accessory_graphs/file_2.fa', 't/data/accessory_graphs/file_3.fa' ],
        groups_filename => $groups_filename
    );

    ok(
        my $obj = Bio::Roary::OrderGenes->new(
            analyse_groups_obj => $analyse_groups,
            gff_files =>
              [ 't/data/accessory_graphs/file_1.gff', 't/data/accessory_graphs/file_2.gff', 't/data/accessory_graphs/file_3.gff' ],
            core_definition => $core_definition
        ),
        "Initialise order genes object for $groups_filename"
    );

    ok( $obj->groups_to_contigs, 'build the graph' );
    check_all_groups_in_output_graph( $groups_filename, $obj->groups_to_contigs, $core_definition );
    ok( -e 'core_accessory_graph.dot', 'core accessory graph created' );
    ok( -e 'accessory_graph.dot',      'accessory graph created' );

    return $obj;
}

sub check_all_groups_in_output_graph {
    my ( $groups_filename, $groups_to_contigs, $core_definition ) = @_;

    open( my $groups_in, $groups_filename );
    while (<$groups_in>) {
        chomp;
        my $line = $_;
        next if ( $line eq '' );
        my ( $group, $attributes ) = split( ':', $line );
        ok( ( $groups_to_contigs->{$group} ), "group $group found in file $groups_filename" );

        # Check to see if the accessory groups are tagged properly
        $attributes =~ s/ //gi;
        my @sequence_ids = split( /\t/, $attributes );
        if ( @sequence_ids >= 3 * $core_definition ) {
            ok( !defined( $groups_to_contigs->{$group}->{accessory_label} ), "group $group is core so shouldnt have any accessory labels" );
        }
        else {
            ok( defined( $groups_to_contigs->{$group}->{accessory_label} ), "group $group is accessory so should have accessory label" );
        }
    }
}

sub cleanup {
    unlink('core_accessory_graph.dot');
    unlink('accessory_graph.dot');
}

