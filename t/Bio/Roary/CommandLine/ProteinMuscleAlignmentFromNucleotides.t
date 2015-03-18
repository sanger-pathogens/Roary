#!/usr/bin/env perl
use Moose;
use Data::Dumper;
use File::Slurp::Tiny qw(read_file write_file);
use Cwd;
use File::Which;

BEGIN { unshift( @INC, './lib' ) }
BEGIN { unshift( @INC, './t/lib' ) }
with 'TestHelper';

BEGIN {
    use Test::Most;
    use_ok('Bio::Roary::CommandLine::ProteinMuscleAlignmentFromNucleotides');
}

my $script_name = 'Bio::Roary::CommandLine::ProteinMuscleAlignmentFromNucleotides';
my $cwd         = getcwd();
system('touch empty_file');
my %scripts_and_expected_files = (
    't/data/nuc_multifasta.fa' =>
      [ 't/data/nuc_multifasta.fa.aln', 't/data/expected_nuc_multifasta.fa.aln' ],
      '-t 1 t/data/nuc_multifasta.fa' =>
        [ 't/data/nuc_multifasta.fa.aln', 't/data/expected_nuc_multifasta.fa.aln' ],
      '-h' =>
        [ 'empty_file', 't/data/empty_file' ],
);


SKIP: 
{

  skip "revtrans.py not installed", 2 unless ( which('revtrans.py'));
  mock_execute_script_and_check_output( $script_name, \%scripts_and_expected_files );
}


done_testing();
