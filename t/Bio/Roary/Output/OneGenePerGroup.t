#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Slurp;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::Roary::Output::OneGenePerGroupFasta');
}

my $plot_groups_obj = Bio::Roary::AnalyseGroups->new(
    fasta_files     => [ 't/data/example_1.faa', 't/data/example_2.faa' ],
    groups_filename => 't/data/example_groups'
);

ok(my $obj = Bio::Roary::Output::OneGenePerGroupFasta->new(
    analyse_groups  => $plot_groups_obj
  ),'initialise creating a fasta file with one gene per group');
ok($obj->create_file(), 'create the fasta file');

is(read_file('pan_genome_reference.fa'), read_file('t/data/expected_pan_genome_reference.fa'), 'contents of pan genome fasta as expected');

unlink('pan_genome_reference.fa');

done_testing();