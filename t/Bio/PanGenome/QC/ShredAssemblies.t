#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Slurp;
use File::Temp;
use Cwd;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::PanGenome::QC::ShredAssemblies');
}

my $temp_directory_obj = File::Temp->newdir(DIR => getcwd, CLEANUP => 1 );
my $tmp = $temp_directory_obj->dirname();

my $shred_obj;
ok(
	$shred_obj = Bio::PanGenome::QC::ShredAssemblies->new(
		gff_files   => ['t/data/shred1.gff', 't/data/shred2.gff'],
		read_size        => 10,
		output_directory => $tmp,
		job_runner       => "Local"
	),
	'shredding object created'
);
ok( $shred_obj->shred, 'data shredded' );
ok( -e "$tmp/shred1.shred.fa", 'output file exists' );
ok( -e "$tmp/shred2.shred.fa", 'output file exists' );

is(
	read_file('t/data/shred1.shred.fa'),
	read_file("$tmp/shred1.shred.fa"),
	'shredded file correct'
);
is(
	read_file('t/data/shred2.shred.fa'),
	read_file("$tmp/shred2.shred.fa"),
	'shredded file correct'
);

my $exp = [ "AAAAA", "TTTTT", "CCCCC", "GGGGG" ];
ok(
	$shred_obj = Bio::PanGenome::QC::ShredAssemblies->new(
		gff_files   => ['t/data/shred1.fa', 't/data/shred2.fa'],
		read_size        => 5,
		output_directory => $tmp,
		job_runner       => "Local"
	),
	'shredding object created'
);
my $got = $shred_obj->_shredded_seq("AAAAATTTTTCCCCCGGGGG ");
is_deeply $got, $exp, 'shredding correct';

done_testing();