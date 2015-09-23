#!/usr/bin/env perl

use Test::Most;
use FindBin;
plan tests => 8;
bail_on_fail if 0;
use Env::Path 'PATH';


my $OPSYS = $^O;
my $BINDIR = "$FindBin::RealBin/../binaries/$OPSYS";

for my $dir ($BINDIR, $FindBin::RealBin) {
    if (-d $dir) {
      $ENV{PATH} .= ":$dir";
     }
}

ok(scalar PATH->Whence($_), "$_ in PATH") for qw(blastp makeblastdb mcl mcxdeblast bedtools prank parallel mafft);

