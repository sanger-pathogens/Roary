#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Slurp;

BEGIN { unshift( @INC, './lib' ) }
$ENV{PATH} .= ":./bin";

BEGIN {
    use Test::Most;
    use_ok('Bio::Roary::OrderGenes');
    use Bio::Roary::AnalyseGroups;
}

my $analyse_groups = Bio::Roary::AnalyseGroups->new(
    fasta_files     => ['t/data/query_1.fa','t/data/query_2.fa','t/data/query_3.fa'],
    groups_filename => 't/data/query_groups'
);

ok(my $obj = Bio::Roary::OrderGenes->new(
  analyse_groups_obj => $analyse_groups,
  gff_files   => ['t/data/query_1.gff','t/data/query_2.gff','t/data/query_3.gff'],
),'Initialise order genes object');


done_testing();
