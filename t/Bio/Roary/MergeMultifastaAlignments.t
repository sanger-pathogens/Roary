#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Slurp::Tiny qw(read_file write_file);

BEGIN { unshift( @INC, './lib' ) }
$ENV{PATH} .= ":./bin";

BEGIN {
    use Test::Most;
    use_ok('Bio::Roary::MergeMultifastaAlignments');
}

my $obj;

my $outputfile = 'output_merged.aln';
ok($obj = Bio::Roary::MergeMultifastaAlignments->new(
  multifasta_files => ['t/data/multfasta1.aln','t/data/multfasta2.aln','t/data/multfasta3.aln'],
  output_filename  => $outputfile
),'initalise obj');


ok($obj->merge_files,'merge files');
ok(-e $outputfile, 'output file exists');

is(read_file($outputfile), read_file('t/data/expected_output_merged.aln'), 'content of outputfile as expected');
unlink($outputfile);

# Test cases where genomes are missing from some gene files
ok($obj = Bio::Roary::MergeMultifastaAlignments->new(
  multifasta_files => ['t/data/multfasta2.aln','t/data/multfasta4.aln','t/data/multfasta1.aln', 't/data/multfasta5.aln'],
  output_filename  => $outputfile
),'initalise obj');


ok($obj->merge_files,'merge files');
ok(-e $outputfile, 'output file exists');

is(read_file($outputfile), read_file('t/data/expected_output_merged_sparse.aln'), 'content of outputfile as expected');
unlink($outputfile);


done_testing();
