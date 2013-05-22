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
$plot_groups_obj->_extract_proteome_objects->{'t/data/example_annotation_2.gff'}->_working_directory_name . '/example_annotation_2.faa',
     $plot_groups_obj->_extract_proteome_objects->{'t/data/example_annotation.gff'}->_working_directory_name . '/example_annotation.faa',));

is_deeply(
    \@sorted_fasta_files,
\@sorted_expected_files,
    'one file created'
);

is(
    read_file( $plot_groups_obj->fasta_files->[0] ),
    read_file('t/data/expected_example_annotation_1.faa'),
    'content of proteome 1 as expected'
);
#is(
#    read_file( $plot_groups_obj->fasta_files->[1] ),
#    read_file('t/data/expected_example_annotation_1.faa'),
#    'content of proteome 2 as expected'
#);

done_testing();
