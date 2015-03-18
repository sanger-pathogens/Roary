#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Slurp::Tiny qw(read_file write_file);
use Moose;
BEGIN { unshift( @INC, './t/lib' ) }
with 'TestHelper';

BEGIN { unshift( @INC, './lib' ) }
$ENV{PATH} .= ":./bin";

BEGIN {
    use Test::Most;
    use_ok('Bio::Roary::AnnotateGroups');
}

my $obj;

ok($obj = Bio::Roary::AnnotateGroups->new(
  gff_files   => ['t/data/query_1.gff','t/data/query_2.gff','t/data/query_3.gff'],
  groups_filename => 't/data/query_groups',
),'initalise');

ok($obj->reannotate,'reannotate');

compare_files('reannotated_groups_file', 't/data/expected_reannotated_groups_file', 'groups reannotated as expected');

unlink('reannotated_groups_file');

done_testing();

