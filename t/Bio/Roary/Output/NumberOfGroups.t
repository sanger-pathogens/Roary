#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use Test::Files;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use Bio::Roary::AnnotateGroups;
    use Bio::Roary::AnalyseGroups;
    use Bio::Roary::GroupStatistics;
    use_ok('Bio::Roary::Output::NumberOfGroups');
}

my $annotate_groups = Bio::Roary::AnnotateGroups->new(
  gff_files   => ['t/data/query_1.gff','t/data/query_2.gff','t/data/query_3.gff'],
  groups_filename => 't/data/query_groups',
);

my $analyse_groups = Bio::Roary::AnalyseGroups->new(
    fasta_files     => ['t/data/query_1.fa','t/data/query_2.fa','t/data/query_3.fa'],
    groups_filename => 't/data/query_groups'
);

my $group_statistics = Bio::Roary::GroupStatistics->new(
  annotate_groups_obj => $annotate_groups,
  analyse_groups_obj  => $analyse_groups 
);

ok(my $obj = Bio::Roary::Output::NumberOfGroups->new(
  group_statistics_obj => $group_statistics,
  annotate_groups_obj      => $annotate_groups
  ),'initialise object');

ok($obj->create_output_files, 'create the raw output file');

ok(-e 'number_of_conserved_genes.Rtab', 'check raw output file created');
compare_ok('t/data/expected_number_of_conserved_genes.tab', 'number_of_conserved_genes.Rtab', 'Content of total groups tab file as expected');
unlink('number_of_conserved_genes.Rtab');

ok(-e 'number_of_new_genes.Rtab', 'check raw output file created');
compare_ok('t/data/expected_number_of_new_genes.tab', 'number_of_new_genes.Rtab', '');
unlink('number_of_new_genes.Rtab');

ok(-e 'number_of_genes_in_pan_genome.Rtab', 'check raw output file created');
compare_ok('t/data/expected_number_of_genes_in_pan_genome.tab', 'number_of_genes_in_pan_genome.Rtab', 'Content of total groups tab file as expected');
unlink('number_of_genes_in_pan_genome.Rtab');

ok(-e 'number_of_unique_genes.Rtab', 'check raw output file created');
compare_ok('t/data/expected_number_of_unique_genes.tab', 'number_of_unique_genes.Rtab', 'Content of unique groups tab file as expected');
unlink('number_of_unique_genes.Rtab');


# Vary the core
ok($obj = Bio::Roary::Output::NumberOfGroups->new(
  group_statistics_obj => $group_statistics,
  annotate_groups_obj      => $annotate_groups,
  core_definition => 0.6
  ),"initialise object with 60 percent core definition");
ok($obj->create_output_files, 'create the raw output files for 60 percent core def');
compare_ok('t/data/expected_number_of_conserved_genes_0.6.tab','number_of_conserved_genes.Rtab', 'Content of conserved genes with 60 percent core def');

unlink('number_of_conserved_genes.Rtab');
unlink('number_of_new_genes.Rtab');
unlink('number_of_genes_in_pan_genome.Rtab');
unlink('number_of_unique_genes.Rtab');
unlink('group_statitics.csv');

done_testing();
