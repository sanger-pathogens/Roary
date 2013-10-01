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


my %scripts_and_expected_files = (
      ' -j Local t/data/example_1.faa t/data/example_2.faa t/data/example_3.faa ' =>
        [ 'clustered_proteins', 't/data/expected_clustered_proteins' ],
      ' -j Local t/data/example_1.faa t/data/example_2.faa t/data/example_3.faa  ' =>
        [ 'pan_genome.fa', 't/data/expected_create_pan_genome.fa' ],
      ' -j Local --output_multifasta_files t/data/query_1.gff t/data/query_2.gff t/data/query_3.gff ' =>
        [ 'pan_genome_sequences/3-group_9.fa', 't/data/3-group_9.fa' ],
              
);

unlink('freq_of_genes.png');

mock_execute_script_and_check_output( $script_name, \%scripts_and_expected_files );

remove_tree('pan_genome_sequences');

unlink('clustered_proteins');
unlink('database_masking.asnb');
unlink('example_1.faa.tmp.filtered.fa');
unlink('example_2.faa.tmp.filtered.fa');
unlink('example_3.faa.tmp.filtered.fa');
unlink('freq_of_genes.png');
unlink('group_statisics.csv');
unlink('query_1.gff.proteome.faa');
unlink('query_2.gff.proteome.faa');
unlink('query_3.gff.proteome.faa');

done_testing();