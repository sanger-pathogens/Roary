package Bio::Roary::External::Mafft;

# ABSTRACT: Wrapper to run mafft

=head1 SYNOPSIS

Wrapper to run mafft
   use Bio::Roary::External::Mafft;
   
	my $mafft_obj = Bio::Roary::External::Mafft->new(
	  input_filename  => $fasta_file,
	  output_filename => $fasta_file.'.aln',
	  job_runner      => 'Local'
	);
	$mafft_obj->run();
=cut

use Moose;
use File::Spec;
with 'Bio::Roary::JobRunner::Role';

has 'input_filename'  => ( is => 'ro', isa => 'Str', required => 1 );
has 'output_filename' => ( is => 'ro', isa => 'Str', default  => 'output' );
has 'exec'            => ( is => 'ro', isa => 'Str', default  => 'mafft' );

# Overload Role
has 'memory_in_mb' => ( is => 'ro', isa => 'Int', lazy => 1, builder => '_build_memory_in_mb' );

sub _build_memory_in_mb {
    my ($self) = @_;
    my $memory_required = 2000;
    return $memory_required;
}

sub _command_to_run {
    my ($self) = @_;

    if(! -e $self->input_filename)
	{
		$self->logger->error( "Input file to MAFFT missing: " . $self->input_filename );
	}
    return join(
        ' ',
        (
            $self->exec,
			'--auto',
			'--quiet',
            $self->input_filename,
			'>',
            $self->output_filename
        )
    );
}

sub run {
    my ($self) = @_;
    my @commands_to_run;

    push( @commands_to_run, $self->_command_to_run() );
    $self->logger->info( "Running command: " . $self->_command_to_run() );

    my $job_runner_obj = $self->_job_runner_class->new(
        commands_to_run => \@commands_to_run,
        memory_in_mb    => $self->memory_in_mb,
        queue           => $self->_queue,
        cpus            => $self->cpus
    );
    $job_runner_obj->run();

    1;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
