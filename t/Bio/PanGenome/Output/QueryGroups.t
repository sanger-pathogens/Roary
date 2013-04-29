#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Slurp;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::PanGenome::Output::QueryGroups');
}

my $plot_groups_obj = Bio::PanGenome::AnalyseGroups->new(
    fasta_files     => [ 't/data/query_1.fa', 't/data/query_2.fa','t/data/query_3.fa' ],
    groups_filename => 't/data/query_groups'
);

ok(my $obj = Bio::PanGenome::Output::QueryGroups->new(
    analyse_groups  => $plot_groups_obj,
    input_filenames => [ 't/data/query_1.fa', 't/data/query_2.fa','t/data/query_3.fa' ]
  ),'initialise groups query object');
  
ok($obj->groups_union(), 'create the union file');
ok($obj->groups_intersection(), 'create the intersection file');
ok($obj->groups_complement(), 'create the complement file');

is(read_file('union_of_groups.gg'), read_file('t/data/expected_union_of_groups.gg'), 'contents of the union groups as expected');
is(read_file('intersection_of_groups.gg'), read_file('t/data/expected_intersection_of_groups.gg'), 'contents of the intersection groups as expected');
is(read_file('complement_of_groups.gg'), read_file('t/data/expected_complement_of_groups.gg'), 'contents of the complement groups as expected');

unlink('union_of_groups.gg');
unlink('intersection_of_groups.gg');
unlink('complement_of_groups.gg');

done_testing();
