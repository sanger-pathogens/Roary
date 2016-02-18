#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Path qw(remove_tree);
use Test::Files;

BEGIN { unshift( @INC, './lib' ) }
$ENV{PATH} .= ":./bin";

BEGIN {
    use Test::Most;
    use_ok('Bio::Roary::ReformatInputGFFs');
}


my $obj;
remove_tree('fixed_input_files');
ok($obj = Bio::Roary::ReformatInputGFFs->new(gff_files => ['t/data/reformat_input_gffs/query_1.gff']), 'initialise with one input gff');
ok($obj->fix_duplicate_gene_ids, 'fix duplicates with one input gff');
is_deeply($obj->fixed_gff_files, ['t/data/reformat_input_gffs/query_1.gff'] ,'list of gff files with one input gff, nothing should change');
ok(!( -d 'fixed_input_files'), 'Directory shouldnt exist because there arent any fixed input files');


ok($obj = Bio::Roary::ReformatInputGFFs->new(gff_files => ['t/data/reformat_input_gffs/query_1.gff', 't/data/reformat_input_gffs/query_2.gff',]), 'initialise with 2 input gffs');
ok(!( -d 'fixed_input_files'), 'Directory shouldnt exist before running');
is_deeply($obj->_get_ids_for_gff_file('t/data/reformat_input_gffs/query_1.gff'),[
          '1_1',
          'abc_00002',
          'abc_00003',
          'abc_00004',
          '1_2'
        ],'extract ids');
is_deeply($obj->_get_ids_for_gff_file('t/data/reformat_input_gffs/query_2.gff'),[
          '1_1',
          'abc_00002',
          'abc_00003',
          'abc_00004',
          '1_2'
        ],'extract ids');
ok($obj->fix_duplicate_gene_ids, 'fix duplicates with 2 input gffs');
ok(( -d 'fixed_input_files'), 'Directory should exist because there is one gff thats fixed');
is_deeply($obj->fixed_gff_files, ['t/data/reformat_input_gffs/query_1.gff','fixed_input_files/query_2.gff' ] ,'list of gff files one in the fixed directory');
ok(( -e 'fixed_input_files/query_2.gff'), 'fixed file should exist');
compare_ok('fixed_input_files/query_2.gff', 't/data/reformat_input_gffs/expected_fixed_query_2.gff',  'fixed file should have expected changes');
remove_tree('fixed_input_files');


ok($obj = Bio::Roary::ReformatInputGFFs->new(gff_files => ['t/data/reformat_input_gffs/query_1.gff', 't/data/reformat_input_gffs/query_2.gff', 't/data/reformat_input_gffs/query_3.gff']), 'initialise with 3 input gffs');
ok(!( -d 'fixed_input_files'), 'Directory shouldnt exist before running');
ok($obj->fix_duplicate_gene_ids, 'fix duplicates with 3 input gffs');
ok(( -d 'fixed_input_files'), 'Directory should exist because there is 2 gffs thats fixed');
is_deeply($obj->fixed_gff_files, ['t/data/reformat_input_gffs/query_1.gff','fixed_input_files/query_2.gff','fixed_input_files/query_3.gff' ] ,'list of gff files 2 in the fixed directory');
ok(( -e 'fixed_input_files/query_2.gff'), 'fixed file should exist');
ok(( -e 'fixed_input_files/query_3.gff'), 'fixed file should exist');
compare_ok('fixed_input_files/query_2.gff','t/data/reformat_input_gffs/expected_fixed_query_2.gff',  'fixed file should have expected changes');
compare_ok('fixed_input_files/query_3.gff', 't/data/reformat_input_gffs/expected_fixed_query_3.gff',  'fixed file should have expected changes');
remove_tree('fixed_input_files');
	

ok($obj = Bio::Roary::ReformatInputGFFs->new(gff_files => ['t/data/reformat_input_gffs/real_1.gff']), 'initialise with 1 gff that has shown to have a bug');
ok(my $fixed_file = $obj->_add_suffix_to_gene_ids_and_return_new_file('t/data/reformat_input_gffs/real_1.gff'), 'fix duplicates');
ok(( -e 'fixed_input_files/real_1.gff'), 'fixed file should exist');
compare_ok('fixed_input_files/real_1.gff', 't/data/reformat_input_gffs/expected_real_1.gff',  'fixed file should have expected changes');
remove_tree('fixed_input_files');


done_testing();

