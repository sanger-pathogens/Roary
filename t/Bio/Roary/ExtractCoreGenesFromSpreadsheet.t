#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;

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
is_deeply($obj->sample_names_to_genes, {
          'query_2' => {
                         '2_3' => 1,
                         '2_7' => 1,
                         '2_2' => 1
                       },
          'query_1' => {
                         '1_6' => 1,
                         '1_3' => 1,
                         '1_2' => 1
                       }
        }, 'Correct of sample names to genes is correct');

done_testing();
