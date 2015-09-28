#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use Cwd;
use Test::Files;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::Roary::External::Mcl');
}

my $cwd = getcwd();
my $obj;


ok(
    $obj = Bio::Roary::External::Mcl->new(
        blast_results   => 'some_blast_results',
        mcxdeblast_exec => $cwd . '/t/bin/dummy_mcxdeblast',
        mcl_exec        => $cwd . '/t/bin/dummy_mcl',
        output_file     => 'output.groups'
    ),
    'initialise object with dummy values'
);

is(
    $obj->_command_to_run,
    $cwd
      . '/t/bin/dummy_mcxdeblast -m9 --score=r --line-mode=abc some_blast_results 2> /dev/null | '
      . $cwd
      . '/t/bin/dummy_mcl - --abc -I 1.5 -o output.groups > /dev/null 2>&1',
    'Command constructed as expected'
);
ok( $obj->run(), 'run dummy command' );

unlink('output.groups');

ok(
    $obj = Bio::Roary::External::Mcl->new(
        blast_results => 't/data/blast_results',
    ),
    'initialise object with real values'
);
ok( $obj->run(), 'run the real command' );
compare_ok('output_groups', 't/data/expected_output_groups', 'outgroups as expected');

unlink('output_groups');

1;

done_testing();
