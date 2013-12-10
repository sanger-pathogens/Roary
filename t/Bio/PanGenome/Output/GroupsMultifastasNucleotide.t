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
    use Bio::PanGenome::AnnotateGroups;
    use Bio::PanGenome::AnalyseGroups;
    
}

remove_tree('pan_genome_sequences');
my $gff_files = [ 't/data/query_1.gff', 't/data/query_2.gff','t/data/query_3.gff' ];


my $annotate_groups = Bio::PanGenome::AnnotateGroups->new(
  gff_files       => $gff_files,
  groups_filename => 't/data/query_groups',
);

$annotate_groups->reannotate;

ok(
    my $obj = Bio::PanGenome::Output::GroupsMultifastasNucleotide->new(
        group_names    => [ 'group_2', 'group_5' ],
        gff_files      => $gff_files,
        annotate_groups => $annotate_groups
    ),
    'initialise creating multiple fastas'
);
ok( $obj->create_files(), 'Create multiple fasta files' );

is(read_file('pan_genome_sequences/00003-hly.fa'),     read_file('t/data/pan_genome_sequences/00003-hly.fa' ), 'Check multifasta content is correct for 3-hly.fa ');
is(read_file('pan_genome_sequences/00002-speH.fa'),    read_file('t/data/pan_genome_sequences/00002-speH.fa' ), 'Check multifasta content is correct for 2-speH.fa ');
is(read_file('pan_genome_sequences/00002-argF.fa'),    read_file('t/data/pan_genome_sequences/00002-argF.fa' ), 'Check multifasta content is correct for 2-argF.fa ');
is(read_file('pan_genome_sequences/00001-group_7.fa'), read_file('t/data/pan_genome_sequences/00001-group_7.fa' ), 'Check multifasta content is correct for 1-group_7.fa ');
is(read_file('pan_genome_sequences/00001-group_6.fa'), read_file('t/data/pan_genome_sequences/00001-group_6.fa' ), 'Check multifasta content is correct for 1-group_6.fa ');
is(read_file('pan_genome_sequences/00001-yfnB.fa'),    read_file('t/data/pan_genome_sequences/00001-yfnB.fa' ), 'Check multifasta content is correct for 1-yfnB.fa ');
remove_tree('pan_genome_sequences');

done_testing();
