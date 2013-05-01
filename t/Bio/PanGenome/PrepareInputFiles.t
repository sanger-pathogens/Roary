#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Slurp;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::PanGenome::PrepareInputFiles');
}

my $obj;

ok(
    $obj = Bio::PanGenome::PrepareInputFiles->new(
        input_files => [
            't/data/example_annotation.gff',   't/data/example_1.faa',
            't/data/example_annotation_2.gff', 't/data/example_2.faa',
        ],
    ),
    'initalise'
);

is_deeply(
    $obj->fasta_files,
    [
        't/data/example_1.faa',
        't/data/example_2.faa',
        $obj->_extract_proteome_obj->_working_directory_name . '/example_annotation.faa',
        $obj->_extract_proteome_obj->_working_directory_name . '/example_annotation_2.faa'
    ],
    'proteome extracted from gff files, input fasta files left alone'
);

is_deeply(
    $obj->lookup_fasta_files_from_unknown_input_files( [ 't/data/example_annotation_2.gff', 't/data/example_1.faa' ] ),
    [$obj->_extract_proteome_obj->_working_directory_name . '/example_annotation_2.faa','t/data/example_1.faa'],
    'previously created faa file looked up from gff filename'
);

done_testing();

