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
    use_ok('Bio::PanGenome::CommandLine::ExtractProteomeFromGFF');
}
my $script_name = 'Bio::PanGenome::CommandLine::ExtractProteomeFromGFF';
my $cwd         = getcwd();

my %scripts_and_expected_files = (
    't/data/example_annotation.gff' =>
      [' t/data/example_annotation.gff.testing.intermediate.translate.fa','t/data/example_annotation.gff.expected.proteome' ],
);

mock_execute_script_and_check_output( $script_name, \%scripts_and_expected_files );

done_testing();
