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

has 'input_file'                   => ( is => 'ro', isa => 'Str',  required => 1 );
has 'output_base'                  => ( is => 'ro', isa => 'Str',  default  => 'output' );
has 'exec'                         => ( is => 'ro', isa => 'Str',  default  => 'cd-hit' );
has '_number_of_threads'           => ( is => 'ro', isa => 'Int',  default  => 1 );
has '_max_available_memory_in_mb'  => ( is => 'ro', isa => 'Int',  default  => 1000 );
has '_use_most_similar_clustering' => ( is => 'ro', isa => 'Bool', default  => 1 );
has '_length_difference_cutoff'    => ( is => 'ro', isa => 'Num',  default  => 0.99 );
has '_sequence_identity_threshold' => ( is => 'ro', isa => 'Num',  default  => 0.99 );
has '_logging'          => ( is => 'ro', isa => 'Str', default  => '2> /dev/null' );

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
    system( $self->_command_to_run );
    # cleanup output files
    1;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
