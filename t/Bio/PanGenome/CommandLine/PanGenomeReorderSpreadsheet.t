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
    use_ok('Bio::PanGenome::CommandLine::PanGenomeReorderSpreadsheet');
}
my $script_name = 'Bio::PanGenome::CommandLine::PanGenomeReorderSpreadsheet';

my %scripts_and_expected_files = (
    '-t t/data/reorder_isolates.tre -s t/data/reorder_isolates_input.csv' =>
      [ 'reordered_spreadsheet.csv', 't/data/reorder_isolates_expected_output.csv' ],
    '-t t/data/reorder_isolates.tre -s t/data/reorder_isolates_input.csv -o different_output_name.csv' =>
      [ 'different_output_name.csv', 't/data/reorder_isolates_expected_output.csv' ],
    '-t t/data/reorder_isolates.tre -s t/data/reorder_isolates_input.csv -f newick' =>
      [ 'reordered_spreadsheet.csv', 't/data/reorder_isolates_expected_output.csv' ],
);

mock_execute_script_and_check_output( $script_name, \%scripts_and_expected_files );

done_testing();
