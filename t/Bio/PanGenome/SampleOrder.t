#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Slurp;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::PanGenome::SampleOrder');
}

ok(my $obj = Bio::PanGenome::SampleOrder->new(
    tree_file        => 't/data/reorder_isolates.tre',
  ), 'initialise sample order object');

is_deeply($obj->ordered_samples(),['query_1', 'query_3','query_4','query_2'],'order of sample names matches the tree');

done_testing();
