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
    use_ok('Bio::Roary::Output::DifferenceBetweenSets');
}

my $plot_groups_obj = Bio::Roary::AnalyseGroups->new(
    fasta_files     => [ 't/data/query_1.fa', 't/data/query_2.fa','t/data/query_3.fa' ],
    groups_filename => 't/data/query_groups'
);

ok(my $obj = Bio::Roary::Output::DifferenceBetweenSets->new(
    analyse_groups  => $plot_groups_obj,
    input_filenames_sets => [ ['t/data/query_1.fa'], ['t/data/query_2.fa','t/data/query_3.fa'] ]
  ),'initialise set difference obj');
  
ok($obj->groups_set_one_unique,'create set one unique');
ok($obj->groups_set_two_unique,'create set two unique');
ok($obj->groups_in_common,'create common set unique');

compare_files('set_difference_unique_set_one','t/data/expected_set_difference_unique_set_one','set one file content as expected');
compare_files('set_difference_unique_set_two','t/data/expected_set_difference_unique_set_two','set two file content as expected');
compare_files('set_difference_common_set','t/data/expected_set_difference_common_set','common set file content as expected');

unlink('set_difference_unique_set_one');
unlink('set_difference_unique_set_two');
unlink('set_difference_common_set');

done_testing();
