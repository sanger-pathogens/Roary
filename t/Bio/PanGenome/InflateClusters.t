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

is(read_file('example.output'),'2363_5_03666 4075_2#3_03437
4075_1#8_03461 2212_1_02994 2212_6_02081 2363_1_00606 2363_2_02124 2363_3_01371 2363_6_01272 2363_8_00966 2541_2_02425 2541_3_02449 2541_7_00441 2541_8_00644 2781_2_02909 3634_6_00968 3634_7_01056 3634_8_02606
2212_3_02841 2363_5_00947
2363_7_00085 2460_2_00826 4075_1#6_04091 4075_1#3_04238 3634_6_04078 2212_1_01414 2363_1_00811 2541_2_00696 2541_8_00920 3634_7_00911
', 'inflated results as expected');
unlink('example.output');



done_testing();

