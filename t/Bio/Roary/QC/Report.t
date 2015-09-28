#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use Test::Files;
use File::Which;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::Roary::QC::Report');
}



my $kraken_data = [
    [ 'assembly1', 'Clostridium',   'Clostridium difficile' ],
    [ 'assembly2', 'Escherichia',   'Escherichia coli' ],
    [ 'assembly3', 'Streptococcus', 'Streptococcus pneumoniae' ]
];

ok(
    my $qc_report_obj = Bio::Roary::QC::Report->new(
        input_files  => [],
        outfile      => "kraken_report.csv",
        _kraken_data => $kraken_data,
        kraken_db    => 't/data/kraken_test/',
        job_runner   => "Local"
    ),
    'QC report object created with no input gff files'
);

ok( $qc_report_obj->report, 'report generated' );
ok( -e 'kraken_report.csv', 'report file exists' );

compare_ok('kraken_report.csv',"t/data/exp_qc_report.csv", 'report file correct' );

unlink('kraken_report.csv');


ok(
    $qc_report_obj = Bio::Roary::QC::Report->new(
        input_files => [ 't/data/query_1.gff', 't/data/query_2.gff' ],
        outfile     => "kraken_report.csv",
        job_runner  => "Local",
        kraken_db   => 't/data/kraken_test/',
        verbose  => 0,
    ),
    'QC report object created with data'
);

is( $qc_report_obj->_tmp_directory . '/abc.fna', $qc_report_obj->_nuc_fasta_filename('abc.gff'), 'filename of nuc from gff' );
is(
    'sed -n \'/##FASTA/,//p\' abc.gff | grep -v \'##FASTA\' > ' . $qc_report_obj->_tmp_directory . '/abc.fna',
    $qc_report_obj->_extract_nuc_fasta_cmd('abc.gff'),
    'extract nuc command'
);

ok( my $nuc_files = $qc_report_obj->_extract_nuc_files_from_all_gffs(), 'extract nuc files from gffs' );

is_deeply( [ $qc_report_obj->_tmp_directory . '/query_1.fna', $qc_report_obj->_tmp_directory . '/query_2.fna' ],
    $nuc_files, 'check extracted nuc files from gffs list' );

compare_ok( $qc_report_obj->_tmp_directory . '/query_1.fna' ,
    't/data/expected_query_1.fna',
    'Check FASTA file 1 extracted as expected'
);
compare_ok( $qc_report_obj->_tmp_directory . '/query_2.fna' ,
    't/data/expected_query_2.fna',
    'Check FASTA file 2 extracted as expected'
);

SKIP:
{

    skip "kraken not installed",        2 unless ( which('kraken') );
    skip "kraken-report not installed", 2 unless ( which('kraken-report') );

    ok( my $kraken_files = $qc_report_obj->_run_kraken_on_nuc_files($nuc_files), 'run kraken over everything' );
    is_deeply( [ $qc_report_obj->_tmp_directory . '/query_1.kraken', $qc_report_obj->_tmp_directory . '/query_2.kraken' ],
        $kraken_files, 'check kraken files are created from nuc files' );
        
    ok(my $kraken_report_files = $qc_report_obj->_run_kraken_report_on_kraken_files( $kraken_files ), 'build reports');
    is_deeply( [ $qc_report_obj->_tmp_directory . '/query_1.kraken.report', $qc_report_obj->_tmp_directory . '/query_2.kraken.report' ],
        $kraken_report_files, 'check kraken report files are created from kraken files' );
        
    is_deeply([['query_1','Staphylococcus', 'Staphylococcus aureus'],['query_2','Staphylococcus', 'Staphylococcus aureus']],$qc_report_obj->_parse_kraken_reports($kraken_report_files),'check output report');
    
    
    ok( $qc_report_obj->report, 'report generated with real data' );
    ok( -e 'kraken_report.csv', 'report file exists with real data' );
    compare_ok('kraken_report.csv',"t/data/exp_qc_report_real.csv", 'report file correct' );
    unlink('kraken_report.csv');
    
}


done_testing();

