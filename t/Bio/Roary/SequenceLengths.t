#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;

BEGIN { unshift( @INC, './lib' ) }
$ENV{PATH} .= ":./bin";

BEGIN {
    use Test::Most;
    use_ok('Bio::Roary::SequenceLengths');
}

ok(
    my $obj = Bio::Roary::SequenceLengths->new(
        fasta_file => 't/data/example_1.faa',
    ),
    'Initialise object'
);

is_deeply(
    $obj->sequence_lengths,
    {
        '1234#10_00006' => 211,
        '1234#10_00003' => 113,
        '1234#10_00001' => 145,
        '1234#10_00005' => 207,
        '1234#10_00002' => 246,
        '1234#10_00007' => 242
    },
    'hash with lengths of each sequence'
);

done_testing();
