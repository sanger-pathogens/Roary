package Bio::PanGenome::CombinedProteome;

# ABSTRACT: Take in multiple FASTA sequences containing proteomes and concat them together and output a FASTA file, filtering out more than 5% X's

=head1 SYNOPSIS

Take in multiple FASTA sequences containing proteomes and concat them together and output a FASTA file, filtering out more than 5% X's
   use Bio::PanGenome::CombinedProteome;
   
   my $obj = Bio::PanGenome::CombinedProteome->new(
     proteome_files   => ['abc.fa','efg.fa'],
     output_filename   => 'example_output.fa',
     maximum_percentage_of_unknowns => 5.0,
   );
   $obj->create_combined_proteome_file;

=cut

use Moose;
use Bio::SeqIO;
use Bio::PanGenome::Exceptions;

has 'proteome_files'                 => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'output_filename'                => ( is => 'ro', isa => 'Str',      default  => 'combined_output.fa' );
has 'maximum_percentage_of_unknowns' => ( is => 'ro', isa => 'Num',      default  => 5 );

has 'number_of_sequences_ignored'    => ( is => 'rw', isa => 'Int',      default  => 0 );
has 'number_of_sequences_seen'       => ( is => 'rw', isa => 'Int',      default  => 0 );

sub BUILD {
    my ($self) = @_;

    for my $filename ( @{ $self->proteome_files } ) {
        Bio::PanGenome::Exceptions::FileNotFound->throw( error => 'Cant open file: ' . $filename )
          unless ( -e $filename );
    }
}


sub _does_sequence_contain_too_many_unknowns
{
  my ($self, $sequence_obj) = @_;
  my $maximum_number_of_Xs = int(($sequence_obj->length()*$self->maximum_percentage_of_unknowns)/100);
  my $number_of_Xs_found = () = $sequence_obj->seq() =~ /X/g;
  if($number_of_Xs_found  > $maximum_number_of_Xs)
  {
    return 1;
  }
  else
  {
    return 0;
  }
}


sub _add_sequences_from_file
{
  my ($self, $filename, $out_fasta_obj) = @_;
  
  my $fasta_obj =  Bio::SeqIO->new( -file => $filename , -format => 'Fasta');
  while(my $seq = $fasta_obj->next_seq())
  {
    $self->number_of_sequences_seen($self->number_of_sequences_seen() + 1);
    if($self->_does_sequence_contain_too_many_unknowns($seq))
    {
      $self->number_of_sequences_ignored($self->number_of_sequences_ignored + 1);
      next; 
    }
    $seq->description(undef);
    $out_fasta_obj->write_seq($seq);
  }
  return 1;
}


sub create_combined_proteome_file {
    my ($self) = @_;
    
    my $out_fasta_obj = Bio::SeqIO->new(-file => "+>".$self->output_filename , -format => 'Fasta');
    for my $filename (@{$self->proteome_files })
    {
      $self->_add_sequences_from_file($filename, $out_fasta_obj);
    }

    1;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
