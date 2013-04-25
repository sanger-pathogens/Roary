#!/usr/bin/env perl
use Moose;
use Data::Dumper;
use File::Slurp;
use Cwd;

BEGIN { unshift( @INC, './lib' ) }
BEGIN { unshift( @INC, './t/lib' ) }
with 'TestHelper';

BEGIN {
    use Test::Most;
    use_ok('Bio::PanGenome::CommandLine::QueryPanGenome');
}
my $script_name = 'Bio::PanGenome::CommandLine::QueryPanGenome';
my $cwd         = getcwd();

system('touch empty_file');

my %scripts_and_expected_files = (
    '-g t/data/example_groups -n group_2 t/data/example_1.faa t/data/example_2.faa' =>
      [ 'pan_genome_results_group_2.fa', 't/data/expected_output_groups_group_2.fa' ],
    '-g t/data/example_groups -n group_5 t/data/example_1.faa t/data/example_2.faa' =>
      [ 'pan_genome_results_group_5.fa', 't/data/expected_output_groups_group_5.fa' ],
    '-g t/data/example_groups -n group_2,group_5 t/data/example_1.faa t/data/example_2.faa' =>
      [ 'pan_genome_results_group_5.fa', 't/data/expected_output_groups_group_5.fa' ],
    '-g t/data/example_groups -n group_5,group_2 t/data/example_1.faa t/data/example_2.faa' =>
      [ 'pan_genome_results_group_5.fa', 't/data/expected_output_groups_group_5.fa' ],
    '-g t/data/example_groups -n group_5,group_2 t/data/example_1.faa t/data/example_2.faa' =>
      [ 'pan_genome_results_group_2.fa', 't/data/expected_output_groups_group_2.fa' ],
    '-g t/data/example_groups -n group_2,group_5 t/data/example_1.faa t/data/example_2.faa' =>
      [ 'pan_genome_results_group_2.fa', 't/data/expected_output_groups_group_2.fa' ],
    '-g t/data/example_groups t/data/example_1.faa t/data/example_2.faa' =>
      [ 'pan_genome_results', 't/data/expected_pan_genome.fa' ],
    '-g t/data/example_groups -o another_filename t/data/example_1.faa t/data/example_2.faa' =>
      [ 'another_filename', 't/data/expected_pan_genome.fa' ],
    '-g t/data/example_groups -n group_which_doesnt_exist t/data/example_1.faa t/data/example_2.faa' =>
      [ 'empty_file', 't/data/empty_file' ],
);

mock_execute_script_and_check_output( $script_name, \%scripts_and_expected_files );

done_testing();
