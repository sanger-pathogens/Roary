#!/usr/bin/env perl
use Moose;
use Data::Dumper;
use File::Path qw( remove_tree);
use Cwd;

BEGIN { unshift( @INC, './lib' ) }
BEGIN { unshift( @INC, './t/lib' ) }
with 'TestHelper';

BEGIN {
    use Test::Most;
    use_ok('Bio::Roary::CommandLine::RoaryPostAnalysis');
}
my $script_name = 'Bio::Roary::CommandLine::RoaryPostAnalysis';
my $cwd = getcwd();

local $ENV{PATH} = "$ENV{PATH}:./bin";

system('cp t/data/post_analysis/* .');
system('touch empty_file');

my %scripts_and_expected_files = (
       '-o clustered_proteins -p pan_genome.fa -s gene_presence_absence.csv -c _clustered.clstr  -i _gff_files -f _fasta_files  -j Local --dont_create_rplots --dont_split_groups' =>
       [ 'clustered_proteins', 't/data/clustered_proteins_post_analysis' ], 
       '-h' =>
         [ 'empty_file', 't/data/empty_file' ],   
);

SKIP: 
{

  skip "Tests dont take variablity into account", 2 if(1);  
  mock_execute_script_and_check_output_sorted_groups( $script_name, \%scripts_and_expected_files );

  ok( -e 'number_of_unique_genes.Rtab', 'number_of_unique_genes.Rtab exists');
  ok( -e 'number_of_new_genes.Rtab', 'number_of_new_genes exists');
  ok( -e 'number_of_genes_in_pan_genome.Rtab', 'number_of_genes_in_pan_genome exists');
  ok( -e 'number_of_conserved_genes.Rtab','number_of_conserved_genes');
  ok( -e 'gene_presence_absence.csv', 'gene_presence_absence exists');
  ok( -e 'core_accessory.tab', 'core_accessory.tab exists');
  ok( -e 'core_accessory.header.embl','core_accessory.header.embl exists');
  ok( -e 'accessory.tab','accessory.tab exists');
  ok( -e 'accessory.header.embl','accessory.header.embl exists');
  ok( -e 'summary_statistics.txt' ,'summary_statistics.txt exists');
  
  compare_tab_files_with_variable_coordinates('accessory.header.embl', 't/data/post_analysis_expected/accessory.header.embl');
  compare_tab_files_with_variable_coordinates('accessory.tab', 't/data/post_analysis_expected/accessory.tab');
  compare_tab_files_with_variable_coordinates('core_accessory.header.embl', 't/data/post_analysis_expected/core_accessory.header.embl');
  compare_tab_files_with_variable_coordinates('core_accessory.tab', 't/data/post_analysis_expected/core_accessory.tab');
  
  cleanup_files();
  
  system('cp t/data/post_analysis/* .');
  system('touch empty_file');
  %scripts_and_expected_files = (
         '-t 1 -o clustered_proteins -p pan_genome.fa -s gene_presence_absence.csv -c _clustered.clstr  -i _gff_files -f _fasta_files  -j Local --dont_create_rplots --dont_split_groups' =>
         [ 'clustered_proteins', 't/data/clustered_proteins_post_analysis' ], 
         '-h' =>
           [ 'empty_file', 't/data/empty_file' ],   
  );
  
  mock_execute_script_and_check_output_sorted_groups( $script_name, \%scripts_and_expected_files );
  
  ok( -e 'number_of_unique_genes.Rtab', 'number_of_unique_genes.Rtab exists');
  ok( -e 'number_of_new_genes.Rtab', 'number_of_new_genes exists');
  ok( -e 'number_of_genes_in_pan_genome.Rtab', 'number_of_genes_in_pan_genome exists');
  ok( -e 'number_of_conserved_genes.Rtab','number_of_conserved_genes');
  ok( -e 'gene_presence_absence.csv', 'gene_presence_absence exists');
  ok( -e 'core_accessory.tab', 'core_accessory.tab exists');
  ok( -e 'core_accessory.header.embl','core_accessory.header.embl exists');
  ok( -e 'accessory.tab','accessory.tab exists');
  ok( -e 'accessory.header.embl','accessory.header.embl exists');
  
  compare_tab_files_with_variable_coordinates('accessory.header.embl', 't/data/post_analysis_expected/accessory.header.embl');
  compare_tab_files_with_variable_coordinates('accessory.tab', 't/data/post_analysis_expected/accessory.tab');
  compare_tab_files_with_variable_coordinates('core_accessory.header.embl', 't/data/post_analysis_expected/core_accessory.header.embl');
  compare_tab_files_with_variable_coordinates('core_accessory.tab', 't/data/post_analysis_expected/core_accessory.tab');

}
cleanup_files();
done_testing();

sub cleanup_files
{
  unlink('_clustered');
  unlink('_clustered.bak.clstr');
  unlink('_clustered.clstr');
  unlink('_combined_files');
  unlink('_combined_files.groups');
  unlink('_fasta_files');
  unlink('_gff_files');
  unlink('_uninflated_mcl_groups');
  unlink('query_1.gff.proteome.faa');
  unlink('query_2.gff.proteome.faa');
  unlink('query_6.gff.proteome.faa');
  unlink('accessory.header.embl');
  unlink('accessory.tab');
  unlink('core_accessory.header.embl');
  unlink('core_accessory.tab');
  unlink('gene_presence_absence.csv');
  unlink('number_of_unique_genes.Rtab');
  unlink('number_of_new_genes.Rtab');
  unlink('number_of_genes_in_pan_genome.Rtab');
  unlink('number_of_conserved_genes.Rtab');
}


