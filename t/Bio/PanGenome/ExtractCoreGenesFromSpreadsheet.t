#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Slurp;

BEGIN { unshift( @INC, './lib' ) }
$ENV{PATH} .= ":./bin";

BEGIN {
    use Test::Most;
    use_ok('Bio::PanGenome::ExtractCoreGenesFromSpreadsheet');
}

my $obj;

ok($obj = Bio::PanGenome::ExtractCoreGenesFromSpreadsheet->new(
  spreadsheet  => 't/data/core_group_statistics.csv',
),'initalise obj');
is_deeply($obj->ordered_core_genes, ['argF','speH','group_5'], 'Correct ordering');

done_testing();
