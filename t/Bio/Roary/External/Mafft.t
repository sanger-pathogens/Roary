#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use Cwd;
use Test::Files;

BEGIN { unshift( @INC, './lib' ) }
BEGIN {
    use Test::Most;
	use Bio::Roary::SortFasta;
    use_ok('Bio::Roary::External::Mafft');
}

ok(
    my $obj = Bio::Roary::External::Mafft->new(
        input_filename  => 't/data/mafft_input.fa',
        output_filename => 't/data/mafft_input.fa.aln',
        job_runner      => 'Local'
    ),
    'initialise mafft obj'
);

is(
    $obj->_command_to_run,
'mafft --auto --quiet t/data/mafft_input.fa > t/data/mafft_input.fa.aln',
    'Command constructed as expected'
);

ok( $obj->run(), 'run mafft' );

ok(-e 't/data/mafft_input.fa.aln', 'output file exists');
my $sort_fasta_after_revtrans = Bio::Roary::SortFasta->new(
   input_filename      => 't/data/mafft_input.fa.aln',
   remove_nnn_from_end => 1,
);
$sort_fasta_after_revtrans->sort_fasta->replace_input_with_output_file;

compare_ok( 't/data/mafft_input.fa.aln', 't/data/expected_mafft_input.fa.aln', "output for mafft matches" );

unlink('t/data/mafft_input.fa.aln');

done_testing();
