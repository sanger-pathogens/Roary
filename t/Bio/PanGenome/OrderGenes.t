#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Slurp;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::PanGenome::OrderGenes');
    use Bio::PanGenome::AnalyseGroups;
}

my $analyse_groups = Bio::PanGenome::AnalyseGroups->new(
    fasta_files     => ['t/data/query_1.fa','t/data/query_2.fa','t/data/query_3.fa'],
    groups_filename => 't/data/query_groups'
);

ok(my $obj = Bio::PanGenome::OrderGenes->new(
  analyse_groups_obj => $analyse_groups,
  gff_files   => ['t/data/query_1.gff','t/data/query_2.gff','t/data/query_3.gff'],
),'Initialise order genes object');

print Dumper $obj->group_order;

done_testing();
