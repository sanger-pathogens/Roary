#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Slurp;

BEGIN { unshift( @INC, './lib' ) }
$ENV{PATH} .= ":./bin";

BEGIN {
    use Test::Most;
    use_ok('Bio::PanGenome::PrepareInputFiles');
}

my $obj;

ok(
    $obj = Bio::PanGenome::PrepareInputFiles->new(
        input_files => [
            't/data/example_annotation.gff',   't/data/example_1.faa',
            't/data/example_annotation_2.gff', 't/data/example_2.faa','t/data/sequences_with_unknowns.faa'
        ],
    ),
    'initalise'
);

my @sorted_fasta_files = sort @{$obj->fasta_files};
my @expected_fasta_files = sort((
            'example_1.faa.tmp.filtered.fa',
            'example_2.faa.tmp.filtered.fa',
            'example_annotation.gff.proteome.faa',
            'example_annotation_2.gff.proteome.faa',
            'sequences_with_unknowns.faa.tmp.filtered.fa'
));

is_deeply(
    \@sorted_fasta_files,
    \@expected_fasta_files,
    'proteome extracted from gff files, input fasta files filtered'
);

is_deeply(
    $obj->lookup_fasta_files_from_unknown_input_files( [ 't/data/example_annotation_2.gff', 't/data/example_1.faa' ] ),
    ['example_annotation_2.gff.proteome.faa','example_1.faa.tmp.filtered.fa'],
    'previously created faa file looked up from gff filename'
);

unlink('example_annotation.gff.proteome.faa');
unlink('example_annotation_2.gff.proteome.faa');
unlink('sequences_with_unknowns.faa.tmp.filtered.fa');
unlink('example_1.faa.tmp.filtered.fa');
unlink('example_2.faa.tmp.filtered.fa');

done_testing();

