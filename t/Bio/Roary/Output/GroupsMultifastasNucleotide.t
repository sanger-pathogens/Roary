#!/usr/bin/env perl
use strict;
use warnings;
use File::Path qw( remove_tree);
use Data::Dumper;
use Test::Files;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use Test::Output;
    use_ok('Bio::Roary::Output::GroupsMultifastasNucleotide');
    use Bio::Roary::AnnotateGroups;
    use Bio::Roary::AnalyseGroups;
    
}

cleanup_files();
my $gff_files = [ 't/data/query_1.gff', 't/data/query_2.gff','t/data/query_3.gff' ];

my $obj;

my $annotate_groups = Bio::Roary::AnnotateGroups->new(
  gff_files       => $gff_files,
  groups_filename => 't/data/query_groups_reference',
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

compare_ok('pan_genome_sequences/hly.fa', 't/data/pan_genome_sequences/hly.fa', 'Check multifasta content is correct for 3-hly.fa');
compare_ok('pan_genome_sequences/speH.fa','t/data/pan_genome_sequences/speH.fa','Check multifasta content is correct for 2-speH.fa');
compare_ok('pan_genome_sequences/argF.fa','t/data/pan_genome_sequences/argF.fa','Check multifasta content is correct for 2-argF.fa');
ok(-e 'pan_genome_reference.fa','pan genome reference file created');
compare_ok('pan_genome_reference.fa', 't/data/expected_g2_g5_pan_genome_reference.fa', 'pan genome reference as expected');

cleanup_files();


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

compare_ok('pan_genome_sequences/hly.fa', 't/data/pan_genome_sequences/hly.fa' , 'Check multifasta content is correct for 3-hly.fa ');
ok(! -e 'pan_genome_sequences/speH.fa', 'Check 2-speH.fa doesnt exist since its non core');
ok(! -e 'pan_genome_sequences/argF.fa', 'Check 2-argF.fa doesnt exist since its non core');
cleanup_files();



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

cleanup_files();

done_testing();


sub cleanup_files {
    remove_tree('pan_genome_sequences');
    unlink('reannotated_groups_file');
    unlink('pan_genome_reference.fa');
}