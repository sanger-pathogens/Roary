#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Slurp;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::PanGenome::GGFile');
}

my $obj;

ok(
    $obj = Bio::PanGenome::GGFile->new(
        fasta_file => 't/data/proteome_with_and_without_descriptions.faa'
    ),
    'initialise object with a file where there are a mix of descriptions in the sequence name lines'
);
ok( $obj->create_gg_file,                                   'Create the GG file' );
ok( -e 'proteome_with_and_without_descriptions.faa.all.gg', 'GG file exists' );

is_deeply(
    read_file('proteome_with_and_without_descriptions.faa.all.gg'),
    read_file('t/data/expected_proteome_with_and_without_descriptions.faa.all.gg'),
    'Content of file matches expected'
);
unlink('proteome_with_and_without_descriptions.faa.all.gg');

done_testing();
