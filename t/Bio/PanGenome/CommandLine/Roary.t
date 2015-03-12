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
    use_ok('Bio::PanGenome::CommandLine::Roary');
	use_ok('Bio::PanGenome::CommandLine::CreatePanGenome');
    use Bio::PanGenome::SequenceLengths;
}
my $script_name = 'Bio::PanGenome::CommandLine::Roary';
my $cwd = getcwd();

local $ENV{PATH} = "$ENV{PATH}:./bin";
my %scripts_and_expected_files;
system('touch empty_file');

%scripts_and_expected_files = (
      ' --dont_split_groups   t/data/query_1.gff t/data/query_2.gff t/data/query_5.gff ' =>
        [ 'clustered_proteins', 't/data/clustered_proteins_pan_genome' ],
      ' --dont_split_groups   t/data/query_1.gff t/data/query_2.gff t/data/query_5.gff    ' =>
        [ 'gene_presence_absence.csv', 't/data/overall_gene_presence_absence.csv' ],     
      ' -t 1 --dont_split_groups   t/data/query_1.gff t/data/query_2.gff t/data/query_5.gff    ' =>
        [ 'gene_presence_absence.csv', 't/data/overall_gene_presence_absence.csv' ],
      ' -j Parallel --dont_split_groups  t/data/query_1.gff t/data/query_2.gff t/data/query_5.gff ' =>
        [ 'clustered_proteins', 't/data/clustered_proteins_pan_genome' ],
      ' -j Parallel  --dont_split_groups t/data/query_1.gff t/data/query_2.gff t/data/query_5.gff    ' =>
        [ 'gene_presence_absence.csv', 't/data/overall_gene_presence_absence.csv' ],     
      ' -t 1 -j Parallel --dont_split_groups  t/data/query_1.gff t/data/query_2.gff t/data/query_5.gff    ' =>
        [ 'gene_presence_absence.csv', 't/data/overall_gene_presence_absence.csv' ],
      '-h' =>
        [ 'empty_file', 't/data/empty_file' ],
);
mock_execute_script_and_check_output_sorted( $script_name, \%scripts_and_expected_files, [0,6,7,8,9] );
cleanup_files();

%scripts_and_expected_files = (
  ' -j Local --dont_split_groups  --output_multifasta_files --dont_delete_files t/data/real_data_1.gff t/data/real_data_2.gff' =>
    [ 'pan_genome_sequences/flgM.fa.aln', 't/data/flgM.fa.aln' ],
);
mock_execute_script_and_check_output( $script_name, \%scripts_and_expected_files );
ok(-e 'core_gene_alignment.aln', 'Core gene alignment exists');

ok(my $seq_len = Bio::PanGenome::SequenceLengths->new(
  fasta_file   => 'core_gene_alignment.aln',
), 'Check size of the core_gene_alignment.aln init');

is($seq_len->sequence_lengths->{'11111_1#11'}, 58389, 'length of first sequence');

ok(-e 'accessory.tab');
ok(-e 'core_accessory.tab');
ok(-e 'number_of_conserved_genes.Rtab');
ok(-e 'number_of_genes_in_pan_genome.Rtab');
ok(-e 'number_of_new_genes.Rtab');
ok(-e 'number_of_unique_genes.Rtab');
ok(-e 'blast_identity_frequency.Rtab');

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
  unlink('gene_presence_absence.csv');
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
  unlink('query_5.gff.proteome.faa');
  unlink('core_gene_alignment.aln');  
  unlink('blast_identity_frequency.Rtab');
  unlink('real_data_1.gff.proteome.faa');
  unlink('real_data_2.gff.proteome.faa');
  unlink('accessory.header.embl');
  unlink('core_accessory.header.embl');

}