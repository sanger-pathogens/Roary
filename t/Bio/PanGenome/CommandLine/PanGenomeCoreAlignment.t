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
    use_ok('Bio::PanGenome::CommandLine::PanGenomeCoreAlignment');
}
my $script_name = 'Bio::PanGenome::CommandLine::PanGenomeCoreAlignment';

my %scripts_and_expected_files = (
    '-m t/data/core_alignment -s t/data/core_alignment.csv' =>
      [ 'core_gene_alignment.aln', 't/data/expected_core_gene_alignment.aln' ],
);

mock_execute_script_and_check_output( $script_name, \%scripts_and_expected_files );

done_testing();
