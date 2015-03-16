#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Slurp;

BEGIN { unshift( @INC, './lib' ) }
$ENV{PATH} .= ":./bin";

BEGIN {
    use Test::Most;
    use_ok('Bio::Roary::GroupLabels');
}

ok(
    my $obj = Bio::Roary::GroupLabels->new(
        groups_filename => 't/data/example_groups_without_labels'
    ),
    'initialise with a groups file'
);
ok($obj->add_labels, 'Add labels to groups');
is(read_file($obj->output_filename), read_file('t/data/expected_group_labels'), 'groups labeled as expected');
unlink('labelled_groups_file');

done_testing();
