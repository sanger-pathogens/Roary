#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Slurp;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::PanGenome::ChunkFastaFile');
}

my $obj;


ok($obj = Bio::PanGenome::ChunkFastaFile->new(
  fasta_file   => 't/data/example_1.faa',
),'initalise object to produce a single sequence file');
is_deeply($obj->sequence_file_names, [$obj->_working_directory_name.'/0.seq'], 'a single sequence file is created' );
is(read_file('t/data/example_1.faa'), read_file($obj->_working_directory_name.'/0.seq'), 'input and output file should be the same');

ok($obj = Bio::PanGenome::ChunkFastaFile->new(
  fasta_file        => 't/data/example_1.faa',
  target_chunk_size => 1,
),'initalise object to produce one file per sequence');
is_deeply($obj->sequence_file_names, [
  $obj->_working_directory_name.'/0.seq',
$obj->_working_directory_name.'/1.seq',
$obj->_working_directory_name.'/2.seq',
$obj->_working_directory_name.'/3.seq',
$obj->_working_directory_name.'/4.seq',
$obj->_working_directory_name.'/5.seq',
], 
'a sequence file per sequence is created' );
is(read_file('t/data/expected_0.seq'), read_file($obj->_working_directory_name.'/0.seq'), 'the first sequence file is as expected');
is(read_file('t/data/expected_5.seq'), read_file($obj->_working_directory_name.'/5.seq'), 'the last sequence file is as expected');


done_testing();
