#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Slurp::Tiny qw(read_file write_file);

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::Roary::Output::GroupsMultifastaProtein');
}

ok(
    my $obj = Bio::Roary::Output::GroupsMultifastaProtein->new(
        nucleotide_fasta_file    => 't/data/nuc_multifasta.fa',
    ),
    'initialise creating the nuc fasta obj'
);
ok($obj->convert_nucleotide_to_protein(),'perform the conversion');

is(read_file('t/data/nuc_multifasta.faa'),read_file('t/data/expected_nuc_multifasta.faa' ),'File content as expected');

unlink('t/data/nuc_multifasta.faa');

done_testing();
