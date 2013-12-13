package Bio::PanGenome::Output::GroupsMultifastaProtein;

# ABSTRACT:  Take a multifasta nucleotide file and output it as proteins.

=head1 SYNOPSIS

Take a multifasta nucleotide file and output it as proteins.
   use Bio::PanGenome::Output::GroupsMultifastaProtein;
   
   my $obj = Bio::PanGenome::Output::GroupsMultifastaProtein->new(
       nucleotide_fasta_file => 'example.fa'
     );
   $obj->convert_nucleotide_to_protein();

=cut

use Moose;
use Bio::SeqIO;
use File::Path qw(make_path);
use File::Basename;
use Bio::PanGenome::Exceptions;
use Bio::PanGenome::AnalyseGroups;

has 'nucleotide_fasta_file' => ( is => 'ro', isa => 'Str',  required => 1 );
has 'output_filename'       => ( is => 'ro', isa => 'Str',  lazy     => 1, builder => '_build_output_filename' );
has '_suffix'               => ( is => 'ro', isa => 'Str',  default  => '.faa' );

sub _build_output_filename
{
  my ($self) = @_;
  my ( $filename, $directories, $suffix ) = fileparse($self->nucleotide_fasta_file, qr/\.[^.]*/);
  
  return join('',($directories, $filename.$self->_suffix));
}

sub _fastatranslate_filename
{
  my ($self) = @_;
  return $self->output_filename.".intermediate";
}

sub _fastatranslate_cmd
{
  my ($self) = @_;
  return 'fastatranslate --geneticcode 11  -f '. $self->nucleotide_fasta_file.' > '.$self->_fastatranslate_filename;
}

sub convert_nucleotide_to_protein
{
  my ($self) = @_;
  system($self->_fastatranslate_cmd());
  my $cmd = 'fasta_grep -f '.$self->_fastatranslate_filename.' | sed \'s/*//\' > '.$self->output_filename;
  system($cmd);
  unlink($self->_fastatranslate_filename);
  1;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

