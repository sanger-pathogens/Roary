package Bio::Roary::SequenceLengths;

# ABSTRACT:  Take in a fasta file and create a hash with the length of each sequence

=head1 SYNOPSIS

Add labels to the groups
   use Bio::Roary::SequenceLengths;
   
   my $obj = Bio::Roary::SequenceLengths->new(
     fasta_file   => 'abc.fa',
   );
   $obj->sequence_lengths;

=cut

use Moose;
use Bio::SeqIO;
use Bio::Roary::Exceptions;

has 'fasta_file'       => ( is => 'ro', isa => 'Str',        required => 1 );
has 'sequence_lengths' => ( is => 'ro', isa => 'HashRef',    lazy     => 1, builder => '_build_sequence_lengths' );
has '_input_seqio'     => ( is => 'ro', isa => 'Bio::SeqIO', lazy     => 1, builder => '_build__input_seqio' );

sub _build__input_seqio {
    my ($self) = @_;
    return Bio::SeqIO->new( -file => $self->fasta_file, -format => 'Fasta' );
}

sub _build_sequence_lengths {
    my ($self) = @_;

    my %sequence_lengths;
    while ( my $input_seq = $self->_input_seqio->next_seq() ) {
        $sequence_lengths{ $input_seq->display_id } = $input_seq->length();
    }
    return \%sequence_lengths;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
