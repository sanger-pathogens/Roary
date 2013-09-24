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

my @sorted_fasta_files = sort @{$obj->fasta_files};
my @expected_fasta_files = sort((
    't/data/example_1.faa',
    't/data/example_2.faa',
    'example_annotation.gff.proteome.faa',
    'example_annotation_2.gff.proteome.faa',
));

is_deeply(
    \@sorted_fasta_files,
    \@expected_fasta_files,
    'proteome extracted from gff files, input fasta files left alone'
);

is_deeply(
    $obj->lookup_fasta_files_from_unknown_input_files( [ 't/data/example_annotation_2.gff', 't/data/example_1.faa' ] ),
    ['example_annotation_2.gff.proteome.faa','t/data/example_1.faa'],
    'previously created faa file looked up from gff filename'
);

unlink('example_annotation.gff.proteome.faa');
unlink('example_annotation_2.gff.proteome.faa');

done_testing();

