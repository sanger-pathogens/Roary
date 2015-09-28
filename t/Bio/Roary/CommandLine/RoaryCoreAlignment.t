#!/usr/bin/env perl
use Moose;
use Data::Dumper;
use Cwd;

BEGIN { unshift( @INC, './lib' ) }
BEGIN { unshift( @INC, './t/lib' ) }
with 'TestHelper';

BEGIN {
    use Test::Most;
    use_ok('Bio::Roary::CommandLine::RoaryCoreAlignment');
}
my $script_name = 'Bio::Roary::CommandLine::RoaryCoreAlignment';
system('touch empty_file');
my %scripts_and_expected_files = (
    '-m t/data/core_alignment -s t/data/core_alignment.csv' =>
      [ 'core_gene_alignment.aln', 't/data/expected_core_gene_alignment.aln' ],
    '-m t/data/core_alignment -s t/data/core_alignment_core0.66.csv --core_definition 0.66' => 
      [ 'core_gene_alignment.aln', 't/data/expected_core_gene_alignment_core0.66.aln' ],
    '-h' =>
      [ 'empty_file', 't/data/empty_file' ],
);

mock_execute_script_and_check_output( $script_name, \%scripts_and_expected_files );

done_testing();
