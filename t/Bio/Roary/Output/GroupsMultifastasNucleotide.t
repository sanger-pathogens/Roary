#!/usr/bin/env perl
use strict;
use warnings;
use File::Path qw( remove_tree);
use Data::Dumper;
use File::Slurp::Tiny qw(read_file write_file);

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use Test::Output;
    use_ok('Bio::Roary::Output::GroupsMultifastasNucleotide');
    use Bio::Roary::AnnotateGroups;
    use Bio::Roary::AnalyseGroups;
    
}

remove_tree('pan_genome_sequences');
my $gff_files = [ 't/data/query_1.gff', 't/data/query_2.gff','t/data/query_3.gff' ];

my $obj;

my $annotate_groups = Bio::Roary::AnnotateGroups->new(
  gff_files       => $gff_files,
  groups_filename => 't/data/query_groups',
);

ok($annotate_groups->reannotate);

ok(
    $obj = Bio::Roary::Output::GroupsMultifastasNucleotide->new(
        group_names     => [ 'group_2', 'group_5' ],
        gff_files       => $gff_files,
        annotate_groups => $annotate_groups,
		dont_delete_files => 1,
    ),
    'initialise creating multiple fastas where you dont delete non core files'
);
ok( $obj->create_files(), 'Create multiple fasta files where you dont delete non core files' );

is(read_file('pan_genome_sequences/hly.fa'),     read_file('t/data/pan_genome_sequences/hly.fa' ), 'Check multifasta content is correct for 3-hly.fa ');
is(read_file('pan_genome_sequences/speH.fa'),    read_file('t/data/pan_genome_sequences/speH.fa' ), 'Check multifasta content is correct for 2-speH.fa ');
is(read_file('pan_genome_sequences/argF.fa'),    read_file('t/data/pan_genome_sequences/argF.fa' ), 'Check multifasta content is correct for 2-argF.fa ');
remove_tree('pan_genome_sequences');


ok(
    $obj = Bio::Roary::Output::GroupsMultifastasNucleotide->new(
        group_names     => [ 'group_2', 'group_5' ],
        gff_files       => $gff_files,
        annotate_groups => $annotate_groups,
		dont_delete_files => 0,
    ),
    'initialise creating multiple fastas where you delete non core files'
);
ok( $obj->create_files(), 'Create multiple fasta files where you delete non core files' );

is(read_file('pan_genome_sequences/hly.fa'),     read_file('t/data/pan_genome_sequences/hly.fa' ), 'Check multifasta content is correct for 3-hly.fa ');
ok(! -e 'pan_genome_sequences/speH.fa', 'Check 2-speH.fa doesnt exist since its non core');
ok(! -e 'pan_genome_sequences/argF.fa', 'Check 2-argF.fa doesnt exist since its non core');
remove_tree('pan_genome_sequences');



# test group number limit
ok(
    $obj = Bio::Roary::Output::GroupsMultifastasNucleotide->new(
        group_names     => [ 'group_2', 'group_5' ],
        gff_files       => $gff_files,
        annotate_groups => $annotate_groups,
        group_limit    => 4
    ),
    'initialise creating multiple fastas'
);
my $exp_stderr = "Number of clusters (8) exceeds limit (4). Multifastas not created. Please check the spreadsheet for contamination from different species or increase the --group_limit parameter.\n";
stderr_is { $obj->create_files() } $exp_stderr, 'multifasta creation fails when group limit exceeded';

done_testing();
