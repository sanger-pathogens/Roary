#!/usr/bin/env perl
use Moose;
use Data::Dumper;
use Cwd;

BEGIN { unshift( @INC, './lib' ) }
BEGIN { unshift( @INC, './t/lib' ) }
with 'TestHelper';

BEGIN {
    use Test::Most;
    use_ok('Bio::Roary::CommandLine::QueryRoary');
}
my $script_name = 'Bio::Roary::CommandLine::QueryRoary';
my $cwd         = getcwd();

system('touch empty_file');
system('touch empty_file2');

my %scripts_and_expected_files = (
    '-g t/data/example_groups -a gene_multifasta -n group_2 t/data/example_1.faa t/data/example_2.faa' =>
      [ 'pan_genome_results_group_2.fa', 't/data/expected_output_groups_group_2.fa' ],
    '-g t/data/example_groups -a gene_multifasta -n group_5 t/data/example_1.faa t/data/example_2.faa ' =>
      [ 'pan_genome_results_group_5.fa', 't/data/expected_output_groups_group_5.fa' ],
    '-g t/data/example_groups -a gene_multifasta -n group_2,group_5 t/data/example_1.faa t/data/example_2.faa' =>
      [ 'pan_genome_results_group_5.fa', 't/data/expected_output_groups_group_5.fa' ],
    '-g t/data/example_groups -a gene_multifasta -n group_5,group_2 t/data/example_1.faa t/data/example_2.faa ' =>
      [ 'pan_genome_results_group_5.fa', 't/data/expected_output_groups_group_5.fa' ],
    '-g t/data/example_groups -a gene_multifasta -n group_5,group_2 t/data/example_1.faa t/data/example_2.faa  ' =>
      [ 'pan_genome_results_group_2.fa', 't/data/expected_output_groups_group_2.fa' ],
    '-g t/data/example_groups -a gene_multifasta -n group_2,group_5 t/data/example_1.faa t/data/example_2.faa   ' =>
      [ 'pan_genome_results_group_2.fa', 't/data/expected_output_groups_group_2.fa' ],
    '-g t/data/example_groups -n group_which_doesnt_exist t/data/example_1.faa t/data/example_2.faa' =>
      [ 'empty_file', 't/data/empty_file' ],
    '-g t/data/query_groups -a union t/data/query_1.fa t/data/query_2.fa t/data/query_3.fa' =>
      [ 'pan_genome_results', 't/data/expected_union_of_groups.gg' ],
    '-g t/data/query_groups -a intersection t/data/query_1.fa t/data/query_2.fa t/data/query_3.fa' =>
      [ 'pan_genome_results', 't/data/expected_intersection_of_groups.gg' ],
    '-g t/data/query_groups -a complement t/data/query_1.fa t/data/query_2.fa t/data/query_3.fa' =>
      [ 'pan_genome_results', 't/data/expected_complement_of_groups.gg' ],
    '-g t/data/query_groups -a difference -i t/data/query_1.fa -t t/data/query_2.fa,t/data/query_3.fa' =>
      [ 'set_difference_unique_set_one', 't/data/expected_set_difference_unique_set_one' ],
    '-g t/data/query_groups -a difference  -i t/data/query_1.fa -t t/data/query_2.fa,t/data/query_3.fa' =>
      [ 'set_difference_unique_set_two', 't/data/expected_set_difference_unique_set_two' ],
    '-g t/data/query_groups -a difference   -i t/data/query_1.fa -t t/data/query_2.fa,t/data/query_3.fa' =>
      [ 'set_difference_common_set', 't/data/expected_set_difference_common_set' ],
    '-g t/data/query_groups -a difference   -i t/data/query_1.fa -t t/data/query_2.fa,t/data/query_3.fa ' =>
      [ 'set_difference_unique_set_two_statistics.csv', 't/data/expected_set_difference_unique_set_two_statistics.csv' ],
    '-g t/data/query_groups -a difference   -i t/data/query_1.fa -t t/data/query_2.fa,t/data/query_3.fa     ' =>
      [ 'set_difference_unique_set_one_statistics.csv', 't/data/expected_set_difference_unique_set_one_statistics.csv' ],
    '-g t/data/query_groups -a difference   -i t/data/query_1.fa -t t/data/query_2.fa,t/data/query_3.fa   ' =>
      [ 'set_difference_common_set_statistics.csv', 't/data/expected_set_difference_common_set_statistics.csv' ],
    '-g t/data/query_groups -a difference   -i t/data/query_1.gff -t t/data/query_2.gff,t/data/query_3.gff' =>
      [ 'set_difference_common_set_statistics.csv', 't/data/expected_gff_set_difference_common_set_statistics.csv' ],
    '-h' => [ 'empty_file2', 't/data/empty_file' ],
);

mock_execute_script_and_check_output_sorted( $script_name, \%scripts_and_expected_files );

unlink('set_difference_unique_set_two')                if ( -e 'set_difference_unique_set_two' );
unlink('set_difference_common_set')                    if ( -e 'set_difference_common_set' );
unlink('pan_genome_results_group_5.fa')                if ( -e 'pan_genome_results_group_5.fa' );
unlink('gene_presence_absence.csv')                    if ( -e 'gene_presence_absence.csv' );
unlink('set_difference_unique_set_two_statistics.csv') if ( -e 'set_difference_unique_set_two_statistics.csv' );
unlink('set_difference_unique_set_one_statistics.csv') if ( -e 'set_difference_unique_set_one_statistics.csv' );
unlink('set_difference_common_set_statistics.csv')     if ( -e 'set_difference_common_set_statistics.csv' );
unlink('pan_genome_reference.fa')                      if ( -e 'pan_genome_reference.fa' );
unlink('set_difference_core_accessory_graph.dot')      if ( -e 'set_difference_core_accessory_graph.dot' );
unlink('set_difference_accessory_graph.dot')           if ( -e 'set_difference_accessory_graph.dot' );

done_testing();
