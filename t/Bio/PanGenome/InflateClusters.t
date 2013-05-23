#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Slurp;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::PanGenome::InflateClusters');
}

my $obj;


ok( $obj = Bio::PanGenome::InflateClusters->new(
  clusters_filename  => 't/data/clustersfile',
  mcl_filename       => 't/data/mcl_file',
  output_file        => 'example.output'
),'initialise object');
ok($obj->inflate,'inflate the results');

is(read_file('example.output'),read_file('t/data/expected_inflated_results'), 'inflated results as expected');
unlink('example.output');


ok( $obj = Bio::PanGenome::InflateClusters->new(
  clusters_filename  => 't/data/clusters_to_inflate',
  mcl_filename       => 't/data/clusters_to_inflate.mcl',
  output_file        => 'example.output'
),'initialise object');
ok($obj->inflate,'inflate the results');

is(read_file('example.output'),read_file('t/data/expected_clusters_to_inflate'), 'inflated results as expected');
unlink('example.output');



done_testing();

