#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use Cwd;
use Test::Output;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::Roary::External::CheckTools');
}
ok( my $check_tools = Bio::Roary::External::CheckTools->new(), 'initialise checking for tools' );
for my $tool ( ( 'parallel', 'blastp', 'makeblastdb', 'mcl', 'bedtools', 'prank', 'mafft', 'grep', 'sed', 'awk', ) ) {
    my $pattern = "Looking for '$tool' - found ";
    stderr_like { $check_tools->check_tool($tool); } qr/$pattern/, "Check for $tool";
}

stderr_like { $check_tools->check_all_tools; } qr/Looking for /, "Check for all tools";
1;

done_testing();
