#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Slurp::Tiny qw(read_file write_file);

BEGIN { unshift( @INC, './lib' ) }
$ENV{PATH} .= ":./bin";

BEGIN {
    use Test::Most;
    use_ok('Bio::Roary::ExtractCoreGenesFromSpreadsheet');
}

my $obj;

ok($obj = Bio::Roary::ExtractCoreGenesFromSpreadsheet->new(
  spreadsheet  => 't/data/core_group_statistics.csv',
),'initalise obj');
is_deeply($obj->ordered_core_genes, ['argF','speH','group_5'], 'Correct ordering');

done_testing();
