#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Slurp;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::PanGenome::ExtractProteomeFromGFFs');
}

my $plot_groups_obj;

ok(
    $plot_groups_obj = Bio::PanGenome::ExtractProteomeFromGFFs->new(
        gff_files => [ 't/data/example_annotation.gff', 't/data/example_annotation_2.gff' ],
    ),
    'initialise object'
);

my @sorted_fasta_files = sort(@{$plot_groups_obj->fasta_files()});
my @sorted_expected_files = sort((
'example_annotation.gff.proteome.faa',
'example_annotation_2.gff.proteome.faa'));

is_deeply(
    \@sorted_fasta_files,
\@sorted_expected_files,
    'one file created'
);

is(
    read_file( $plot_groups_obj->fasta_files->[0] ),
    read_file('t/data/example_annotation.gff.proteome.faa.expected'),
    'content of proteome 1 as expected'
);

unlink('example_annotation.gff.proteome.faa');
unlink('example_annotation_2.gff.proteome.faa');


done_testing();
