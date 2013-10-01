package Bio::PanGenome::External::Cdhit;

# ABSTRACT: Wrapper to run cd-hit

=head1 SYNOPSIS

Wrapper to run cd-hit
   use Bio::PanGenome::External::Cdhit;
   
   my $obj = Bio::PanGenome::External::Cdhit->new(
     input_file   => 'abc.fa',
     exec         => 'cd-hit',
     output_base  => 'efg',
   );
  $obj->run;

=cut

use Moose;
with 'Bio::PanGenome::JobRunner::Role';

has 'input_file'                   => ( is => 'ro', isa => 'Str',  required => 1 );
has 'output_base'                  => ( is => 'ro', isa => 'Str',  default  => 'output' );
has 'exec'                         => ( is => 'ro', isa => 'Str',  default  => 'cd-hit' );
has '_number_of_threads'           => ( is => 'ro', isa => 'Int',  default  => 1 );
has '_max_available_memory_in_mb'  => ( is => 'ro', isa => 'Int',  lazy => 1, builder => '_build__max_available_memory_in_mb' );
has '_use_most_similar_clustering' => ( is => 'ro', isa => 'Bool', default  => 1 );
has '_length_difference_cutoff'    => ( is => 'ro', isa => 'Num',  default  => 1 );
has '_sequence_identity_threshold' => ( is => 'ro', isa => 'Num',  default  => 1 );
has '_logging'          => ( is => 'ro', isa => 'Str', default  => '2> /dev/null' );

# Overload Role
has '_memory_required_in_mb'  => ( is => 'ro', isa => 'Int',  lazy => 1, builder => '_build__memory_required_in_mb' );

sub _build__memory_required_in_mb
{
  my ($self) = @_;
  my $filename = $self->input_file;
  my $memory_required = 1000;
  if(-e $filename)
  {
    $memory_required = -s $filename;
    # Convert to mb
    $memory_required = int($memory_required/1000000);
    # Triple memory for worst case senario
    $memory_required *= 5;
    $memory_required = 1000 if($memory_required < 1000);
  }

  return $memory_required;
}

sub _build__max_available_memory_in_mb
{
  my ($self) = @_;
  my $memory_to_cdhit = int($self->_memory_required_in_mb *0.9);
  return $memory_to_cdhit;
}

sub clusters_filename
{
  my ($self) = @_;
  return join('.',($self->output_base,'clstr'));
}

sub _command_to_run {
    my ($self) = @_;
    return join(
        ' ',
        (
            $self->exec,                        '-i', $self->input_file,                   '-o',
            $self->output_base,                 '-T', $self->_number_of_threads,           '-M',
            $self->_max_available_memory_in_mb, '-g', $self->_use_most_similar_clustering, '-s',
            $self->_length_difference_cutoff,   '-c', $self->_sequence_identity_threshold, 
            $self->_logging
        )
    );
}

sub run {
    my ($self) = @_;
    my @commands_to_run;
    push(@commands_to_run, $self->_command_to_run );
    
    my $job_runner_obj = $self->_job_runner_class->new( commands_to_run => \@commands_to_run, memory_in_mb => $self->_memory_required_in_mb, queue => $self->_queue );
    $job_runner_obj->run();
    
    1;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
