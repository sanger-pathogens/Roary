package Bio::PanGenome::External::Muscle;

# ABSTRACT: Wrapper around Muscle for sequence alignment

=head1 SYNOPSIS

Wrapper around Muscle for sequence alignment

   use Bio::PanGenome::External::Muscle;
   
   my $seg= Bio::PanGenome::External::Muscle->new(
     fasta_files => [],
   );
   
   $seg->run();

=method output_file

Returns the path to the results file

=cut

use Moose;
with 'Bio::PanGenome::JobRunner::Role';

has 'fasta_files'   => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'exec'          => ( is => 'ro', isa => 'Str',      default  => 'muscle' );
has 'output_suffix' => ( is => 'ro', isa => 'Str',      default  => '.aln' );

# Overload Role
has '_memory_required_in_mb' => ( is => 'ro', isa => 'Int', lazy => 1, builder => '_build__memory_required_in_mb' );
has '_queue' => ( is => 'rw', isa => 'Str', default => 'small' );

sub _build__memory_required_in_mb {
    my ($self)          = @_;
    my $memory_required = 4000;
    return $memory_required;
}

sub _command_to_run {
    my ( $self, $fasta_file, $output_file ) = @_;
    return
      join( " ", ( $self->exec, '-in', $fasta_file, '-out', $output_file, '-quiet', '-maxhours', 1, '> /dev/null 2>&1') );
}

sub run {
    my ($self) = @_;
    my @commands_to_run;

    for my $fasta_file ( @{ $self->fasta_files } ) {
        push( @commands_to_run, $self->_command_to_run( $fasta_file, $fasta_file.$self->output_suffix) );
    }

    my $job_runner_obj = $self->_job_runner_class->new(
        commands_to_run => \@commands_to_run,
        memory_in_mb    => $self->_memory_required_in_mb,
        queue           => $self->_queue,
        dont_wait       => $self->dont_wait,
        cpus            => $self->cpus 
    );
    $job_runner_obj->run();

    1;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
