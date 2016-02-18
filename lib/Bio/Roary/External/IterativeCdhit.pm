package Bio::Roary::External::IterativeCdhit;

# ABSTRACT: Iteratively run CDhit

=head1 SYNOPSIS

Iteratively run CDhit

   use Bio::Roary::External::IterativeCdhit;
   
   my $seg= Bio::Roary::External::IterativeCdhit->new(
     output_cd_hit_filename => '',
     output_combined_filename  => '',
     number_of_input_files => 10, 
     output_filtered_clustered_fasta  => '',
   );
   
   $seg->run();

=cut

use Moose;
with 'Bio::Roary::JobRunner::Role';

has 'output_cd_hit_filename'          => ( is => 'ro', isa => 'Str', required => 1 );
has 'output_combined_filename'        => ( is => 'ro', isa => 'Str', required => 1 );
has 'number_of_input_files'           => ( is => 'ro', isa => 'Int', required => 1 );
has 'output_filtered_clustered_fasta' => ( is => 'ro', isa => 'Str', required => 1 );
has 'exec'                            => ( is => 'ro', isa => 'Str', default  => 'iterative_cdhit' );
has '_max_cpus'                       => ( is => 'ro', isa => 'Int',  default  => 40 );
# Overload Role
has 'memory_in_mb' => ( is => 'ro', isa => 'Int', lazy => 1, builder => '_build_memory_in_mb' );

sub _build_memory_in_mb {
    my ($self)          = @_;
    my $filename        = $self->output_combined_filename;
    my $memory_required = 2000;
    if ( -e $filename ) {
        $memory_required = -s $filename;

        # Convert to mb
        $memory_required = int( $memory_required / 1000000 );

        # Pentuple memory for worst case senario
        $memory_required *= 5;
        $memory_required = 2000 if ( $memory_required < 2000 );
    }

    return $memory_required;
}

sub _build__max_available_memory_in_mb {
    my ($self) = @_;
    my $memory_to_cdhit = int( $self->memory_in_mb * 0.9 );
    return $memory_to_cdhit;
}

sub _command_to_run {
    my ($self) = @_;
	my $cpus = ($self->cpus > $self->_max_cpus) ? $self->_max_cpus :  $self->cpus;
	
    return join(
        ' ',
        (
            $self->exec,                     '-c', $self->output_cd_hit_filename, '-m',
            $self->output_combined_filename, '-n', $self->number_of_input_files, '--cpus', $cpus, '-f',
            $self->output_filtered_clustered_fasta
        )
    );
}

sub run {
    my ($self) = @_;
    my @commands_to_run;
    push( @commands_to_run, $self->_command_to_run );
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
