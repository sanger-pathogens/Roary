#!/usr/bin/env perl
use Moose;
use Data::Dumper;
use Cwd;

BEGIN { unshift( @INC, './lib' ) }
BEGIN { unshift( @INC, './t/lib' ) }
with 'TestHelper';

BEGIN {
    use Test::Most;
    use_ok('Bio::Roary::CommandLine::RoaryReorderSpreadsheet');
}
my $script_name = 'Bio::Roary::CommandLine::RoaryReorderSpreadsheet';
system('touch empty_file');
my %scripts_and_expected_files = (
    '-t t/data/reorder_isolates.tre -s t/data/reorder_isolates_input.csv' =>
      [ 'reordered_spreadsheet.csv', 't/data/reorder_isolates_expected_output.csv' ],
    '-t t/data/reorder_isolates.tre -s t/data/reorder_isolates_input.csv -o different_output_name.csv' =>
      [ 'different_output_name.csv', 't/data/reorder_isolates_expected_output.csv' ],
    '-t t/data/reorder_isolates.tre -s t/data/reorder_isolates_input.csv -f newick' =>
      [ 'reordered_spreadsheet.csv', 't/data/reorder_isolates_expected_output.csv' ],
      
    '-t t/data/reorder_isolates.tre -s t/data/reorder_isolates_input.csv -a depth' =>
      [ 'reordered_spreadsheet.csv', 't/data/reorder_isolates_expected_output.csv' ],
    '-t t/data/reorder_isolates.tre -s t/data/reorder_isolates_input.csv -a depth -b height' =>
      [ 'reordered_spreadsheet.csv', 't/data/reorder_isolates_expected_output_depth_height.csv' ],
    '-t t/data/reorder_isolates.tre -s t/data/reorder_isolates_input.csv -a depth -b creation' =>
      [ 'reordered_spreadsheet.csv', 't/data/reorder_isolates_expected_output_depth_creation.csv' ],  
    '-t t/data/reorder_isolates.tre -s t/data/reorder_isolates_input.csv -a depth -b alpha' =>
      [ 'reordered_spreadsheet.csv', 't/data/reorder_isolates_expected_output_depth_alpha.csv' ],
    '-t t/data/reorder_isolates.tre -s t/data/reorder_isolates_input.csv -a depth -b revalpha' =>
      [ 'reordered_spreadsheet.csv', 't/data/reorder_isolates_expected_output_depth_revalpha.csv' ],
      
    '-t t/data/reorder_isolates.tre -s t/data/reorder_isolates_input.csv -a breadth' =>
      [ 'reordered_spreadsheet.csv', 't/data/reorder_isolates_expected_output.csv' ],
    '-t t/data/reorder_isolates.tre -s t/data/reorder_isolates_input.csv -a breadth -b height' =>
      [ 'reordered_spreadsheet.csv', 't/data/reorder_isolates_expected_output_breadth_height.csv' ],
    '-t t/data/reorder_isolates.tre -s t/data/reorder_isolates_input.csv -a breadth -b creation' =>
      [ 'reordered_spreadsheet.csv', 't/data/reorder_isolates_expected_output_breadth_creation.csv' ],  
    '-t t/data/reorder_isolates.tre -s t/data/reorder_isolates_input.csv -a breadth -b alpha' =>
      [ 'reordered_spreadsheet.csv', 't/data/reorder_isolates_expected_output_breadth_alpha.csv' ],
    '-t t/data/reorder_isolates.tre -s t/data/reorder_isolates_input.csv -a breadth -b revalpha' =>
      [ 'reordered_spreadsheet.csv', 't/data/reorder_isolates_expected_output_breadth_revalpha.csv' ],

      '-h' =>
        [ 'empty_file', 't/data/empty_file' ],
);

mock_execute_script_and_check_output( $script_name, \%scripts_and_expected_files );

done_testing();
