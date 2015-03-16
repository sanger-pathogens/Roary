package Bio::Roary::QC::Report;

# ABSTRACT: generate a report based on kraken output

=head1 SYNOPSIS

=cut

use Moose;
use File::Temp;
use File::Path 'rmtree';
use Cwd;
use Bio::Roary::QC::ShredAssemblies;
use Bio::Roary::QC::Kraken;

has 'input_files'      => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'kraken_exec'      => ( is => 'ro', isa => 'Str',      default => 'kraken' );
has 'kraken_db'        => ( is => 'ro', isa => 'Str',      default => '' );
has 'outfile'          => ( is => 'rw', isa => 'Str',      default => 'qc_report.csv' );
has '_kraken_data'     => ( is => 'rw', isa => 'ArrayRef', lazy_build => 1 );
has '_header'          => ( is => 'rw', isa => 'Str',      lazy_build => 1 );
has 'job_runner'       => ( is => 'rw', isa => 'Str',      default => 'LSF' );

has '_tmp_directory_obj' => ( is => 'rw', lazy_build => 1 );
has '_tmp_directory'   =>   ( is => 'rw', lazy_build => 1, isa => 'Str', );

sub _build__kraken_data {
	my $self = shift;

	my $shredder = Bio::Roary::QC::ShredAssemblies->new(
		gff_files        => $self->input_files,
		output_directory => $self->_tmp_directory,
		job_runner       => $self->job_runner
	);
	$shredder->shred or die ( "Failed to shred assembly data\n" );

	my $kraken = Bio::Roary::QC::Kraken->new(
		assembly_directory => $self->_tmp_directory,
		job_runner         => $self->job_runner
	);
	return $kraken->top_hits;
}

sub _build__header {
	return join( ',', ( 'Sample', 'Genus', 'Species' ) );
}

sub _build__tmp_directory_obj {
	return File::Temp->newdir(DIR => getcwd, CLEANUP => 1 ); 
}

sub _build__tmp_directory {
	my $self = shift;
	return $self->_tmp_directory_obj->dirname();
}

sub report {
	my $self = shift;

	open( OUTFILE, '>', $self->outfile );
	print OUTFILE $self->_header . "\n";
	for my $line ( @{ $self->_kraken_data } ){
		print OUTFILE join( ',', @{ $line } ) . "\n";
	}
	close OUTFILE;
}


__PACKAGE__->meta->make_immutable;
no Moose;
1;
