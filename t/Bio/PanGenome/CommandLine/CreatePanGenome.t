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
    use_ok('Bio::PanGenome::CommandLine::CreatePanGenome');
}
my $script_name = 'Bio::PanGenome::CommandLine::CreatePanGenome';
my $cwd = getcwd();


my %scripts_and_expected_files = (
      ' -j Local t/data/example_1.faa t/data/example_2.faa t/data/example_3.faa' =>
        [ 'clustered_proteins', 't/data/expected_clustered_proteins' ],
      ' -j Local t/data/example_1.faa t/data/example_2.faa t/data/example_3.faa ' =>
          [ 'pan_genome.fa', 't/data/expected_create_pan_genome.fa' ],
);

unlink('freq_of_genes.png');

mock_execute_script_and_check_output( $script_name, \%scripts_and_expected_files );

done_testing();