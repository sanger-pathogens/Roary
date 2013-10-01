#!/usr/bin/env perl
use strict;
use warnings;
use File::Path qw( remove_tree);
use Data::Dumper;
use File::Slurp;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::PanGenome::Output::GroupsMultifastasNucleotide');
}

my $gff_files = [ 't/data/query_1.gff', 't/data/query_2.gff','t/data/query_3.gff' ];

my $plot_groups_obj = Bio::PanGenome::AnalyseGroups->new(
    fasta_files     => $gff_files,
    groups_filename => 't/data/query_groups'
);

ok(
    my $obj = Bio::PanGenome::Output::GroupsMultifastasNucleotide->new(
        group_names    => [ 'group_2', 'group_5' ],
        gff_files      => $gff_files,
        analyse_groups => $plot_groups_obj
    ),
    'initialise creating multiple fastas'
);

ok( $obj->create_files(), 'Create multiple fasta files' );

is(read_file('pan_genome_sequences/3-group_1.fa'), read_file('t/data/pan_genome_sequences/3-group_1.fa' ), 'Check multifasta content is correct for 3-group_1.fa ');
is(read_file('pan_genome_sequences/2-group_3.fa'), read_file('t/data/pan_genome_sequences/2-group_3.fa' ), 'Check multifasta content is correct for 2-group_3.fa ');
is(read_file('pan_genome_sequences/2-group_2.fa'), read_file('t/data/pan_genome_sequences/2-group_2.fa' ), 'Check multifasta content is correct for 2-group_2.fa ');
is(read_file('pan_genome_sequences/1-group_7.fa'), read_file('t/data/pan_genome_sequences/1-group_7.fa' ), 'Check multifasta content is correct for 1-group_7.fa ');
is(read_file('pan_genome_sequences/1-group_6.fa'), read_file('t/data/pan_genome_sequences/1-group_6.fa' ), 'Check multifasta content is correct for 1-group_6.fa ');
is(read_file('pan_genome_sequences/1-group_5.fa'), read_file('t/data/pan_genome_sequences/1-group_5.fa' ), 'Check multifasta content is correct for 1-group_5.fa ');

remove_tree('pan_genome_sequences');

done_testing();
