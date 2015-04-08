#!/usr/bin/env perl
use Moose;
use Data::Dumper;
use File::Slurp::Tiny qw(read_file write_file);
use Cwd;

BEGIN { unshift( @INC, './lib' ) }
BEGIN { unshift( @INC, './t/lib' ) }
with 'TestHelper';

BEGIN {
    use Test::Most;
    use_ok('Bio::Roary::CommandLine::MergeMultipleFastaAlignments');
}
my $script_name = 'Bio::Roary::CommandLine::MergeMultipleFastaAlignments';
system('touch empty_file');
my %scripts_and_expected_files = (
    't/data/multfasta1.aln t/data/multfasta2.aln t/data/multfasta3.aln' =>
      [ 'merged_alignments.aln', 't/data/expected_output_merged.aln' ],
    '-o different_output_file.aln t/data/multfasta1.aln t/data/multfasta2.aln t/data/multfasta3.aln' =>
      [ 'different_output_file.aln', 't/data/expected_output_merged.aln' ],
      '-h' =>
        [ 'empty_file', 't/data/empty_file' ],
);

mock_execute_script_and_check_output( $script_name, \%scripts_and_expected_files );

done_testing();
