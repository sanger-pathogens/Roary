#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use Cwd;
use Test::Files;
use Bio::Roary::SortFasta;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::Roary::External::Prank');
}

ok(
    my $obj = Bio::Roary::External::Prank->new(
        input_filename  => 't/data/prank_input.fa',
        output_filename => 't/data/prank_input.fa.aln',
        job_runner      => 'Local'
    ),
    'initialise prank obj'
);

is(
    $obj->_command_to_run,
'prank -d=t/data/prank_input.fa -o=t/data/prank_input.fa.aln -codon -F -quiet -once > /dev/null 2>&1 && mv t/data/prank_input.fa.aln*.fas t/data/prank_input.fa.aln',
    'Command constructed as expected'
);

ok( $obj->run(), 'run prank' );

ok(-e 't/data/prank_input.fa.aln', 'output file exists');
my $sort_fasta_after_revtrans = Bio::Roary::SortFasta->new(
   input_filename      => 't/data/prank_input.fa.aln',
   remove_nnn_from_end => 1,
);
$sort_fasta_after_revtrans->sort_fasta->replace_input_with_output_file;

compare_ok( 't/data/prank_input.fa.aln', 't/data/expected_prank_input.fa.aln', "output for prank matches" );

unlink('t/data/prank_input.fa.aln');

done_testing();
