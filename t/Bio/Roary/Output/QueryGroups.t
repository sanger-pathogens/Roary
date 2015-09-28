#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use Moose;
BEGIN { unshift( @INC, './t/lib' ) }
with 'TestHelper';

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::Roary::Output::QueryGroups');
}

my $plot_groups_obj = Bio::Roary::AnalyseGroups->new(
    fasta_files     => [ 't/data/query_1.fa', 't/data/query_2.fa','t/data/query_3.fa' ],
    groups_filename => 't/data/query_groups'
);

my $obj;
ok($obj = Bio::Roary::Output::QueryGroups->new(
    analyse_groups  => $plot_groups_obj,
    input_filenames => [ 't/data/query_1.fa', 't/data/query_2.fa','t/data/query_3.fa' ]
  ),'initialise groups query object');
  
ok($obj->groups_union(), 'create the union file');
ok($obj->groups_intersection(), 'create the intersection file');
ok($obj->groups_complement(), 'create the complement file');

compare_files('union_of_groups.gg','t/data/expected_union_of_groups.gg', 'contents of the union groups as expected');
compare_files('intersection_of_groups.gg', 't/data/expected_intersection_of_groups.gg', 'contents of the intersection groups as expected');
compare_files('complement_of_groups.gg', 't/data/expected_complement_of_groups.gg', 'contents of the complement groups as expected');

######################################
# test varying core definition
ok($obj = Bio::Roary::Output::QueryGroups->new(
    analyse_groups  => $plot_groups_obj,
    input_filenames => [ 't/data/query_1.fa', 't/data/query_2.fa','t/data/query_3.fa' ],
    core_definition => 0.66
  ),'initialise groups query object');
  
ok($obj->groups_intersection(), 'create the intersection file');
ok($obj->groups_complement(), 'create the complement file');

compare_files('intersection_of_groups.gg', 't/data/expected_intersection_of_groups_core0.66.gg', 'contents of the intersection groups as expected');
compare_files('complement_of_groups.gg', 't/data/expected_complement_of_groups_core0.66.gg', 'contents of the complement groups as expected');


unlink('union_of_groups.gg');
unlink('intersection_of_groups.gg');
unlink('complement_of_groups.gg');

######################################

$plot_groups_obj = Bio::Roary::AnalyseGroups->new(
    fasta_files     => [ 't/data/query_1.fa', 't/data/query_2.fa','t/data/query_3.fa' ],
    groups_filename => 't/data/query_groups_paralogs'
);

ok($obj = Bio::Roary::Output::QueryGroups->new(
    analyse_groups  => $plot_groups_obj,
    input_filenames => [ 't/data/query_1.fa', 't/data/query_2.fa','t/data/query_3.fa' ]
  ),'initialise groups query object with paralogs');
  
ok($obj->groups_intersection(), 'create the intersection file');

compare_files('intersection_of_groups.gg', 't/data/expected_intersection_of_groups_paralogs.gg', 'contents of the intersection groups with paralogs as expected');
unlink('intersection_of_groups.gg');


done_testing();

