#!/usr/bin/env perl
use Moose;
use Data::Dumper;
use Cwd;

BEGIN { unshift( @INC, './lib' ) }
BEGIN { unshift( @INC, './t/lib' ) }
with 'TestHelper';

BEGIN {
    use Test::Most;
    use_ok('Bio::Roary::CommandLine::TransferAnnotationToGroups');
}
my $script_name = 'Bio::Roary::CommandLine::TransferAnnotationToGroups';
my $cwd         = getcwd();
system('touch empty_file');
my %scripts_and_expected_files = (
    '-g t/data/query_groups t/data/query_1.gff t/data/query_2.gff t/data/query_3.gff' =>
      [ 'reannotated_groups', 't/data/expected_reannotated_groups_file' ],
      '-h' =>
        [ 'empty_file', 't/data/empty_file' ],
);

mock_execute_script_and_check_output_sorted( $script_name, \%scripts_and_expected_files );

done_testing();
