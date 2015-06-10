package Bio::Roary::SortFasta;

# ABSTRACT: sort a fasta file by name

=head1 SYNOPSIS

sort a fasta file by name
   use Bio::Roary::SortFasta;
   
   my $obj = Bio::Roary::SortFasta->new(
     input_filename   => 'infasta.fa',
   );
   $obj->sort_fasta->replace_input_with_output_file;

=cut

use Moose;
use File::Copy;
use Bio::SeqIO;

has 'input_filename'  => ( is => 'ro', isa => 'Str', required => 1 );
has 'output_filename' => ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build_output_filename' );
has 'make_multiple_of_three' => ( is => 'ro', isa => 'Bool', default => 0);

has '_input_seqio'  => ( is => 'ro', isa => 'Bio::SeqIO', lazy => 1, builder => '_build__input_seqio' );
has '_output_seqio' => ( is => 'ro', isa => 'Bio::SeqIO', lazy => 1, builder => '_build__output_seqio' );

sub _build_output_filename
{
  my ($self) = @_;
  return $self->input_filename.".sorted.fa";
}

sub _build__input_seqio {
    my ($self) = @_;
    return Bio::SeqIO->new( -file => $self->input_filename, -format => 'Fasta' );
}

sub _build__output_seqio {
    my ( $self) = @_;
    return Bio::SeqIO->new( -file => ">".$self->output_filename, -format => 'Fasta' );
}

sub sort_fasta {
    my ($self) = @_;
    
    my %input_sequences;
    while ( my $input_seq = $self->_input_seqio->next_seq() ) {
		
		if($self->make_multiple_of_three)
		{
			my $seq_length = $input_seq->length();
			if($seq_length % 3 == 1)
			{
				 $input_seq->seq($input_seq->seq()."NN");
			}
			elsif($seq_length % 3 == 2)
			{
				$input_seq->seq($input_seq->seq()."N");
			}
		}
       $input_sequences{$input_seq->display_id} = $input_seq;
    }
    
    for my $sequence_name(sort  keys %input_sequences)
    {
      $self->_output_seqio->write_seq($input_sequences{$sequence_name});
    }
    return $self;
}

sub replace_input_with_output_file
{
  my ($self) = @_;
  move($self->output_filename, $self->input_filename);
  return $self;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
