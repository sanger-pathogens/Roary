#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Basename;

BEGIN { unshift( @INC, './lib' ) }
$ENV{PATH} .= ":./bin";

BEGIN {
    use Test::Most;
    use_ok('Bio::Roary::PrepareInputFiles');
}

my $obj;

ok(
    $obj = Bio::Roary::PrepareInputFiles->new(
        input_files => [
            't/data/example_annotation.gff',   't/data/example_1.faa',
            't/data/example_annotation_2.gff', 't/data/example_2.faa','t/data/sequences_with_unknowns.faa'
        ],
    ),
    'initalise'
);

my @sorted_fasta_files = sort map { basename($_) } sort @{$obj->fasta_files};
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

my @input_files_lookup = sort map { basename($_) } @{$obj->lookup_fasta_files_from_unknown_input_files( [ 't/data/example_annotation_2.gff', 't/data/example_1.faa' ] )};
is_deeply(
    \@input_files_lookup,
    ['example_1.faa.tmp.filtered.fa','example_annotation_2.gff.proteome.faa'],
    'previously created faa file looked up from gff filename'
);

unlink('example_annotation.gff.proteome.faa');
unlink('example_annotation_2.gff.proteome.faa');
unlink('sequences_with_unknowns.faa.tmp.filtered.fa');
unlink('example_1.faa.tmp.filtered.fa');
unlink('example_2.faa.tmp.filtered.fa');

done_testing();

