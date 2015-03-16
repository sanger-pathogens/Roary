package Bio::Roary::FilterUnknownsFromFasta;

# ABSTRACT: Take in fasta files, remove sequences with too many unknowns and return a list of the new files

=head1 SYNOPSIS

Take in fasta files, remove sequences with too many unknowns and return a list of the new files
   use Bio::Roary::FilterUnknownsFromFasta;
   
   my $obj = Bio::Roary::FilterUnknownsFromFasta->new(
       fasta_files        => [],
     );
   $obj->filtered_fasta_files();

=cut

use Moose;
use Bio::SeqIO;
use Cwd;
use Bio::Roary::Exceptions;
use File::Basename;

has 'fasta_files'                    => ( is => 'ro', isa => 'ArrayRef',  required => 1 );
has 'apply_unknowns_filter'          => ( is => 'rw', isa => 'Bool', default => 1 );
has 'maximum_percentage_of_unknowns' => ( is => 'ro', isa => 'Num',  default  => 5 );

has 'filtered_fasta_files' => ( is => 'ro', isa => 'ArrayRef', lazy => 1, builder => '_build_filtered_fasta_files' );

has 'input_fasta_to_output_fasta' => ( is => 'ro', isa => 'HashRef', default => sub {{}} );

sub _build_filtered_fasta_files
{
  my ($self) = @_;
  
  my @output_file_names;
  for my $fasta_file (@{$self->fasta_files})
  {
    my ( $filename, $directories, $suffix ) = fileparse($fasta_file);
    push(@output_file_names, $self->_filter_fasta_sequences_and_return_new_file($filename,$fasta_file ));
  }
  return \@output_file_names;
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


sub _filter_fasta_sequences_and_return_new_file
{
  my ($self, $output_file, $input_file) = @_;
  my $output_filename = $output_file.'.tmp.filtered.fa';
  my $out_fasta_obj = Bio::SeqIO->new( -file => ">".$output_filename, -format => 'Fasta');
  my $fasta_obj     = Bio::SeqIO->new( -file => $input_file, -format => 'Fasta');
  
  $self->input_fasta_to_output_fasta->{$input_file} = $output_filename;

  while(my $seq = $fasta_obj->next_seq())
  {
    if($self->_does_sequence_contain_too_many_unknowns($seq))
    {
      next; 
    }
    # strip out extra details put in by fastatranslate
    $seq->description(undef);
    $out_fasta_obj->write_seq($seq);
  }
  return $output_filename;
}



no Moose;
__PACKAGE__->meta->make_immutable;

1;

