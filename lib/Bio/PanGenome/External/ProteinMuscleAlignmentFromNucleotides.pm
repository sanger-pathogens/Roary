package Bio::PanGenome::External::ProteinMuscleAlignmentFromNucleotides;

# ABSTRACT: Take in a multifasta file of nucleotides, convert to proteins and align with muscle

=head1 SYNOPSIS

Take in a multifasta file of nucleotides, convert to proteins and align with muscle

   use Bio::PanGenome::External::ProteinMuscleAlignmentFromNucleotides;
   
   my $seg = Bio::PanGenome::External::ProteinMuscleAlignmentFromNucleotides->new(
     fasta_files => [],
   );
   
   $seg->run();

=method output_file

Returns the path to the results file

=cut

use Moose;
with 'Bio::PanGenome::JobRunner::Role';

has 'fasta_files'   => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'exec'          => ( is => 'ro', isa => 'Str',      default  => 'protein_muscle_alignment_from_nucleotides' );

# Overload Role
has '_memory_required_in_mb' => ( is => 'ro', isa => 'Int', lazy     => 1, builder => '_build__memory_required_in_mb' );
has '_queue'                 => ( is => 'rw', isa => 'Str', default  => 'normal' );
has '_files_per_chunk'       => ( is => 'ro', isa => 'Int', default  => 25 );

sub _build__memory_required_in_mb {
    my ($self)          = @_;
    my $memory_required = 1000;
    return $memory_required;
}

sub _command_to_run {
    my ( $self, $fasta_files, ) = @_;
    return $self->exec. " ". join( " ", @{$fasta_files}  );
}

sub run {
    my ($self) = @_;
    my @commands_to_run;

    my @files_chunk;
    for my $fasta_file ( @{ $self->fasta_files } ) {
        push(@files_chunk,$fasta_file);
        if(@files_chunk == $self->_files_per_chunk )
        {
          push(@commands_to_run, $self->_command_to_run(\@files_chunk));
          @files_chunk = ();
        }
    }
    
    if(@files_chunk > 0)
    {
      push(@commands_to_run, $self->_command_to_run(\@files_chunk));
    }

    my $job_runner_obj = $self->_job_runner_class->new(
        commands_to_run => \@commands_to_run,
        memory_in_mb    => $self->_memory_required_in_mb,
        queue           => $self->_queue,
        dont_wait       => $self->dont_wait,
    );
    $job_runner_obj->run();
    
    $job_runner_obj->submit_dependancy_job('pan_genome_core_alignment');
    1;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
