#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Slurp;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::PanGenome::QC::Report');
}

my $kraken_data = [ 
	['assembly1', 'Clostridium', 'Clostridium difficile'],
	['assembly2', 'Escherichia', 'Escherichia coli'],
	['assembly3', 'Streptococcus', 'Streptococcus pneumoniae']
];

ok(
	my $qc_report_obj = Bio::PanGenome::QC::Report->new( 
		fasta_assemblies => [],
		outfile          => "kraken_report.csv",
		_kraken_data     => $kraken_data
	),
	'QC report object created'
);

ok( $qc_report_obj->report, 'report generated' );
ok( -e 'kraken_report.csv', 'report file exists' );

is(
	read_file('kraken_report.csv'),
	read_file("t/data/exp_qc_report.csv"),
	'report file correct'
);

unlink( 'kraken_report.csv' );

done_testing();