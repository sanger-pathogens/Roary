#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use Test::Files;

BEGIN { unshift( @INC, './lib' ) }
$ENV{PATH} .= ":./bin";

BEGIN {
    use Test::Most;
    use_ok('Bio::Roary::GroupStatistics');
}

my $annotate_groups = Bio::Roary::AnnotateGroups->new(
  gff_files   => ['t/data/query_1.gff','t/data/query_2.gff','t/data/query_3.gff'],
  groups_filename => 't/data/query_groups',
);

my $analyse_groups = Bio::Roary::AnalyseGroups->new(
    fasta_files     => ['t/data/query_1.fa','t/data/query_2.fa','t/data/query_3.fa'],
    groups_filename => 't/data/query_groups'
);

my $obj;

ok($obj = Bio::Roary::GroupStatistics->new(
  annotate_groups_obj => $annotate_groups,
  analyse_groups_obj  => $analyse_groups 
),'Initialise group statistics object');
ok($obj->create_spreadsheet,'Create the CSV file');
ok(-e 'gene_presence_absence.csv', 'CSV file exists');
compare_ok('gene_presence_absence.csv','t/data/expected_group_statitics.csv', 'Spreadsheet content as expected');
ok($obj->create_rtab,'Create the Rtab file');
ok(-e 'gene_presence_absence.Rtab', 'Rtab file exists');
compare_ok('gene_presence_absence.Rtab','t/data/expected_gene_presence_and_absence.Rtab', 'Rtab matrix content as expected');

unlink('gene_presence_absence.csv');
unlink('gene_presence_absence.Rtab');

############################

my $annotate_groups_2 = Bio::Roary::AnnotateGroups->new(
  gff_files   => ['t/data/query_1.gff','t/data/query_2.gff','t/data/query_3.gff','t/data/query_4_missing_genes.gff'],
  groups_filename => 't/data/query_groups_missing_genes',
);

my $analyse_groups_2 = Bio::Roary::AnalyseGroups->new(
    fasta_files     => ['t/data/query_1.fa','t/data/query_2.fa','t/data/query_3.fa','t/data/query_4_missing_genes.fa'],
    groups_filename => 't/data/query_groups_missing_genes'
);

ok($obj = Bio::Roary::GroupStatistics->new(
  annotate_groups_obj => $annotate_groups_2,
  analyse_groups_obj  => $analyse_groups_2,
  output_filename     => 'missing_genes_stats.csv' 
),'Initialise group statistics object where one isolate has only 1 gene');
ok($obj->create_spreadsheet,'Create the CSV file');
ok(-e 'missing_genes_stats.csv', 'CSV file exists');
compare_ok('missing_genes_stats.csv','t/data/expected_group_statitics_missing_genes.csv', 'Spreadsheet content as expected with missing genes');

unlink('missing_genes_stats.csv');


## TEST VERBOSE STATS ##

ok($obj = Bio::Roary::GroupStatistics->new(
  annotate_groups_obj => $annotate_groups,
  analyse_groups_obj  => $analyse_groups,
  _verbose            => 1,
  output_filename     => 'verbose_stats.csv'
),'Initialise group statistics object');
ok($obj->create_spreadsheet,'Create the CSV file');
ok(-e 'verbose_stats.csv', 'CSV file exists');
compare_ok('verbose_stats.csv','t/data/expected_group_statitics_verbose.csv', 'Verbose spreadsheet content as expected');

unlink('verbose_stats.csv');

done_testing();
