package Bio::PanGenome::QC::Kraken;

# ABSTRACT: run kraken on list of inputs and parse output

=head1 SYNOPSIS

=cut

use Moose;
use Bio::PanGenome::JobRunner::LSF;
use File::Basename;
use Data::Dumper;
with 'Bio::PanGenome::JobRunner::Role';

has 'assembly_directory' => ( is => 'ro', isa => 'Str',      required => 1 );
has 'glob_search'        => ( is => 'ro', isa => 'Str',      default => '*.shred.fa' );
has 'kraken_exec'        => ( is => 'ro', isa => 'Str',      default => 'kraken' );
has 'kraken_report_exec' => ( is => 'ro', isa => 'Str',      default => 'kraken-report' );
has 'kraken_db'          => ( is => 'ro', isa => 'Str',      default => '/lustre/scratch108/pathogen/pathpipe/kraken/minikraken_20140330/' );
has 'top_hits'           => ( is => 'rw', isa => 'ArrayRef', lazy_build => 1 );
has 'kraken_memory'      => ( is => 'rw', isa => 'Int',      default => 2000 );

sub _build_top_hits {
	my $self = shift;

	my @top_hits;
	my $file_search = join( '/', ($self->assembly_directory, $self->glob_search) );
	foreach my $shred_ass ( glob $file_search ){
		push( @top_hits, $self->_top_kraken_hit( $shred_ass ) );
	}

	return \@top_hits;
}

sub _top_kraken_hit {
	my ( $self, $assembly ) = @_;

	my $kraken_output = $assembly;
	$kraken_output =~ s/fa$/kraken/;
	my $kraken_report = "$kraken_output.report";

	my $kraken_runner_obj = $self->_job_runner_class->new( 
		commands_to_run => [ $self->_kraken_cmd( $assembly, $kraken_output ) ], 
		memory_in_mb => $self->kraken_memory, 
		queue => $self->_queue
	);
    $kraken_runner_obj->run();

    my $kraken_report_runner_obj = $self->_job_runner_class->new( 
		commands_to_run => [ $self->_kraken_report_cmd( $kraken_output, $kraken_report ) ], 
		memory_in_mb => $self->kraken_memory, 
		queue => $self->_queue
	);
    $kraken_report_runner_obj->run();

	# parse report
	my ( $top_genus, $top_species ) = @{ $self->_parse_kraken_report($kraken_report) };

	my $assembly_id = basename( $assembly, '.shred.fa' );

	return [ $assembly_id, $top_genus, $top_species ];
}

sub _parse_kraken_report {
	my ( $self, $kraken_report ) = @_;

	# parse report
	open( REPORT, '<', $kraken_report );
	my ( $top_genus, $top_species );
	while ( <REPORT> ){
		my @parts = split( "\t" );
		chomp @parts;

		$top_genus = $parts[5] if ( (! defined $top_genus) && $parts[3] eq 'G' );
		$top_species = $parts[5] if ( (! defined $top_species) && $parts[3] eq 'S' );

		last if (defined $top_genus && defined $top_species);
	}

	$top_genus ||= "not_found";
	$top_genus =~ s/^\s+//g;
	$top_species ||= "not_found";
	$top_species =~ s/^\s+//g;

	return [ $top_genus, $top_species ];
}

sub _kraken_cmd {
	my ( $self, $a, $kraken_output ) = @_;

	my $kcmd = $self->kraken_exec . 
	" --db " . $self->kraken_db . 
	" --output $kraken_output $a";
	return $kcmd;
}

sub _kraken_report_cmd {
	my ( $self, $k, $report_output ) = @_;

	my $krcmd = $self->kraken_report_exec .
	" --db " . $self->kraken_db .
	" $k > $report_output";
	return $krcmd;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;