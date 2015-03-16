package Bio::Roary::Output::GroupsMultifastaProtein;

# ABSTRACT:  Take a multifasta nucleotide file and output it as proteins.

=head1 SYNOPSIS

Take a multifasta nucleotide file and output it as proteins.
   use Bio::Roary::Output::GroupsMultifastaProtein;

   my $obj = Bio::Roary::Output::GroupsMultifastaProtein->new(
       nucleotide_fasta_file => 'example.fa'
     );
   $obj->convert_nucleotide_to_protein();

=cut

use Moose;
use Bio::SeqIO;
use File::Path qw(make_path);
use File::Basename;
use Bio::Roary::Exceptions;
use Bio::Roary::AnalyseGroups;

has 'nucleotide_fasta_file' => ( is => 'ro', isa => 'Str',  required => 1 );
has 'output_filename'       => ( is => 'ro', isa => 'Str',  lazy     => 1, builder => '_build_output_filename' );
has '_suffix'               => ( is => 'ro', isa => 'Str',  default  => '.faa' );
has 'translation_table'  => ( is => 'rw', isa => 'Int',      default => 11 );

sub _build_output_filename
{
  my ($self) = @_;
  my ( $filename, $directories, $suffix ) = fileparse($self->nucleotide_fasta_file, qr/\.[^.]*/);

  return join('',($directories, $filename.$self->_suffix));
}

# Read all the sequences for a gene into memory to sort them - very small files so shouldnt be a problem
sub _fastatranslate
{
  my ($self) = @_;
  my $input_fasta_file_obj    = Bio::SeqIO->new(-file => $self->nucleotide_fasta_file, -format => 'Fasta' );
  my $output_protein_file_obj = Bio::SeqIO->new(-file =>">".$self->output_filename,    -format => 'Fasta', -alphabet => 'protein' );

  my %protein_sequence_objs;
  while (my $seq = $input_fasta_file_obj->next_seq){
    $protein_sequence_objs{$seq->display_id} = $seq->translate(-codontable_id => $self->translation_table );
  }

  for my $sequence_name ( sort keys %protein_sequence_objs)
  {
    $output_protein_file_obj->write_seq($protein_sequence_objs{$sequence_name});
  }

  return 1;
}

sub convert_nucleotide_to_protein
{
  my ($self) = @_;
  $self->_fastatranslate();
  1;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

