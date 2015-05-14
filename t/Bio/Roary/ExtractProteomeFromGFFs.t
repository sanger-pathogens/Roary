#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Slurp::Tiny qw(read_file write_file);

BEGIN { unshift( @INC, './lib' ) }
$ENV{PATH} .= ":./bin";

BEGIN {
    use Test::Most;
    use_ok('Bio::Roary::ExtractProteomeFromGFFs');
}

my $plot_groups_obj;

ok(
    $plot_groups_obj = Bio::Roary::ExtractProteomeFromGFFs->new(
        gff_files => [ 't/data/example_annotation.gff', 't/data/example_annotation_2.gff' ],
    ),
    'initialise object'
);

my @sorted_fasta_files = sort( @{ $plot_groups_obj->fasta_files() } );
my @sorted_expected_files = sort( ( 'example_annotation.gff.proteome.faa', 'example_annotation_2.gff.proteome.faa' ) );

is_deeply( \@sorted_fasta_files, \@sorted_expected_files, 'one file created' );

is(
    read_file( $plot_groups_obj->fasta_files->[0] ),
    read_file('t/data/example_annotation.gff.proteome.faa.expected'),
    'content of proteome 1 as expected'
);

unlink('example_annotation.gff.proteome.faa');
unlink('example_annotation_2.gff.proteome.faa');

ok(
    $plot_groups_obj = Bio::Roary::ExtractProteomeFromGFFs->new(
        gff_files => [ 't/data/genbank_gbff/genbank1.gff', 't/data/genbank_gbff/genbank2.gff', 't/data/genbank_gbff/genbank3.gff' ],
    ),
    'initialise object with genbank gff files'
);
@sorted_fasta_files = sort( @{ $plot_groups_obj->fasta_files() } );
@sorted_expected_files = sort( ( 'genbank1.gff.proteome.faa', 'genbank2.gff.proteome.faa', 'genbank3.gff.proteome.faa' ) );

is_deeply( \@sorted_fasta_files, \@sorted_expected_files, 'GB files created output' );

for my $filename (@sorted_expected_files) {
    is( read_file($filename), read_file( 't/data/genbank_gbff/' . $filename . '.expected' ), "content of proteome $filename as expected" );
}

unlink('genbank1.gff.proteome.faa');
unlink('genbank2.gff.proteome.faa');
unlink('genbank3.gff.proteome.faa');

done_testing();
