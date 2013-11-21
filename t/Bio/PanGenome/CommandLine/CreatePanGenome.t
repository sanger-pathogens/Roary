#!/usr/bin/env perl
use Moose;
use Data::Dumper;
use File::Slurp;
use File::Path qw( remove_tree);
use Cwd;

BEGIN { unshift( @INC, './lib' ) }
BEGIN { unshift( @INC, './t/lib' ) }
with 'TestHelper';

BEGIN {
    use Test::Most;
    use_ok('Bio::PanGenome::CommandLine::CreatePanGenome');
}
my $script_name = 'Bio::PanGenome::CommandLine::CreatePanGenome';
my $cwd = getcwd();

local $ENV{PATH} = "$ENV{PATH}:./bin";

my %scripts_and_expected_files = (
       ' -j Local t/data/query_1.gff t/data/query_2.gff t/data/query_6.gff ' =>
       [ 'clustered_proteins', 't/data/clustered_proteins_pan_genome' ],
      ' -j Local t/data/query_1.gff t/data/query_2.gff t/data/query_6.gff     ' =>
          [ 'group_statisics.csv', 't/data/overall_group_statisics.csv' ],
              
);
mock_execute_script_and_check_output( $script_name, \%scripts_and_expected_files );
cleanup_files();


%scripts_and_expected_files = (
  ' -j Local --output_multifasta_files t/data/query_1.gff t/data/query_2.gff t/data/query_6.gff ' =>
    [ 'pan_genome_sequences/00002-speH.fa.aln', 't/data/00002-speH.fa.aln' ],
);
mock_execute_script_and_check_output( $script_name, \%scripts_and_expected_files );

ok(-e 'accessory.tab');
ok(-e 'core_accessory.tab');
ok(-e 'number_of_conserved_genes.Rtab');
ok(-e 'number_of_genes_in_pan_genome.Rtab');
ok(-e 'number_of_new_genes.Rtab');
ok(-e 'number_of_unique_genes.Rtab');


cleanup_files();


done_testing();


sub cleanup_files
{
  remove_tree('pan_genome_sequences');
  unlink('clustered_proteins');
  unlink('database_masking.asnb');
  unlink('example_1.faa.tmp.filtered.fa');
  unlink('example_2.faa.tmp.filtered.fa');
  unlink('example_3.faa.tmp.filtered.fa');
  unlink('group_statisics.csv');
  unlink('query_1.gff.proteome.faa');
  unlink('query_2.gff.proteome.faa');
  unlink('query_3.gff.proteome.faa');
  unlink('_clustered');
  unlink('_clustered.bak.clstr');
  unlink('pan_genome.fa');
  unlink('core_accessory.header.tab');
  unlink('accessory.header.tab');
  unlink('accessory.tab');
  unlink('core_accessory.tab');
  unlink('number_of_conserved_genes.Rtab');
  unlink('number_of_genes_in_pan_genome.Rtab');
  unlink('number_of_new_genes.Rtab');
  unlink('number_of_unique_genes.Rtab');
  unlink('query_6.gff.proteome.faa');

}