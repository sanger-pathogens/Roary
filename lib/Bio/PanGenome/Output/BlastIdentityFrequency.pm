package Bio::Roary::Output::BlastIdentityFrequency;

# ABSTRACT:  Take in blast results and find the percentage identity graph

=head1 SYNOPSIS

Take in blast results and find the percentage identity graph
   use Bio::Roary::Output::BlastIdentityFrequency;
   
   my $obj = Bio::Roary::Output::BlastIdentityFrequency->new(
       input_filename      => '_blast_results',
       output_filename  => 'blast_identity_frequency.Rtab',
     );
   $obj->create_file();

=cut

use Moose;
use Bio::SeqIO;
use Bio::Roary::Exceptions;

has 'input_filename'        => ( is => 'ro', isa => 'Str', default => '_blast_results' );
has 'output_filename'       => ( is => 'ro', isa => 'Str', default => 'blast_identity_frequency.Rtab' );

has '_output_fh'            => ( is => 'ro', lazy => 1, builder => '_build__output_fh' );
has '_input_fh'             => ( is => 'ro', lazy => 1, builder => '_build__input_fh' );

sub _build__output_fh
{
  my ($self) = @_;
  open( my $fh, '>', $self->output_filename )
    or Bio::Roary::Exceptions::CouldntWriteToFile->throw(
      error => "Couldnt write output file:" . $self->output_filename );
  return $fh;
}

sub _build__input_fh
{
  my ($self) = @_;
  my $input_string  = 'awk \'{print $3}\' '.$self->input_filename.'  | awk \'BEGIN {FS="."}; {print $1}\'| sort | uniq -c | awk \'{print $2"\t"$1}\'';
  
  open( my $fh, '-|', $input_string ) or die "Couldnt open results file";
  return $fh;
}

sub create_file
{
  my ($self) = @_;
  
  my $input_fh = $self->_input_fh;
  while(<$input_fh>)
  {
    print {$self->_output_fh} $_;
  }
  close($self->_input_fh);
  close($self->_output_fh);
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
