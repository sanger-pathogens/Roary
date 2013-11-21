#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Slurp;


BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use Bio::PanGenome::AnnotateGroups;
    use Bio::PanGenome::AnalyseGroups;
    use Bio::PanGenome::GroupStatistics;
    use_ok('Bio::PanGenome::Output::NumberOfGroups');
}

my $annotate_groups = Bio::PanGenome::AnnotateGroups->new(
  gff_files   => ['t/data/query_1.gff','t/data/query_2.gff','t/data/query_3.gff'],
  groups_filename => 't/data/query_groups',
);

my $analyse_groups = Bio::PanGenome::AnalyseGroups->new(
    fasta_files     => ['t/data/query_1.fa','t/data/query_2.fa','t/data/query_3.fa'],
    groups_filename => 't/data/query_groups'
);

my $group_statistics = Bio::PanGenome::GroupStatistics->new(
  annotate_groups_obj => $annotate_groups,
  analyse_groups_obj  => $analyse_groups 
);

ok(my $obj = Bio::PanGenome::Output::NumberOfGroups->new(
  group_statistics_obj => $group_statistics,
  annotate_groups_obj      => $annotate_groups
  ),'initialise object');

ok($obj->create_output_files, 'create the raw output file');

ok(-e 'number_of_conserved_genes.Rtab', 'check raw output file created');
is(read_file('t/data/expected_number_of_conserved_genes.tab'), read_file('number_of_conserved_genes.Rtab'), 'Content of total groups tab file as expected');
unlink('number_of_conserved_genes.Rtab');

ok(-e 'number_of_new_genes.Rtab', 'check raw output file created');
is(read_file('t/data/expected_number_of_new_genes.tab'), read_file('number_of_new_genes.Rtab'), '');
unlink('number_of_new_genes.Rtab');

ok(-e 'number_of_genes_in_pan_genome.Rtab', 'check raw output file created');
is(read_file('t/data/expected_number_of_genes_in_pan_genome.tab'), read_file('number_of_genes_in_pan_genome.Rtab'), 'Content of total groups tab file as expected');
unlink('number_of_genes_in_pan_genome.Rtab');

ok(-e 'number_of_unique_genes.Rtab', 'check raw output file created');
is(read_file('t/data/expected_number_of_unique_genes.tab'), read_file('number_of_unique_genes.Rtab'), 'Content of unique groups tab file as expected');
unlink('number_of_unique_genes.Rtab');

unlink('group_statitics.csv');

done_testing();
