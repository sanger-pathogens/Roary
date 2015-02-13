#!/usr/bin/env perl
use strict;
use warnings;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::PanGenome::QC::Kraken');
}

ok(
	my $kraken_obj = Bio::PanGenome::QC::Kraken->new( 
		assembly_directory => "t/data/kraken",
		glob_search        => "*.test.fa",
		job_runner         => "Local"
	),
	'kraken object created'
);

my $exp = "kraken --db /lustre/scratch108/pathogen/pathpipe/kraken/minikraken_20140330/ --output test.kraken test.fa";
is( $kraken_obj->_kraken_cmd( 'test.fa', 'test.kraken' ), $exp, 'kraken command correct'  );

$exp = $exp = "kraken-report --db /lustre/scratch108/pathogen/pathpipe/kraken/minikraken_20140330/ test.kraken > test.kraken_report";
is( $kraken_obj->_kraken_report_cmd( 'test.kraken', 'test.kraken_report' ), $exp, 'kraken-report command correct' );

$exp = [ 'Brucella', 'Brucella ceti' ];
is_deeply( $kraken_obj->_parse_kraken_report( "t/data/kraken_report.txt" ), $exp, 'kraken report parsed fine' );

done_testing();