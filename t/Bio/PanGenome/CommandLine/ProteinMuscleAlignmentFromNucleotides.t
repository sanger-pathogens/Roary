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
    use_ok('Bio::PanGenome::CommandLine::ProteinMuscleAlignmentFromNucleotides');
}
my $script_name = 'Bio::PanGenome::CommandLine::ProteinMuscleAlignmentFromNucleotides';
my $cwd         = getcwd();

my %scripts_and_expected_files = (
    't/data/nuc_multifasta.fa' =>
      [ 't/data/nuc_multifasta.fa.aln', 't/data/expected_nuc_multifasta.fa.aln' ],
);



unlink('t/data/nuc_multifasta.fa.aln');
mock_execute_script_and_check_output( $script_name, \%scripts_and_expected_files );
unlink('t/data/nuc_multifasta.fa.aln');

done_testing();
