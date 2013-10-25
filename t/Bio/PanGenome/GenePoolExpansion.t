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
    use Bio::PanGenome::GenePoolExpansion;
    use_ok('Bio::PanGenome::GenePoolExpansion');
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

ok(my $obj = Bio::PanGenome::GenePoolExpansion->new(
  group_statistics_obj => $group_statistics
  ),'initialise object');

is(@{$obj->gene_pool_expansion()->[0]},$obj->number_of_iterations, 'gene results from 10 iterations'); 

is_deeply($group_statistics->_sorted_file_names,[
          't/data/query_1.fa',
          't/data/query_2.fa',
          't/data/query_3.fa'], 'Make sure we dont shuffle the original files');

ok($obj->create_plot, 'create the plot');
ok(-e 'gene_count.png', 'plot created');

ok($obj->create_raw_output_file, 'create the raw output file');
ok(-e 'gene_count.tab', 'check raw output file created');

is(read_file('t/data/expected_gene_count.tab'), read_file('gene_count.tab'), '');

unlink('gene_count.tab');
unlink('gene_count.png');
unlink('group_statitics.csv');

done_testing();
