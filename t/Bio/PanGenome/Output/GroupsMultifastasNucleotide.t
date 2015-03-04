#!/usr/bin/env perl
use strict;
use warnings;
use File::Path qw( remove_tree);
use Data::Dumper;
use File::Slurp;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use Test::Output;
    use_ok('Bio::PanGenome::Output::GroupsMultifastasNucleotide');
    use Bio::PanGenome::AnnotateGroups;
    use Bio::PanGenome::AnalyseGroups;
    
}

remove_tree('pan_genome_sequences');
my $gff_files = [ 't/data/query_1.gff', 't/data/query_2.gff','t/data/query_3.gff' ];

my $obj;

my $annotate_groups = Bio::PanGenome::AnnotateGroups->new(
  gff_files       => $gff_files,
  groups_filename => 't/data/query_groups',
);

$annotate_groups->reannotate;

ok(
    $obj = Bio::PanGenome::Output::GroupsMultifastasNucleotide->new(
        group_names     => [ 'group_2', 'group_5' ],
        gff_files       => $gff_files,
        annotate_groups => $annotate_groups
    ),
    'initialise creating multiple fastas'
);
ok( $obj->create_files(), 'Create multiple fasta files' );

is(read_file('pan_genome_sequences/hly.fa'),     read_file('t/data/pan_genome_sequences/hly.fa' ), 'Check multifasta content is correct for 3-hly.fa ');
is(read_file('pan_genome_sequences/speH.fa'),    read_file('t/data/pan_genome_sequences/speH.fa' ), 'Check multifasta content is correct for 2-speH.fa ');
is(read_file('pan_genome_sequences/argF.fa'),    read_file('t/data/pan_genome_sequences/argF.fa' ), 'Check multifasta content is correct for 2-argF.fa ');
remove_tree('pan_genome_sequences');

# test group number limit
ok(
    $obj = Bio::PanGenome::Output::GroupsMultifastasNucleotide->new(
        group_names     => [ 'group_2', 'group_5' ],
        gff_files       => $gff_files,
        annotate_groups => $annotate_groups,
        group_limit    => 4
    ),
    'initialise creating multiple fastas'
);
my $exp_stderr = "Number of clusters (8) exceeds limit (4). Multifastas not created. Please check the spreadsheet for contamination from different species.\n";
stderr_is { $obj->create_files() } $exp_stderr, 'multifasta creation fails when group limit exceeded';

done_testing();
