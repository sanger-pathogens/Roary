#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Basename;
use Test::Files;

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

my @sorted_fasta_files = map { basename($_) } sort( @{ $plot_groups_obj->fasta_files() } );
my @sorted_expected_files = sort( ( 'example_annotation.gff.proteome.faa', 'example_annotation_2.gff.proteome.faa' ) );

is_deeply( \@sorted_fasta_files, \@sorted_expected_files, 'one file created' );

compare_ok( $plot_groups_obj->fasta_files->[0] ,
    't/data/example_annotation.gff.proteome.faa.expected',
    'content of proteome 1 as expected'
);

unlink('example_annotation.gff.proteome.faa');
unlink('example_annotation_2.gff.proteome.faa');

ok(
    $plot_groups_obj = Bio::Roary::ExtractProteomeFromGFFs->new(
        gff_files => [ 't/data/example_annotation_no_fasta_line.gff', 't/data/example_annotation_2.gff' ],
    ),
    'initialise object where one GFF has no FASTA line'
);
compare_ok( $plot_groups_obj->fasta_files->[0] ,
    't/data/example_annotation.gff.proteome.faa.expected',
    'content of proteome 1 as expected'
);
unlink('example_annotation_no_fasta_line.gff.proteome.faa');
unlink('example_annotation_2.gff.proteome.faa');

ok(
    $plot_groups_obj = Bio::Roary::ExtractProteomeFromGFFs->new(
        gff_files => [ 't/data/genbank_gbff/genbank1.gff', 't/data/genbank_gbff/genbank2.gff', 't/data/genbank_gbff/genbank3.gff' ],
    ),
    'initialise object with genbank gff files'
);
@sorted_fasta_files = map { basename($_) } sort( @{ $plot_groups_obj->fasta_files() } );
@sorted_expected_files = sort( ( 'genbank1.gff.proteome.faa', 'genbank2.gff.proteome.faa', 'genbank3.gff.proteome.faa' ) );

is_deeply( \@sorted_fasta_files, \@sorted_expected_files, 'GB files created output' );

for my $full_filename ( @{ $plot_groups_obj->fasta_files() } ) {
    my $base_filename = basename($full_filename);
    compare_ok($full_filename,
        't/data/genbank_gbff/' . $base_filename . '.expected',
        "content of proteome $full_filename as expected"
    );
}

unlink('genbank1.gff.proteome.faa');
unlink('genbank2.gff.proteome.faa');
unlink('genbank3.gff.proteome.faa');

ok(
    $plot_groups_obj = Bio::Roary::ExtractProteomeFromGFFs->new(
        gff_files => [ 't/data/locus_tag_gffs/query_1.gff', 't/data/locus_tag_gffs/query_2.gff', 't/data/locus_tag_gffs/query_3.gff' ],
    ),
    'initialise object with locus tag id gff files'
);
@sorted_fasta_files = map { basename($_) } sort( @{ $plot_groups_obj->fasta_files() } );
@sorted_expected_files = sort( ( 'query_1.gff.proteome.faa', 'query_2.gff.proteome.faa', 'query_3.gff.proteome.faa' ) );

is_deeply( \@sorted_fasta_files, \@sorted_expected_files, 'locus tag id files created output' );

for my $full_filename ( @{ $plot_groups_obj->fasta_files() } ) {
    my $base_filename = basename($full_filename);
    compare_ok($full_filename, 't/data/locus_tag_gffs/' . $base_filename . '.expected' ,
        "content of proteome $full_filename as expected" );
}

unlink('query_1.gff.proteome.faa');
unlink('query_2.gff.proteome.faa');
unlink('query_3.gff.proteome.faa');



ok(
    $plot_groups_obj = Bio::Roary::ExtractProteomeFromGFFs->new(
        gff_files => [ 't/data/allow_no_fasta_delimiter/annotation_1.gff', 't/data/allow_no_fasta_delimiter/annotation_2.gff' ],
    ),
    'initialise object with multi contig files'
);

@sorted_fasta_files = map { basename($_) } sort( @{ $plot_groups_obj->fasta_files() } );
@sorted_expected_files = sort( ( 'annotation_1.gff.proteome.faa', 'annotation_2.gff.proteome.faa' ) );

is_deeply( \@sorted_fasta_files, \@sorted_expected_files, 'locus tag id files created output' );

for my $full_filename ( @{ $plot_groups_obj->fasta_files() } ) {
    my $base_filename = basename($full_filename);
    
    compare_ok($full_filename, 't/data/allow_no_fasta_delimiter/' . $base_filename . '.expected' ,
        "content of proteome $full_filename as expected" );
}
unlink('annotation_1.gff.proteome.faa');
unlink('annotation_2.gff.proteome.faa');



done_testing();
