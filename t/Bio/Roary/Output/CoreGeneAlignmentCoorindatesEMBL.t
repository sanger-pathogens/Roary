#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use Test::Files;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::Roary::Output::CoreGeneAlignmentCoordinatesEMBL');
}

ok(
    my $core_gene_obj = Bio::Roary::Output::CoreGeneAlignmentCoordinatesEMBL->new(
        multifasta_files => [
            't/data/multifasta_files/1.fa.aln', 't/data/multifasta_files/outof_order.fa.aln',
            't/data/multifasta_files/2.fa.aln', 't/data/multifasta_files/3.fa.aln'
        ],
        gene_lengths => {
            't/data/multifasta_files/1.fa.aln'           => 1,
            't/data/multifasta_files/outof_order.fa.aln' => 10,
            't/data/multifasta_files/2.fa.aln'           => 100,
            't/data/multifasta_files/3.fa.aln'           => 1000
        },
				output_filename => 'output_name.embl'
    ),
    'initialise core gene obj'
);

is('efg',$core_gene_obj->_gene_name_from_filename('t/abc/efg.fa.aln'), 'Get gene name with directory');
is('efg',$core_gene_obj->_gene_name_from_filename('efg.fa.aln'), 'Get gene name with no directory');
is('efg',$core_gene_obj->_gene_name_from_filename('efg'), 'Get gene name where theres no extension');
is('efg',$core_gene_obj->_gene_name_from_filename('efg.fa'), 'Get gene name with partial extension');

ok($core_gene_obj->create_file,'create the embl header file');
compare_ok('output_name.embl', 't/data/multifasta_files/expected_output.embl', 'content of embl file as expected');

is(1112,$core_gene_obj->_current_coordinate,'next coordinate');
unlink('output_name.embl');

done_testing();
