#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::Roary::Output::EmblGroups');
}


my $annotate_groups = Bio::Roary::AnnotateGroups->new(
  gff_files   => ['t/data/query_1.gff','t/data/query_2.gff','t/data/query_3.gff'],
  groups_filename => 't/data/query_groups',
);

my $analyse_groups = Bio::Roary::AnalyseGroups->new(
    fasta_files     => ['t/data/query_1.fa','t/data/query_2.fa','t/data/query_3.fa'],
    groups_filename => 't/data/query_groups'
);

ok(my $obj = Bio::Roary::Output::EmblGroups->new(
  output_filename => 'group_statitics.csv',
  annotate_groups_obj => $annotate_groups,
  analyse_groups_obj  => $analyse_groups
), 'initialise embl groups');

is($obj->_get_heat_map_colour(['a','b','c','d'], 4),2,  'heatmap colour');
is($obj->_get_heat_map_colour(['a','b','c'],     4),16, 'heatmap colour');
is($obj->_get_heat_map_colour(['a','b'],         4),3,  'heatmap colour');
is($obj->_get_heat_map_colour(['a'],             4),4,  'heatmap colour');


is($obj->_get_heat_map_colour(['a','b','c','d','e','f','g','h','i','j'], 10),2,  'heatmap colour loop over each colour 10');
is($obj->_get_heat_map_colour(['a','b','c','d','e','f','g','h','i'    ], 10),15, 'heatmap colour loop over each colour 9');
is($obj->_get_heat_map_colour(['a','b','c','d','e','f','g','h'        ], 10),16, 'heatmap colour loop over each colour 8');
is($obj->_get_heat_map_colour(['a','b','c','d','e','f','g'            ], 10),10, 'heatmap colour loop over each colour 7');
is($obj->_get_heat_map_colour(['a','b','c','d','e','f'                ], 10),7,  'heatmap colour loop over each colour 6');
is($obj->_get_heat_map_colour(['a','b','c','d','e'                    ], 10),3,  'heatmap colour loop over each colour 5');
is($obj->_get_heat_map_colour(['a','b','c','d'                        ], 10),8,  'heatmap colour loop over each colour 4');
is($obj->_get_heat_map_colour(['a','b','c'                            ], 10),9,  'heatmap colour loop over each colour 3');
is($obj->_get_heat_map_colour(['a','b'                                ], 10),5,  'heatmap colour loop over each colour 2');
is($obj->_get_heat_map_colour(['a'                                    ], 10),4,  'heatmap colour loop over each colour 1 ');

done_testing();
