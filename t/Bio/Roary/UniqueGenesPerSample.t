#!/usr/bin/env perl
use strict;
use warnings;
use Test::Files;
use Data::Dumper;

BEGIN { unshift( @INC, './lib' ) }
$ENV{PATH} .= ":./bin";

BEGIN {
    use Test::Most;
    use_ok('Bio::Roary::UniqueGenesPerSample');
}

ok(
    my $obj = Bio::Roary::UniqueGenesPerSample->new(
        clustered_proteins => 't/data/unique_genes_per_sample/clustered_proteins_valid',
    ),
    'Initialise object'
);

is_deeply($obj->_sample_to_gene_freq, {
          '11111_4#44' => 1,
          '123_4#5' => 2,
          '999_4#5' => 1,
          '22222_6#21' => 1
        }, 'sample frequencies');


ok($obj->write_unique_frequency, 'create output file');
ok(-e $obj->output_filename, 'output file exists');

compare_ok($obj->output_filename, 't/data/unique_genes_per_sample/expected_unique_genes_per_sample.tsv', 'got expected unique gene frequency');

unlink($obj->output_filename);

done_testing();
