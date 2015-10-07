package Bio::Roary::External::Fasttree;

# ABSTRACT: Wrapper to run Fasttree

=head1 SYNOPSIS

Wrapper to run cd-hit
   use Bio::Roary::External::Fasttree;
   
   my $obj = Bio::Roary::External::Fasttree->new(
     input_file   => 'abc.fa',
     exec         => 'Fasttree',
     output_base  => 'efg',
   );
  $obj->run;

=cut

use Moose;
with 'Bio::Roary::JobRunner::Role';

has 'input_file'                   => ( is => 'ro', isa => 'Str', required => 1 );
has 'output_file'                  => ( is => 'ro', isa => 'Str', lazy     => 1,  builder => '_build_output_file' );
has 'exec'                         => ( is => 'ro', isa => 'Str', default  => 'FastTree' );
has 'alt_exec'                     => ( is => 'ro', isa => 'Str', default  => 'fasttree' );
has '_logging'                     => ( is => 'ro', isa => 'Str', default  => '2> /dev/null' );

sub _build_output_file
{
    my ($self) = @_;
	return $self->input_file.".newick";
}

sub _command_to_run {
    my ($self) = @_;

	my $executable = $self->_find_exe([$self->exec, $self->alt_exec]);
    my $logging_str = "";
	$logging_str = $self->_logging if(! $self->verbose);

    return join(
        ' ', ($executable, '-fastest', '-nt', $self->input_file, '>', $self->output_file, $logging_str)
    );
}

sub run {
    my ($self) = @_;
    my @commands_to_run;

	if(!defined($self->input_file) || ! ( -e $self->input_file))
	{
		$self->logger->error( "The input file is missing so not creating a tree" );
		return 1;
	}

	if(-s $self->input_file < 5)
	{
		$self->logger->info( "The input file is too small so not creating a tree" );
		return 1;
	}

    push(@commands_to_run, $self->_command_to_run() );
    $self->logger->info( "Running command: " . $self->_command_to_run() );
    my $job_runner_obj = $self->_job_runner_class->new( commands_to_run => \@commands_to_run, memory_in_mb => $self->memory_in_mb, queue => $self->_queue, cpus => $self->cpus );
    $job_runner_obj->run();
    
    1;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
