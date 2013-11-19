#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Slurp;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::PanGenome::ContigsToGeneIDsFromGFF');
}


ok(my $obj = Bio::PanGenome::ContigsToGeneIDsFromGFF->new(
  gff_file   => 't/data/query_1.gff'
),'Initialise contigs to gene ids obj');

print Dumper $obj->contig_to_ids;


done_testing();
